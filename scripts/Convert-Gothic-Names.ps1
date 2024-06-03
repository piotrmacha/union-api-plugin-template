<#
    .SYNOPSIS
        Converts a Gothic API Names.txt to the Union format
    .DESCRIPTION
        The Convert-Gothic-Names function reads a file with the export of all Gothic symbols with addresses0
        and converts it to the format supported by Union Framework (tab-separated values)
    .EXAMPLE
        ./Convert-Gothic-Names.ps1 -Filename Path/to/Gothic/Names.txt -OutputFilename Output_Names.tsv
        # Convert file quietly
    .EXAMPLE
        ./Convert-Gothic-Names.ps1 -Filename Path/to/Gothic/Names.txt -OutputFilename Output_Names.tsv -Warnings
        # Print a warning if something can't be converted
    .EXAMPLE
        ./Convert-Gothic-Names.ps1 -Filename Path/to/Gothic/Names.txt -OutputFilename Output_Names.tsv -Warnings -PrintStdOut
        # Output the converted file contents to standard output
#>
param(
    [Parameter(mandatory = $true, HelpMessage = "Input file")]
    [string]$Filename,
    [Parameter(mandatory = $false, HelpMessage = "Output file")]
    [string]$OutputFilename,
    [Parameter(mandatory = $false, HelpMessage = "Enable warnings about not converted line")]
    [switch]$Warnings = $false,
    [Parameter(mandatory = $false, HelpMessage = "Print output on stdout")]
    [switch]$PrintStdOut = $false
)

function Convert-Gothic-Names
{
    param(
        [Parameter(mandatory = $true, HelpMessage = "Input file")]
        [string]$Filename,
        [Parameter(mandatory = $false, HelpMessage = "Output file")]
        [string]$OutputFilename,
        [Parameter(mandatory = $false, HelpMessage = "Enable warnings about not converted line")]
        [switch]$Warnings = $false,
        [Parameter(mandatory = $false, HelpMessage = "Print output on stdout")]
        [switch]$PrintStdOut = $false
    )

    if (-not (Get-Item -Path $Filename).Exists)
    {
        Write-Error "Input file does not exist: $Filename"
        return
    }

    $output = @()
    $lines = Get-Content -Path $Filename
    foreach ($line in $lines)
    {
        $originalLine = $line
        $line = $line.Replace("public: ", "")
        $line = $line.Replace("protected: ", "")
        $line = $line.Replace("private: ", "")
        $line = $line.Replace("static ", "")
        $line = $line.Replace("virtual ", "")
        $line = $line.Replace("enum ", "")
        $line = $line.Replace("struct ", "")
        $line = $line.Replace("[thunk]:", "")

        $matches = [System.Text.RegularExpressions.Regex]::Matches(
                $line,
                "(0x[0-9A-F]+) ([a-zA-Z0-9\s_\*:&<>\(\),]+)?\s?(__[a-z]+) ([a-zA-Z0-9<> \*~]+::)?([^\(]+)\((.*)");

        if (($matches.Count -eq 0) -and ($Warnings))
        {
            Write-Warning "Could not convert: $originalLine"
            Write-Warning "    pre-processed: $line"
        }

        foreach ($match in $matches)
        {
            $address = $match.Groups[1].Value
            $returnType = $match.Groups[2].Value.Trim()
            $callingConvention = $match.Groups[3].Value
            $class = $match.Groups[4].Value.Replace("::", "")
            $name = $match.Groups[5].Value
            $arguments = $match.Groups[6].Value.Replace(",", "`t")
            $arguments = $arguments.Replace("struct ", "")
            $arguments = $arguments.Replace("class ", "")
            $arguments = $arguments.Replace(" *", "*")
            $arguments = $arguments.Replace(" &", "&")
            $arguments = $arguments -replace "\)$",""

            $out = @()
            $out += $address
            $out += $returnType
            $out += $callingConvention
            $out += $class
            $out += $name
            $out += $arguments
            $outstring = [string]::Join("`t", $out)
            $output += $outstring

            if ($PrintStdOut)
            {
                Write-Host $outstring
            }
        }
    }

    if ($OutputFilename)
    {
        Set-Content -Path $OutputFilename -Value ([string]::Join("`n", $output)) -Force -ErrorVariable $ErrorMessage
        if ($ErrorMessage)
        {
            Write-Error "Could not save the file: $ErrorMessage"
        }
    }

    return $output
}

Convert-Gothic-Names @PSBoundParameters | Out-Null
