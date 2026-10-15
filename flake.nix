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
      imports = [
        famedly-engineering-standards.flakeModules.default
        ./tests
      ];

      systems = famedly-engineering-standards.lib.famedlySystems;

      perSystem =
        {
          pkgs,
          inputs',
          self',
          ...
        }:
        {
          famedly.standards.nix.projects."." = { };
          packages = pkgs.lib.packagesFromDirectoryRecursive {
            callPackage = pkgs.lib.callPackageWith (pkgs // { inherit inputs inputs' self'; });
            directory = ./packages;
          };
        };

      flake.nixosModules.default = flake-parts.lib.importApply ./modules { inherit inputs; };
    };
}
