# NixOS Module Options


<a id="homebrew-enable"></a>
## [`homebrew.enable`](module.nix#L8)

**Type:** `boolean`

**Default:** `true`

<a id="homebrew-brewInstall"></a>
## [`homebrew.brewInstall`](module.nix#L13)

Install homebrew if it not present

**Type:** `boolean`

**Default:** `true`

<a id="homebrew-brewPath"></a>
## [`homebrew.brewPath`](module.nix#L19)

The bath of the brew binary

**Type:** `path`

**Default:**

```nix
if pkgs.stdenv.targetPlatform.isDarwin
then "/opt/homebrew/bin/brew"
else "/home/linuxbrew/.linuxbrew/bin/brew"
```

<a id="homebrew-taps"></a>
## [`homebrew.taps`](module.nix#L28)

Homebrew Taps to add

**Type:** `list of submodule`

**Default:** `[]`

<a id="homebrew-taps-<name>-name"></a>
## [`homebrew.taps.<name>.name`](module.nix#L33)

Name of the TAP

**Type:** `string`

<a id="homebrew-taps-<name>-repo"></a>
## [`homebrew.taps.<name>.repo`](module.nix#L37)

Repository source

**Type:** `string`

<a id="homebrew-taps-<name>-trusted"></a>
## [`homebrew.taps.<name>.trusted`](module.nix#L41)

automatically trust this tap

**Type:** `boolean`

**Default:** `true`

<a id="homebrew-casks"></a>
## [`homebrew.casks`](module.nix#L50)

Homebrew casks to install

**Type:** `list of string`

**Default:** `[]`

<a id="homebrew-formulae"></a>
## [`homebrew.formulae`](module.nix#L56)

Homebrew formulae / packages to install

**Type:** `list of string`

**Default:** `[]`

<a id="homebrew-mas"></a>
## [`homebrew.mas`](module.nix#L62)

Mac App Store apps to install with ID

**Type:** `list of submodule`

**Default:** `[]`

<a id="homebrew-mas-<name>-name"></a>
## [`homebrew.mas.<name>.name`](module.nix#L67)

Name of the app

**Type:** `string`

<a id="homebrew-mas-<name>-id"></a>
## [`homebrew.mas.<name>.id`](module.nix#L71)

App ID

**Type:** `signed integer`

<a id="homebrew-ignoreMasChanges"></a>
## [`homebrew.ignoreMasChanges`](module.nix#L79)


If set to true it will not include Mac App Store changes when comparing
the Brewbundles. This prevents constantly running `brew install` command
on activation if apps are manually installed from the Mac App Store


**Type:** `boolean`

**Default:** `true`

<a id="homebrew-cleanup"></a>
## [`homebrew.cleanup`](module.nix#L89)


if set to true, it will delete  applications installed manually and
not specified in the flake config. It uses `brew bundle cleanup`.
By default is set to true to stick to reproducible environments
principles of nix.


**Type:** `boolean`

**Default:** `true`

<a id="homebrew-update"></a>
## [`homebrew.update`](module.nix#L100)


If set to true it will run a brew update in the activation script
(when running home-manager switch)


**Type:** `boolean`

**Default:** `true`

<a id="homebrew-upgrade"></a>
## [`homebrew.upgrade`](module.nix#L109)


If set to true it will run a `brew upgrade --greedy` in the activation
script (when running home-manager switch). If you want to keep a
specific version, uses `brew pin` command.


**Type:** `boolean`

**Default:** `true`

<a id="homebrew-enableShellIntegration"></a>
## [`homebrew.enableShellIntegration`](module.nix#L119)


Whether to globally enable shell integration for bash, zsh or fish shells.


**Type:** `boolean`

**Default:** `true`

---
*Generated with [nix-options-doc](https://github.com/Thunderbottom/nix-options-doc)*
