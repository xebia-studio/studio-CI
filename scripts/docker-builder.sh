#!/bin/sh

WORKSPACE=$(cd $(dirname $0);cd ..; pwd)
DOCKER_DIR=$WORKSPACE/docker
CACHE_DIR=cache
function usage {
    echo $(basename $0) CONTAINER [--push];
}

function dlcache() {
    if [ ! -d $CACHE_DIR ];then
        mkdir -p $CACHE_DIR
    fi

    if [ $# -gt 1 ];then
        DEST=$2
    else
        DEST=$(basename $1)
    fi

    if [ $SHOULD_CACHE == 0 ] || [ ! -f $CACHE_DIR/$DEST ];then
        echo Downloading $DEST
        curl -L $1 -o $CACHE_DIR/$DEST
    fi

    if [ $# -eq 3 ];then
        echo "$3  $CACHE_DIR/$2" > $CACHE_DIR/$2.sha1
        shasum -s -c $CACHE_DIR/$2.sha1
    fi
}

function header() {
#    echo "~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~"
    echo "o $1"
#    echo "~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~"
}

if [ $# -lt 1 ];then
    usage
    exit 1
fi

# Parameters
CONTAINER=$1
SHOULD_CACHE=1
SHOULD_BUILD=1
SHOULD_PUSH=0
while (( "$#" )); do
    if [ "$1" == "--push" ]; then
        SHOULD_PUSH=1
    fi
    if [ "$1" == "--push-only" ]; then
        SHOULD_PUSH=1
        SHOULD_BUILD=1
    fi
    if [ "$1" == "--no-cache" ]; then
        SHOULD_CACHE=0
    fi
    shift
done

if [ ! -d $DOCKER_DIR/$CONTAINER ];then
    echo $CONTAINER does not exist
    exit 2
fi

cd $DOCKER_DIR/$CONTAINER
VERSION=$(grep "# VERSION" Dockerfile | awk '{print $3}')

if [ $SHOULD_BUILD == 1 ];then
    header "Pre building $CONTAINER:$VERSION"
    if [ -d prebuild ];then
        for SCRIPT in $(ls prebuild);do
            echo "- $SCRIPT"
            . prebuild/$SCRIPT
        done
    fi

    header "Building $CONTAINER:$VERSION"
    docker build -t $CONTAINER:$VERSION . || exit 3

    header "Post building $CONTAINER:$VERSION"
    if [ -d postbuild ];then
        for SCRIPT in $(ls postbuild);do
            echo $SCRIPT
            . postbuild/$SCRIPT
        done
    fi
fi

if [ $SHOULD_PUSH == 1 ];then
    header "Uploading $CONTAINER:$VERSION to docker hub"
    docker push $CONTAINER:$VERSION || exit 4
fi
