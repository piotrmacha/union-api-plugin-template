<#
    .SYNOPSIS
        Shows the available versions of Union API
    .DESCRIPTION
        Nek\Get-UnionApiVersion
#>
function Get-UnionApiVersion
{
    . "$PSScriptRoot/CommonFunctions.ps1"

    $fetchType = GetConfigProperty -Name "UNION_API_FETCH_TYPE" -ReturnFirst $true
    $version = GetUnionAPIVersion

    if ("$fetchType" -eq "SOURCE")
    {
        Write-Host "Union API fetch:`t" -NoNewline
        Write-Host -ForegroundColor Cyan "SOURCE"
        Write-Host "Union API commitRef:`t" -NoNewline
        Write-Host -ForegroundColor Yellow "$($version.CommitRef)"
        Write-Host "Union API version:`t" -NoNewline
        Write-Host -ForegroundColor Yellow "$($version.Commit)"
    }
    if ("$fetchType" -eq "BINARY")
    {
        Write-Host "Union API fetch:`t" -NoNewline
        Write-Host -ForegroundColor Cyan "BINARY"
        Write-Host "Union API version:`t" -NoNewline
        Write-Host -ForegroundColor Yellow "$($Version.Binary)"
    }

    $rows = @()
    $releases = GetRepositoryReleases
    $first = $releases[0].name
    foreach ($release in $releases)
    {
        $matcher = $release.body | Select-String -Pattern "(Union|Gothic) API\: \[([a-zA-Z0-9]+)\]\(([^\)]+)\)" -AllMatches
        $unionApiRef = "unknonw";
        $gothicApiRef = "unknonw";
        foreach ($match in $matcher.Matches)
        {
            $type = $match.Groups[1]
            $ref = $match.Groups[2]
            if ("$type" -eq "Union")
            {
                $unionApiRef = $ref
            }
            if ("$type" -eq "Gothic")
            {
                $gothicApiRef = $ref
            }
        }
        $rows += [PSCustomObject]@{
            "Version             " = $release.name
            "Union API Ref" = $unionApiRef
            "Gothic API Ref" = $gothicApiRef
            Date = $release.published_at
        }
    }
    $rows | Format-Table -AutoSize

    Write-Host "To change the version: " -NoNewline
    Write-Host -ForegroundColor White "Nek\Set-UnionApiVersion [version]"
    Write-Host "To install the newest: " -NoNewline
    Write-Host -ForegroundColor Green ("**Nek\Set-UnionApiVersion $first**" | ConvertFrom-MarkDown -AsVt100EncodedString).VT100EncodedString
}

Export-ModuleMember -Function Get-UnionApiVersion