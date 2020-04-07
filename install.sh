#!/bin/bash
# build rpm packages by cross-compiler, install script
# Liu Yang <yang.liu.sn@gmail.com>
# Fu Wei <tekkamanninja@gmail.com>

CONFIG_DIR=`pwd`/configs
. ${CONFIG_DIR}/config.conf

ARCH_INSTALL_DIR=${CROSSBUILD_DIR}/install/${TARGET_ARCH}
ARCH_INSTALL_BACKUP_DIR=${CROSSBUILD_DIR}/install/${TARGET_ARCH}/backup

AUTOCONF_DIR=${ARCH_INSTALL_DIR}/autoconf
RPMCONF_DIR=${ARCH_INSTALL_DIR}/rpm
PLATFORMCONF_DIR=${ARCH_INSTALL_DIR}/platform
CMAKE_DIR=${ARCH_INSTALL_DIR}/cmake
MESON_DIR=${ARCH_INSTALL_DIR}/meson
PLATFORM_INSTALL_SH=${ARCH_INSTALL_DIR}/install.sh

BACKUP_DIR=${ARCH_INSTALL_BACKUP_DIR}/`date +%Y%m%d%H%M%S`
BACKUP_VENDOR_DIR=${BACKUP_DIR}/${VENDOR}

RPM_CONFIG_HOST_DIR=/usr/lib/rpm
RPM_VENDOR_CONFIG_HOST_DIR=${RPM_CONFIG_HOST_DIR}/${VENDOR}
#RPM_PLATFORM_CONFIG_HOST_DIR=$RPM_CONFIG_HOST_DIR/platform/${TARGET_ARCH}-linux

#RPM_CONFIG_CROSS_DIR=${ARCH_CONDIF_DIR}/rpm.${TARGET_ARCH}
RPM_CONFIG_CROSS_DIR=/usr/lib/rpm.${TARGET_ARCH}
RPM_VENDOR_CONFIG_CROSS_DIR=${RPM_CONFIG_CROSS_DIR}/${VENDOR}
RPM_PLATFORM_CONFIG_CROSS_DIR=${RPM_CONFIG_CROSS_DIR}/platform/${TARGET_ARCH}-linux
RPM_MACROS_D_CONFIG_CROSS_DIR=${RPM_CONFIG_CROSS_DIR}/macros.d
#`rpm -E '%{_rpmconfigdir}'`

echo 'Preparing cross build rpm environment...'
#sudo dnf -y group install 'Development Tools'
#sudo dnf -y group install 'RPM Development Tools'

#import the original rpm config from Host
DATE_SUBFIX=`date +%Y%m%d%H%M%S`

pushd /usr/lib
if [ ! -L rpm ]; then
	sudo mv rpm rpm.host
	sudo ln -s rpm.host rpm
fi

if [ -d rpm.${TARGET_ARCH} ]; then
	mkdir ${ARCH_INSTALL_BACKUP_DIR}/rpm.${DATE_SUBFIX}
	mv rpm.${TARGET_ARCH}/* ${ARCH_INSTALL_BACKUP_DIR}/rpm.${DATE_SUBFIX}/
else
	sudo mkdir -m 777 rpm.${TARGET_ARCH}
fi

cp -vrf rpm.host/* rpm.${TARGET_ARCH}/

if [ -L rpm ]; then
	sudo rm rpm
fi
sudo ln -s rpm.${TARGET_ARCH} rpm

popd

#overwrite the arch config for cross build
if [ -d ${AUTOCONF_DIR} ]; then
	for config_file in `ls ${AUTOCONF_DIR}`; do
		cp -vf ${AUTOCONF_DIR}/${config_file} \
			${RPM_CONFIG_CROSS_DIR}/
		cp -vf ${AUTOCONF_DIR}/${config_file} \
			${RPM_VENDOR_CONFIG_CROSS_DIR}/
	done
fi
if [ -d ${PLATFORMCONF_DIR} ]; then
	mkdir -p ${RPM_PLATFORM_CONFIG_CROSS_DIR}
	cp -vf ${PLATFORMCONF_DIR}/* ${RPM_PLATFORM_CONFIG_CROSS_DIR}
fi

if [ -d ${RPMCONF_DIR} ]; then
	cp -vf ${RPMCONF_DIR}/rpmrc $HOME/.rpmrc
	cp -vf ${RPMCONF_DIR}/rpmmacros $HOME/.rpmmacros
#	echo "%_rpmconfigdir $HOME/configs/csky/rpm" >> $HOME/.rpmmacros
fi

if [ -f ${PLATFORM_INSTALL_SH} ]
then
	sh ${PLATFORM_INSTALL_SH}
fi

mkdir -p ${RPM_MACROS_D_CONFIG_CROSS_DIR}
#overwrite the arch config for cross cmake
if [ -d ${CMAKE_DIR} ]; then
	cp -vf ${CMAKE_DIR}/* ${RPM_MACROS_D_CONFIG_CROSS_DIR}
fi
#overwrite the arch config for cross meson
if [ -d ${MESON_DIR} ]; then
	cp -vf ${MESON_DIR}/* ${RPM_MACROS_D_CONFIG_CROSS_DIR}
fi

mkdir -p ${BUILD_LOG_DIR}
mkdir -p ${SYSROOT_DIR}
echo "Please put sysroot to ${SYSROOT_DIR}."
echo "And make softlink /usr/${TOOL_PREFIX}/sysroot to it."

echo "Environment for cross rpm building finished."

