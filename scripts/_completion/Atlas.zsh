#compdef Atlas Atlas-backup Atlas-calendar Atlas-contacts Atlas-cookbook Atlas-docs Atlas-gallery Atlas-mail Atlas-mcp Atlas-memory Atlas-notes Atlas-personal Atlas-preset Atlas-research Atlas-sessions Atlas-signature Atlas-skills Atlas-tasks Atlas-theme Atlas-webhook
# Zsh tab-completion for the Atlas umbrella + sub-CLIs.
#
# Drop in any directory on $fpath, e.g.:
#     fpath=(/path/to/atlas-ui/scripts/_completion $fpath)
#     autoload -U compinit; compinit
#
# Then `Atlas <tab>` completes subcommands; `Atlas mail <tab>`
# completes mail subcommands; `Atlas-mail <tab>` works the same.

_ATLAS_scripts_dir() {
    local self="${(%):-%x}"
    while [[ -L "$self" ]]; do self="$(readlink "$self")"; done
    cd "${self:h}/.." && pwd
}

typeset -gA _ATLAS_subs

_ATLAS_refresh() {
    _ATLAS_subs=()
    local dir="$(_ATLAS_scripts_dir)"
    local py="$dir/../venv/bin/python"
    [[ -x "$py" ]] || py="$(command -v python3)"
    local f sub help_out commands
    for f in "$dir"/Atlas-*; do
        [[ -x "$f" ]] || continue
        case "$f" in
            *.bak|*.pyc|*.pre-*) continue ;;
        esac
        sub="${${f:t}#Atlas-}"
        help_out=$("$py" "$f" --help 2>/dev/null) || continue
        commands=$(echo "$help_out" | grep -oE '\{[a-z0-9_,-]+\}' | head -1 \
            | tr -d '{}' | tr ',' ' ')
        _ATLAS_subs[$sub]="$commands"
    done
}

_Atlas() {
    [[ ${#_ATLAS_subs} -eq 0 ]] && _ATLAS_refresh

    local cmd="${words[1]}"

    if [[ "$cmd" == "Atlas" ]]; then
        if (( CURRENT == 2 )); then
            local -a subs=(${(k)_ATLAS_subs} help)
            _describe 'subcommand' subs
            return
        fi
        local sub="${words[2]}"
        if [[ "$sub" == "help" ]] && (( CURRENT == 3 )); then
            local -a subs=(${(k)_ATLAS_subs})
            _describe 'subcommand' subs
            return
        fi
        if (( CURRENT == 3 )); then
            local -a sc=(${(s/ /)_ATLAS_subs[$sub]})
            _describe 'command' sc
            return
        fi
        return
    fi

    # Atlas-foo <tab>
    local sub="${cmd#Atlas-}"
    if (( CURRENT == 2 )); then
        local -a sc=(${(s/ /)_ATLAS_subs[$sub]})
        _describe 'command' sc
        return
    fi
}

_Atlas "$@"
