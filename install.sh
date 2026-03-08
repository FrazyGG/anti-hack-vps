#!/bin/bash
# ==============================================
# ANTI-HACK VPS INSTALLER
# ==============================================
# Cara pakai:
# curl -s https://raw.githubusercontent.com/USERNAME/anti-hack-vps/main/install.sh | bash
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

# Cek curl/wget
if ! command -v curl &> /dev/null; then
    echo -e "${YELLOW}📦 Menginstall curl...${NC}"
    apt-get update -qq && apt-get install curl -y -qq
fi

# Tentukan direktori install
INSTALL_DIR="/opt/anti-hack-vps"
mkdir -p $INSTALL_DIR

echo -e "${YELLOW}📥 Mendownload script dari GitHub...${NC}"

# Download file utama
curl -s -o $INSTALL_DIR/anti-hack-manager.sh https://raw.githubusercontent.com/USERNAME/anti-hack-vps/main/anti-hack-manager.sh

# Cek download berhasil
if [ ! -f "$INSTALL_DIR/anti-hack-manager.sh" ]; then
    echo -e "${RED}❌ Gagal mendownload script!${NC}"
    exit 1
fi

# Beri izin execute
chmod +x $INSTALL_DIR/anti-hack-manager.sh

# Buat symlink di /usr/local/bin
ln -sf $INSTALL_DIR/anti-hack-manager.sh /usr/local/bin/anti-hack

echo -e "${GREEN}✅ Installasi selesai!${NC}"
echo ""
echo -e "${YELLOW}📌 Cara menggunakan:${NC}"
echo "   ketik: ${GREEN}anti-hack${NC}  (dari mana saja)"
echo ""
echo -e "${CYAN}Menjalankan Anti-Hack Manager...${NC}"
sleep 2

# Jalankan script
$INSTALL_DIR/anti-hack-manager.sh
