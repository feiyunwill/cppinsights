#! /bin/sh
#
# C++ Insights, copyright (C) by Andreas Fertig
# Distributed under an MIT license. See LICENSE for details
#
#------------------------------------------------------------------------------
# Verifies the fish completion for C++ Insights:
#   1. `insights --autocomplete` emits "option\001description\001" lines.
#   2. `complete -C "insights --use"` offers --use-libc++ (with a description).

build_dir=$1
test_dir=$2
script=$3

export PATH="$build_dir:$PATH"

ret=0

echo "Running fish autocomplete tests..."

# 1. The C++ backend must emit descriptions separated by a TAB.
if insights --autocomplete 2>/dev/null | grep -q "$(printf '\t')"; then
    echo "[PASSED] insights --autocomplete emits descriptions"
else
    echo "[FAILED] insights --autocomplete does not emit descriptions"
    ret=1
fi

# 2. Completing "insights --use" must offer --use-libc++.
out=$(fish -c "source '$script'; complete -C 'insights --use'" 2>/dev/null)

if echo "$out" | grep -q -- '--use-libc++'; then
    echo "[PASSED] completing --use offers --use-libc++"
else
    echo "[FAILED] completing --use does not offer --use-libc++"
    echo "$out"
    ret=1
fi

exit $ret
