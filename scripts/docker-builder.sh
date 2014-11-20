#!/bin/sh

WORKSPACE=$(cd $(dirname $0);cd ..; pwd)
DOCKER_DIR=$WORKSPACE/docker
CACHE_DIR=cache
function usage {
    cat << EOF
$(basename $0) OPTIONS CONTAINER
OPTIONS:
    --push
    --push-only
    --build
    --list
    --help
    --no-cache
EOF

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

function listContainers() {
    for PREFIX in $(ls -1 $DOCKER_DIR);do
        if [ -d $DOCKER_DIR/$PREFIX ];then
            for CONTAINER in $(ls -1 $DOCKER_DIR/$PREFIX);do
                echo "- $PREFIX/$CONTAINER"
            done
        fi
    done
}

function checkContainer() {
    if [ ! -d $DOCKER_DIR/$CONTAINER ];then
        echo $CONTAINER does not exist
        echo
        echo "Available docker containers :"
        listContainers
        echo
        exit 2
    fi
    cd $DOCKER_DIR/$CONTAINER
    VERSION=$(grep "# VERSION" Dockerfile | awk '{print $3}')
}

if [ $# -lt 1 ];then
    usage
    exit 1
fi

# Parameters
SHOULD_CACHE=1
SHOULD_BUILD=0
SHOULD_LIST=0
SHOULD_PUSH=0
while (( "$#" )); do

    CONTAINER=$1
    case "$1" in
    "--push")
        SHOULD_PUSH=1
    ;;
    "--build")
        SHOULD_BUILD=1
    ;;
    "--push-only")
        SHOULD_PUSH=1
        SHOULD_BUILD=1
    ;;
    "--no-cache")
        SHOULD_CACHE=0
    ;;
    "--list")
        SHOULD_LIST=1
        SHOULD_BUILD=0
    ;;
    "--help")
        usage
        exit 0
    ;;
    esac
    shift
done

if [ $SHOULD_BUILD == 1 ];then
    checkContainer

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
    checkContainer
    header "Uploading $CONTAINER:$VERSION to docker hub"
    docker push $CONTAINER:$VERSION || exit 4
fi

if [ $SHOULD_LIST == 1 ];then
   listContainers
fi
