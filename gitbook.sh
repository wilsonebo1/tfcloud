#!/usr/bin/env bash

set -euo pipefail
IFS=$'\n\t'

export USER_ID=${USER_ID:-$(id -u)}
export REFNAME=${REFNAME:-$(git reflog | head -n 1 | cut -d ' ' -f1)}

function _gitbook {
    local pdfname=$BOOK-guide-$(date +%Y-%m-%d)-$REFNAME.pdf

    echo "Building $BOOK book in $BOOK_DIR as $USER_ID"

    pushd $BOOK_DIR

    set -x
    rm -rf node_modules

    gitbook install
    gitbook build
    gitbook pdf ./ ./$pdfname

    chown -Rf $USER_ID:$USER_ID *.pdf _book node_modules
    set +x

    popd
}

_gitbook
