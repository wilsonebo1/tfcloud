#!/usr/bin/env bash

# Script to build and test install guide PDFs.
#
# By default, will use pre-built image from ECR.
#
# To build PDFs and run tests, run:
#
#     ./build.sh test
#
# To build a new image, run:
#
#     REBUILD_IMAGE=1 ./build.sh push
#

set -euo pipefail
IFS=$'\n\t'

GUIDES="${GUIDES:-""}"
IMAGE_NAME=dr-gitbook
FULL_IMAGE_NAME="docker.hq.datarobot.com/datarobot/dr-gitbook:latest"
TEST_CONTAINER=gitbook-test

# set REBUILD_IMAGE to rebuild and push image
REBUILD_IMAGE="${REBUILD_IMAGE:-""}"

function _error() {
    >&2 printf "\e[31mERROR: %s\e[00m\n" "$@"
    exit 1
}


function _note() {
    printf "\e[32m\n[ %s ]\n---------------------\e[00m\n" "$@"
}


function _warn() {
    printf "\e[33mWARNING: %s\e[00m\n" "$@"
}


function _build() {
    set +x
    _note "Building ${IMAGE_NAME}"
    set -x
    docker build --rm -t "${IMAGE_NAME}" .
    set +x
}

function _push() {
    set +x
    _note "Pushing $IMAGE_NAME"
    if [ -z "${REBUILD_IMAGE}" ]; then
        2>&1 echo "Must set REBUILD_IMAGE to rebuild and push!"
        exit 1
    else
        set -x
        docker tag "${IMAGE_NAME}" "${FULL_IMAGE_NAME}"
        dockerwise push "${FULL_IMAGE_NAME}"
        set +x
    fi
}


function _clean {
    set +x
    _note "Cleaning up dangling images and test container"
    set +e
    set -x
    docker images --filter="dangling=true" -q | xargs --no-run-if-empty docker rmi 2>/dev/null
    docker rm "$(docker stop "${TEST_CONTAINER}" 2>/dev/null)" 2>/dev/null
    find . -type d -name _book -exec rm -rf {} \; 2>/dev/null
    set +x
    set -e
}


function _test {
    set +x
    _note "Testing can build HTML and PDF"
    rm -f test-results.xml

    local oldIFS refname user_id

    refname="$(git reflog | head -n 1 | cut -d " " -f1 || echo -n "")"
    if [ -z "$refname" ]; then
        _error "Could not determine git ref!"
    else
        echo "refname: ${refname}"
    fi

    user_id="$(id -u)"

    oldIFS="$IFS"
    IFS=' '

    echo "Pulling ${FULL_IMAGE_NAME}"
    docker pull "${FULL_IMAGE_NAME}"

    rm -rf output/*
    docker run --rm --name "${TEST_CONTAINER}" --user="${UID}" -i \
        -e "GUIDES=${GUIDES}" \
        -e "HOME=/tmp/" \
        -e "REFNAME=${refname}" \
        -e "USER_ID=${user_id}" \
        -w /tmp/gitbook \
        -v "$(pwd):/tmp/gitbook" \
        -v "$(pwd)/gitbook.sh:/tmp/gitbook.sh" "${FULL_IMAGE_NAME}" \
        /tmp/gitbook.sh
    set +x

    IFS="$oldIFS"
    cat > test-results.xml <<EOF
<?xml version="1.0" encoding="utf-8"?>
<testsuite errors="0" failures="0" name="Gitbook Tests" skips="0" tests="1">
<testcase classname="tests.test_build_html_and_pdf" file="build.sh">
</testcase>
</testsuite>
EOF
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
    local target="${1:-}"
    shift
    local args="$*"

    # shellcheck disable=SC2086
    case "${target}" in
        build)
            _note "Building"
            set -x
            _build $args
            set +x ;;
        clean)
            _note "Cleaning"
            set -x
            _clean $args
            set +x ;;
        push)
            _note "Building and Pushing"
            if [ -z "${REBUILD_IMAGE}" ]; then
                2>&1 echo "Must set REBUILD_IMAGE to rebuild and push!"
                exit 1
            fi
            set -x
            _clean
            _build $args
            _push
            set +x ;;
        test*)
            _note "Running Tests"
            set -x
            _clean
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
elif [ "$1" == "-h" ] || [ "$1" == "--help" ]; then
    _usage
else
    _run_target "$@"
fi
