{
  description = "Integration for Homebrew (brew.sh) with Nix home-manager";
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

  outputs = {...}: {
    homeManagerModules.default = import ./module.nix;
  };
}
