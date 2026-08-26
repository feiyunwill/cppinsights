#! /bin/zsh
#
# C++ Insights, copyright (C) by Andreas Fertig
# Distributed under an MIT license. See LICENSE for details
#
#------------------------------------------------------------------------------
# Verifies the zsh completion for C++ Insights:
#   1. `insights --autocomplete` emits "option\001description\001" lines.
#   2. The _insights completion function returns the Insights options.
#   3. After "--", the function delegates to clang's autocomplete.

build_dir=$1
test_dir=$2
script=$3

export PATH="$build_dir:$PATH"

ret=0

echo "Running zsh autocomplete tests..."

# 1. The C++ backend must emit descriptions separated by a TAB.
if insights --autocomplete 2>/dev/null | grep -q $'\t'; then
    echo "[PASSED] insights --autocomplete emits descriptions"
else
    echo "[FAILED] insights --autocomplete does not emit descriptions"
    ret=1
fi

# 2. Completing "--use" must offer --use-libc++ with a description.
out=$(zsh -fc "
    source '$script'
    words=(insights --use)
    CURRENT=2
    _insights_opts=()
    _insights_descs=()
    _insights
    for ((i=1;i<=\${#_insights_opts[@]};i++)); do
        echo \"\${_insights_opts[i]}\t\${_insights_descs[i]}\"
    done
" 2>/dev/null)

if echo "$out" | grep -q -- '--use-libc++'; then
    echo "[PASSED] completing --use offers --use-libc++"
else
    echo "[FAILED] completing --use does not offer --use-libc++"
    echo "$out"
    ret=1
fi

if echo "$out" | grep -- '--use-libc++' | grep -q $'\t'; then
    echo "[PASSED] --use-libc++ has a description"
else
    echo "[FAILED] --use-libc++ is missing a description"
    echo "$out"
    ret=1
fi

# 3. After "--", clang options must be offered (e.g. -std=).
out=$(zsh -fc "
    source '$script'
    words=(insights -- -std)
    CURRENT=3
    _insights_opts=()
    _insights_descs=()
    _insights
    echo \"\${_insights_opts[@]}\"
" 2>/dev/null)

if echo "$out" | grep -q -- '-std='; then
    echo "[PASSED] after -- offers clang -std="
else
    echo "[FAILED] after -- does not offer clang -std="
    echo "$out"
    ret=1
fi

exit $ret
