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
  #   source <(sudo kubectl completion bash)
  #   source <(sudo kubectl completion zsh)
  # '';
}
