{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
    flake-compat.url = "github:edolstra/flake-compat";
  };

  outputs =
    { nixpkgs, ... }@inputs:
    {
      nixosModules = import ./modules inputs;
      packages = import ./packages inputs;
      formatter.x86_64-linux = nixpkgs.legacyPackages.x86_64-linux.nixfmt-rfc-style;
    };
}
