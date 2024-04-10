resource "k3d_cluster" "pluto" {
    name          = "pluto"
    servers_count = 1
    agents_count  = 2

    kube_api {
        host_ip = "0.0.0.0"
        host_port = 6445
    }

    ports {
      host_port = 12345
      container_port = 80
      node_filters = [
        "loadbalancer",
      ]
    }
    ports {
      host_port = 443
      container_port = 443
      node_filters = [
        "loadbalancer",
      ]
    }

    k3d_options {
        no_loadbalancer = false
        no_image_volume = false
    }

    kube_config {
        update_default = true
        switch_context = true
    }

    volumes {
      source = "/media/kubernetes/pvc"
      destination = "/var/lib/rancher/k3s/storage"
      node_filters = [
        "all"
      ]
    }
    volumes {
      source = "/media/kubernetes/data"
      destination = "/kubernetes"
      node_filters = [
        "server:0",
        "agent:*"
      ]
    }
}
