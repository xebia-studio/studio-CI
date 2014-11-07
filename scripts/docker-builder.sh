#!/bin/sh

DOCKER_DIR=./$(dirname $0)/../docker
function usage {
    echo $(basename $0) CONTAINER [--push];
}

function dlcache() {
    if [ ! -d cache ];then
        mkdir cache
    fi
    if [ ! -f cache/$2 ];then
        curl $1 -o cache/$2
    fi
}

if [ $# -lt 1 ];then
    usage
    exit 1
fi

CONTAINER=$1
echo $DOCKER_DIR/$CONTAINER
if [ ! -d $DOCKER_DIR/$CONTAINER ];then
    echo $CONTAINER does not exist
    exit 2
fi

cd $DOCKER_DIR/$CONTAINER

VERSION=$(grep "# VERSION" Dockerfile | awk '{print $3}')

# Prebuild
echo Pre building $CONTAINER:$VERSION
if [ -d prebuild ];then
    for SCRIPT in $(ls prebuild);do
        . prebuild/$SCRIPT
    done
fi

# Build
echo Building $CONTAINER:$VERSION
#docker build -t $CONTAINER:$VERSION . || exit 3

# Postbuild
echo Post buildig $CONTAINER:$VERSION
if [ -d postbuild ];then
    for SCRIPT in $(ls postbuild);do
        /bin/sh postbuild/$SCRIPT
    done
fi

if [ SHOULD_PUSH == 1 ];then
    docker push -t $CONTAINER:$VERSION || exit 4
fi
