# Fase de construcción
FROM node:20 AS build

# Establecer el directorio de trabajo
WORKDIR /app

# Copiar los archivos de dependencias
COPY package*.json ./

# Instalar dependencias
RUN npm install

# Copiar el resto del código fuente
COPY . .

# Establecer la variable de entorno para la URL base del API
ARG REACT_APP_API_BASE_URL
ENV REACT_APP_API_BASE_URL ${REACT_APP_API_BASE_URL}

# Construir la aplicación
RUN npm run build

# Fase de producción
FROM node:20 AS production

# Establecer el directorio de trabajo
WORKDIR /app

# Copiar los archivos construidos desde la fase de construcción
COPY --from=build /app/build ./build

# Instalar un servidor HTTP simple para servir la aplicación
RUN npm install -g serve

# Exponer el puerto 3000
EXPOSE 3000

# Comando para ejecutar el servidor en modo producción
CMD ["serve", "-s", "build", "-l", "3000"]
