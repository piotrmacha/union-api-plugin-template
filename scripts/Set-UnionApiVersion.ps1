<#
    .SYNOPSIS
        Sets the Union API version in Configuration.cmake
    .DESCRIPTION
        Nek\Set-UnionApiVersion [version]
#>
function Set-UnionApiVersion
{
    param(
        [Parameter(Position=0, mandatory=$true, HelpMessage="Version got from Get-UnionApiVersion")]
        [string]$Version
    )

    if ($Version -eq "") {
        Write-Error "Usage: Nek\Set-UnionApiVersion [version]"
        return
    }

    . "$PSScriptRoot/CommonFunctions.ps1"

    $current = GetUnionAPIVersion
    Write-Host "[Source] Union API commitRef:`t" -NoNewline
    Write-Host -ForegroundColor Yellow "$($current.CommitRef)"
    Write-Host "[Source] Union API version:`t" -NoNewline
    Write-Host -ForegroundColor Yellow "$($current.Commit)"
    Write-Host "[Binary] Union API version:`t" -NoNewline
    Write-Host -ForegroundColor Yellow "$($current.Binary)"

    $includeTag = $Version.StartsWith("202") -or $Version.StartsWith("v") # Let's make an 2030 millenium problem

    SetConfigProperty -Name "UNION_API_COMMIT_REF" -Value "$($includeTag ? "tags/$Version" : $Version)"
    SetConfigProperty -Name "UNION_API_VERSION" -Value "$Version"

    $current = GetUnionAPIVersion
    Write-Host "[Source] Union API commitRef:`t" -NoNewline
    Write-Host -ForegroundColor Yellow "$($current.CommitRef)"
    Write-Host "[Source] Union API version:`t" -NoNewline
    Write-Host -ForegroundColor Yellow "$($current.Commit)"
    Write-Host "[Binary] Union API version:`t" -NoNewline
    Write-Host -ForegroundColor Yellow "$($current.Binary)"

    Write-Host ""
    Write-Host -ForegroundColor White "Run CMake configure again to apply the changes. You may need to " -NoNewline
    Write-Host -ForegroundColor Green "Nek\Clear-Build" -NoNewline
    Write-Host -ForegroundColor White " first.`n"
}

Export-ModuleMember -Function Set-UnionApiVersion