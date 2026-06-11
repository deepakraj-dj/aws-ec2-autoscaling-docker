FROM nginx:alpine
WORKDIR /usr/share/nginx/html
COPY AWS/testss.html index.html
EXPOSE 80