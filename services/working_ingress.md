$ kubectl describe ingress -A

Name:             nginx
Labels:           <none>
Namespace:        nginx
Address:          10.96.0.17
Ingress Class:    traefik
Default backend:  nginx:80 (10.42.0.84:80,10.42.0.85:80)
Rules:
  Host        Path  Backends
  ----        ----  --------
  *
              /nginx       nginx:80 (10.42.0.84:80,10.42.0.85:80)
              /webserver   nginx:80 (10.42.0.84:80,10.42.0.85:80)
Annotations:  traefik.ingress.kubernetes.io/router.middlewares: nginx-nginx@kubernetescrd
Events:       <none>


Name:             jellyfin
Labels:           <none>
Namespace:        jellyfin
Address:          10.96.0.17
Ingress Class:    traefik
Default backend:  <default>
Rules:
  Host        Path  Backends
  ----        ----  --------
  *
              /media      jellyfin-web:web (10.42.0.89:8096)
              /jellyfin   jellyfin-web:web (10.42.0.89:8096)
              /web        jellyfin-web:web (10.42.0.89:8096)
Annotations:  traefik.ingress.kubernetes.io/router.middlewares: jellyfin-jellyfin@kubernetescrd
Events:       <none>


Name:             default
Labels:           <none>
Namespace:        nginx
Address:
Ingress Class:    traefik
Default backend:  nginx:80 (10.42.0.84:80,10.42.0.85:80)
Rules:
  Host        Path  Backends
  ----        ----  --------
  *           *     nginx:80 (10.42.0.84:80,10.42.0.85:80)
Annotations:  traefik.ingress.kubernetes.io/router.middlewares: nginx-nginx@kubernetescrd
Events:       <none>
