#!/bin/bash
#
# Notes:
# 1. Build's all the images for development. You can also pull the images from
#    docker registry, but they are a bit bulky.
# 2. If your user is not a member of the docker group you can add it by running
#    sudo adduser $USER docker . On restart you would be able to run docker and
#    this script without root privilege.
# 3. This works for docker version >= 1.5.0
# 4. If run without -u option it will not rebuild all the images unless the base
#    ubuntu image is updated.

# Exit on error
set -e

# Environment Variables
## Use's cache by default unless the -u options is passed
CACHE_OPTION=""

## This file/symlinks name
SELF_NAME=$(basename $0)

# Functions
usage() {
printf "Usage: ./%s [OPTIONS]

  OPTIONS:
    -a Pull all images needed for development from hub.docker.com/u/singnet/
    -b Build singnet/opencog-deps image. It is the base image for
       tools, cogutil, cogserver, and the buildbot images.
    -c Builds singnet/cogutil image. It will build singnet/opencog-deps
       if it hasn't been built, as it forms its base image.
    -e Builds singnet/minecraft image. It will build all needed images if they
       haven't already been built.
    -j Builds singnet/jupyter image. It will add jupyter notebook to
    singnet/opencog-dev:cli
    -m Builds singnet/moses image.
    -p Builds singnet/postgres image.
    -r Builds singnet/relex image.
    -t Builds singnet/opencog-dev:cli image. It will build
    singnet/opencog-deps
       and singnet/cogutil if they haven't been built, as they form its base
       images.
    -u This option signals all image builds to not use cache.
    -h This help message. \n" "$SELF_NAME"
}

# -----------------------------------------------------------------------------
## Build singnet/opencog-deps image.
build_opencog_deps() {
    echo "---- Starting build of singnet/opencog-deps ----"
    OCPKG_OPTION=""
    if [ ! -z "$OCPKG_URL" ]; then
        OCPKG_OPTION="--build-arg OCPKG_URL=$OCPKG_URL"
    fi
    docker build $CACHE_OPTION $OCPKG_OPTION -t singnet/opencog-deps base
    echo "---- Finished build of singnet/opencog-deps ----"
}

## If the singnet/opencog-deps image hasn't been built yet then build it.
check_opencog_deps() {
    if [ -z "$(docker images singnet/opencog-deps | grep -i opencog-deps)" ]
    then build_opencog_deps
    fi
}

# -----------------------------------------------------------------------------
## Build singnet/cogutil image.
build_cogutil() {
    check_opencog_deps
    echo "---- Starting build of singnet/cogutil ----"
    docker build $CACHE_OPTION -t singnet/cogutil cogutil
    echo "---- Finished build of singnet/cogutil ----"

}

## If the singnet/cogutil image hasn't been built yet then build it.
check_cogutil() {
    if [ -z "$(docker images singnet/cogutil | grep -i cogutil)" ]
    then build_cogutil
    fi
}

# -----------------------------------------------------------------------------
## Build singnet/opencog-dev:cli image.
build_dev_cli() {
    check_cogutil
    echo "---- Starting build of singnet/opencog-dev:cli ----"
    docker build $CACHE_OPTION -t singnet/opencog-dev:cli tools/cli
    echo "---- Finished build of singnet/opencog-dev:cli ----"
}

## If the singnet/opencog-dev:cli image hasn't been built yet then build it.
check_dev_cli() {
    if [ -z "$(docker images singnet/opencog-dev:cli | grep -i opencog-dev)" ]
    then build_dev_cli
    fi
}

# -----------------------------------------------------------------------------
## Pull all images needed for development from hub.docker.com/u/opencog/
pull_dev_images() {
  echo "---- Starting pull of opencog development images ----"
  docker pull singnet/opencog-deps
  docker pull singnet/cogutil
  docker pull singnet/opencog-dev:cli
  docker pull singnet/postgres
  docker pull singnet/relex
  echo "---- Finished pull of opencog development images ----"
}

# -----------------------------------------------------------------------------
# Main Execution
if [ $# -eq 0 ] ; then NO_ARGS=true ; fi

while getopts "abcehjmprtu" flag ; do
    case $flag in
        a) PULL_DEV_IMAGES=true ;;
        b) BUILD_OPENCOG_BASE_IMAGE=true ;;
        t) BUILD_TOOL_IMAGE=true ;;
        e) BUILD_EMBODIMENT_IMAGE=true ;;
        c) BUILD_COGUTIL_IMAGE=true ;;
        m) BUILD__MOSES_IMAGE=true ;;
        p) BUILD__POSTGRES_IMAGE=true ;;
        r) BUILD_RELEX_IMAGE=true ;;
        j) BUILD_JUPYTER_IMAGE=true ;;
        u) CACHE_OPTION=--no-cache ;;
        h) usage ;;
        \?) usage; exit 1 ;;
        *)  UNKNOWN_FLAGS=true ;;
    esac
done

# NOTE: To avoid repetion of builds don't reorder the sequence here.

if [ $PULL_DEV_IMAGES ] ; then
    pull_dev_images
    exit 0
fi

if [ $BUILD_OPENCOG_BASE_IMAGE ] ; then
    build_opencog_deps
fi

if [ $BUILD_COGUTIL_IMAGE ] ; then
    build_cogutil
fi

if [ $BUILD_TOOL_IMAGE ] ; then
    build_dev_cli
fi

if [ $BUILD_EMBODIMENT_IMAGE ] ; then
    check_dev_cli
    echo "---- Starting build of singnet/minecraft ----"
    docker build $CACHE_OPTION -t singnet/minecraft:0.1.0 minecraft
    echo "---- Finished build of singnet/minecraft ----"
fi

if [ $BUILD__MOSES_IMAGE ] ; then
    check_cogutil
    echo "---- Starting build of singnet/moses ----"
    docker build $CACHE_OPTION -t singnet/moses moses
    echo "---- Finished build of singnet/moses ----"
fi

if [ $BUILD__POSTGRES_IMAGE ] ; then
    echo "---- Starting build of singnet/postgres ----"
    ATOM_SQL_OPTION=""
    if [ ! -z "$ATOM_SQL_URL" ]; then
        ATOM_SQL_OPTION="--build-arg ATOM_SQL_URL=$ATOM_SQL_URL"
    fi
    docker build $CACHE_OPTION $ATOM_SQL_OPTION -t singnet/postgres postgres
    echo "---- Finished build of singnet/postgres ----"
fi

if [ $BUILD_RELEX_IMAGE ] ; then
    echo "---- Starting build of singnet/relex ----"
    RELEX_OPTIONS=""
    if [ ! -z "$RELEX_REPO" ]; then
        RELEX_OPTIONS="--build-arg RELEX_REPO=$RELEX_REPO"
    fi
    if [ ! -z "$RELEX_BRANCH" ]; then
        RELEX_OPTIONS="$RELEX_OPTIONS --build-arg RELEX_BRANCH=$RELEX_BRANCH"
    fi
    docker build $CACHE_OPTION $RELEX_OPTIONS -t singnet/relex relex
    echo "---- Finished build of singnet/relex ----"
fi

if [ $BUILD_JUPYTER_IMAGE ]; then
    check_dev_cli
    echo "---- Starting build of singnet/jupyter ----"
    docker build $CACHE_OPTION -t singnet/jupyter tools/jupyter_notebook
    echo "---- Finished build of singnet/jupyter ----" 
fi

if [ $UNKNOWN_FLAGS ] ; then usage; exit 1 ; fi
if [ $NO_ARGS ] ; then usage ; fi
