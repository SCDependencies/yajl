#!/bin/bash

# Amazon Linux preparation script.

CPWD=`pwd`

. ./common.pre.build.sh

cd ${CPWD}

# Platform file

echo "amzn1" > ${BUILDDIR}/platform

cd ${CPWD}
