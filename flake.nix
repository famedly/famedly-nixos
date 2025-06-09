{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
    flake-compat.url = "github:edolstra/flake-compat";
  };

  outputs =
    { nixpkgs, ... }@inputs:
    {
      packages = import ./packages inputs;
    };
}
