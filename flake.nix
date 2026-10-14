{
  inputs = {
    famedly-engineering-standards.url = "github:famedly/engineering-standards";

    nixpkgs.follows = "famedly-engineering-standards/nixpkgs";
    flake-parts.follows = "famedly-engineering-standards/flake-parts";

    fleet-nixos = {
      url = "github:adamcik/fleet-nixos";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    { famedly-engineering-standards, flake-parts, ... }@inputs:
    flake-parts.lib.mkFlake { inherit inputs; } {
      imports = [ famedly-engineering-standards.flakeModules.default ];

      systems = famedly-engineering-standards.lib.famedlySystems;

      perSystem =
        {
          pkgs,
          lib,
          system,
          ...
        }:
        {
          famedly.standards.nix.projects."." = { };

          # DriveStrike only ships x86_64 Linux binaries.
          packages = lib.optionalAttrs (system == "x86_64-linux") {
            drivestrike = pkgs.callPackage ./packages/drivestrike.nix { };
          };
        };

      flake.nixosModules.default = import ./modules inputs;
    };
}
