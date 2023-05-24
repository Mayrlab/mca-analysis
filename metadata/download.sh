#!/bin/bash -l

message () { cat <<< "[INFO] $@" 1>&2; }

check_md5 () {
    message "Verifying $1..."
    local result=$(md5 -q "$1")
    if [[ $result == $2 ]]; then
        message "Success."
    else
        message "MD5 sum mismatch!"
    fi
}

dl () {
    wget -O "$1" "$2"
    check_md5 "$1" "$3"
}

## cell info
dl 'MCA1.1_cell_info.xlsx' 'https://figshare.com/ndownloader/files/21759027' 'c1616c5595c2b1ba0199935d49cbb321'

dl 'MCA2.0_cell_info.csv' 'https://figshare.com/ndownloader/files/36222822' 'cfa730ecae8c9788d1c3154b5364d8df'
gzip 'MCA2.0_cell_info.csv'
