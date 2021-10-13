#!/bin/bash

set -e

# Variables
DIR=`readlink -f .`;
PARENT_DIR=`readlink -f ${DIR}/..`;

export PLATFORM_VERSION=11
export ANDROID_MAJOR_VERSION=r
export CROSS_COMPILE=$PARENT_DIR/aarch64-linux-android-4.9/bin/aarch64-linux-android-
export CC=$PARENT_DIR/clang-4639204/bin/clang
export CLANG_TRIPLE=$PARENT_DIR/clang-4639204/bin/aarch64-linux-gnu-
export ARCH=arm64
export VARIANT=m31
KERNEL_MAKE_ENV=""

# Color
ON_BLUE=`echo -e "\033[44m"`	# On Blue
RED=`echo -e "\033[1;31m"`	# Red
BLUE=`echo -e "\033[1;34m"`	# Blue
GREEN=`echo -e "\033[1;32m"`	# Green
Under_Line=`echo -e "\e[4m"`	# Text Under Line
STD=`echo -e "\033[0m"`		# Text Clear

# Functions
pause(){
  read -p "${RED}$2${STD}Press ${BLUE}[Enter]${STD} key to $1..." fackEnterKey
}

function trap_ctrlc ()
{
    # exit shell script with error code 2
    # if omitted, shell script will continue execution
    exit 2
}

variant(){
  findconfig=""
  findconfig=($(ls arch/arm64/configs/afaneh_* 2>/dev/null))
  declare -i i=1
  shift 2
  for e in "${findconfig[@]}"; do
    echo "$i) $(basename $e | cut -d'_' -f2)"
    i=i+1
  done
  echo ""
  read -p "Select variant: " REPLY
  i="$REPLY"
  if [[ $i -gt 0 && $i -le ${#findconfig[@]} ]]; then
    export v="${findconfig[$i-1]}"
    export VARIANT=$(basename $v | cut -d'_' -f2)
    echo ${VARIANT} selected
    pause 'continue'
  else
    pause 'return to Main menu' 'Invalid option, '
    . $DIR/build_menu
  fi
}

toolchain(){
  if [ ! -d $PARENT_DIR/aarch64-linux-android-4.9 ]; then
    pause 'clone Toolchain aarch64-linux-android-4.9 cross compiler'
    git clone --branch android-9.0.0_r59 https://android.googlesource.com/platform/prebuilts/gcc/linux-x86/aarch64/aarch64-linux-android-4.9 $PARENT_DIR/aarch64-linux-android-4.9
    . $DIR/build_menu
  fi
}

clang(){
  if [ ! -d $PARENT_DIR/clang-4639204 ]; then
    pause 'clone Android Clang/LLVM Prebuilts'
    git clone https://github.com/mohammad92/prebuilts_clang_host_linux-x86_clang-4639204 $PARENT_DIR/clang-4639204
    . $DIR/build_menu
  fi
}

clean(){
  echo "${GREEN}***** Cleaning in Progress *****${STD}";
  make clean
  make mrproper
  [ -d "out" ] && rm -rf out
  echo "${GREEN}***** Cleaning Done *****${STD}";
}

build(){
  echo "${GREEN}***** Cleaning in Progress *****${STD}";
  make clean
  make mrproper
  [ -d "out" ] && rm -rf out

  echo "${GREEN}***** Compiling kernel *****${STD}"
  [ ! -d "out" ] && mkdir out
  make -j$(nproc) -C $(pwd) O=$(pwd)/out $KERNEL_MAKE_ENV exynos9610-m31snsxx_defconfig
  make -j$(nproc) -C $(pwd) O=$(pwd)/out $KERNEL_MAKE_ENV | tee log.txt

  [ -e out/arch/arm64/boot/Image.gz ] && cp out/arch/arm64/boot/Image.gz $(pwd)/out/Image.gz
  if [ -e out/arch/arm64/boot/Image ]; then
    cp out/arch/arm64/boot/Image $(pwd)/out/Image
  fi
}

anykernel3(){
  if [ ! -d $PARENT_DIR/AnyKernel3 ]; then
    pause 'clone AnyKernel3 - Flashable Zip Template'
    git clone https://github.com/osm0sis/AnyKernel3 $PARENT_DIR/AnyKernel3
  fi
  variant
  [ -e $PARENT_DIR/${VARIANT}_kernel.zip ] && rm $PARENT_DIR/${VARIANT}_kernel.zip
  if [ -e arch/arm64/boot/Image ]; then
    cp arch/arm64/boot/Image $PARENT_DIR/AnyKernel3/zImage
  elif [ -e arch/arm64/boot/Image.gz ]; then
    cp arch/arm64/boot/Image.gz $PARENT_DIR/AnyKernel3/zImage
  else
    pause 'return to Main menu' 'Build kernel first, '
  fi
  cd $PARENT_DIR/AnyKernel3
  git reset --hard
  sed -i "s/ExampleKernel by osm0sis/${VARIANT} kernel by afaneh92/g" anykernel.sh
  sed -i "s/=maguro/=${VARIANT}/g" anykernel.sh
  sed -i "s/=toroplus/=/g" anykernel.sh
  sed -i "s/=toro/=/g" anykernel.sh
  sed -i "s/=tuna/=/g" anykernel.sh
  sed -i "s/omap\/omap_hsmmc\.0\/by-name\/boot/13520000\.ufs\/by-name\/boot/g" anykernel.sh
  sed -i "s/backup_file/#backup_file/g" anykernel.sh
  sed -i "s/replace_string/#replace_string/g" anykernel.sh
  sed -i "s/insert_line/#insert_line/g" anykernel.sh
  sed -i "s/append_file/#append_file/g" anykernel.sh
  sed -i "s/patch_fstab/#patch_fstab/g" anykernel.sh
  zip -r9 $PARENT_DIR/${VARIANT}_kernel.zip * -x .git README.md *placeholder
  cd $DIR
  pause 'continue'
}

# Run once
toolchain
clang

# Show menu
show_menus(){
  clear
  echo "${ON_BLUE} B U I L D - M E N U ${STD}"
  echo "1. ${Under_Line}B${STD}uild"
  echo "2. ${Under_Line}C${STD}lean"
  echo "3. Make ${Under_Line}f${STD}lashable zip"
  echo "4. E${Under_Line}x${STD}it"
}

# Read input
read_options(){
  local choice
  read -p "Enter choice [ 1 - 4] " choice
  case $choice in
    1|b|B) build ;;
    2|c|C) clean ;;
    3|f|F) anykernel3;;
    4|x|X) exit 0;;
    *) pause 'return to Main menu' 'Invalid option, '
  esac
}

# initialise trap to call trap_ctrlc function
# when signal 2 (SIGINT) is received
trap "trap_ctrlc" 2

build