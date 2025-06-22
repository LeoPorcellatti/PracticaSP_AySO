#!/bin/bash

echo "***** Creando particiones en sde *****"
sudo fdisk /dev/sde << EOF
n
p
1

+512M
t
82
n
p
2


t
2
8e
w
EOF

echo "***** Creando particiones en sdc *****"
sudo fdisk /dev/sdc << EOF
n
p
1

+2G
n




t
1
8e
t
2
8e
w
EOF

echo "***** Creando particiones en sdd *****"
sudo fdisk /dev/sdd << EOF
n
p



t
8e
w
EOF

# creo los PV
echo "***** Creando los PV *****"
sudo pvcreate /dev/sde2 /dev/sdc1 /dev/sdc2 /dev/sdd1

# Creo las VG
echo "***** Creando las VG *****"
sudo vgcreate vg_temp /dev/sdc1
sudo vgcreate vg_datos /dev/sdc2 /dev/sdd1 /dev/sde2

# Creo los LV
echo "***** Creando los LV *****"
sudo lvcreate -L 10M vg_datos -n lv_docker
sudo lvcreate -L 1.5G vg_datos -n lv_multimedia
sudo lvcreate -l 100%FREE vg_temp -n lv_swap


# Formateo el LV (Creo el File System y el swap)
echo "***** Formateando los VG *****"
sudo mkfs.ext4 /dev/mapper/vg_datos-lv_docker
sudo mkfs.ext4 /dev/mapper/vg_datos-lv_multimedia
sudo mkswap /dev/mapper/vg_temp-lv_swap

# Monto el LV y activo el swapon 
echo "***** Montando volúmenes y activando swap *****"
sudo mkdir -p /Multimedia

sudo mount /dev/mapper/vg_datos-lv_docker /var/lib/docker/
sudo mount /dev/mapper/vg_datos-lv_multimedia /Multimedia
sudo swapon /dev/mapper/vg_temp-lv_swap

sudo mkswap /dev/sde1
sudo swapon /dev/sde1

# Hago las Persitencias en fstab #00 para swap # 02 para particiones
echo "***** Creando Persistencias en fstab *****"
echo "/dev/mapper/vg_datos-lv_docker /var/lib/docker ext4 defaults 0 2" | sudo tee -a /etc/fstab
echo "/dev/mapper/vg_datos-lv_multimedia /Multimedia ext4 defaults 0 2" | sudo tee -a /etc/fstab
echo "/dev/mapper/vg_temp-lv_swap none swap sw 0 0" | sudo tee -a /etc/fstab
echo "/dev/sde1 none swap sw 0 0" | sudo tee -a /etc/fstab 

echo "***** Listo *****"
