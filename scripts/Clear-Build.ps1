<#
    .SYNOPSIS
        Clears CMake build directory
    .DESCRIPTION
        Nek\Clear-Build
#>
function Clear-Build {
    $buildDirectory = Get-Item -Path out -ErrorAction SilentlyContinue
    if ($buildDirectory)
    {
        Remove-Item $buildDirectory.FullName -Confirm:$false -Recurse -ErrorAction SilentlyContinue -ErrorVariable $Problem
        if ($Problem) {
            Write-Warning "Some items couldn't be removed: $Problem"
        }
    }
    Write-Host -ForegroundColor green "Build directory clean`n"
}

Export-ModuleMember -Function Clear-Build