{ pkgs ? import <nixpkgs> { } }:
with pkgs;
mkShell {
  buildInputs = [
    minikube
    k3s

    kubectl
    kubernetes-helm

    opentofu

    jq
  ];

  # shellHook = ''
  # '';
}
