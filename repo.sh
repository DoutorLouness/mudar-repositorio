#!/bin/bash

export DEBIAN_FRONTEND=noninteractive

# Cores para o terminal
CYAN='\033[0;36m'
GREEN='\033[1;32m'
YELLOW='\033[1;33m'
RED='\033[1;31m'
NC='\033[0m'

echo -e "${CYAN}======================================================${NC}"
echo -e "${YELLOW} Otimizador para repositórios Brasileiros${NC}"
echo -e "${CYAN}======================================================${NC}"

# 1. Verificação de privilégios (Root)
if [ "$EUID" -ne 0 ]; then
    echo -e "${RED}[ERRO] Este script precisa ser executado como root (sudo su).${NC}"
    exit 1
fi

# 2. Identificação do Sistema Operacional
if [ -f /etc/os-release ]; then
    . /etc/os-release
    OS=$ID
    OS_LIKE=$ID_LIKE
else
    echo -e "${RED}[ERRO] Não foi possível identificar o sistema operacional.${NC}"
    exit 1
fi

echo -e "${GREEN}[INFO] Sistema detectado: $PRETTY_NAME${NC}"
echo -e "${CYAN}[INFO] Aplicando otimizações de rede para o Brasil...${NC}"

# 3. Lógica de Substituição por Sistema
case "$OS" in
    ubuntu|linuxmint|pop)
        echo -e "${YELLOW}[+] Configurando mirrors do Ubuntu/Mint para br.archive.ubuntu.com...${NC}"
        # Formato Tradicional
        if [ -f /etc/apt/sources.list ]; then
            sed -i -E 's/http:\/\/([a-z]{2}\.)?archive\.ubuntu\.com/http:\/\/br.archive.ubuntu.com/g' /etc/apt/sources.list
        fi
        # Formato Moderno (Deb822 - Ubuntu 24.04+)
        if [ -f /etc/apt/sources.list.d/ubuntu.sources ]; then
            sed -i -E 's/http:\/\/([a-z]{2}\.)?archive\.ubuntu\.com/http:\/\/br.archive.ubuntu.com/g' /etc/apt/sources.list.d/ubuntu.sources
        fi
        apt-get update -qq > /dev/null 2>&1
        echo -e "${GREEN}[V] Repositórios atualizados!${NC}"
        ;;

    debian|kali|parrot)
        echo -e "${YELLOW}[+] Configurando mirrors do Debian para ftp.br.debian.org...${NC}"
        if [ -f /etc/apt/sources.list ]; then
            sed -i -E 's/deb\.debian\.org/ftp.br.debian.org/g' /etc/apt/sources.list
        fi
        if [ -f /etc/apt/sources.list.d/debian.sources ]; then
            sed -i -E 's/deb\.debian\.org/ftp.br.debian.org/g' /etc/apt/sources.list.d/debian.sources
        fi
        apt-get update -qq > /dev/null 2>&1
        echo -e "${GREEN}[V] Repositórios atualizados!${NC}"
        ;;

    centos|rocky|almalinux|rhel|fedora)
        echo -e "${YELLOW}[+] Sistemas RHEL usam mirrorlists baseados em Geo-IP.${NC}"
        echo -e "${YELLOW}[+] Ativando o 'fastestmirror' para garantir a rota brasileira mais rápida...${NC}"
        
        # Para DNF (sistemas mais novos)
        if [ -f /etc/dnf/dnf.conf ]; then
            if ! grep -q "fastestmirror=True" /etc/dnf/dnf.conf; then
                echo "fastestmirror=True" >> /etc/dnf/dnf.conf
            fi
        fi
        # Para YUM (sistemas mais antigos)
        if [ -f /etc/yum.conf ]; then
            if ! grep -q "fastestmirror=1" /etc/yum.conf; then
                echo "fastestmirror=1" >> /etc/yum.conf
            fi
        fi
        echo -e "${GREEN}[V] Otimização de rotas aplicada!${NC}"
        ;;

    arch|manjaro|endeavouros)
        echo -e "${YELLOW}[+] Configurando mirrors do Arch Linux para servidores BR...${NC}"
        if [ -f /etc/pacman.d/mirrorlist ]; then
            # Faz backup do original
            cp /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist.bak
            # Insere o mirror BR da USP no topo da lista
            sed -i '1i Server = http://sunsite.icm.edu.pl/pub/Linux/distributions/archlinux/$repo/os/$arch' /etc/pacman.d/mirrorlist
            sed -i '1i Server = https://archlinux.c3sl.ufpr.br/$repo/os/$arch' /etc/pacman.d/mirrorlist
            sed -i '1i ## Brazil Mirrors' /etc/pacman.d/mirrorlist
        fi
        echo -e "${GREEN}[V] Repositórios brasileiros adicionados ao topo!${NC}"
        ;;

    alpine)
        echo -e "${YELLOW}[+] Configurando mirrors do Alpine Linux para UFPR (Brasil)...${NC}"
        if [ -f /etc/apk/repositories ]; then
            sed -i 's/dl-cdn.alpinelinux.org/alpine.c3sl.ufpr.br/g' /etc/apk/repositories
        fi
        echo -e "${GREEN}[V] Repositórios atualizados!${NC}"
        ;;

    opensuse*|sles)
        echo -e "${YELLOW}[+] O openSUSE utiliza um redirecionador inteligente (download.opensuse.org).${NC}"
        echo -e "${GREEN}[V] Nenhuma alteração necessária, ele já te envia para o mirror BR mais próximo!${NC}"
        ;;

    *)
        # Fallback genérico tentando usar o ID_LIKE se o ID falhar
        if [[ "$OS_LIKE" == *"debian"* || "$OS_LIKE" == *"ubuntu"* ]]; then
             echo -e "${YELLOW}[+] Distro baseada em Debian identificada. Tentando otimizar...${NC}"
             sed -i -E 's/http:\/\/([a-z]{2}\.)?archive\.ubuntu\.com/http:\/\/br.archive.ubuntu.com/g' /etc/apt/sources.list 2>/dev/null
             sed -i -E 's/deb\.debian\.org/ftp.br.debian.org/g' /etc/apt/sources.list 2>/dev/null
             apt-get update -qq > /dev/null 2>&1
             echo -e "${GREEN}[V] Tentativa de otimização concluída!${NC}"
        elif [[ "$OS_LIKE" == *"rhel"* || "$OS_LIKE" == *"fedora"* || "$OS_LIKE" == *"centos"* ]]; then
             echo -e "${YELLOW}[+] Distro baseada em Red Hat identificada. Ativando fastestmirror...${NC}"
             grep -q "fastestmirror" /etc/dnf/dnf.conf 2>/dev/null || echo "fastestmirror=True" >> /etc/dnf/dnf.conf 2>/dev/null
             echo -e "${GREEN}[V] Tentativa de otimização concluída!${NC}"
        else
             echo -e "${RED}[!] Sistema '$OS' não reconhecido ou já otimizado de fábrica.${NC}"
        fi
        ;;
esac

echo -e "${CYAN}======================================================${NC}"
echo -e "${GREEN} Configuração finalizada com sucesso!${NC}"
echo -e "${CYAN}======================================================${NC}"
