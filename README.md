# 🚀 Otimizador Universal de Repositórios BR (repo.sh)

Um script Bash simples e rápido para otimizar os gerenciadores de pacotes de diversas distribuições Linux, forçando a utilização de espelhos (mirrors) localizados no **Brasil**. 

Isso garante downloads muito mais rápidos na hora de instalar pacotes e atualizar o seu servidor ou máquina local.

## 🎯 Por que usar?
Ao instalar uma distribuição Linux, muitas vezes os repositórios padrão apontam para servidores nos Estados Unidos ou na Europa. Isso causa lentidão nos downloads (via `apt`, `dnf`, `pacman`, etc.). Este script detecta automaticamente o seu sistema operacional e faz a troca cirúrgica para os melhores mirrors brasileiros oficiais (como os da USP, UFPR, entre outros).

## 🛠️ Sistemas Suportados

O script reconhece e otimiza automaticamente as seguintes famílias de distribuições:

* **Debian-based:** Debian, Ubuntu, Linux Mint, Pop!_OS, Kali, Parrot.
* **RHEL-based:** CentOS, Rocky Linux, AlmaLinux, RHEL, Fedora (Ativa o `fastestmirror`).
* **Arch-based:** Arch Linux, Manjaro, EndeavourOS.
* **Alpine Linux**
* *openSUSE / SLES* (Apenas verifica, pois já possuem redirecionamento inteligente nativo).

## ⚡ Como Usar

Você pode baixar e executar o script com um único comando no seu terminal. 

**Requisito:** É necessário rodar como `root` (ou usando `sudo`), pois o script altera arquivos de configuração do sistema localizados em `/etc/`.

### Opção 1: Rodar direto via cURL (Mais rápido)
```bash
bash <(curl -s https://raw.githubusercontent.com/DoutorLouness/mudar-repositorio/main/repo.sh)
