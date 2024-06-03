param(
    [string]$BuildDirectory
)

New-Item -ItemType Directory -Force -Path "$BuildDirectory/vdf/System" | Out-Null
New-Item -ItemType Directory -Force -Path "$BuildDirectory/vdf/System/Autorun" | Out-Null
New-Item -ItemType Directory -Force -Path "$BuildDirectory/vdf/System/Autorun/Signatures" | Out-Null
Copy-Item "$BuildDirectory/*.dll" "$BuildDirectory/vdf/System/Autorun/"
Copy-Item "$BuildDirectory/Signatures/*.tsv" "$BuildDirectory/vdf/System/Autorun/Signatures"
Start-Process -FilePath "$PSScriptRoot/GothicVDFS.exe" -ArgumentList "/B","$BuildDirectory/plugin.vs" -WorkingDirectory $BuildDirectory