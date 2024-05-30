#!/bin/bash

# Functions for colored output
function info {
    echo -e "\e[1;34m$1\e[0m"
}

function success {
    echo -e "\e[1;32m$1\e[0m"
}

function warning {
    echo -e "\e[1;33m$1\e[0m"
}

function error {
    echo -e "\e[1;31m$1\e[0m"
}

function progress_bar {
    local duration=$1
    already_done() { for ((done=0; done<$elapsed; done++)); do echo -n "#"; done }
    remaining() { for ((remain=$elapsed; remain<$duration; remain++)); do echo -n "."; done }
    percentage() { echo -n "($((elapsed*100/duration))%)"; }

    for ((elapsed=1; elapsed<=$duration; elapsed++)); do
        already_done; remaining; percentage
        sleep 1
        echo -ne "\r"
    done
    echo
}

# ASCII Banner
success "
 +----------------------------------------------------+   
 | INFO     | TERMUX DANA INSTALLER                   . 
 +----------------------------------------------------+   
   ____    _    _   _    _            
  |  _ \  / \  | \ | |  / \           
  | | | |/ _ \ |  \| | / _ \          
  | |_| / ___ \| |\  |/ ___ \         
  |____/_/   \_\_| \_/_/   \_\        
          Installer                   
"

# Pesan informasi
info "Starting Installation Frida"
info "Author: KN"
info "DANA"

info "Mengubah sumber repositori..."
cat <<EOF > $PREFIX/etc/apt/sources.list
deb https://mirror.imtaqin.id/termux-main stable main
deb https://mirror.imtaqin.id/termux-root root stable
deb https://mirror.imtaqin.id/termux-x11 x11 main
EOF
apt update -y
# Memperbarui paket-paket dan meng-upgrade
info "Memperbarui paket-paket..."
# Memeriksa arsitektur CPU
ARCH=$(getprop ro.product.cpu.abi)
info "Arsitektur yang Terdeteksi: $ARCH"


pkg install tur-repo -y
pkg update -y 
pkg install python3.9 -y
ln -s python3.9 $PREFIX/bin/python
ln -s $PREFIX/bin/pip3.9 $PREFIX/bin/pip

pkg install build-essential git wget binutils openssl libandroid-glob -y

# Memilih URL sesuai arsitektur
case "$ARCH" in
    "armeabi-v7a")
        FRIDA_URL="https://github.com/frida/frida/releases/download/16.2.1/frida-core-devkit-16.2.1-android-arm.tar.xz"
        ;;
    "arm64-v8a")
        FRIDA_URL="https://github.com/frida/frida/releases/download/16.2.1/frida-core-devkit-16.2.1-android-arm64.tar.xz"
        ;;
    "x86_64")
        FRIDA_URL="https://github.com/frida/frida/releases/download/16.2.1/frida-core-devkit-16.2.1-android-x86_64.tar.xz"
        ;;
    *)
        error "Arsitektur CPU tidak didukung: $ARCH"
        exit 1
        ;;
esac

# Mengunduh devkit Frida core
info "Mengunduh devkit Frida core..."
wget $FRIDA_URL -O /sdcard/devkit.tar.xz

# Menyiapkan penyimpanan Termux
info "Menyiapkan penyimpanan Termux..."
termux-setup-storage
sleep 5

mkdir -p /sdcard/devkit

info "Ekstrak devkit..."
tar -xf /sdcard/devkit.tar.xz -C /sdcard/devkit/

# Mengatur variabel lingkungan
export FRIDA_CORE_DEVKIT=/sdcard/devkit/


# Menginstal frida dan frida-tools dengan opsi untuk menghindari error
info "Menginstal frida dan frida-tools..."

pip install frida==16.2.1 frida-tools==12.3.0
success "Instalasi Frida selesai."

# Memeriksa keberadaan Git
if ! command -v git &> /dev/null; then
    warning "Git tidak ditemukan, sedang menginstal..."
    pkg install git -y
else
    success "Git sudah terpasang."
fi

# Memasang Node.js
info "Menginstal Node.js..."
pkg install nodejs -y

# Mengunduh dana-sheet
info "Mengunduh dana-sheet..."
wget https://installer.imtaqin.id/files/pushdana.zip

info "Ekstrak dana-sheet..."
mkdir pushdana
unzip pushdana.zip -d pushdana

info "Menjalankan dana-sheet..."
cd pushdana
npm install
node index.js

# Menambahkan script ke .bashrc
info "Menambahkan Frida ke .bashrc..."
echo "export FRIDA_CORE_DEVKIT=/sdcard/devkit/" >> ~/.bashrc

success "Proses selesai."
success "Silakan restart Termux untuk memulai Frida secara otomatis."
exit 0
