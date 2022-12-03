#!/usr/bin/env bash

IS_ASCII="False";
if file -b $1 | grep -qi "ascii\|utf-8" ; then
	IS_ASCII="True";
else
	IS_ASCII="False";
fi