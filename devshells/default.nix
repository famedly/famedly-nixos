{ nixpkgs, ... }@inputs:
let
  # TODO: Someone should test if the devshells work with
  # aarch64-darwin so we can add support for MacOS
  systems = [ "x86_64-linux" ];
in
nixpkgs.lib.genAttrs systems (system: {
  rust = import ./rust.nix (inputs // { inherit system; });
})
