## [$PROFILE](profile.ps1) - Better Interface for Powershell

> Copy and paste the content of `profile.ps1` into yout `$PROFILE` file. To access it use `notepad $PROFILE`.
> Then run `. $PROFILE`

### Preview - `[git:current_branch +added ~modified -deleted] ~/dir_base_name $`
[Preview](preview.png)

> [!Note]
> You can enable it to show ahead and behind status, by uncommeting the following lines:
```sh
#if ($ahead -gt 0 -or $behind -gt 0) {
#    $gitInfo += " (↑$ahead ↓$behind)"
#}
``` 
