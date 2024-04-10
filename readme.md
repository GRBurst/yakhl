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
- Plain K3s has several limitations when using as a plain service in your OS, e.g. it can be tedious to cleanup (there is a killall script, but that does not work on all OS, e.g. not possible to use in NixOS, see https://github.com/NixOS/nixpkgs/issues/98090).


## Setup

### K3d

Check out what you can do via `k3d help` or check the docs @ [k3d.io](https://k3d.io)

Create Cluster with config:
```bash
k3d cluster create --config k3s/cluster.yml
```


Example Workflow: Create a new cluster and use it with `kubectl`

1. `k3d cluster create CLUSTER_NAME` to create a new single-node cluster (= 1 container running k3s + 1 loadbalancer container)
2. [Optional, included in cluster create] `k3d kubeconfig merge CLUSTER_NAME --kubeconfig-switch-context` to update your default kubeconfig and switch the current-context to the new one
3. execute some commands like `kubectl get pods --all-namespaces`
4. `k3d cluster delete CLUSTER_NAME` to delete the default cluster

### Services
Currently the main services are deployed to k3s.
After creating the cluster, `cd` into the `k3s` folder and run terraform (OpenTofu).

```bash
cd k3s
tofu apply -auto-approve
```

Right now, this will deploy:
- nginx under "https://localhost", "https://web.localhost" and "https://web.localhost.localdomain"
- jellyfin under "https://media.localhost" and "https://media.localhost.localdomain"
- nextcloud under "https://cloud.localhost"


### Dashboard

WIP with token access.


Forward with:
```bash
kubectl -n kubernetes-dashboard port-forward svc/kubernetes-dashboard-kong-proxy 8443:443
```

Open at https://localhost:8443/ and input the token. You can query the token with:
```bash
tofu output -json token | jq -r ".token"
```

## Learnings

- Don't depend on persistent volume claims in a deployment. Terraform waits for the creation of the claim, but kubernetes creates the claim on first request. Hence, the deployment has to claim it, before it is created.
- Ingress rules are referenced by `<middleware-namespace>-<middleware-name>@kubernetescrd`.


