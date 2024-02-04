#!/bin/bash

_Key='/etc/cghkey'

clear

[[ ! -e ${_Key} ]] && exit 

#Modificado el 06-04-2023

dir_user="/userDIR"
dir="/etc/adm-lite"

add_new_user(){
  local Fecha=`date +%d-%m-%y-%R`
  [[ $(cat /etc/passwd |grep $1: |grep -vi [a-z]$1 |grep -v [0-9]$1 > /dev/null) ]] && return 1
  local valid=$(date '+%C%y-%m-%d' -d " +$3 days")
  clear
  msg -bar3

  system=$(cat -n /etc/issue |grep 1 |cut -d ' ' -f6,7,8 |sed 's/1//' |sed 's/      //')
  distro=$(echo "$system"|awk '{print $1}')
  vercion=$(echo $system|awk '{print $2}'|cut -d '.' -f1)

  if [[ ${distro} = @(Ubuntu|Debian) ]]; then
    if [[ ${vercion} = "16" ]]; then
      passCIFRED=$(openssl passwd -1 $2)
    else
      passCIFRED=$(openssl passwd -6 $2)
    fi
  fi

  if useradd -M -s /bin/false -e ${valid} -K PASS_MAX_DAYS=$3 -p ${passCIFRED} -c $4,$2 $1 ; then
	return 1
  else
  	return 0
  fi
}


fun_ip () {
MEU_IP=$(ip addr | grep 'inet' | grep -v inet6 | grep -vE '127\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | grep -o -E '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | head -1)
MEU_IP2=$(wget -qO- ipv4.icanhazip.com)
[[ "$MEU_IP" != "$MEU_IP2" ]] && echo "$MEU_IP2" || echo "$MEU_IP"
}
removeonline(){
i=1
    [[ -d /var/www/html ]] && [[ -e /var/www/html/$arquivo_move ]] && rm -rf /var/www/html/$arquivo_move > /dev/null 2>&1
    [[ -e /var/www/$arquivo_move ]] && rm -rf /var/www/$arquivo_move > /dev/null 2>&1
    echo -e "${cor[5]}Extraxion Exitosa Exitosa"
    echo -e "$barra"
echo "SUBIENDO"
subironline
}   
subironline(){
[ ! -d /var ] && mkdir /var
[ ! -d /var/www ] && mkdir /var/www
[ ! -d /var/www/html ] && mkdir /var/www/html
[ ! -e /var/www/html/index.html ] && touch /var/www/html/index.html
[ ! -e /var/www/index.html ] && touch /var/www/index.html
chmod -R 755 /var/www
cp $HOME/$arquivo_move /var/www/$arquivo_move
cp $HOME/$arquivo_move /var/www/html/$arquivo_move
service apache2 restart
IP="$(fun_ip)"
echo -e "\033[1;36m http://$IP:81/$arquivo_move\033[0m"
echo -e "$barra"
echo -e "${cor[5]}Carga Exitosa!"
echo -e "$barra"
read -p "PRESIONE ENTER"
}


echo -e "\033[1;33mMenu de Respaldos de Usuarios\033[1;30m
 ----------------------------------
 \033[1;32m1) \033[1;37mCrear respaldo de Usuarios Online
 ----------------------------------
 \033[1;32m2) \033[1;37mRestaurar Usuarios de un backup Online
 ----------------------------------
 \033[1;32m3) \033[1;37m RESTAURAR FILE LOCAL
 ----------------------------------"
read -p "ECOJE: " option
function backup_de_usuarios(){
msg -bar3
read -p "Ingrese Nombre de su Fichero o pulse ENTER: " name
bc="$HOME/$name"
arquivo_move="$name"
clear
i=1
[[ -e $bc ]] && rm $bc
echo -e "\033[1;37mHaciendo Backup de Usuarios...\033[0m"
[[ -e /bin/ejecutar/token ]] && passTK=$(cat < /bin/ejecutar/token)
#for user in `awk -F : '$3 > 900 { print $1 }' /etc/passwd |grep -v "nobody" |grep -vi polkitd |grep -vi systemd-[a-z] |grep -vi systemd-[0-9] |sort`
for user in `cat "/etc/passwd"|grep 'home'|grep 'false'|grep -v 'syslog' | cut -d: -f1 |sort`
do
[[ -e $dir$dir_user/$user ]] && {
pass=$(cat $dir$dir_user/$user | grep "senha" | awk '{print $2}')
limite=$(cat $dir$dir_user/$user | grep "limite" | awk '{print $2}')
data=$(cat $dir$dir_user/$user | grep "data" | awk '{print $2}')
data_sec=$(date +%s)
data_user=$(chage -l "$user" |grep -i co |awk -F ":" '{print $2}')
data_user_sec=$(date +%s --date="$data_user")
variavel_soma=$(($data_user_sec - $data_sec))
dias_use=$(($variavel_soma / 86400))
if [[ "$dias_use" -le 0 ]]; 
then
dias_use=0
fi
sl=$((dias_use + 1))
i=$((i + 1))
[[ -z "$limite" ]] && limite="5"
echo -e "\033[1;31m [ SCRIPT ] \033[1;37m "
} || {
linea=$(cat /etc/passwd | grep -w ${user})
if [[ "${linea}" =~ ,([^:]+): ]]; then
        pass="${BASH_REMATCH[1]}"
fi
limite="$(cat /etc/passwd | grep -w ${user} | awk -F ':' '{split($5, a, ","); print a[1]}')"
data_sec=$(date +%s)
data_user=$(chage -l "$user" |grep -i co |awk -F ":" '{print $2}')
data_user_sec=$(date +%s --date="$data_user")
variavel_soma=$(($data_user_sec - $data_sec))
dias_use=$(($variavel_soma / 86400))
if [[ "$dias_use" -le 0 ]]; 
then
dias_use=0
fi
sl=$((dias_use + 1))
i=$((i + 1))
[[ -z "$limite" ]] && limite="5"
echo -ne "\033[1;31m [ SYSTEM ] \033[1;37m"
read -p "Introduzca la contraseña manualmente o pulse ENTER: " pass
 if [ -z "$pass" ]; then
pass="$user"
 fi
}
[[ $(echo $limite) = "HWID" ]] && echo "$user:$user:HWID:$sl:$pass" >> $bc && echo -e "\033[1;37mUser $pass \033[0;35m [\033[0;36m$limite\033[0;35m]\033[0;31m Backup [\033[1;31mOK\033[1;37m] con $sl DIAS\033[0m"
[[ $(echo $limite) = "TOKEN" ]] && echo "$user:$passTK:TOKEN:$sl:$pass" >> $bc && echo -e "\033[1;37mUser $pass \033[0;35m [\033[0;36m$limite\033[0;35m]\033[0;31m Backup [\033[1;31mOK\033[1;37m] con $sl DIAS\033[0m"
[[ "$limite" =~ ^[0-9]+$ ]] && echo "$user:$pass:$limite:$sl" >> $bc && echo -e "\033[1;37mUser $user \033[0;35m [\033[0;36mSSH\033[0;35m]\033[0;31m Backup [\033[1;31mOK\033[1;37m] con $sl DIAS\033[0m"
done
echo " "
echo -e "\033[1;31mBackup Completado !!!\033[0m"
echo " "
echo -e "\033[1;37mLos usuarios $i se encuentra en el archivo \033[1;31m $bc \033[1;37m"
}
function restaurar_usuarios(){
cd $HOME
echo "INGRESE LINK Que Mantienes Online en GitHub, o VPS " 
read -p "Pega tu Link : " url1
wget -q -O recovery $url1 && echo -e "\033[1;31m- \033[1;32mFile Exito!" || echo -e "\033[1;31m- \033[1;31mFile Fallo"
#echo -n "Escriba el directorio del archivo Backup: "
echo -e "\033[1;37mRestaurando Usuarios...\033[0m"
[[ -e $HOME/recovery ]] && arq="$HOME/recovery" || return 	
for user in `cat $arq`
do
USER=$(echo "$user" |awk -F : '{print $1}')
CLAVE=$(echo "$user" |awk -F : '{print $2}')
LIMITE=$(echo "$user" |awk -F : '{print $3}')
DIAS=$(echo "$user" |awk -F : '{print $4}')
NameTKID=$(echo "$user" |awk -F : '{print $5}')
valid=$(date '+%C%y-%m-%d' -d " +$DIAS days")
datexp=$(date "+%d/%m/%Y" -d " +$DIAS days")
if cat /etc/passwd |grep $USER: 1> /dev/null 2>/dev/null
then
echo -e "\033[1;37m\033[1;31m$USER \033[1;37mEXISTE: \033[1;31m${CLAVE}  [\033[1;31mFAILED\033[1;37m]\033[0m" > /dev/null
else
add_new_user "${USER}" "${CLAVE}" "${DIAS}" "${LIMITE}" "${newfile}" "${ovpnauth}"
	if [ $? = 1 ]; then
	  [[ ${LIMITE} = "HWID" ]] && {
	  echo "senha: $NameTKID" > /etc/adm-lite/userDIR/$USER
	  echo -e "\033[1;31m$NameTKID \033[1;37mRESTORE: \033[1;31m$LIMITE - \033[1;37m[\033[1;31mOk\033[1;37m] \033[1;37mcon\033[1;31m ${DIAS} \033[1;37m Dias\033[0m"
	  }
	  [[ ${LIMITE} = "TOKEN" ]] && {
	  echo "senha: $NameTKID" > /etc/adm-lite/userDIR/$USER
	  echo -e "\033[1;31m$NameTKID \033[1;37mRESTORE: \033[1;31m$LIMITE - \033[1;37m[\033[1;31mOk\033[1;37m] \033[1;37mcon\033[1;31m ${DIAS} \033[1;37m Dias\033[0m"
	  }
	  [[ ${LIMITE} =~ ^[0-9]+$ ]] && {
	  echo "senha: ${CLAVE}" > /etc/adm-lite/userDIR/$USER
	  echo -e "\033[1;31m$USER \033[1;37mRESTORE: \033[1;31m${CLAVE} - \033[1;37m[\033[1;31mOk\033[1;37m] \033[1;37mcon\033[1;31m ${DIAS} \033[1;37m Dias\033[0m"
	  }
	  echo "limite: $LIMITE" >> /etc/adm-lite/userDIR/$USER
	  echo "data: $valid" >> /etc/adm-lite/userDIR/$USER
	else
	  echo -e "\033[1;37m\033[1;31m$USER \033[1;37mESTADO  [\033[1;31mFAILED\033[1;37m]\033[0m" > /dev/null
	fi
fi
done
}

_resLOC () {

cd $HOME
echo "INGRESE LA RUTA LOCAL DONDE TIENES ALOJADO EL FICHERO " 
echo -e "  EJEMPLO : /root/file.txt "
read -p "Pega TU RUTA : " url1
[[ -e $url1 ]] && {
echo -e " FILE ENCONTRADO \n" 
arq="$url1"
} || {
echo -e " FILE NO FOUND \n"
return
}
#echo -n "Escriba el directorio del archivo Backup: "
echo -e "\033[1;37mRestaurando Usuarios de ... $arq\033[0m \n"
for user in `cat $arq`
do
USER=$(echo "$user" |awk -F : '{print $1}')
CLAVE=$(echo "$user" |awk -F : '{print $2}')
LIMITE=$(echo "$user" |awk -F : '{print $3}')
DIAS=$(echo "$user" |awk -F : '{print $4}')
NameTKID=$(echo "$user" |awk -F : '{print $5}')
valid=$(date '+%C%y-%m-%d' -d " +$DIAS days")
datexp=$(date "+%d/%m/%Y" -d " +$DIAS days")
if cat /etc/passwd |grep $USER: 1> /dev/null 2>/dev/null
then
echo -e "\033[1;37m\033[1;31m$USER \033[1;37mEXISTE: \033[1;31m${CLAVE}  [\033[1;31mFAILED\033[1;37m]\033[0m" > /dev/null
else
add_new_user "${USER}" "${CLAVE}" "${DIAS}" "${LIMITE}" "${newfile}" "${ovpnauth}"
	if [ $? = 1 ]; then
	  [[ ${LIMITE} = "HWID" ]] && {
	  echo "senha: $NameTKID" > /etc/adm-lite/userDIR/$USER
	  echo -e "\033[1;31m$NameTKID \033[1;37mRESTORE: \033[1;31m$LIMITE - \033[1;37m[\033[1;31mOk\033[1;37m] \033[1;37mcon\033[1;31m ${DIAS} \033[1;37m Dias\033[0m"
	  }
	  [[ ${LIMITE} = "TOKEN" ]] && {
	  echo "senha: $NameTKID" > /etc/adm-lite/userDIR/$USER
	  echo -e "\033[1;31m$NameTKID \033[1;37mRESTORE: \033[1;31m$LIMITE - \033[1;37m[\033[1;31mOk\033[1;37m] \033[1;37mcon\033[1;31m ${DIAS} \033[1;37m Dias\033[0m"
	  }
	  [[ ${LIMITE} =~ ^[0-9]+$ ]] && {
	  echo "senha: ${CLAVE}" > /etc/adm-lite/userDIR/$USER
	  echo -e "\033[1;31m$USER \033[1;37mRESTORE: \033[1;31m${CLAVE} - \033[1;37m[\033[1;31mOk\033[1;37m] \033[1;37mcon\033[1;31m ${DIAS} \033[1;37m Dias\033[0m"
	  }
	  echo "limite: $LIMITE" >> /etc/adm-lite/userDIR/$USER
	  echo "data: $valid" >> /etc/adm-lite/userDIR/$USER
	else
	  echo -e "\033[1;37m\033[1;31m$USER \033[1;37mESTADO  [\033[1;31mFAILED\033[1;37m]\033[0m" > /dev/null
	fi
fi
done

}

if [ $option -eq 1 ]; then
_SFTP="$(lsof -V -i tcp -P -n | grep -v "ESTABLISHED" |grep -v "COMMAND" | grep "LISTEN" | grep apache2)"
[[ -z ${_SFTP} ]] && _SFTP="$(lsof -V -i tcp -P -n | grep -v "ESTABLISHED" |grep -v "COMMAND" | grep "LISTEN" | grep nginx)"
portFTP=$(echo -e "$_SFTP" |cut -d: -f2 | cut -d' ' -f1 | uniq)
portFTP=$(echo ${portFTP} | sed 's/\s\+/,/g' | cut -d , -f1)
backup_de_usuarios
msg -bar3
echo -e "		\033[4;31mNOTA importante\033[0m"
echo -e "Recuerda Ir a GitHub y cargarlo Online, para luego poder Restaurarlo!!"
msg -bar3
echo -e " \033[0;31mSi esta usando maquina, Montalo Online"
echo -e "  Para luego usar el Link del Fichero, y puedas ."
echo -e " Descargarlo desde cualquier sitio con acceso WEB"
echo -e "    Ejemplo : http://ip-del-vps:${portFTP}/tu-fichero.\033[0m"
msg -bar3
read -p "PRESIONA ENTER PARA CARGAR ONLINE"
[[ -z $portFTP ]] && echo -e "SERVICIO FTP NO ACTIVO " || removeonline
fi

if [ $option -eq 2 ]; then
restaurar_usuarios
fi
if [ $option -eq 3 ]; then
_resLOC
fi
