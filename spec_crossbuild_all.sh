#!/bin/bash -vx
# build rpm packages by cross-compiler
# Liu Yang <yang.liu.sn@gmail.com>
# Fu Wei <tekkamanninja@gmail.com>

BUILD_NAME=`basename ${1}`
if [ "${BUILD_NAME##*.}x" != "specx" ]
	echo "${1} is not a SPEC file !"
	exit 1
fi
if [ -f "${1}" ]
	echo "Missing SPEC file !"
	exit 1
fi
SPEC_FILE=${1}

CONFIG_DIR=`pwd`/configs
. ${CONFIG_DIR}/config.conf

rpmbuild --target=${TARGET_PLATFORM} \
	${RPM_BOOTSTRAP_OPTS} \
	${RPM_UNDEFINE_OPTS} \
	${RPM_CLEAN_OPTS} \
	${RPM_OTHER_OPTS} \
	-ba \
	${SPEC_FILE} \
	2>&1 | tee ${LOGFILE}

#SPEC_FILE=rpmbuild/SPECS/${PKG_NAME}.spec
