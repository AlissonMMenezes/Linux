#!/bin/bash

DIRETORIO=$(echo $2)

function usage(){
	clear
	echo "Script de backup curso 451"
	echo "Opcoes de uso:"
	echo "$0 cadastrar"
	echo " -- Cadastrar um servidor no banco"
	echo "$0 remover"
	echo " -- Remover um servidor do banco"
	echo "$0  gerar"
	echo " -- Gera o backup dos servidores cadastrados"
	echo "$0 listar"
	echo " -- Lista o servidores cadastrados para o backup"

}

function geraBackup(){

	for linha in $(cat banco.txt)
	do
		SERVIDOR=$(echo $linha | cut -f1 -d';' )
		DIRETORIO=$(echo $linha | cut -f2 -d';' | tr "," " ")
		DATA=$( date +%d_%m_%Y)
		echo "Realizando Backup"
		ssh root@$SERVIDOR "tar zcf /tmp/_${SERVIDOR}_$DATA.tar.gz $DIRETORIO "
		echo "Copiando arquivo"
		scp root@$SERVIDOR:/tmp/_${SERVIDOR}_$DATA.tar.gz /backup/
		echo "Removendo backup da origem"
		ssh root@$SERVIDOR "rm -f /tmp/_${SERVIDOR}_$DATA.tar.gz"
	done
}


function cadastrar(){
	echo "Digite o ip do servidor"
	read SERVIDOR
	SERVIDOR=$(echo "$SERVIDOR" | tr -d " ")
	
	grep "$SERVIDOR" banco.txt
	
	if [ $? == 0 ]; then
		echo "Servidor ja cadastrado"
		exit 
	fi 

	echo "Digite os diretorios sepados por ,"
	read DIRETORIOS
	DIRETORIOS=$(echo $DIRETORIOS | tr " " "," )
	echo "$SERVIDOR;$DIRETORIOS" >> banco.txt
	listar
}

function listar(){
	nl banco.txt
}

function remover(){
	echo "Digite o ip a ser removido"
	read SERVIDOR
	sed -i "/$SERVIDOR/d" banco.txt
	nl banco.txt
}	



case $1 in
   'cadastrar')
	cadastrar
   ;;

   'remover')
	remover
   ;;

   'listar')
	listar
   ;;
   'gerar')
	geraBackup
   ;;
   *)
	usage
   ;;
esac














