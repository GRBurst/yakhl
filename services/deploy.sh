#!/usr/bin/env bash

if [[ "${1:-}" == "full" ]]; then
    tofu destroy -auto-approve
    k3d cluster delete pluto
    sleep 3
    k3d cluster create --config ../k3s/cluster.yml
    echo "Waiting for cluster to get ready..."
    sleep 60
fi


tofu apply -auto-approve -target=kubernetes_namespace.nginx
tofu apply -auto-approve -target=kubernetes_namespace.nextcloud
tofu apply -auto-approve -target=kubernetes_namespace.jellyfin
tofu apply -auto-approve -target=kubernetes_namespace.valheim

sleep 5

tofu apply -auto-approve
