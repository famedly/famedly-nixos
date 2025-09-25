{ nixpkgs, supportedSystems, ... }@flake-inputs:
nixpkgs.lib.recursiveUpdate
  (nixpkgs.lib.genAttrs supportedSystems (
    system:
    let
      pkgs = nixpkgs.legacyPackages.${system};
    in
    {
      cargo-udeps = pkgs.callPackage ./cargo-udeps.nix { inherit flake-inputs; };
    }
  ))
  {
    x86_64-linux.drivestrike = nixpkgs.legacyPackages.x86_64-linux.callPackage ./drivestrike.nix { };
  }
