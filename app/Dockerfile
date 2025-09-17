FROM nginx:alpine AS build

WORKDIR /usr/share/nginx/html

# Remove default nginx static content
RUN rm -rf ./*

COPY . .

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
