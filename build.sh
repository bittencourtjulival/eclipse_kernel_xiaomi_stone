#!/bin/bash

#
# This Bash script automates the process of building a custom kernel for any device using Clang.
# It packages the compiled kernel with AnyKernel3 and sends real-time updates via Telegram.
# USAGE : ./build.sh or bash build.sh
#
# Copyright (C) 2025 Amrita Das <bhabanidas431@gmail.com>
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation;
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, see <http://www.gnu.org/licenses/>.

echo "Do you want to include KernelSU? (y / n)"
read KernelSU

if [ "$KernelSU" = "y" ]; then
    echo "Build KernelSU Selected"
    curl -LSs "https://raw.githubusercontent.com/rifsxd/KernelSU-Next/next/kernel/setup.sh" | bash -s next
else
    echo "Build Non KernelSU Selected"
fi

# Set Kernel Build Variables
DEVICE_CODENAME="stone"  # Device codename (e.g., veux, garnet, etc.)
DEVICE_NAME="POCO X5 5G/Redmi Note 12 5G/Note 12R Pro"          # Device Market name (e.g., POCO X4 PRO 5G)
KERNEL_NAME="Eclipse"    # Kernel name
KERNEL_DEFCONFIG="${DEVICE_CODENAME}_defconfig"
ANYKERNEL3_DIR=$PWD/AnyKernel3/

if [ "$KernelSU" = "y" ]; then
    FINAL_KERNEL_ZIP="${KERNEL_NAME}-Kernel-KSU-${DEVICE_CODENAME}-$(date '+%Y%m%d').zip"
else
    FINAL_KERNEL_ZIP="${KERNEL_NAME}-Kernel-${DEVICE_CODENAME}-$(date '+%Y%m%d').zip"
fi

# Set Build Status (Change to "STABLE/TESTING" if needed)
BUILD_STATUS="STABLE"

# Get Hostname
BUILD_HOSTNAME=$(hostname)

# Set Compiler Path (Change if needed)
COMPILER_PATH="$HOME/clang-r547379/bin"

# Dynamically detect compiler name & version
if [ -d "$COMPILER_PATH" ]; then
    export PATH="$COMPILER_PATH:$PATH"
    COMPILER_NAME="$($COMPILER_PATH/clang --version | head -n 1 | sed -E 's/\(.*\)//' | awk '{$1=$1;print}')"
else
    COMPILER_NAME="Unknown Compiler"
fi

export ARCH=arm64
export KBUILD_BUILD_HOST=$BUILD_HOSTNAME
export KBUILD_BUILD_USER="Julival"
export KBUILD_COMPILER_STRING="$COMPILER_NAME"

# Telegram Bot Config
BOT_TOKEN="put telegram bot token"
CHAT_ID="put telegram channel/chat id"

# Function to send Telegram message
send_message() {
    curl -s -X POST "https://api.telegram.org/bot${BOT_TOKEN}/sendMessage" \
         -d "chat_id=${CHAT_ID}" \
         -d "parse_mode=MarkdownV2" \
         -d "text=$1"
}

# Clone Clang if not found
if ! [ -d "$HOME/clang-r547379" ]; then
    send_message "⚙️ Clang not found! Cloning..."
    if ! git clone -q https://gitlab.com/crdroidandroid/android_prebuilts_clang_host_linux-x86_clang-r547379.git -b 15.0 --depth=1 --single-branch ~/clang-r547379; then
        send_message "❌ Cloning failed! Aborting..."
        exit 1
    fi
fi

# Start Build Process
BUILD_START=$(date +"%s")
send_message "🔥 *${KERNEL_NAME} Kernel Build Started\!*
📱 *Device:* \`${DEVICE_NAME} (${DEVICE_CODENAME})\`
🖥 *Building on:* \`$(hostname)\`
⚙️ *Compiler:* \`${COMPILER_NAME}\`
🔰 *Build Status:*   \`${BUILD_STATUS}\`"

# Clean previous builds
make O=out clean

# Set Defconfig
make $KERNEL_DEFCONFIG O=out

# Compile Kernel
make -j$(nproc) O=out \
                ARCH=arm64 \
                CC=clang \
                CLANG_TRIPLE=aarch64-linux-gnu- \
                CROSS_COMPILE=aarch64-linux-gnu- \
                CROSS_COMPILE_ARM32=arm-linux-gnueabi- \
                LD=ld.lld \
                LLVM=1 \
                LLVM_IAS=1

# Check for compiled files
if [ ! -f "$PWD/out/arch/arm64/boot/Image" ]; then
    send_message "❌ Build failed! Image not found."
    exit 1
fi

send_message "✅ *${KERNEL_NAME} Kernel built successfully\!* Zipping files..."

# Move files to AnyKernel3 )
rm -rf $ANYKERNEL3_DIR/Image $ANYKERNEL3_DIR/dtbo.img $ANYKERNEL3_DIR/dtb
cp $PWD/out/arch/arm64/boot/Image $ANYKERNEL3_DIR/
cp $PWD/out/arch/arm64/boot/dtbo.img $ANYKERNEL3_DIR/
cp $PWD/out/arch/arm64/boot/dtb.img $ANYKERNEL3_DIR/dtb

# Zip Kernel
cd $ANYKERNEL3_DIR/
zip -r9 "../$FINAL_KERNEL_ZIP" * -x README $FINAL_KERNEL_ZIP

# Upload Kernel to Telegram
send_message "📤 Uploading ${KERNEL_NAME} Kernel zip..."
curl -F chat_id="$CHAT_ID" \
     -F document=@"../$FINAL_KERNEL_ZIP" \
     -F parse_mode="MarkdownV2" \
     -F caption="✅ *${KERNEL_NAME} Kernel for ${DEVICE_CODENAME} ${DEVICE_NAME}*
🖥️ *Built on:* \`${BUILD_HOSTNAME}\`
⚙️ *Compiler:* \`${COMPILER_NAME}\`
🔰 *Build Status:* \`${BUILD_STATUS}\`" \
     "https://api.telegram.org/bot$BOT_TOKEN/sendDocument"

BUILD_END=$(date +"%s")
BUILD_TIME=$((BUILD_END - BUILD_START))

send_message "🚀 ${KERNEL_NAME} Kernel build completed in $(($BUILD_TIME / 60)) min $(($BUILD_TIME % 60)) sec"

# Clean up
rm -rf out/
rm -rf $ANYKERNEL3_DIR/Image $ANYKERNEL3_DIR/dtbo.img $ANYKERNEL3_DIR/dtb

exit 0

