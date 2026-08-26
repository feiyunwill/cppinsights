#compdef insights
#
# C++ Insights, copyright (C) by Andreas Fertig
# Distributed under an MIT license. See LICENSE for details
#
#------------------------------------------------------------------------------
# zsh completion for C++ Insights.
#
# Completes the C++ Insights options (with descriptions) as well as the Clang
# options provided after "--". The option list is obtained from `insights
# --autocomplete` and `insights -- --autocomplete=...` which both emit lines in
# the form "option\tdescription" (a single TAB, the same format clang uses).

_insights_get_options()
{
  # $1 == ""  -> C++ Insights options (insights --autocomplete)
  # $1 == arg -> Clang options after "--" (insights -- --autocomplete="arg")
  local raw
  if [[ -z "$1" ]]; then
    raw=$(insights --autocomplete 2>/dev/null)
  else
    raw=$(insights -- --autocomplete="$1" 2>/dev/null)
  fi

  # Split each "option\tdescription" line into option + description.
  local IFS=$'\n'
  local line opt desc
  _insights_opts=()
  _insights_descs=()
  for line in ${=raw}; do
    opt=${line%%$'\t'*}
    desc=${line#*$'\t'}
    [[ -z "$opt" ]] && continue
    _insights_opts+=("$opt")
    _insights_descs+=("$desc")
  done
}

_insights()
{
  local sep_index=0 i j clang_args arg builtin_opt builtin_desc

  # Detect a "--" separator: everything after it is passed to Clang.
  for (( i = 1; i <= ${#words[@]}; i++ )); do
    if [[ "${words[i]}" == "--" ]]; then
      sep_index=$i
      break
    fi
  done

  if (( sep_index > 0 )); then
    # Build the comma-separated argument list clang expects (words after "--").
    clang_args=("${words[@]:sep_index+1}")
    arg=""
    for (( j = 1; j <= ${#clang_args[@]}; j++ )); do
      arg="$arg${clang_args[j-1]}"
      [[ $j != ${#clang_args[@]} && "${clang_args[j]}" != '=' ]] && arg="$arg,"
    done

    _insights_get_options "$arg"

    if (( ${#_insights_opts[@]} == 0 )); then
      _files
      return
    fi

    compadd -d _insights_descs -a _insights_opts
    return
  fi

  # No "--" yet: complete C++ Insights options plus a few built-in flags.
  _insights_get_options ""

  local -a all_opts all_descs
  all_opts=("${_insights_opts[@]}")
  all_descs=("${_insights_descs[@]}")

  # A handful of built-in flags that are not part of InsightsOptions.def.
  for builtin_desc in \
    '-h:Display available options' \
    '--help:Display available options' \
    '--help-list:Display available options' \
    '--version:Display the version' \
    '-p:Specify the build path' \
    '--extra-arg:Additional argument appended to the compiler command line' \
    '--extra-arg-before:Additional argument prepended to the compiler command line'; do
    builtin_opt="${builtin_desc%%:*}"
    all_opts+=("$builtin_opt")
    all_descs+=("${builtin_desc#*:}")
  done

  if (( ${#all_opts[@]} == 0 )); then
    _files
    return
  fi

  compadd -d all_descs -a all_opts
}

_insights "$@"

# ex: ts=4 sw=4 et filetype=zsh
