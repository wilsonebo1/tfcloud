#!/usr/bin/env bash

set -euo pipefail
IFS=$'\n\t'

if [ -z "${GUIDES:-""}" ]; then
    echo "Defaulting to all guides."
    set -f
    declare -a "GUIDES=( installation rpm-installation managerless-hadoop )"
    set +f
else
    set -f
    declare -a "GUIDES=( $GUIDES )"
    set +f
fi

BUILD_DIR="/tmp/gitbook/output"
DATE="$(date +%Y-%m-%d)"
REFNAME="${REFNAME:-$(git reflog | head -n 1 | cut -d ' ' -f1)}"

mkdir -p "$BUILD_DIR"

function _gitbook {
    local guide_dir="/tmp/gitbook/$GUIDE"
    local pdf_file
    pdf_file="${BUILD_DIR}/${GUIDE}-guide-${DATE}-${REFNAME}.pdf"

    echo "Building $GUIDE guide in $guide_dir as $UID and saving output to $pdf_file"
    set -x
    mkdir -p "$guide_dir"
    cd "$guide_dir" || exit 1
    gitbook install
    gitbook pdf ./ "$pdf_file"
    set +x
}

function _gitbook_all {
    echo "Building guides (" "${GUIDES[@]}" ")"
    # shellcheck disable=SC2068
    for GUIDE in ${GUIDES[@]}; do
        _gitbook
    done
}

_gitbook_all
