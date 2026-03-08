#!/bin/bash
# ==============================================
# ANTI-HACK VPS MANAGER - UBUNTU 24
# ==============================================
# File: /opt/anti-hack-vps/anti-hack-manager.sh
# ==============================================

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

VERSION="2.0"
INSTALL_DIR="/opt/anti-hack-vps"
BACKUP_DIR="/root/anti-hack-backup"

# ==============================================
# CEK ROOT
# ==============================================
cek_root() {
    if [ "$EUID" -ne 0 ]; then
        echo -e "${RED}❌ Error: Script ini harus dijalankan sebagai root!${NC}"
        echo "   Jalankan: sudo su -"
        exit 1
    fi
}

# ==============================================
# CEK OS
# ==============================================
cek_os() {
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        OS=$ID
        VER=$VERSION_ID
        if [ "$OS" != "ubuntu" ]; then
            echo -e "${RED}❌ Script ini khusus untuk Ubuntu!${NC}"
            exit 1
        fi
    fi
}

# ==============================================
# BACKUP
# ==============================================
buat_backup() {
    echo -e "${YELLOW}💾 Membuat backup...${NC}"
    TIMESTAMP=$(date +%Y%m%d_%H%M%S)
    BACKUP_PATH="${BACKUP_DIR}/backup-${TIMESTAMP}"
    mkdir -p "$BACKUP_PATH"
    
    cp /etc/hosts "$BACKUP_PATH/hosts.backup" 2>/dev/null
    iptables-save > "$BACKUP_PATH/iptables.backup" 2>/dev/null
    
    echo -e "${GREEN}✓ Backup: $BACKUP_PATH${NC}"
    echo "$BACKUP_PATH" > /tmp/last_backup
}

# ==============================================
# INSTALL PROTEKSI
# ==============================================
install_proteksi() {
    clear
    echo -e "${GREEN}╔════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║         INSTALL PROTEKSI              ║${NC}"
    echo -e "${GREEN}╚════════════════════════════════════════╝${NC}"
    
    cek_root
    cek_os
    buat_backup
    
    echo -e "\n${YELLOW}[1/4] Menginstall dependensi...${NC}"
    apt-get update -qq
    apt-get install -y iptables iptables-persistent curl wget -qq
    
    echo -e "${YELLOW}[2/4] Memblokir metadata...${NC}"
    iptables -F OUTPUT 2>/dev/null
    iptables -A OUTPUT -d 169.254.169.254 -j DROP
    iptables -A OUTPUT -d metadata.google.internal -j DROP
    
    echo -e "${YELLOW}[3/4] Memblokir IP checker...${NC}"
    for d in ifconfig.me api.ipify.org ipinfo.io icanhazip.com; do
        iptables -A OUTPUT -d $d -j DROP 2>/dev/null
    done
    
    echo -e "${YELLOW}[4/4] DNS Spoofing...${NC}"
    cp /etc/hosts /etc/hosts.bak
    echo "" >> /etc/hosts
    echo "# ANTI-HACK PROTEKSI" >> /etc/hosts
    echo "127.0.0.1 169.254.169.254" >> /etc/hosts
    echo "127.0.0.1 metadata.google.internal" >> /etc/hosts
    echo "127.0.0.1 ifconfig.me" >> /etc/hosts
    
    netfilter-persistent save
    
    echo ""
    echo -e "${GREEN}✅ PROTEKSI TERINSTALL${NC}"
    echo ""
    echo -n "Test metadata: "
    timeout 2 curl -s -I http://169.254.169.254/latest/meta-data/ > /dev/null 2>&1 && echo -e "${RED}❌ GAGAL${NC}" || echo -e "${GREEN}✓ OK${NC}"
}

# ==============================================
# UNINSTALL PROTEKSI
# ==============================================
uninstall_proteksi() {
    clear
    echo -e "${RED}╔════════════════════════════════════════╗${NC}"
    echo -e "${RED}║         UNINSTALL PROTEKSI            ║${NC}"
    echo -e "${RED}╚════════════════════════════════════════╝${NC}"
    
    cek_root
    
    echo -e "${YELLOW}Yakin uninstall? (y/n): ${NC}"
    read confirm
    [ "$confirm" != "y" ] && return
    
    buat_backup
    
    echo -e "\n${YELLOW}Menghapus firewall rules...${NC}"
    iptables -D OUTPUT -d 169.254.169.254 -j DROP 2>/dev/null
    iptables -D OUTPUT -d metadata.google.internal -j DROP 2>/dev/null
    
    echo -e "${YELLOW}Mengembalikan hosts file...${NC}"
    [ -f /etc/hosts.bak ] && cp /etc/hosts.bak /etc/hosts
    
    netfilter-persistent save
    
    echo -e "${GREEN}✅ PROTEKSI DIHAPUS${NC}"
}

# ==============================================
# CEK STATUS
# ==============================================
cek_status() {
    clear
    echo -e "${BLUE}╔════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║         STATUS PROTEKSI               ║${NC}"
    echo -e "${BLUE}╚════════════════════════════════════════╝${NC}"
    
    echo ""
    echo -n "Metadata: "
    timeout 2 curl -s -I http://169.254.169.254/latest/meta-data/ > /dev/null 2>&1 && echo -e "${RED}TIDAK TERPROTEKSI${NC}" || echo -e "${GREEN}TERPROTEKSI${NC}"
    
    echo -n "IP Checker: "
    timeout 2 curl -s -I https://ifconfig.me > /dev/null 2>&1 && echo -e "${RED}TIDAK TERPROTEKSI${NC}" || echo -e "${GREEN}TERPROTEKSI${NC}"
    
    echo -n "Firewall: "
    iptables -L OUTPUT -v 2>/dev/null | grep -q "169.254.169.254" && echo -e "${GREEN}AKTIF${NC}" || echo -e "${RED}TIDAK AKTIF${NC}"
    
    echo ""
    echo -e "${CYAN}Tekan Enter...${NC}"
    read
}

# ==============================================
# LIHAT BACKUP
# ==============================================
lihat_backup() {
    clear
    echo -e "${CYAN}╔════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║         DAFTAR BACKUP                 ║${NC}"
    echo -e "${CYAN}╚════════════════════════════════════════╝${NC}"
    
    if [ -d "$BACKUP_DIR" ]; then
        ls -la $BACKUP_DIR | grep backup-
    else
        echo "Belum ada backup"
    fi
    
    echo ""
    echo -e "${CYAN}Tekan Enter...${NC}"
    read
}

# ==============================================
# MENU UTAMA
# ==============================================
menu() {
    while true; do
        clear
        echo -e "${CYAN}"
        echo "╔════════════════════════════════════════╗"
        echo "║     ANTI-HACK VPS MANAGER v$VERSION     ║"
        echo "║         Ubuntu 24 Support              ║"
        echo "╠════════════════════════════════════════╣"
        echo "║                                        ║"
        echo "║  ${GREEN}[1]${NC} 🔒 INSTALL Proteksi            ║"
        echo "║  ${RED}[2]${NC} 🔓 UNINSTALL Proteksi          ║"
        echo "║  ${BLUE}[3]${NC} 📊 CEK Status                 ║"
        echo "║  ${CYAN}[4]${NC} 📁 Lihat Backup               ║"
        echo "║  ${RED}[0]${NC} 🚪 Keluar                      ║"
        echo "║                                        ║"
        echo "╚════════════════════════════════════════╝${NC}"
        echo ""
        echo -n "Pilih menu: "
        read pilihan
        
        case $pilihan in
            1) install_proteksi ;;
            2) uninstall_proteksi ;;
            3) cek_status ;;
            4) lihat_backup ;;
            0) echo "Terima kasih!"; exit 0 ;;
            *) echo "Pilihan salah!"; sleep 1 ;;
        esac
    done
}

# Jalankan menu
menu
