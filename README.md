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