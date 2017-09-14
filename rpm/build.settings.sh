#!/bin/bash

# Common settings script.

YAJLVERSION=2.1.1
BUILDDIR=~/rpmbuild
ARCH=`uname -p`
YAJL_GIT_URL=https://github.com/SCDependencies/yajl.git

WGETOPTIONS="--no-check-certificate"
RPMOPTIONS="-ivh --force"


