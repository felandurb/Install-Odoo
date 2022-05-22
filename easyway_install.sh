
#!/bin/bash

function update(){
	apt update
	apt upgrade -y
	apt autoremove -y
}

odoov=12

#Instalación de repositorio multiverse y actualización de addons de forma automatica (ubuntu 18.04)
add-apt-repository multiverse
update

#Descargar de archivos base
##wkhtmltopdf
#https://github.com/wkhtmltopdf/wkhtmltopdf/releases/tag/0.12.5	(Ultima versión)
wget -P download https://github.com/wkhtmltopdf/wkhtmltopdf/releases/download/0.12.5/wkhtmltox_0.12.5-1.bionic_amd64.deb

##Postgresql
#https://www.postgresql.org/download/linux/ubuntu/
#Consulta arquitectura
if [ $(arch) == 'x86_64' ]; then archtype=[arch=amd64]; fi
text="deb ${archtype} http://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main"
echo $text > pgdg.list
cp pgdg.list /etc/apt/sources.list.d/
rm pgdg.list
wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo apt-key add -

#Odoo
wget -P download --quiet -O - https://nightly.odoo.com/odoo.key | apt-key add -
touch /etc/apt/sources.list.d/odoo.list
echo "deb http://nightly.odoo.com/${odoov}.0/nightly/deb/ ./" >> /etc/apt/sources.list.d/odoo.list
update

apt install odoo python3-dev python3-pip xfonts-75dpi xfonts-base -y
pip3 install --upgrade pip
pip3 install transbank-sdk


#Configuración
##wkhtmltopdf
dpkg -i download/wkhtmltox_0.12.5-1.bionic_amd64.deb

rm -R download/

mkdir /opt/odoo
mkdir /opt/odoo/addons

cd /opt/odoo/addons

eval "git clone --branch ${odoov}.0 https://gitlab.com/dansanti/l10n_cl_fe.git"
eval "git clone --branch ${odoov}.0 https://gitlab.com/dansanti/payment_webpay.git"
eval "git clone --branch ${odoov}.0 https://gitlab.com/dansanti/l10n_cl_dte_point_of_sale.git"
eval "git clone --branch ${odoov}.0 https://github.com/KonosCL/addons-konos.git"
eval "git clone --branch ${odoov}.0 https://github.com/OCA/reporting-engine.git"
eval "git clone --branch ${odoov}.0 https://github.com/OCA/server-ux.git"
eval "git clone --branch ${odoov}.0 https://gitlab.com/dansanti/payment_currency.git"

cd l10n_cl_fe

pip install -r requirements.txt

cp /root/Install-Odoo/odoo.conf /etc/odoo/odoo.conf

service odoo restart

#Instalando nginx
sudo apt install nginx

ufw enable
ufw allow 22
ufw allow 8069
ufw allow "Nginx HTTP"
ufw allow "Nginx HTTPS"

cp /root/Install-Odoo/default /etc/nginx/sites-available/modificar

#Descargar enterprise
#git clone --branch ${odoov} --single-branch https://github.com/odoo/enterprise.git
#mkdir /opt/odoo/enterprise
#mkdir /opt/odoo/custom


