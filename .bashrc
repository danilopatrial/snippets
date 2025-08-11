parse_git() {
    git rev-parse --is-inside-work-tree &>/dev/null || return

    local branch
    branch=$(git symbolic-ref --short HEAD 2>/dev/null || git rev-parse --short HEAD 2>/dev/null)

    local status added modified deleted
    status=$(git status --porcelain 2>/dev/null)

    added=$(echo "$status" | grep -E -c '^(A|.A)')
    modified=$(echo "$status" | grep -E -c '^(M|.M)')
    deleted=$(echo "$status" | grep -E -c '^(D|.D)')

    added=${added:-0}
    modified=${modified:-0}
    deleted=${deleted:-0}

    local ahead=0 behind=0
    local remote
    remote=$(git rev-parse --abbrev-ref --symbolic-full-name @{upstream} 2>/dev/null)

    if [[ -n "$remote" ]]; then
        local counts
        counts=$(git rev-list --left-right --count "$remote...HEAD" 2>/dev/null)
        if [[ "$counts" =~ ^[0-9]+[[:space:]][0-9]+$ ]]; then
            behind=$(echo "$counts" | cut -d' ' -f1)
            ahead=$(echo "$counts" | cut -d' ' -f2)
        fi
    fi

    local git_info="$branch"

    if [[ "$ahead" =~ ^[0-9]+$ && "$ahead" -gt 0 ]]; then
        git_info+=" ↑$ahead"
    fi

    if [[ "$behind" =~ ^[0-9]+$ && "$behind" -gt 0 ]]; then
        git_info+=" ↓$behind"
    fi

    if (( added > 0 || modified > 0 || deleted > 0 )); then
        git_info+=" +$added ~$modified -$deleted"
    fi

    echo "$git_info"
}

PS1='\[\e[32m\]$(git_info=$(parse_git); if [[ -n "$git_info" ]]; then echo "[$git_info] "; fi)\[\e[0m\]\[\e[36m\]\W\[\e[0m\] \$ '
