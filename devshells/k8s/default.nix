{
  system,
  nixpkgs,
  ...
}@flake-inputs:
let
  pkgs = nixpkgs.legacyPackages.${system};
in
pkgs.mkShell {
  packages =
    with pkgs;
    [
      kubectl
      kubelogin-oidc
      kubetui
      kubernetes-helm
    ];
}
