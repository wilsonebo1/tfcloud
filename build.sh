#!/usr/bin/env bash

set -euo pipefail
IFS=$'\n\t'

ALL_BOOKS="installation rpm-installation managerless-hadoop"
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
    find . -type d -name _book -exec rm -rf {} \;
    set +x
    set -e
}


function _test {
    set +x
    _note "Testing can build HTML and PDF"
    rm -f test-results.xml

    local refname=$(git reflog | head -n 1 | cut -d ' ' -f1)
    local user_id=$(id -u)

    local oldIFS=$IFS
    IFS=' '

    rm -rf output/*
    for book_dir in $ALL_BOOKS; do
        local book=$(echo $book_dir | sed -e 's#\/#-#')
        set -x
        echo "Building book: $book"
        docker run --rm --name $TEST_CONTAINER \
               --user=$UID \
               -i \
               -e "BOOK=$book" \
               -e "BOOK_DIR=$book_dir" \
               -e "BUILD_DIR=/tmp/gitbook/output" \
               -e "HOME=/tmp/" \
               -e "REFNAME=$refname" \
               -e "USER_ID=$user_id" \
               -w /tmp/gitbook \
               -v $(pwd):/tmp/gitbook \
               -v $(pwd)/gitbook.sh:/tmp/gitbook.sh $IMAGE_NAME \
               /tmp/gitbook.sh
        set +x
    done
    IFS=$oldIFS
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
    local target=$1
    shift
    local args=$@

    case "$target" in
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
        test*)
            _note "Running Test"
            set -x
            _clean
            _build $args
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
