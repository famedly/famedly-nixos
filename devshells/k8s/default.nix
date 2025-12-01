{
  stdenv,
  nixpkgs,
  ...
}@flake-inputs:
let
  pkgs = nixpkgs.legacyPackages.${stdenv.hostPlatform.system};
in
pkgs.mkShell {
  packages =
    with pkgs;
    [
      kubectl
      kubelogin-oidc
      kubetui
    ];
}
