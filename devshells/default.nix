{ nixpkgs, ... }@inputs:
let
  systems = [
    "x86_64-linux"
    "aarch64-darwin"
  ];
in
nixpkgs.lib.genAttrs systems (system: {
  rust = import ./rust (inputs // { inherit system; });
  k8s = import ./k8s (inputs // { inherit system; });
})
