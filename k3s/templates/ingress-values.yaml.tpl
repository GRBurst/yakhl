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

stripPrefixes:
  %{~ for prefix in strip_prefixes ~}
  - ${prefix}
  %{~ endfor ~}

port: ${service_port}
