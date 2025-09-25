{ nixpkgs, supportedSystems, ... }@inputs:
nixpkgs.lib.genAttrs supportedSystems (system:
/**
  Library functions that require a system-specific `pkgs` instance.

  This primarily means custom builders.
*/
{
  mkRustShell = import ./mk-rust-shell.nix (inputs // { inherit system; });
})
