
# /usr/local/bin/Porcellatti_check_URL.sh
sudo vim /usr/local/bin/Porcellatti_check_URL.sh

# OPCIONAL - en caso de querer darle acceso a todos: sudo chmod 777 /usr/local/bin/Porcellatti_check_URL.sh

### Creo el bash script ###
#!/bin/bash

LISTADO="$1"

ARCHIVO_LOG="/var/log/status_URL.log"
DIR_BASE="/tmp/head-check"
DIR_OK="$DIR_BASE/ok"
DIR_CLIENTE="$DIR_BASE/cliente"
DIR_SERVIDOR="$DIR_BASE/servidor"

#Crear directorios
mkdir -p "$DIR_OK" "$DIR_CLIENTE" "$DIR_SERVIDOR"

# Validar que haya recibido el archivo
if [[ ! -f "$LISTADO" ]]; then
  echo "Error: Listado no encontrado."
  exit 1
fi

# Leo las líneas y obtengo el DOMINIO y el URL:
grep -vE '^#|^$' "$LISTADO" | while IFS=';' read -r DOMINIO URL; do

# Verificar status del URL:
STATUS_CODE=$(curl -LI -o /dev/null -w '%{http_code}\n' -s "$URL")

# Obtengo la fecha y escribo la linea en mi archivo status_url
DATE=$(date +"%Y-%m-%d_%H_%M_%S")
LINEA="$DATE - Code: $STATUS_CODE - URL: $URL"

echo "$LINEA" | sudo tee -a "$ARCHIVO_LOG"

# Determinar carpeta y ruta específica
if (( STATUS_CODE == 200 )); then
  DEST="$DIR_OK/$DOMINIO.log"
elif (( STATUS_CODE >= 400 && STATUS_CODE < 500 )); then
  DEST="$DIR_CLIENTE/$DOMINIO.log"
elif (( STATUS_CODE >= 500 && STATUS_CODE < 600 )); then
  DEST="$DIR_SERVIDOR/$DOMINIO.log"
fi

echo "$LINEA" >> "$DEST"
done

#ejecuto
sudo /usr/local/bin/Porcellatti_check_URL.sh /home/LPorcellatti/PracticaSP_AySO/20250622/202408/bash_script/Lista_URL.txt


