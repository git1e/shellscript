#!/bin/bash

# 显示脚本的使用说明
usage() {
    #参数说明
    “”“
    -a: 操作类型，split表示分割文件，merge表示合并文件，split 必须有参数-s和-p参数，merge 必须有参数-p参数
    -f: 文件名，用于分割文件时，指定文件名，合并文件时，指定文件名
    -s: 分割文件的最大大小，单位为MB
    -p: 文件的前缀，用于分割文件时，指定文件名前缀，合并文件时，指定文件名前缀
    “”“
    echo "Usage: 
    split file: $0  -a split -f filename -s max_size -p file_prefix
    or
    merge to file: $0 -a merge -p file_prefix"
    exit 1
}

# 检查是否是有效的数字
is_number() {
    [[ "$1" =~ ^[0-9]+$ ]]
}

# 解析命令行参数
while getopts "f:a:s:p:" opt; do
    case "$opt" in
        f) file=$OPTARG ;;
        a) action=$OPTARG ;;
        s) max_size=$OPTARG ;;
        p) prefix=$OPTARG ;;
        *)
        usage
        ;;
    esac
done


function split_file() {


    # 检查文件是否存在
    if [ -n "$file" ] && [ ! -f "$file" ]; then
        echo "Error: File not found: $file"
        exit 2
    fi

    # 检查 max_size 是否为数字
    if [ -n "$max_size" ] && ! is_number "$max_size"; then
        echo "Error: Invalid max_size: $max_size. It should be a number."
        exit 3
    fi
    md5sum $file
    split -b "$max_size"M "$file" "$prefix"
}



function merge_files() {
    merge_file=${prefix}.merged
    if [ "$action" = "merge" ] && [ -n "$prefix" ]; then
        cat "$prefix"* > $merge_file
        md5sum $merge_file
    else
        echo "Error: Invalid action or prefix."
        exit 4
    fi
}



if [  "$action" = "split" ];then
    split_file
elif [ "$action" = "merge" ]; then
    merge_files
else
    echo "Error: Invalid action."
    usage
    exit 5
fi
