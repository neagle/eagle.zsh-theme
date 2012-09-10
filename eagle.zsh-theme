# Fly like an eagle
# Based off the blinks zsh theme

function _prompt_char() {
  if $(git rev-parse --is-inside-work-tree >/dev/null 2>&1); then
    echo "%{%F{blue}%}±%{%f%k%}"
  else
    echo ' '
  fi
}

#ZSH_THEME_GIT_PROMPT_PREFIX=" %F{green}($(git_time_since_commit)%F{green})[%{%F{yellow}%}"
ZSH_THEME_GIT_PROMPT_PREFIX="$(git_prompt_status) %F{green}[%{%F{green}%}"
ZSH_THEME_GIT_PROMPT_SUFFIX="%{%f%k%K{black}%F{green}%}]"
ZSH_THEME_GIT_PROMPT_DIRTY=" %{%F{red}%}*%{%f%k%}"
ZSH_THEME_GIT_PROMPT_CLEAN=""
#
# Colors vary depending on time lapsed.
ZSH_THEME_GIT_TIME_SINCE_COMMIT_SHORT="%{$fg[green]%}"
ZSH_THEME_GIT_TIME_SHORT_COMMIT_MEDIUM="%{$fg[yellow]%}"
ZSH_THEME_GIT_TIME_SINCE_COMMIT_LONG="%{$fg[red]%}"
ZSH_THEME_GIT_TIME_SINCE_COMMIT_NEUTRAL="%{$fg[cyan]%}"

ZSH_THEME_GIT_PROMPT_ADDED="%{$fg[green]%} ✚"
ZSH_THEME_GIT_PROMPT_MODIFIED="%{$fg[blue]%} ✹"
ZSH_THEME_GIT_PROMPT_DELETED="%{$fg[red]%} ✖"
ZSH_THEME_GIT_PROMPT_RENAMED="%{$fg[magenta]%} ➜"
ZSH_THEME_GIT_PROMPT_UNMERGED="%{$fg[yellow]%} ═"
ZSH_THEME_GIT_PROMPT_UNTRACKED="%{$fg[cyan]%} ✭"

alias gicons="echo 'LEGEND\n======\n✚ = Added\n✹ = Modified\n✖ = Deleted\n➜ = Renamed\n═ = Unmerged\n✭ = Untracked'"

# Determine the time since last commit. If branch is clean,
# use a neutral color, otherwise colors will vary according to time.
function git_time_since_commit() {# {{{
    if git rev-parse --git-dir > /dev/null 2>&1; then
        # Only proceed if there is actually a commit.
        if [[ $(git log 2>&1 > /dev/null | grep -c "^fatal: bad default revision") == 0 ]]; then
            # Get the last commit.
            last_commit=`git log --pretty=format:'%at' -1 2> /dev/null`
            now=`date +%s`
            seconds_since_last_commit=$((now-last_commit))

            # Totals
            MINUTES=$((seconds_since_last_commit / 60))
            HOURS=$((seconds_since_last_commit/3600))

            # Sub-hours and sub-minutes
            DAYS=$((seconds_since_last_commit / 86400))
            SUB_HOURS=$((HOURS % 24))
            SUB_MINUTES=$((MINUTES % 60))

            if [[ -n $(git status -s 2> /dev/null) ]]; then
                if [ "$MINUTES" -gt 30 ]; then
                    COLOR="$ZSH_THEME_GIT_TIME_SINCE_COMMIT_LONG"
                elif [ "$MINUTES" -gt 10 ]; then
                    COLOR="$ZSH_THEME_GIT_TIME_SHORT_COMMIT_MEDIUM"
                else
                    COLOR="$ZSH_THEME_GIT_TIME_SINCE_COMMIT_SHORT"
                fi
            else
                COLOR="$ZSH_THEME_GIT_TIME_SINCE_COMMIT_NEUTRAL"
            fi

            if [ "$HOURS" -gt 24 ]; then
                echo "$COLOR${DAYS}d${SUB_HOURS}h${SUB_MINUTES}m"
            elif [ "$MINUTES" -gt 60 ]; then
                echo "$COLOR${HOURS}h${SUB_MINUTES}m"
            else
                echo "$COLOR${MINUTES}m"
            fi
        else
            COLOR="$ZSH_THEME_GIT_TIME_SINCE_COMMIT_NEUTRAL"
            echo "$COLOR~"
        fi
    fi
}# }}}

# Contextual todos!
# http://wynnnetherland.com/journal/contextual-todo-list-counts-in-your-zsh-prompt

# This keeps the number of todos always available the right hand side of my
# command line. I filter it to only count those tagged as "+next", so it's more
# of a motivation to clear out the list.
todo_count(){
  if $(which todo &> /dev/null)
  then
    num=$(echo $(todo ls $1 | wc -l))
    let todos=num-2
    if [ $todos != 0 ]
    then
      echo "$todos"
    else
      echo ""
    fi
  else
    echo ""
  fi
}

function todo_prompt() {
  #local COUNT=$(todo_count $1);
  local COUNT=$(todo_count);
  if [ -n "$COUNT" ]; then
    echo "$1: $COUNT";
  else
    echo "";
  fi
}

PROMPT='%{%f%k%b%}
%{%K{black}%(?,%{$fg[magenta]%}(^_^%),%F{red}(>_<%)) %F{green}%}%n%{%F{blue}%}@%{%F{cyan}%}%m%{%F{green}%} %{%F{yellow}%K{black}%}%~%{%F{green}%}$(git_prompt_info)%E%{%f%k%}
%{%K{black}%}$(_prompt_char)%{%K{black}%} %#%{%f%k%} '

# RPROMPT='!%{%B%F{cyan}%}%!%{%f%k%b%}'
RPROMPT='$(todo_prompt TODO) %{$fg[yellow]%}%D{%l:%M %p} %{$fg[cyan]%}✧ %F{green}%D{%A, %B %e}'
