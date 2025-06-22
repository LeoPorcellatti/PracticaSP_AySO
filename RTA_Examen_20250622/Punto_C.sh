# Modifico el archivo HTML > ~/PracticaSP_AySO/202408/docker/web$ vim index.html 

#Reinicio el servicio de Docker
sudo systemctl restart docker

#Extiendo el LV de docker por el disponible
sudo lvextend -l 100%FREE /dev/mapper/vg_datos-lv_docker

#Hago el Resize 
sudo resize2fs /dev/mapper/vg_datos-lv_docker

#Descargo la imagen
docker pull nginx


# Me conecto a Docker 
docker login -u lporcellatti
#pongo el token temporal

# Creo un archivo 
echo "FROM nginx 
COPY web /usr/share/nginx/html" > Dockerfile

# Creo la imagen 
docker build -t lporcellatti/web3_sp2025_porcellatti:v1 -t lporcellatti/web3_sp2025_porcellatti:latest .

# La pusheo a docker hub
docker push lporcellatti/web3_sp2025_porcellatti -a

# La hago correr en mi puerto
docker run -d -p 8080:80 lporcellatti/web3_sp2025_porcellatti:v1

# buscar con la ip de la VM + 8080 

# Modificar archivo info.txt

grep "model name" /proc/cpuinfo | uniq | head -1 | awk '{print "CPU Modelo: "$6" Frecuencia: "$9}' > web/file/info.txt

# Modifico el docker-compose.yml
vim docker-compose.yml

# version: '3'

# services:
#     web:
#         image: lporcellatti/web3_sp2025_porcellatti:latest
#         ports:
#             - "8081:80"
#         volumes:
#             - "./web/file:/usr/share/nginx/html/file"

# Levantar el servicio actualizado
docker compose up -d

# Probar con el nuevo puerto :8081, si llega a no mostrarlo hay que refrescar la página


