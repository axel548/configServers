#!/bin/bash

#chmod +x crear_usuario.sh
#sh crear_usuario.sh usuario 'contrasenia'

# Verificar si se proporcionaron los argumentos de usuario y contraseña
if [ -z $1 ]; then
    echo "Por favor, proporciona el nombre de usuario."
    exit 1  # Salir del script con código de error
fi

usuario=$1

echo "Creando usuario..."
adduser --disabled-password --gecos "" "$usuario"

echo "\n"
echo "Insertando usuario a la lista de usuarios permitidos del vsftpd.userlist..."
echo "$usuario" >> /etc/vsftpd.userlist

echo "\n"
echo "Configuracion de carpetas del usuario..."
mkdir /home/$usuario/ftp
chown nobody:nogroup /home/$usuario/ftp
chmod a-w /home/$usuario/ftp
mkdir /home/$usuario/ftp/files
chown hostinger:hostinger /home/$usuario/ftp/files
echo "vsftpd sample file" | sudo tee /home/$usuario/ftp/files/sample.txt



echo "\n"
echo "Configuracion de carpetas del usuario para la web..."
mkdir /var/www/$usuario

usermod -aG web $usuario
chown -R .web /var/www/$usuario/
chmod -R g+w /var/www/$usuario/
mkdir /home/$usuario/ftp/web
mount --bind /var/www/$usuario/ /home/$usuario/ftp/web


cp /var/www/default/index.html /var/www/$usuario/index.html
cp /var/www/default/styles.css /var/www/$usuario/styles.css

chmod -R 755 /var/www/clase_redes/
echo "RewriteCond %{REQUEST_URI} ^/$usuario/ [NC]" >> /var/www/.htaccess


echo "\n"
echo "Reinicio de los servicios..."
sudo systemctl restart vsftpd
sudo systemctl restart apache2
