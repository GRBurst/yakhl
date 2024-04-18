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


%{ if additional_ingress_middlewares != "" }
additionalIngressMiddlewares:
  %{~ for middleware in additional_ingress_middlewares ~}
  - ${middleware}
  %{~ endfor ~}
%{ endif }

%{ if additional_ingress_annotations != "" }
additionalIngressAnnotations:
  %{~ for annotation in additional_ingress_annotations ~}
  ${annotation.key}:
    name: ${annotation.key}
    value: ${annotation.value}
  %{~ endfor ~}
%{ endif }

port: ${service_port}
