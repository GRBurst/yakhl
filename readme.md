# Yet another kubernetes home lab

** WIP Status **

Personal playground for my home cloud.

Motivation:
- Learn more about kubernetes
- Try to bypass limitations of other home lab collections

It will be edge, cloud native and very modern.


## Decisions

Using k3d to run k3s in docker, see https://github.com/k3d-io/k3d?tab=readme-ov-file#usage.

- K3s offers a more production ready environment than minikube
- Plain K3s has several limitations when using as a plain service in your OS, e.g. it can be tedious to cleanup (there is a killall script, but that does not work on all OS, e.g. not possible to use in NixOS).


## Usage

Check out what you can do via `k3d help` or check the docs @ [k3d.io](https://k3d.io)

Example Workflow: Create a new cluster and use it with `kubectl`

1. `k3d cluster create CLUSTER_NAME` to create a new single-node cluster (= 1 container running k3s + 1 loadbalancer container)
2. [Optional, included in cluster create] `k3d kubeconfig merge CLUSTER_NAME --kubeconfig-switch-context` to update your default kubeconfig and switch the current-context to the new one
3. execute some commands like `kubectl get pods --all-namespaces`
4. `k3d cluster delete CLUSTER_NAME` to delete the default cluster
