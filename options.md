# NixOS Module Options


## [`homebrew.enable`](module.nix#L8)

**Type:** `lib.types.bool`

**Default:** `true`

## [`homebrew.brewInstall`](module.nix#L13)

Install homebrew if it not present

**Type:** `lib.types.bool`

**Default:** `true`

## [`homebrew.brewPath`](module.nix#L19)

The bath of the brew binary

**Type:** `lib.types.path`

**Default:**

```nix
if pkgs.stdenv.targetPlatform.isDarwin
then "/opt/homebrew/bin/brew"
else "/home/linuxbrew/.linuxbrew/bin/brew"
```

## [`homebrew.taps`](module.nix#L28)

Homebrew Taps to add

**Type:**

```nix
lib.types.listOf (lib.types.submodule {
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
})
```

**Default:** `[]`

## [`homebrew.casks`](module.nix#L45)

Homebrew casks to install

**Type:** `lib.types.listOf lib.types.str`

**Default:** `[]`

## [`homebrew.formulae`](module.nix#L51)

Homebrew formulae / packages to install

**Type:** `lib.types.listOf lib.types.str`

**Default:** `[]`

## [`homebrew.mas`](module.nix#L57)

Mac App Store apps to install with ID

**Type:**

```nix
lib.types.listOf (lib.types.submodule {
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
})
```

**Default:** `[]`

## [`homebrew.ignoreMasChanges`](module.nix#L74)


If set to true it will not include Mac App Store changes when comparing
the Brewbundles. This prevents constantly running `brew install` command
on activation if apps are manually installed from the Mac App Store


**Type:** `lib.types.bool`

**Default:** `true`

## [`homebrew.cleanup`](module.nix#L84)


if set to true, it will delete  applications installed manually and
not specified in the flake config. It uses `brew bundle cleanup`.
By default is set to true to stick to reproducible environments
principles of nix.


**Type:** `lib.types.bool`

**Default:** `true`

## [`homebrew.update`](module.nix#L95)


If set to true it will run a brew update in the activation script
(when running home-manager switch)


**Type:** `lib.types.bool`

**Default:** `true`

## [`homebrew.upgrade`](module.nix#L104)


If set to true it will run a `brew upgrade --greedy` in the activation
script (when running home-manager switch). If you want to keep a
specific version, uses `brew pin` command.


**Type:** `lib.types.bool`

**Default:** `true`

## [`homebrew.enableShellIntegration`](module.nix#L114)


Whether to globally enable shell integration for bash, zsh or fish shells.


**Type:** `lib.types.bool`

**Default:** `false`

