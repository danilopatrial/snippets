function Get-GitInfo {
    try {
        # Check if inside a Git repository
        $isRepo = (git rev-parse --is-inside-work-tree 2>$null)
        if (-not $isRepo) { return "" }

        # Current branch
        $branch = (git rev-parse --abbrev-ref HEAD 2>$null)

        # Status counts
        $statusLines = git status --porcelain
        $added    = ($statusLines | Select-String "^\s*A" | Measure-Object).Count
        $modified = ($statusLines | Select-String "^\s*M" | Measure-Object).Count
        $deleted  = ($statusLines | Select-String "^\s*D" | Measure-Object).Count

        # Ahead/behind relative to remote
        $ahead = 0
        $behind = 0
        $remote = (git rev-parse --abbrev-ref --symbolic-full-name "@{upstream}" 2>$null)
        if ($remote) {
            $syncStatus = git rev-list --left-right --count "$remote...HEAD" 2>$null
            if ($syncStatus) {
                $counts = $syncStatus -split '\s+'
                if ($counts.Length -ge 2) {
                    $behind = [int]$counts[0]
                    $ahead  = [int]$counts[1]
                }
            }
        }

        # Build Git info string
        $gitInfo = "git:$branch"
        #if ($ahead -gt 0 -or $behind -gt 0) {
        #    $gitInfo += " (↑$ahead ↓$behind)"
        #}
        if ($added -gt 0 -or $modified -gt 0 -or $deleted -gt 0) {
            $gitInfo += " +$added ~${modified} -$deleted"
        }

        return $gitInfo
    }
    catch {
        return ""
    }
}


function Prompt {
    #$time = (Get-Date -Format "HH:mm")
    $location = (Split-Path -Leaf (Get-Location))
    $gitInfo = Get-GitInfo
    if ($gitInfo) { $gitInfo = "[$gitInfo]" }

    #Write-Host "[$time]" -ForegroundColor Cyan -NoNewline
    if ($gitInfo) { Write-Host $gitInfo -ForegroundColor Green -NoNewline }
    Write-Host " ~/$location" -NoNewline
    return " $ "
}
