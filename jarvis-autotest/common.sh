function _error() {
    >&2 printf "\e[31mERROR: $@\e[00m\n"
    exit 1
}


function _note() {
    printf "\e[32m\n[ $@ ]\n------------------------------------------\e[00m\n"
}


function _warn() {
    printf "\e[33mWARNING: $@\e[00m\n"
}
