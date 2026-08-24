#
# C++ Insights, copyright (C) by Andreas Fertig
# Distributed under an MIT license. See LICENSE for details
#
#------------------------------------------------------------------------------
# fish completion for C++ Insights.
#
# The C++ Insights options (with their descriptions) are registered statically
# when this file is loaded: `insights --autocomplete` emits lines of the form
# "option\tdescription" (a single TAB, the same format clang uses), which we
# split on the TAB here.
#
# Options given after "--" are forwarded to Clang. Because fish's dynamic
# completions cannot attach a description to computed arguments, those are
# completed by name only.

# Clear any previously registered insights completions (idempotent reload).
complete -c insights -e

# Register the C++ Insights options (and their descriptions) statically.
for line in (insights --autocomplete 2>/dev/null | string split \n)
    # Each line is "option\tdescription" (TAB separated).
    set -l fields (string split -- (printf '\t') -- $line)
    set -l opt $fields[1]
    set -l desc $fields[2]
    [ -z "$opt" ]; and continue
    complete -c insights -l (string replace -- '--' '' $opt) -d "$desc"
end

# A handful of built-in flags that are not part of InsightsOptions.def.
complete -c insights -s h            -l help        -d 'Display available options'
complete -c insights -s h            -l help-list   -d 'Display available options'
complete -c insights -l version      -d 'Display the version'
complete -c insights -s p            -l build-path -d 'Specify the build path'
complete -c insights -l extra-arg        -d 'Additional argument appended to the compiler command line'
complete -c insights -l extra-arg-before -d 'Additional argument prepended to the compiler command line'

# After "--" the remaining arguments are passed to Clang. Complete them by
# name (no description) using clang's own autocomplete via `insights --`.
complete -c insights -n '__fish_seen_argument --' \
    -a '(set -l cargs (commandline -opc); set -l idx (contains -i -- -- $cargs); set -l rest (string join , -- $cargs[(math $idx + 1)..-1]); insights -- --autocomplete="$rest" 2>/dev/null | string replace -r \'\t.*\' \'\')'

# ex: ts=4 sw=4 et filetype=fish
