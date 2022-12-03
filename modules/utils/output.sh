#!/usr/bin/env bash

mkdir -p $dir_output
cp -r $dir $dir_output
[[ "$(dirname $dir)" != "$dir_output" ]] && rm -rf "$dir"