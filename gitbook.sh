#!/usr/bin/env bash

set -euo pipefail
IFS=$'\n\t'

export REFNAME=${REFNAME:-$(git reflog | head -n 1 | cut -d ' ' -f1)}

function _gitbook {
    local pdfname=$BOOK-guide-$(date +%Y-%m-%d)-$REFNAME.pdf

    echo "Building $BOOK book in $BOOK_DIR as $UID"
    echo "and saving output to $BUILD_DIR"

    mkdir -p $BUILD_DIR

    pushd $BOOK_DIR

        set -x
        rm -rf node_modules

        gitbook install
        gitbook build
        gitbook pdf ./ ${BUILD_DIR}/${pdfname}

        set +x

    popd
}

_gitbook
