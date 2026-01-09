{
  lib,
  config,
  pkgs,
  ...
}: {
  options.homebrew = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
    };

    brewInstall = lib.mkOption {
      description = "Install homebrew if it not present";
      type = lib.types.bool;
      default = true;
    };

    brewPath = lib.mkOption {
      description = "The bath of the brew binary";
      default =
        if pkgs.stdenv.targetPlatform.isDarwin
        then "/opt/homebrew/bin/brew"
        else "/home/linuxbrew/.linuxbrew/bin/brew";
      type = lib.types.path;
    };

    taps = lib.mkOption {
      description = "Homebrew Taps to add";
      default = [];
      type = lib.types.listOf (lib.types.submodule {
        options = {
          name = lib.mkOption {
            type = lib.types.str;
            description = "Name of the TAP";
          };
          repo = lib.mkOption {
            type = lib.types.str;
            description = "Repository source";
          };
        };
      });
    };

    casks = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      description = "Homebrew casks to install";
      default = [];
    };

    formulae = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      description = "Homebrew formulae / packages to install";
      default = [];
    };

    mas = lib.mkOption {
      description = "Mac App Store apps to install with ID";
      default = [];
      type = lib.types.listOf (lib.types.submodule {
        options = {
          name = lib.mkOption {
            type = lib.types.str;
            description = "Name of the app";
          };
          id = lib.mkOption {
            type = lib.types.int;
            description = "App ID";
          };
        };
      });
    };

    ignoreMasChanges = lib.mkOption {
      description = ''
        If set to true it will not include Mac App Store changes when comparing
        the Brewbundles. This prevents constantly running `brew install` command
        on activation if apps are manually installed from the Mac App Store
      '';
      type = lib.types.bool;
      default = true;
    };

    cleanup = lib.mkOption {
      description = ''
        if set to true, it will delete  applications installed manually and
        not specified in the flake config. It uses `brew bundle cleanup`.
        By default is set to true to stick to reproducible environments
        principles of nix.
      '';
      type = lib.types.bool;
      default = true;
    };

    update = lib.mkOption {
      description = ''
        If set to true it will run a brew update in the activation script
        (when running home-manager switch)
      '';
      type = lib.types.bool;
      default = true;
    };

    upgrade = lib.mkOption {
      description = ''
        If set to true it will run a `brew upgrade --greedy` in the activation
        script (when running home-manager switch). If you want to keep a
        specific version, uses `brew pin` command.
      '';
      type = lib.types.bool;
      default = true;
    };

    enableShellIntegration = lib.mkOption {
      description = ''
        Whether to globally enable shell integration for bash, zsh or fish shells.
      '';
      type = lib.types.bool;
      default = true;
    };
  };

  config = let
    tapsStr = lib.concatStringsSep "\n" (lib.lists.naturalSort (lib.lists.naturalSort (
      map (item: ''tap "${item.name}", "${item.repo}"'') config.homebrew.taps
    )));
    masStr = lib.concatStringsSep "\n" (lib.lists.naturalSort (lib.lists.naturalSort (
      map (item: ''mas "${item.name}", id: ${toString item.id}'') config.homebrew.mas
    )));
    formulaeStr = lib.concatStringsSep "\n" (lib.lists.naturalSort (lib.lists.naturalSort (
      map (item: ''brew "${item}"'') (["mas"] ++ config.homebrew.formulae)
    )));
    casksStr = lib.concatStringsSep "\n" (lib.lists.naturalSort (lib.lists.naturalSort (
      map (item: ''cask "${item}"'') config.homebrew.casks
    )));

    brewFile = pkgs.writeText "Brewfile" (builtins.concatStringsSep "\n" (
      lib.strings.filter (str: str != "") (
        pkgs.lib.concatLists [
          [tapsStr formulaeStr]
          (
            if pkgs.stdenv.isDarwin
            then [casksStr masStr]
            else []
          )
        ]
      )
    ));

    bundleCheckFilter =
      if config.homebrew.ignoreMasChanges
      then ''| grep -v "mas"''
      else "";
  in
    lib.mkIf config.homebrew.enable {
      home.sessionVariables = {
        HOMEBREW_BUNDLE_FILE = brewFile;
      };

      programs.bash.initExtra = lib.mkIf config.homebrew.enableShellIntegration (lib.mkOrder 1450 ''
        # Load Homebrew
        if [ -f "${config.homebrew.brewPath}" ]; then
          eval "$(${config.homebrew.brewPath} shellenv)"
        fi
      '');

      programs.zsh.initContent = lib.mkIf config.homebrew.enableShellIntegration (lib.mkOrder 1450 ''
        # Load Homebrew
        if [ -f "${config.homebrew.brewPath}" ]; then
          eval "$(${config.homebrew.brewPath} shellenv)"
        fi
      '');

      programs.fish.shellInit = lib.mkIf config.homebrew.enableShellIntegration (lib.mkOrder 1450 ''
        set -l hashomebrew false
        # Load Homebrew
        if test -e "${config.homebrew.brewPath}"
          set -l hashomebrew true
        end

        if $hashomebrew
          # Homebrew Autocomplete
          if test -d "$(${config.homebrew.brewPath} --prefix)/share/fish/completions"
            set -p fish_complete_path "$(${config.homebrew.brewPath} --prefix)/share/fish/completions"
          end

          if test -d "$(${config.homebrew.brewPath} --prefix)/share/fish/vendor_completions.d"
            set -p fish_complete_path "$(${config.homebrew.brewPath} --prefix)/share/fish/vendor_completions.d"
          end
        end
      '');

      home.activation.homebrewInstall = lib.hm.dag.entryAfter ["installPackages" "linkGeneration"] (
        if config.homebrew.brewInstall
        then ''
          if [ ! -f "${config.homebrew.brewPath}" ]; then
            echo "Homebrew not found (${config.homebrew.brewPath}), installing..."
            /bin/bash -c "$(${pkgs.curl}/bin/curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
          fi
        ''
        else ""
      );

      # Run a brew update before installing packages from the bundle
      home.activation.homebrewUpdate = lib.mkIf config.homebrew.update (
        lib.hm.dag.entryAfter ["installPackages" "homebrewInstall"] ''
          if [ -f "${config.homebrew.brewPath}" ]; then
            "${config.homebrew.brewPath}" update
          fi
        ''
      );

      # Remove packages that are not present in the brew bundle
      home.activation.homebrewBundleCleanup = lib.mkIf config.homebrew.cleanup (
        lib.hm.dag.entryAfter ["homebrewInstall"] ''
          if [ -f "${config.homebrew.brewPath}" ]; then
            "${config.homebrew.brewPath}" bundle cleanup --file "${brewFile}" --force
          fi
        ''
      );

      # Install packages from the brew bundle file generated
      home.activation.homebrewBundleInstall = lib.hm.dag.entryAfter ["homebrewInstall" "homebrewUpdate"] ''
        if [ -f "${config.homebrew.brewPath}" ]; then
            # Checks for changes in Bundlefile
            oldHash=$("${config.homebrew.brewPath}" bundle dump --file=- ${bundleCheckFilter} | ${pkgs.openssl}/bin/openssl sha512 )
            newHash=$(cat ${brewFile} ${bundleCheckFilter} | ${pkgs.openssl}/bin/openssl sha512 )
            if [ "$newHash" = "$oldHash" ]; then
              echo "Homebrew Bundle unchanged... skipping"
            else
              "${config.homebrew.brewPath}" bundle install --file "${brewFile}"
            fi
        else
          echo "-- Error: ${config.homebrew.brewPath} was not installed/found"
        fi
      '';

      # Run auto upgrade with brew upgrade --greedy
      home.activation.homebrewUpgrade = lib.mkIf config.homebrew.upgrade (
        lib.hm.dag.entryAfter ["homebrewApps"] ''
          if [ -f "${config.homebrew.brewPath}" ]; then
            "${config.homebrew.brewPath}" upgrade --greedy
          fi
        ''
      );
    };
}
