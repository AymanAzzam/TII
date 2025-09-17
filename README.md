# TII

## Docker
1. Go to the folder app
2. Run the following command to buld the docker image
```
docker build -t hextris .
```
3. Run the following command to run the docker image on port 8082
```
docker run -p 8082:80 hextris
```
4. Access the app on http://localhost:8082
5. Push the image to Docker hub
```
docker tag hextris:latest aymanazzam63/hextris:latest
docker push aymanazzam63/hextris:latest
```

## Kubernetes
1. Start Minikube
```
minikube start
```
2. Build Docker image inside Minikube’s Docker
```
eval $(minikube docker-env)
docker build -t hextris:latest .
```
3. Apply manifest files
```
kubectl apply -f kubernetes/deployment.yaml
kubectl apply -f kubernetes/service.yaml
kubectl apply -f kubernetes/ingress.yaml
```
4. Enable ingress in Minikube
```
minikube addons enable ingress
```
5. Get minikube ip
```
minikube ip
```
6. Ensure ingress-nginx-controller is LoadBalancer 
```
kubectl get svc -n ingress-nginx
kubectl patch svc ingress-nginx-controller -n ingress-nginx -p '{"spec": {"type": "LoadBalancer"}}'
```
7. Update hosts to point hextris.local to Ingress-nginx EXTERNAL-IP (/etc/hosts for linux, C:\Windows\System32\drivers\etc\hosts for windows)
```
<Ingress-nginx-EXTERNAL-IP> hextris.local
```
8. Create a network route between local machine and minikube so can reach the ingress controller.
```
minikube tunnel
```
9. Access the app on http://hextris.local