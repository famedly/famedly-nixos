{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
    flake-compat.url = "github:edolstra/flake-compat";
    fenix = {
      url = "github:nix-community/fenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    { nixpkgs, ... }@inputs:
    let
      # Generally supported systems; specific outputs may have more
      # specific requirements, e.g. drivestrike is not built for
      # darwin.
      supportedSystems = [
        "x86_64-linux"
        "aarch64-darwin"
      ];
    in
    {
      nixosModules = import ./modules inputs;
      packages = import ./packages (inputs // { inherit supportedSystems; });
      pkgsLib = import ./pkgs-lib (inputs // { inherit supportedSystems; });
      devShells = import ./devshells (inputs // { inherit supportedSystems; });
      formatter.x86_64-linux = nixpkgs.legacyPackages.x86_64-linux.nixfmt-rfc-style;
    };
}
