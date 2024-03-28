serviceName: ${service_name}
namespace: ${namespace}

hosts:
  %{~ for host in hosts ~}
  - ${host}
  %{~ endfor ~}

prefixes:
  %{~ for prefix in prefixes ~}
  - ${prefix}
  %{~ endfor ~}

port: ${service_port}
