#!/bin/bash

CPWD=`pwd`

. ./build.settings.sh

# YAJL

cd ${BUILDDIR}/tmp
rm -rf yajl-${YAJLVERSION}
git clone ${YAJL_GIT_URL} --branch ${YAJLVERSION} yajl-${YAJLVERSION}
ER=$?
if ! [ ${ER} -eq 0 ] ; then
    git clone ${YAJL_GIT_URL} yajl-${YAJLVERSION}
    ER=$?
    if ! [ ${ER} -eq 0 ] ; then
	cd ${CPWD}
	exit -1
    fi
fi

cd yajl-${YAJLVERSION}
rm -fR .git
cd ..

tar zcf ${BUILDDIR}/SOURCES/yajl-${YAJLVERSION}.tar.gz yajl-${YAJLVERSION}
ER=$?
if ! [ ${ER} -eq 0 ] ; then
    cd ${CPWD}
    exit -1
fi

rpmbuild -ta ${BUILDDIR}/SOURCES/yajl-${YAJLVERSION}.tar.gz
ER=$?
if ! [ ${ER} -eq 0 ] ; then
    cd ${CPWD}
    exit -1
fi

# Make binary tarball

cd ${BUILDDIR}/RPMS/${ARCH}
mkdir -p di
mv *debuginfo* di
mv *devel* di
rm -rf yajl-${YAJLVERSION}
mkdir yajl-${YAJLVERSION}
mv *.rpm yajl-${YAJLVERSION}/

PLATFORM=`cat ${BUILDDIR}/platform`

tar cvfz yajl-${YAJLVERSION}-${PLATFORM}-${ARCH}.tar.gz yajl-${YAJLVERSION}

cd ${CPWD}
