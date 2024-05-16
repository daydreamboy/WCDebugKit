#!/usr/bin/env bash

##
# Remove the elements from the array
#
# @param the original array
# @param the array to remove
# @return the rest array after remove
#
# @example
# array=('x86' 'i386' 'arm64')
# to_remove=('arm64')
# declare -a output=($(array_remove_elements array[@] to_remove[@]))
#
function array_remove_elements() {
    declare -a original_array=(${!1})
    declare -a elements_to_remove=(${!2})
    declare -a return_array=()

    for i in "${original_array[@]}"; do
        if [[ ! " ${elements_to_remove[*]} " =~ " ${i} " ]]; then
            return_array+=(${i})
        fi
    done

    echo ${return_array[@]}
}