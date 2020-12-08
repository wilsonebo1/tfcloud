#!/usr/bin/env bash

function _error() {
    >&2 printf "\e[31mERROR: %s\e[00m\n" "$@"
    exit 1
}


function _note() {
    printf "\e[32m\n[ %s ]\n------------------------------------------\e[00m\n" "$@"
}


function _warn() {
    printf "\e[33mWARNING: %s\e[00m\n" "$@"
}
