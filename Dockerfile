# 1er paso: Construir la aplicación con Node
FROM node:lts-alpine AS Builder
# Crear la carpeta necesaria para construir la aplicación
RUN mkdir -p /tmp/nginx/vue-app
# Configurar la carpeta en la que se deben ejecutar los siguientes comandos
WORKDIR /tmp/nginx/vue-app
# Copiar los siguientes archivos para instalar las dependencias
COPY package*.json ./
# Instalar las dependencias y borrar caché de Node.js
RUN npm i
RUN npm cache clean --force
# Copiar todos los archivos de la aplicación en la carpeta del contendor
COPY . .
# Contruir la aplicación
RUN npm run build

# 2do paso: Mostrar la aplicación con Nginx
FROM nginx:stable-alpine
# Crear las carpetas necesarias para el servidor
RUN mkdir -p /var/log/nginx
RUN mkdir -p /var/www/html
# Copiar los archivos de configuración de Nginx
COPY nginx/nginx.conf /etc/nginx/nginx.conf
COPY nginx/default.conf /etc/nginx/conf.d/default.conf
# Copiar los archivos finales de la aplicación en la carpeta del servidor
COPY --from=Builder /tmp/nginx/vue-app/dist /var/www/html
# Hacer que todos los archivos pertenezcan al usuario nginx
RUN chown -R nginx:nginx /var/www/html
# Abrir el puerto 80 del contenedor
EXPOSE 80
# Iniciar el servidor Nginx
CMD ["nginx", "-g", "daemon off;"]
