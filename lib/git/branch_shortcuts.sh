# ------------------------------------------------------------------------------
# SCM Breeze - Streamline your SCM workflow.
# Copyright 2011 Nathan Broadbent (http://madebynathan.com). All Rights Reserved.
# Released under the LGPL (GNU Lesser General Public License)
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# Numbered shortcuts for git branch
# ------------------------------------------------------------------------------

# Function wrapper around 'll'
# Adds numbered shortcuts to output of ls -l, just like 'git status'
unalias $git_branch_alias > /dev/null 2>&1; unset -f $git_branch_alias > /dev/null 2>&1
function _scmb_git_branch_shortcuts {
  # Use ruby to inject numbers into ls output
  ruby -e "$( cat <<EOF
    output = %x(script -q -c "$_git_cmd branch --color=always \"$@\"" /dev/null)
    line_count = output.lines.to_a.size
    output.lines.each_with_index do |line, i|
      spaces = (line_count > 9 && i < 9 ? "  " : " ")
      puts line.sub(/^([ *]{2})/, "\\\1\e[2;37m[\e[0m#{i+1}\e[2;37m]\e[0m" << spaces)
    end
EOF
)"

  # Set numbered file shortcut in variable
  local e=1
  for branch in $($_git_cmd branch "$@" | sed "s/^[* ]\{2\}//"); do
    export $git_env_char$e="$branch"
    if [ "${scmbDebug:-}" = "true" ]; then echo "Set \$$git_env_char$e  => $file"; fi
    let e++
  done
}

alias "$git_branch_alias"="_scmb_git_branch_shortcuts"