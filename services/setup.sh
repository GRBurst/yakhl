#!/usr/bin/env bash

echo "Creating directories"
mkdir -p /media/kubernetes/data
mkdir -p /media/kubernetes/pvc

echo "Setting up services"
for ns in $(rg -oIN --no-heading -t "tf" "resource.*kubernetes_namespace.*" | cut -d " " -f3 | tr -d '"'); do
	echo "Setting up $ns"
	tofu apply -target="kubernetes_namespace.$ns" -auto-approve
	mkdir -p "/media/kubernetes/data/$ns"
done

mkdir -p nextcloud/data
mkdir -p jellyfin/library/{shows,movies}
