serviceName: ${service_name}
namespace: ${namespace}

hosts:
  %{~ for host in hosts ~}
  - ${host}
  %{~ endfor ~}

%{ if prefixes != "" }
prefixes:
  %{~ for prefix in prefixes ~}
  - ${prefix}
  %{~ endfor ~}
%{ endif }

%{ if strip_prefixes != "" }
stripPrefixes:
  %{~ for prefix in strip_prefixes ~}
  - ${prefix}
  %{~ endfor ~}
%{ endif }

port: ${service_port}
