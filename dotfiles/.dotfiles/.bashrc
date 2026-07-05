#!/bin/bash
# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac
# ----------------------------------------------------------
# © 2026 Morphological Source Code & Quineic Statistical Dynamics BSD 3-clause; no warranty or merchantability implied, nor agreements/services-rendered
# ----------------------------------------------------------
# ==========================================================
# Aliases + Key+Commands [(modifier) + key]
# ==========================================================
# uncomment with your fossil identity if you want
# fossil user default Phovos Phovos@outlook.com
alias ...='../../'
alias ..='../'
# gitdoc  # see (gitdoc) below
# H [] # see (H) below
# alert [] # see (alert) below
# popx [] # see (popx) below
# bp # see (bp) below
# .bp # see (bp) below
# backup [] # see (backup) below
# ct [] # see (ct) below
# hg [] # see (hg) below
# HG [] # see (HG) below
# gunadd [] # reverse git add (takes off git add <file> from staging area)
# unstage # see (unstage) below
alias ls='ls --color=auto'
alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'
alias ip='ip --color=auto'
alias ll='ls -alF --color=auto'
alias lll='ls -A --color=auto'
alias l='ls -CF --color=auto'
alias kex='kex --win -s'
# -------- Fossil Aliases (The Basics) --------
alias fs='fossil status'
alias fst='fossil stash'
alias fsp='fossil stash pop'
alias fsl='fossil stash list'
alias fdiff='fossil diff --color'
alias fdf='fossil diff --color-words'
alias fl='fossil timeline'
alias fll='fossil timeline -n 20'
alias fco='fossil checkout'
alias fup='fossil update'
alias fcom='fossil commit'
alias fcm='fossil commit -m'
alias fpush='fossil push'
alias fpull='fossil pull'
alias fsync='fossil sync'
alias fclone='fossil clone'
alias finit='fossil init'
alias fopen='fossil open'
alias fclose='fossil close'
alias finfo='fossil info'
alias fcat='fossil cat'
alias fadd='fossil add'
alias faddrm='fossil add --remove'
alias frm='fossil rm'
alias fmv='fossil mv'
alias frevert='fossil revert'
alias fclean='fossil clean'
alias fscrub='fossil scrub'
alias ftag='fossil tag'
alias fbranch='fossil branch'
alias fmerge='fossil merge'
alias fconf='fossil config'
alias fuser='fossil user'
alias fcap='fossil capabilities'
alias fverify='fossil verify'
alias fpolicy='fossil policy'

# --- git Aliases ---
alias gs='git status'
alias gca='git commit -a'
alias gcam='git commit -am'
alias gp='git push'
alias gup='git pull'
alias gco='git checkout'
alias gcb='git checkout -b'
alias gl='git log --graph --oneline --decorate --all'
alias gll='git log -1 --stat'
alias gclean='git clean -fdX'
alias diff='git diff --color-words'
alias dif='git diff --color --word-diff --stat'

# ==========================================================
# FOSSIL SCM - First Class Support
# ==========================================================
# NOT a 'requirement', but it is, you know? Installing it is out of scope, what kind of decrepit system doesn't have Fossil SCM support (hint-hint)?

# sudo apt-get install fossil
# Or build from source
# git clone https://fossil-scm.org/home /tmp/fossil
# cd /tmp/fossil
# ./configure
# make
# sudo make install
# User-responsibility, not this workflow's

# -------- Core Environment --------
export FOSSIL_HOME="$HOME/.fossil"
export FOSSIL_REPO_DIR="$HOME/repos"
export FOSSIL_WORK_DIR="$HOME/workspaces"

# Ensure directories exist
mkdir -p "$FOSSIL_HOME" "$FOSSIL_REPO_DIR" "$FOSSIL_WORK_DIR" 2>/dev/null

# -------- Fossil Functions --------

# fsi - Fossil Status with Info
fsi() {
    echo "$(green '═══ Fossil Repository Status ═══')"
    fossil status
    echo
    echo "$(yellow 'Current Branch:') $(fossil branch current 2>/dev/null || echo 'None')"
    echo "$(yellow 'Checkout:')     $(fossil info | grep checkout | awk '{print $2}')"
}

# fclone - Clone with workspace creation
fclone() {
    if [ $# -lt 1 ]; then
        echo "Usage: fclone <repo-url> [workspace-name]"
        echo "Example: fclone https://fossil-scm.org/home my-fossil"
        return 1
    fi
    
    local url="$1"
    local name="${2:-$(basename "$url" .fossil)}"
    local repo_path="$FOSSIL_REPO_DIR/$name.fossil"
    local work_path="$FOSSIL_WORK_DIR/$name"
    
    echo "$(green "Cloning $url -> $repo_path")"
    fossil clone "$url" "$repo_path"
    
    if [ $? -eq 0 ]; then
        mkdir -p "$work_path"
        cd "$work_path"
        echo "$(green "Opening repository in $work_path")"
        fossil open "$repo_path"
        echo "$(blue "Clone complete! In workspace: $work_path")"
    else
        echo "$(red "Clone failed")"
        return 1
    fi
}

# fnew - Initialize new Fossil repository
fnew() {
    if [ $# -lt 1 ]; then
        echo "Usage: fnew <repo-name> [workspace-name]"
        echo "Example: fnew myproject"
        return 1
    fi
    
    local name="$1"
    local repo_path="$FOSSIL_REPO_DIR/$name.fossil"
    local work_path="${2:-$FOSSIL_WORK_DIR/$name}"
    
    echo "$(green "Creating new repository: $repo_path")"
    fossil init "$repo_path"
    
    if [ $? -eq 0 ]; then
        mkdir -p "$work_path"
        cd "$work_path"
        echo "$(green "Opening repository in $work_path")"
        fossil open "$repo_path"
        echo "$(blue "Repository created! In workspace: $work_path")"
        echo "$(yellow "Next steps:")"
        echo "   fossil add ."
        echo "   fossil commit -m 'Initial commit'"
        echo "   fossil ui           # Start web interface"
    else
        echo "$(red "Repository creation failed")"
        return 1
    fi
}

# fui - Start Fossil UI (with options)
fui() {
    if [ -f "$FOSSIL_REPO_DIR/$(basename $(pwd)).fossil" ]; then
        local repo="$FOSSIL_REPO_DIR/$(basename $(pwd)).fossil"
        echo "$(green "Starting Fossil UI for $repo")"
        fossil ui "$repo" &
    elif [ -f "$(pwd)/$(basename $(pwd)).fossil" ]; then
        echo "$(green "Starting Fossil UI for $(pwd)/$(basename $(pwd)).fossil")"
        fossil ui &
    else
        echo "$(red "No Fossil repository found in current directory")"
        echo "Try: fossil ui <repository.fossil>"
        return 1
    fi
}

# fserve - Start Fossil server (background)
fserve() {
    if [ $# -lt 1 ]; then
        echo "Usage: fserve <repository.fossil> [port]"
        echo "Example: fserve myrepo.fossil 8081"
        return 1
    fi
    
    local repo="$1"
    local port="${2:-8081}"
    
    if [ ! -f "$repo" ]; then
        echo "$(red "Repository not found: $repo")"
        return 1
    fi
    
    echo "$(green "Starting Fossil server on port $port")"
    echo "$(yellow "Access at: http://localhost:$port")"
    fossil server "$repo" --port "$port" &
}

# fserve-repo - Serve current repository
fserve-repo() {
    local port="${1:-8081}"
    local repo="$(pwd)/$(basename $(pwd)).fossil"
    
    if [ -f "$repo" ]; then
        fserve "$repo" "$port"
    else
        echo "$(red "No .fossil repository found in current directory")"
        return 1
    fi
}

# fbranch-current - Show current branch with color
fbranch-current() {
    local branch=$(fossil branch current 2>/dev/null)
    if [ -n "$branch" ]; then
        echo "$(green "Current branch: $branch")"
    else
        echo "$(yellow "Not in a Fossil workspace")"
    fi
}

# fcommit-with-msg - Commit with message and optional --amend
fcom() {
    if [ $# -eq 0 ]; then
        echo "Usage: fcom <message> [--amend]"
        echo "Example: fcom 'Fixed bug' --amend"
        return 1
    fi
    
    local msg="$1"
    shift
    local extra="$@"
    
    if [[ "$extra" == *"--amend"* ]]; then
        echo "$(yellow "Amending previous commit...")"
        fossil commit --amend -m "$msg"
    else
        echo "$(green "Committing with message: $msg")"
        fossil commit -m "$msg" $extra
    fi
}

# fbranch-new - Create and switch to new branch
fbranch-new() {
    if [ $# -lt 1 ]; then
        echo "Usage: fbranch-new <branch-name> [base-commit]"
        echo "Example: fbranch-new feature/x"
        return 1
    fi
    
    local branch="$1"
    local base="${2:-trunk}"
    
    echo "$(green "Creating branch: $branch from $base")"
    fossil branch new "$branch" "$base"
    fossil update "$branch"
    echo "$(blue "Switched to branch: $branch")"
}

# fpush-private - Push private artifacts
fpush-private() {
    echo "$(yellow "Pushing private artifacts...")"
    fossil push --private
}

# fprovenance - Show artifact provenance
fprovenance() {
    if [ $# -lt 1 ]; then
        echo "Usage: fprovenance <artifact-hash>"
        return 1
    fi
    fossil provenance "$@"
}

# fsync-all - Full sync with debug info
fsync-all() {
    echo "$(green "Full sync with debug...")"
    fossil sync --verbose --httptrace
}

# fbackup - Backup the current repository
fbackup() {
    local repo="$(pwd)/$(basename $(pwd)).fossil"
    if [ -f "$repo" ]; then
        local backup="${repo}.backup-$(date +%Y%m%d-%H%M%S)"
        echo "$(green "Backing up to: $backup")"
        cp "$repo" "$backup"
        echo "$(blue "Backup complete")"
    else
        echo "$(red "No .fossil repository found")"
        return 1
    fi
}

# fdetritus - The higher-arity detritus form (composing sets via stdin/out)
fdetritus() {
    if [ $# -eq 0 ]; then
        cat <<'DETRITUS_HELP'
┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
┃           Fossil Detritus Mode (Higher-Arity)          ┃
┣━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┫
┃ Format: fdetritus <command> <args>                     ┃
┃ Example: echo "status" | fdetritus                     ┃
┃          fdetritus timeline -n 5 | grep -i commit      ┃
┣━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┫
┃  Detritus pipes allow set composition via stdio:      ┃
┃    stdout → stdin  (morphism chaining)                ┃
┃    stdin  → stdout (categorical transformation)       ┃
┃    stderr → /dev/null (pure functional composition)   ┃
┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛
DETRITUS_HELP
        return 0
    fi
    
    # Parse stdin for detritus commands
    if [ ! -t 0 ]; then
        # We have piped input - compose sets
        local input=$(cat)
        echo "$(yellow "Detritus composition: processing stdin")"
        echo "$input" | fossil "$@"
    else
        # Direct command mode
        fossil "$@"
    fi
}

# -------- Fossil ISA Table Display --------
fisa() {
    cat <<'FOSSIL_ISA'
┌─────────────┬───────────────────────┬──────────────────────────────────────┬──────────────────────────────┐
│ Fossil ISA  │ Typical CLI           │ BW² Detritus Form                   │ Turing Analogy               │
├─────────────┼───────────────────────┼──────────────────────────────────────┼──────────────────────────────┤
│ OPEN        │ fossil open           │ [ByteWord_repo, ByteWord_workspace] │ Init tape cursor             │
│ CLOSE       │ fossil close          │ [BW_substrate, BW_null]             │ Tape detach / noop           │
│ INIT        │ fossil init           │ [BW_new_repo, BW_meta]              │ Tape genesis, PC=0           │
│ DESCRIBE    │ fossil info           │ [BW_ID, BW_hash]                    │ Read-only fetch (memory query│
│ COMMIT      │ fossil commit         │ [BW_delta, BW_authority]            │ Collapse → store on tape     │
│ AMEND       │ fossil amend          │ [BW_last_commit, BW_delta]          │ GOTO local PC → rewrite      │
│ BRANCH      │ fossil branch         │ [BW_tip, BW_name]                   │ Fork tape branch (PC split)  │
│ MERGE       │ fossil merge          │ [BW_head1, BW_head2]                │ Deterministic merge → new PC │
│ TIMELINE    │ fossil timeline       │ [BW_cursor, BW_bounds]              │ Enumerate reachable tape     │
│ UPDATE      │ fossil update         │ [BW_commit, BW_registers]           │ Load commit → registers      │
│ REVERT      │ fossil revert         │ [BW_prev_commit, BW_registers]      │ Undo → backward jump (GOTO)  │
│ CLEAN       │ fossil clean          │ [BW_workspace, BW_flags]            │ Reset tape → zero state      │
│ SCRUB       │ fossil scrub          │ [BW_garbage, BW_metadata]           │ GC unreachable detritus      │
│ SNAPSHOT    │ fossil snapshot       │ [BW_marker, BW_meta]                │ Marker → read-only tape label│
│ TAG         │ fossil tag            │ [BW_commit, BW_label]               │ Annotate cell in tape        │
│ COMMENT     │ fossil comment        │ [BW_commit, BW_string]              │ Optional tape metadata       │
│ ANNOTATE    │ fossil annotate       │ [BW_commit, BW_struct]              │ Typed metadata for registers │
│ PROVENANCE  │ fossil provenance     │ [BW_cursor, BW_ancestry]            │ Trace tape dependency graph  │
│ USER        │ fossil user           │ [BW_action, BW_identity]            │ Inject agent identity into PC│
│ CAPABILITY  │ fossil capabilities   │ [BW_action, BW_constraints]         │ Set boundary constraints     │
│ VERIFY      │ fossil verify         │ [BW_commit, BW_checksum]            │ Assert tape invariant        │
│ POLICY      │ fossil policy         │ [BW_commit, BW_rules]               │ Guard tape region → branch   │
│ READ        │ fossil cat            │ [BW_commit, BW_register]            │ Load instruction into PC     │
│ WRITE       │ fossil push           │ [BW_register, BW_commit]            │ Store instruction → tape     │
│ NOOP        │ NOP                   │ [BW_null, BW_null]                  │ Explicit no-op / align PC    │
└─────────────┴───────────────────────┴──────────────────────────────────────┴──────────────────────────────┘
FOSSIL_ISA
}

# -------- Fossil CLI/TTL Prompt Integration (Optional) --------
# Show Fossil branch in prompt
fossil_prompt() {
    if [ -n "$(command -v fossil 2>/dev/null)" ] && [ -f ".fslckout" ]; then
        local branch=$(fossil branch current 2>/dev/null)
        if [ -n "$branch" ]; then
            echo " [$branch]"
        fi
    fi
}

# Uncomment to add Fossil info to PS1:
# PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]$(fossil_prompt)\$ '

# -------- Autocomplete Setup (if available) --------
if command -v fossil >/dev/null 2>&1; then
    # Enable fossil autocomplete if available
    if [ -f /usr/share/bash-completion/completions/fossil ]; then
        . /usr/share/bash-completion/completions/fossil
    elif [ -f /etc/bash_completion.d/fossil ]; then
        . /etc/bash_completion.d/fossil
    fi
    
    echo "$(green "✓ Fossil SCM initialized")"
    echo "$(blue " Type 'fisa' for ISA reference")"
    echo "$(blue " Type 'fnew' or 'fclone' to start")"
fi

# --------------------------------------------------
# Custom fossil example (commented-out)
# --------------------------------------------------
# fossil timeline -n 10

# Detritus composition (pipes through stdin)
# echo "timeline -n 10" | fdetritus

# Chain compositions
# fdetritus timeline -n 10 | grep "commit" | fdetritus info

# Pure set composition via stdin/stdout
# ls -la | fdetritus add    # Add all files in current dir

# ----------------------------------------------------
# Git Functions
# ----------------------------------------------------
function unstage() {
  git reset HEAD -- $1
}
# Enable fsmonitor-watchman deamon for git IPC
git config --global core.fsmonitor 'true'
# Git configuration
git config --global rerere.enabled true
# Reverse git add (takes off git add <file> from staging area)
function restage() {
    if [ $# -eq 0 ]; then
        git restore --staged .
    else
        git restore --staged "$@"
    fi
    echo "Unstaged: $@"
}
gunadd() {
    git reset HEAD -- "$@"
    echo "Unstaged: $@"
}
gitdoc() {
    cat <<'GIT_DOC'
    ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━=┓
    ┃                  Git Staging & Reset Cheat Sheet               ┃
    ┣━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━=┫
    ┃ Command                         ┃ Effect                       ┃
    ┣━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━=┫
    ┃ git add <file>                    ┃ Stage changes for commit   ┃
    ┃ gunadd <file>                     ┃ Unstage, keep changes      ┃
    ┃ git reset HEAD <file>             ┃ (Same as gunadd)           ┃
    ┃ git checkout -- <file>            ┃ Discard local changes      ┃
    ┃ git restore --staged <file>       ┃ Unstage, keep changes      ┃
    ┃ git restore <file>                ┃ Discard local changes      ┃
    ┃ git reset --soft HEAD~1           ┃ Undo commit, keep staged   ┃
    ┃ git reset --mixed HEAD~1          ┃ Undo commit, unstage files ┃
    ┃ git reset --hard HEAD~1           ┃ Undo commit & changes!     ┃
    ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━=━━┛

    `gunadd` is an alias for:
       git reset HEAD <file>    # Unstages, but keeps file changes

    Use `git reset --hard` with caution—it nukes all changes⚠

GIT_DOC
# ==========================================================
# Shell Behavior Enhancements
# ==========================================================
# Enable bash history features
HISTCONTROL=ignoreboth
HISTSIZE=5000
HISTFILESIZE=10000
shopt -s histappend checkwinsize
# Set a colored prompt
force_color_prompt=yes
if [ -n "$force_color_prompt" ]; then
    if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
        color_prompt=yes
    fi
fi
if [ "$color_prompt" = yes ]; then
    PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
else
    PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w\$ '
fi
# enable programmable completion features
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    export LS_COLORS="$LS_COLORS:ow=30;44:" # fix ls color for folders with 777 permissions
fi
# ==========================================================
# Colorized Output Functions
# ==========================================================
# Define basic ANSI color escape codes for named colors
RED='\033[38;5;196m'
GREEN='\033[38;5;46m'
YELLOW='\033[38;5;226m'
BLUE='\033[38;5;21m'
PURPLE='\033[38;5;93m'
NC='\033[0m' # No Color
# NAMED color functions
red() { ct "$RED" "$@"; }
green() { ct "$GREEN" "$@"; }
yellow() { ct "$YELLOW" "$@"; }
blue() { ct "$BLUE" "$@"; }
purple() { ct "$PURPLE" "$@"; }
# Color Picker: Cycles through all 256 available colors in the terminal
cpick() {
    for i in {0..255}; do
        # Print each color number in its respective color
        echo -en "\033[38;5;${i}m${i} \033[0m"
        # Line break after every 16 colors for readability
        if (( (i + 1) % 16 == 0 )); then
            echo # New line
        fi
    done
    # Displaying named colors at the end of the cycle
    echo -e "\nNamed Colors:"
    echo -e "${RED}RED    \033[0m"
    echo -e "${GREEN}GREEN  \033[0m"
    echo -e "${YELLOW}YELLOW \033[0m"
    echo -e "${BLUE}BLUE   \033[0m"
    echo -e "${PURPLE}PURPLE \033[0m"

}
# Function to colorize text using cpick #'s
ct() {
    local color_code="$1"
    shift
    echo -e "${color_code}$*${NC}"
}
echo "$(green "demiurge spectral #'s:.")"
cpick
# ==========================================================
# Custom Functions
# ==========================================================
# HISTORY grep
hg() {
    history | grep --color=auto -i "$@"
}
# Filter command history with reverse sorting and unique results
HG() {
    history | grep -i "$@" | sort -r | uniq
}
# cr - Reverse search through command history
#
# Usage:
#   cr [PATTERN]
#
# This function allows you to search through your command history in reverse order.
# If no PATTERN is provided, it will search for the last executed command.
# If PATTERN is provided, it will search for commands containing that pattern.
#
# The search results are displayed with line numbers, and you can enter the line
# number to re-execute the corresponding command.
#
# Examples:
#   cr         # Search for the last executed command
#   cr apt     # Search for commands containing the pattern "apt"
#   cr 'apt install'  # Search for commands containing the exact phrase "apt install"
#
cr() {
  if [ $# -eq 0 ]; then
    last_cmd="$(fc -ln -1 | sed "s/^\s*//")"
    if [ -n "$last_cmd" ]; then
      history | grep -i "$last_cmd" | uniq
    fi
  else
    history | grep -i "$@" | uniq
  fi
  echo -ne "\033[32m(reverse-i-search)\033[0m"': '
}
# ----------------------------------------------------	
# H - Custom command history filtering
#
# Usage:
#   H [PATTERN]
#
# This function filters and sorts the command history based on the provided PATTERN.
# It removes duplicate commands and sorts the output in reverse chronological order.
#
# The function performs the following steps:
#   1. Excludes lines that represent invocations of the `H` function itself.
#   2. Filters the remaining lines based on the provided PATTERN.
#   3. Sorts the output in reverse order based on the second column (command timestamp).
#   4. Removes duplicate lines, considering all fields except the first (line number).
#   5. Performs a final sorting of the output.
#
# If no PATTERN is provided, it will display the entire command history.
#
# Examples:
#   H             # Show the entire command history
#   H apt         # Show commands containing the pattern "apt"
#   H 'apt install'  # Show commands containing the exact phrase "apt install"
#
H() {
    history | egrep -v '^ *[[:digit:]]+ +H +' | grep "$@" | sort -rk 2 | uniq -f 1 | sort
}
# ----------------------------------------------------
# backup - Create a backup copy of a file
#
# Usage:
#   backup FILENAME
#
# This function creates a backup copy of the specified file with the ".bak" extension.
#
# Arguments:
#   FILENAME - The name of the file to be backed up.
#
# Example:
#   backup important_file.txt
#
# This will create a backup copy named "important_file.txt.bak" in the same directory.
#
function backup() {
    cp "$1" "$1.bak"
}
# alert - Notify when a long-running command completes
#
# Usage:
#   command; alert
#
# This alias is used to notify the user when a long-running command completes.
# It prints the last executed command with the prefix "Command completed: ".
#
# To use it, simply append `; alert` to the end of the command you want to monitor.
#
# Example:
#   sleep 10; alert
#
# This will execute the `sleep 10` command and print "Command completed: sleep 10" when it finishes.
#
alias alert='echo "Command completed: $(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'
# ----------------------------------------------------
cherry() {
    local YELLOW="\033[1;33m"
    local GREEN="\033[1;32m"
    local RED="\033[1;31m"
    local BLUE="\033[1;34m"
    local CYAN="\033[1;36m"
    local RESET="\033[0m"

    echo -e "${YELLOW}Last 10 Commits:${RESET}"
    git log --oneline -n 10 --graph --color

    if [ -z "$1" ]; then
        echo -e "${CYAN}Usage: cpick <commit-hash>${RESET}"
        return 1
    fi

    echo -e "${GREEN}Cherry-picking commit: $1${RESET}"
    git cherry-pick "$1"

    if [ $? -eq 0 ]; then
        echo -e "${BLUE}Successfully applied $1${RESET}"
    else
        echo -e "${RED}Cherry-pick failed! Resolve conflicts and run:${RESET}"
        echo -e "${CYAN}   git cherry-pick --continue${RESET} or ${CYAN}git cherry-pick --abort${RESET}"
    fi
}
# ----------------------------------------------------
# Reverse 'git add' (unstage files)
function gunadd() {
    if [ $# -eq 0 ]; then
        git reset HEAD .
    else
        git reset HEAD "$@"
    fi
    echo "Unstaged: $*"
}
# ----------------------------------------------------
# popx - Pop multiple directories from the directory stack
#
# Usage:
#   popx NUM
#
# This function pops NUM directories from the directory stack and prints the current
# working directory after the operation.
#
# Arguments:
#   NUM - The number of directories to pop from the stack (must be > 0).
#
# If the directory stack is empty or if NUM is less than or equal to 0,
# an error message is displayed, and the function returns with an error code.
#
# Example:
#   popx 3
#
# This will pop the last 3 directories from the stack and print the current
# working directory after the operation.
#
popx() {
  if [ $# -ne 1 ]; then
    echo "Usage: popx <num>"
    return 1
  fi
  num=$1
  if [ $num -le 0 ]; then
    echo "Error: Number must be > 0"
    return 1
  fi
  for ((i=0; i<num; i++)); do
    if [ ${#DIR_STACK[@]} -eq 0 ]; then
      echo "Error: Directory stack empty"
      return 1
    fi
    popd > /dev/null || break
  done
  pwd
}
# ----------------------------------------------------------
# bp - Backport non-hidden files and directories to parent directory
#
# Usage:
#   bp
#
# This function copies all non-hidden files and directories from the current
# directory to the parent directory.
#
# Example:
#   bp
#
bp() {
    cp -r ./* ../
}
# .bp - Backport all files and directories to parent directory
#
# Usage:
#   .bp
#
# This function copies all files and directories (including hidden ones) from the
# current directory to the parent directory.
#
# After copying the files and directories, it prompts the user to confirm whether
# to delete the current directory if it's empty. If the user confirms, it deletes
# the current directory and changes to the parent directory.
#
# Example:
#   .bp
#
.bp() {
  local current_dir="$(pwd)"
  local parent_dir="$(dirname "$current_dir")"
  if [[ "$current_dir" == "/" ]]; then
    echo "Cannot move the root directory."
    return 1
  fi
  shopt -s dotglob
  for item in ./*; do
    if [[ -e "$item" ]]; then
      cp -rv "$item" "$parent_dir" || return
      rm -rf "$item"
    fi
  done
  shopt -u dotglob
  if [[ "$(ls -A "$current_dir")" == "" ]]; then
    read -r -p "Delete empty current directory? [y/N] " response
    if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then
      rmdir "$current_dir" && cd "$parent_dir" || return
      echo "Directory deleted and changed to parent."
    else
      cd "$parent_dir" || return
      echo "Files moved, directory not deleted, changed to parent"
    fi
  else
    cd "$parent_dir" || return
    echo "Files moved, current directory not empty, changed to parent."
  fi
}
fi

# ==========================================================
# Dotfiles Custom Binaries (for C applets, etc.)
# ==========================================================
# Add ~/.dotfiles/bin to PATH
if [ -d "$HOME/.dotfiles/bin" ]; then
    export PATH="$HOME/.dotfiles/bin:$PATH"
fi

alias ploader='ploader'
alias clip='clipbridge'

# Check if tools exist and are executable
if command -v ploader >/dev/null 2>&1; then
    echo "$(green '✓ ploader available')"
fi

# ==========================================================
# CPython/uv/ty
# ==========================================================
# Initialize uv
export UV_ROOT="$HOME/.uv"
[ -f "$UV_ROOT/uv.sh" ] && source "$UV_ROOT/uv.sh"

# Auto-activate or create uv venv
if [ -f ".venv/bin/activate" ]; then
  source .venv/bin/activate >/dev/null 2>&1
elif [ -d "$HOME/workspaces/${PWD##*/}/.venv" ]; then
  uv venv .venv >/dev/null 2>&1
  source .venv/bin/activate >/dev/null 2>&1
fi
