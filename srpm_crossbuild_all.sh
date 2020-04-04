#!/bin/bash -vx
# build rpm packages by cross-compiler
# Liu Yang <yang.liu.sn@gmail.com>
# Fu Wei <tekkamanninja@gmail.com>

BUILD_NAME=`basename ${1}`
if [ "${BUILD_NAME##*.src.}x" != "rpmx" ]; then
	echo "${1} is not a SRPM file !"
	exit 1
fi
if [ ! -f "${1}" ]; then
	echo "Missing SRPM file !"
	exit 1
fi
SRPM_FILE=${1}

CONFIG_DIR=`pwd`/configs
. ${CONFIG_DIR}/config.conf

rpmbuild --target=${TARGET_PLATFORM} \
	${RPM_BOOTSTRAP_OPTS} \
	${RPM_UNDEFINE_OPTS} \
	${RPM_CLEAN_OPTS} \
	${RPM_OTHER_OPTS} \
	-ra \
	${SRPM_FILE} \
	2>&1 | tee ${LOGFILE}

