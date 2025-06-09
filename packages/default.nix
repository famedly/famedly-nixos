{ nixpkgs, ... }:
{
  x86_64-linux.drivestrike = nixpkgs.legacyPackages.x86_64-linux.callPackage ./drivestrike.nix { };
}
