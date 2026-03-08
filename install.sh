#!/bin/bash
# ==============================================
# ANTI-HACK VPS INSTALLER
# ==============================================
# Cara pakai:
# curl -s https://raw.githubusercontent.com/FrazyGG/anti-hack-vps/main/install.sh | bash
# ==============================================

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${GREEN}"
echo "╔════════════════════════════════════════════════════╗"
echo "║         ANTI-HACK VPS INSTALLER                   ║"
echo "║         Proteksi Metadata & IP Publik             ║"
echo "╚════════════════════════════════════════════════════╝"
echo -e "${NC}"

# Cek root
if [ "$EUID" -ne 0 ]; then
    echo -e "${RED}❌ Error: Jalankan sebagai root!${NC}"
    echo "   sudo su -"
    exit 1
fi

# GANTI DENGAN USERNAME GITHUB KAMU
GITHUB_USER="ahmad62626"
REPO_NAME="anti-hack-vps"
BRANCH="main"

# Install curl jika belum ada
if ! command -v curl &> /dev/null; then
    echo -e "${YELLOW}📦 Menginstall curl...${NC}"
    apt-get update -qq && apt-get install curl -y -qq
fi

# Tentukan direktori install
INSTALL_DIR="/usr/local/bin"

echo -e "${YELLOW}📥 Mendownload script dari GitHub...${NC}"

# Download file utama
curl -s -o $INSTALL_DIR/anti-hack https://raw.githubusercontent.com/${GITHUB_USER}/${REPO_NAME}/${BRANCH}/anti-hack-manager.sh

# Cek download berhasil
if [ ! -f "$INSTALL_DIR/anti-hack" ]; then
    echo -e "${RED}❌ Gagal mendownload script!${NC}"
    echo "   Cek: https://github.com/${GITHUB_USER}/${REPO_NAME}"
    exit 1
fi

# Beri izin execute
chmod +x $INSTALL_DIR/anti-hack

echo -e "${GREEN}✅ Installasi selesai!${NC}"
echo ""
echo -e "${YELLOW}📌 Cara menggunakan:${NC}"
echo "   ketik: ${GREEN}anti-hack${NC}  (dari mana saja)"
echo ""
echo -e "${CYAN}Menjalankan Anti-Hack Manager...${NC}"
sleep 2

# Jalankan script
anti-hack
