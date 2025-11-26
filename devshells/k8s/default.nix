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

  shellHook = ''
    KUBE_TMP=$(mktemp -d)
    cp ${./kubeconfig.yaml} "$KUBE_TMP/config"
    chmod 600 "$KUBE_TMP/config"

    if [ -n "$KUBECONFIG" ]; then
      export KUBECONFIG="$KUBE_TMP/config:$KUBECONFIG"
    elif [ -f "$HOME/.kube/config" ]; then
      export KUBECONFIG="$KUBE_TMP/config:$HOME/.kube/config"
    else
      export KUBECONFIG="$KUBE_TMP/config"
    fi
  '';
}
