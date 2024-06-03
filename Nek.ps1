Remove-Module Nek -ErrorAction Ignore
New-Module -Name Nek -ScriptBlock {
    . $PSScriptRoot/scripts/Clear-Build.ps1
    . $PSScriptRoot/scripts/Get-UnionApiVersion.ps1
    . $PSScriptRoot/scripts/Set-UnionApiVersion.ps1
} | Import-Module

$module = Get-Module Nek
$functions = @()
$longestName = 0
foreach ($command in $module.ExportedCommands.Values)
{
    if ($command.Name.Length -gt $longestName)
    {
        $longestName = $command.Name.Length;
    }
}
foreach ($command in $module.ExportedCommands.Values)
{
    $about = Get-Help $command.Name | Select-Object -Property SYNOPSIS
    $help = Get-Help $command.Name | Select-Object -Property DESCRIPTION
    $spaces = $longestName - 4
    if ($spaces -lt 0)
    {
        $spaces = 0;
    }
    $spaces = " " * ($spaces + 4)
    $params = @()
    :Outer
    foreach ($param in $command.Parameters.Values)
    {
        foreach ($attrib in $param.Attributes)
        {
            if ($attrib.ToString() -eq "System.Management.Automation.AliasAttribute")
            {
                break Outer
            }
        }
        $set = $param.ParameterSets
        $meta = $set.Values[0][0]
        $tags = ""
        if ($meta.IsMandatory)
        {
            $tags = "[Required]"
        }
        $params += "$tags $($param.Name): $($param.ParameterType)"
    }
    $functions += [PSCustomObject]@{
        Module = $command.Module.Name
        Namespace = $command.Name
        Usage = $help.Description.Text
        About = $about.Synopsis
        Arguments = $params
    }
}
$functions | Format-Table -AutoSize
