function GetConfigProperty
{
    param(
        [string]$Name,
        [bool]$ReturnFirst = $true
    )
    $configuration = Get-Content -Path "$PSScriptRoot\..\Configuration.cmake"
    $matches = $configuration | Select-String -Pattern "set\($Name\s*`"?([^`"]+)`"?" -AllMatches
    $results = @()
    foreach ($match in $matches.Matches)
    {
        $results += $match.Groups[1]
    }
    if ($ReturnFirst -eq $true)
    {
        return $results[0]
    }
    return $results
}

function SetConfigProperty
{
    param(
        [string]$Name,
        [string]$Value
    )
    $configuration = Get-Content -Path "$PSScriptRoot\..\Configuration.cmake"
    Set-Content -Path "$PSScriptRoot\..\Configuration.cmake.bak" -Value $configuration
    $changed = $configuration
    $Matches = $configuration | Select-String -Pattern "set\($Name\s*`"?([^`"]+)`"?" -AllMatches
    foreach ($match in $Matches.Matches)
    {
        $from = $match.Value
        $old = $match.Groups[1]
        $to = $from.Replace($old, $Value)
        $changed = $changed -replace "set\($Name\s*`"?([^`"]+)`"?","set($Name `"$Value`""
        Write-Host "Changed configuration " -NoNewline
        Write-Host -ForegroundColor Cyan $Name -NoNewline
        Write-Host -ForegroundColor Gray " = " -NoNewline
        Write-Host -ForegroundColor Green $old
        Write-Host "             to value " -NoNewline
        Write-Host -ForegroundColor Cyan $Name -NoNewline
        Write-Host -ForegroundColor Gray " = " -NoNewline
        Write-Host -ForegroundColor Green $Value
    }
    Set-Content -Path "$PSScriptRoot\..\Configuration.cmake" -Value $changed
}

function GetRepositoryReleases
{
    $result = GetConfigProperty -Name "UNION_API_URL" -ReturnFirst $false
    if (-not $result)
    {
        Write-Error "Not found configuration: UNION_API_URL"
        return;
    }

    $url = $result[0];
    $matcher = $url | Select-String -Pattern "^https:\/\/github\.com\/([^\/]+)\/([^\/]+)"
    if ($matcher.Matches.Length -eq 0)
    {
        Write-Error "UNION_API_URL is not a GitHub repository ($url)"
        return
    }

    $owner = $matcher.Matches[0].Groups[1]
    $repo = $matcher.Matches[0].Groups[2]
    $uri = "https://api.github.com/repos/$owner/$repo/releases"

    $request = @{
        Method = "GET"
        Uri = $uri
        Headers = @{
            Accept = "application/vnd.github+json"
            "X-GitHub-Api-Version" = "2022-11-28"
        }
    }
    return Invoke-RestMethod -Uri $uri
}

function GetUnionAPIVersion {
    $commitRef = GetConfigProperty -Name "UNION_API_COMMIT_REF" -ReturnFirst $true
    $commit = $commitRef.ToString().replace("tags/", "")
    $binary = GetConfigProperty -Name "UNION_API_VERSION" -ReturnFirst $true
    return [PSCustomObject]@{
        CommitRef = $commitRef
        Commit = $commit
        Binary = $binary
    }
}

