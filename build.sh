#!/usr/bin/env bash

set -euo pipefail
IFS=$'\n\t'


IMAGE_NAME=dr-gitbook
TEST_CONTAINER=gitbook-test


function _error() {
    >&2 printf "\e[31mERROR: $@\e[00m\n"
    exit 1
}


function _note() {
    printf "\e[32m\n[ $@ ]\n---------------------\e[00m\n"
}


function _warn() {
    printf "\e[33mWARNING: $@\e[00m\n"
}


function _build() {
    set +x
    _note "Building $IMAGE_NAME"
    set -x
    docker build --rm -t $IMAGE_NAME .
    set +x
}


function _clean {
    set +x
    _note "Cleaning up dangling images and test container"
    set +e
    set -x
    docker images --filter="dangling=true" -q \
        | xargs --no-run-if-empty docker rmi
    docker rm $(docker stop $TEST_CONTAINER) 2>/dev/null
    set +x
    set -e
}


function _test {
    set +x
    _note "Testing can build HTML and PDF"
    set +e
    for book in administration installation; do
        set -x
        docker run --rm --name $TEST_CONTAINER \
               -v $(pwd)/$book:/gitbook $IMAGE_NAME gitbook build
        docker run --rm --name $TEST_CONTAINER \
               -v $(pwd)/$book:/gitbook $IMAGE_NAME gitbook pdf
        set +x
    done
    set -e
}


function _usage() {
    echo "Usage: ./build.sh TARGET"
    echo "Runs target (build, clean, test)."
    echo
    echo "  TARGET   action to perform (e.g. test, release)"
    echo
    echo "  -h, --help  print this usage"
}


function _run_target() {
    # run specified target with arguments
    local target=$1
    shift
    local args=$@

    case "$target" in
        build)
            _note "Building"
            set -x
            _build
            set +x ;;
        clean)
            _note "Cleaning"
            set -x
            _clean
            set +x ;;
        test*)
            _note "Running Test"
            set -x
            _clean
            _build
            _test
            set +x
            ;;
        *)
            _error "No target found for $target!" ;;
    esac
}

if [ $# -lt 1 ]; then
    _usage
    _error "Target must be specified!"
elif [ $1 == '-h' ] || [ $1 == '--help' ]; then
    _usage
else
    _run_target $@
fi
