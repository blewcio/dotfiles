## Command discovery: browse Bob's own aliases, functions and scripts.
## Everything is driven by bin/cmd-index, which parses the dotfiles sources
## and the comment next to each definition (convention: see its header),
## so the docs live in the code and cannot drift from it.

# List own functions and scripts with descriptions, grouped by source file
# Usage: funcs [--missing]   (--missing: only entries without a description)
list_functions() {
  ~/dotfiles/bin/cmd-index --list --kind function --kind script "$@"
}
alias funcs=list_functions

# Show function or script usage and description
describe_function() {
  if [ $# -eq 0 ]; then
    echo "Usage: describe_function FUNCTION_OR_SCRIPT_NAME"
    echo "Example: describe_function csv_cat"
    echo "Example: describe_function pic-info"
    return 1
  fi

  # First check if it's a script in bin/
  if [ -f ~/dotfiles/bin/$1 ]; then
    echo "Script: $1"
    echo "Location: ~/dotfiles/bin/$1"
    echo ""
    # Extract header comments (lines starting with # after shebang, stop at first non-comment)
    local header=$(awk '/^#!/{next} /^#/{print} /^[^#]/{if(NR>1)exit}' ~/dotfiles/bin/$1)
    if [ -n "$header" ]; then
      echo "$header"
    else
      echo "No description available. View the script with: cat ~/dotfiles/bin/$1"
    fi
    return 0
  fi

  # Otherwise check if it's a function
  local result=$(grep -B 3 "^ *$1 *()" ~/dotfiles/shell.d/*.sh 2>/dev/null)
  if [ -z "$result" ]; then
    echo "Function or script '$1' not found"
    echo ""
    echo "Try 'funcs' to see all available functions and scripts"
    return 1
  fi
  echo "Function: $1"
  echo ""
  echo "$result" | sed 's/.*shell.d\///' | grep -v '^--$'
}
alias fhelp=describe_function

# Internal: fzf browser over cmd-index entries; falls back to a plain listing
# Usage: _cmd_browse <alias|all> [initial query]
# Fields passed through fzf (tab separated): 1 display, 2 file, 3 line,
# 4 name, 5 kind, 6 definition, 7 description
_cmd_browse() {
  local what="$1"; shift
  local idx=~/dotfiles/bin/cmd-index
  local kindargs=() loaded="" header sel
  [[ "$what" == alias ]] && kindargs=(--kind alias)

  if [[ ! -x "$(command -v fzf)" ]]; then
    "$idx" --list "${kindargs[@]}" | grep -i -e "$*"
    return
  fi

  # Which of the dotfiles aliases exist in this shell (conditional ones may not)
  if [[ "$what" == alias ]]; then
    loaded=$(alias | sed -e 's/^alias //' -e "s/^'//" -e 's/=.*//' -e "s/'\$//" | tr '\n' ' ')
    header=$'✓ loaded in this shell   ctrl-e edit source   enter print details'
  else
    header=$'ctrl-e edit source   enter print details'
  fi

  sel=$("$idx" "${kindargs[@]}" | awk -F'\t' -v what="$what" -v loaded=" $loaded " '
    BEGIN { OFS = "\t" }
    {
      if (what == "alias") {
        def = $6; if (length(def) > 44) def = substr(def, 1, 43) "..."
        disp = sprintf("%s %-16s %-45s %s", (index(loaded, " " $2 " ") ? "✓" : "·"), $2, def, $3)
      } else {
        disp = sprintf("%-8s %-24s %s", $1, $2, $3)
      }
      print disp, $4, $5, $2, $1, $6, $3
    }' | fzf --height=80% --reverse --delimiter=$'\t' --with-nth=1 --nth=1 \
        --query="$*" --header="$header" \
        --preview 'printf "\033[1m%s\033[0m  (%s)\n" {4} {5}; [ -n {7} ] && printf "%s\n" {7}; [ -n {6} ] && printf "\n  %s\n" {6}; printf "\n"; (command -v bat >/dev/null 2>&1 && bat --style=numbers --color=always --line-range {3}: {2} || tail -n +{3} {2}) | head -30' \
        --preview-window='right:50%:wrap' \
        --bind "ctrl-e:execute(${EDITOR:-vim} +{3} {2})")

  [[ -z "$sel" ]] && return 0
  printf '%s\n' "$sel" | awk -F'\t' -v home="$HOME" '{
    f = $2; sub(home, "~", f)
    printf "%s  (%s)\n", $4, $5
    if ($7 != "") printf "  %s\n", $7
    if ($5 == "alias") printf "  = %s\n", $6
    printf "  %s:%s\n", f, $3
  }'
}

# Browse own aliases as defined in the dotfiles (fzf search)
# Usage: aliases [query]  |  aliases --all [query] (everything loaded in this shell, incl. other scripts)
list_aliases() {
  if [[ "$1" == "-a" || "$1" == "--all" ]]; then
    shift
    if [[ -x "$(command -v fzf)" ]]; then
      alias | sed 's/^alias //' | sort | fzf --height=60% --reverse --query "$*" \
        --header 'All aliases loaded in this shell' --preview 'echo {}' --preview-window=down:3:wrap
    else
      alias | sed 's/^alias //' | sort | grep -i -- "$*"
    fi
    return
  fi
  _cmd_browse alias "$@"
}
alias aliases=list_aliases

# Browse all own aliases, functions and scripts with descriptions (fzf search)
# Usage: cmds [query]
list_commands() {
  _cmd_browse all "$@"
}
alias cmds=list_commands
