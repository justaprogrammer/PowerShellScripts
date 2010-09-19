# ----------------------------------------------------------------------------- 
# WARNING: This script is no where near tested enough to be using without 
# the utmost care.
#
# This script will do the followign when its done:
#   Remove duplicate entries from the system path.
#   Check the registry to determine if certain programs are installed.
#   Add the installation folders of said programs to your path if they do 
# not yet exist.
#   Eventually search for windows services to add to your path.
# ----------------------------------------------------------------------------- 


# Paths to add
[string[][]]$newPaths= 
(
    ("7-zip", "hklm:software\7-zip", "Path"),
    ("FarManager 2.0", "hklm:software\Far2", "InstallPath"),
    ("SlikSvn", "hklm:software\SlikSvn\Install", "Location"),
    ("KDIff3", "hklm:software\KDiff3", "InstallDir"),
    ("SlikSvn", "hklm:software\SlikSvn\Install", "Location"),
    ("Vim", "hklm:software\Vim\Gvim", "path")
);

# Get our existing path as an array
$pathArray = $ENV:Path.Split(';');

foreach ($pathInfo in $newPaths) {
    #TODO: encapsulate to a function
    if (Test-Path $pathInfo[1]) {
        $pathInfo[0] + " found"
        $path = (Get-ItemProperty $pathInfo[1] | Where-Object {  $_.Name -eq $pathInfo[2] } )
        if (! $pathArray -contains $path ) {
            "   Appending to path"
            $pathArray += $path
        }
        else {
            "    Already in path"
        }
    }
    else {
        $pathInfo[0] + " not found"
    }
}
# Sort the array and remove duplicates:
$sortedPathArray = sort-object $pathArray -unique

$newPathArray = @()
foreach ($pathItem in $pathArray) {
    if ($newPathArray -contains $pathItem) {
        "Removing DuplicateItem: " + $pathItem;
    }
    else {
        $newPathArray += $pathItem
    }
}

""
"Old Path: " + $ENV:Path
""
""
[string] $newPath = [string]::Join(';', $newPathArray);
# This is where the breakage happens
[Environment]::SetEnvironmentVariable('Path', $newPath, 'Machine')
"New Path: " + $ENV:Path