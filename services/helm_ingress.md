$ kubectl describe ingress -A

Name:             jellyfin-web-ingress
Labels:           app.kubernetes.io/managed-by=Helm
Namespace:        jellyfin
Address:          10.96.0.17
Ingress Class:    traefik
Default backend:  <default>
Rules:
  Host                   Path  Backends
  ----                   ----  --------
  localhost
                         /media,/jellyfin   jellyfin-web:8096 (10.42.0.89:8096)
  localhost.localdomain
                         /media,/jellyfin   jellyfin-web:8096 (10.42.0.89:8096)
Annotations:             meta.helm.sh/release-name: jellyfin
                         meta.helm.sh/release-namespace: default
                         traefik.ingress.kubernetes.io/router.middlewares: jellyfin-jellyfin-web@kubernetescrd
Events:                  <none>


Name:             nginx-ingress
Labels:           app.kubernetes.io/managed-by=Helm
Namespace:        nginx
Address:          10.96.0.17
Ingress Class:    traefik
Default backend:  <default>
Rules:
  Host                   Path  Backends
  ----                   ----  --------
  localhost
                         /nginx,/webserver   nginx:80 (10.42.0.84:80,10.42.0.85:80)
  localhost.localdomain
                         /nginx,/webserver   nginx:80 (10.42.0.84:80,10.42.0.85:80)
Annotations:             meta.helm.sh/release-name: nginx
                         meta.helm.sh/release-namespace: default
                         traefik.ingress.kubernetes.io/router.middlewares: nginx-nginx@kubernetescrd
Events:                  <none>
