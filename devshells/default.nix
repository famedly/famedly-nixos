{ nixpkgs, supportedSystems, ... }@inputs:
nixpkgs.lib.genAttrs supportedSystems (system: {
  rust = import ./rust (inputs // { inherit system; });
  k8s = import ./k8s (inputs // { inherit system; });
})
