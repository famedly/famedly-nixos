{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    nixpkgs-unstable.url = "https://channels.nixos.org/nixos-unstable/nixexprs.tar.xz";
    flake-compat.url = "github:edolstra/flake-compat";
    fenix = {
      url = "github:nix-community/fenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    fleet-nixos = {
      url = "github:adamcik/fleet-nixos";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
  };

  outputs =
    { nixpkgs, ... }@inputs:
    {
      nixosModules = import ./modules inputs;
      packages = import ./packages inputs;
      devShells = import ./devshells inputs;
      formatter.x86_64-linux = nixpkgs.legacyPackages.x86_64-linux.nixfmt-rfc-style;
    };
}
