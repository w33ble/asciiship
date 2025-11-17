# vim:et sts=2 sw=2 ft=zsh

USER_COLOR=yellow
ROOT_COLOR=red
HOST_COLOR=green
DIR_COLOR=cyan
GIT_BRANCH_COLOR=magenta
GIT_STATUS_COLOR=red
GIT_COMMIT_COLOR=green
GIT_ACTION_COLOR=yellow
VIRTUAL_ENV_COLOR=yellow
BACKGROUND_JOBS_COLOR=blue
EXIT_SUCCESS_COLOR=green
EXIT_FAILURE_COLOR=red
EXECUTION_TIME_COLOR=yellow

_prompt_asciiship_vimode() {
  case ${KEYMAP} in
    vicmd) print -n '%S%#%s' ;;
    *) print -n '%#' ;;
  esac
}

zle-keymap-select() {
  zle reset-prompt
  zle -R
}
zle -N zle-keymap-select

typeset -g VIRTUAL_ENV_DISABLE_PROMPT=1

setopt nopromptbang prompt{cr,percent,sp,subst}

autoload -Uz add-zsh-hook
# Depends on duration-info module to show last command duration
if (( ${+functions[duration-info-preexec]} && \
    ${+functions[duration-info-precmd]} )); then
  zstyle ':zim:duration-info' format ' took %B%F{$EXECUTION_TIME_COLOR}%d%f%b'
  add-zsh-hook preexec duration-info-preexec
  add-zsh-hook precmd duration-info-precmd
fi
# Depends on git-info module to show git information
typeset -gA git_info
if (( ${+functions[git-info]} )); then
  zstyle ':zim:git-info:branch' format '%b'
  zstyle ':zim:git-info:commit' format 'HEAD %F{$GIT_COMMIT_COLOR}(%c)'
  zstyle ':zim:git-info:action' format ' %F{$GIT_ACTION_COLOR}(${(U):-%s})'
  zstyle ':zim:git-info:stashed' format '\\\$'
  zstyle ':zim:git-info:unindexed' format '!'
  zstyle ':zim:git-info:indexed' format '+'
  zstyle ':zim:git-info:ahead' format '>'
  zstyle ':zim:git-info:behind' format '<'
  zstyle ':zim:git-info:keys' format \
      'status' '%S%I%i%A%B' \
      'prompt' ' on %%B%F{$GIT_BRANCH_COLOR}%b%c%s${(e)git_info[status]:+" %F{$GIT_STATUS_COLOR}[${(e)git_info[status]}]"}%f%%b'
  add-zsh-hook precmd git-info
fi

PS1='
%(2L.%B%F{$USER_COLOR}(%L)%f%b .)%(!.%B%F{$ROOT_COLOR}%n%f%b in .${SSH_TTY:+"%B%F{$USER_COLOR}%n%f%b in "})${SSH_TTY:+"%B%F{$HOST_COLOR}%m%f%b in "}%B%F{$DIR_COLOR}%~%f%b${(e)git_info[prompt]}${VIRTUAL_ENV:+" via %B%F{$VIRTUAL_ENV_COLOR}${VIRTUAL_ENV:t}%f%b"}${duration_info}
%B%(1j.%F{$BACKGROUND_JOBS_COLOR}*%f .)%(?.%F{$EXIT_SUCCESS_COLOR}.%F{$EXIT_FAILURE_COLOR}%? )$(_prompt_asciiship_vimode)%f%b '
unset RPS1
