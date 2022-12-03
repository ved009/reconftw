#!/usr/bin/env bash

runtime=""
T=$2-$1
D=$((T/60/60/24))
H=$((T/60/60%24))
M=$((T/60%60))
S=$((T%60))
(( $D > 0 )) && runtime="$runtime$D days, "
(( $H > 0 )) && runtime="$runtime$H hours, "
(( $M > 0 )) && runtime="$runtime$M minutes, "
runtime="$runtime$S seconds."