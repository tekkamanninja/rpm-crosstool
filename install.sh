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
PLATFORM_INSTALL_SH=${ARCH_INSTALL_DIR}/install.sh

BACKUP_DIR=${ARCH_INSTALL_BACKUP_DIR}/`date +%Y%m%d%H%M%S`
BACKUP_VENDOR_DIR=${BACKUP_DIR}/${VENDOR}

RPM_CONFIG_DIR=`rpm -E '%{_rpmconfigdir}'`
RPM_VENDOR_CONFIG_DIR=${RPM_CONFIG_DIR}/${VENDOR}
RPM_PLATFORM_CONFIG_DIR=$RPM_CONFIG_DIR/platform/${TARGET_ARCH}-linux

echo 'Preparing cross build rpm environment...'
#sudo dnf -y group install 'Development Tools'
#sudo dnf -y group install 'RPM Development Tools'

if [ -d ${AUTOCONF_DIR} ]; then
#backup original config.* file, then install
	mkdir -p ${BACKUP_VENDOR_DIR}
	for config_file in `ls ${AUTOCONF_DIR}`; do
		cp -vif ${RPM_CONFIG_DIR}/${config_file} ${BACKUP_DIR}/
		cp -vif ${RPM_VENDOR_CONFIG_DIR}/${config_file} \
			${BACKUP_VENDOR_DIR}/

		sudo cp -vif ${AUTOCONF_DIR}/${config_file} ${RPM_CONFIG_DIR}/
		sudo cp -vif ${AUTOCONF_DIR}/${config_file} \
			${RPM_VENDOR_CONFIG_DIR}/
	done
fi
if [ -d ${RPMCONF_DIR} ]; then
	cp -vif ${RPMCONF_DIR}/rpmrc $HOME/.rpmrc
	cp -vif ${RPMCONF_DIR}/rpmmacros $HOME/.rpmmacros
fi

if [ -d ${PLATFORMCONF_DIR} ]; then
	sudo mkdir -p ${RPM_PLATFORM_CONFIG_DIR}
	sudo cp -vi ${PLATFORMCONF_DIR}/* ${RPM_PLATFORM_CONFIG_DIR}
fi

if [ -f ${PLATFORM_INSTALL_SH} ]
then
	sh ${PLATFORM_INSTALL_SH}
fi

mkdir -p ${BUILD_LOG_DIR}
mkdir -p ${SYSROOT_DIR}
echo "Please put sysroot to ${SYSROOT_DIR}."
echo "And make softlink /usr/${TOOL_PREFIX}/sysroot to it."

echo "Environment for cross rpm building finished."

