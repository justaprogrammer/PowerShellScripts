# Copyright (c) 2010 Justin Dearing <zippy1981 at gmail dot com>
# 
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
# 
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.


# ----------------------------------------------------------------------------- 
# WARNING: This script is not tested enough to be using without the utmost care.
#
# This script will do the following when its done:
#   Remove duplicate entries from the system path.
#   Check the registry to determine if certain programs are installed.
#   Add the installation folders of said programs to your path if they do 
# not yet exist.
#   Eventually search for windows services to add to your path.
# ----------------------------------------------------------------------------- 


# Paths to add
[string[][]] $newPaths= 
(
    ("7-zip", "hklm:software\7-zip", "Path"),
    ("FarManager 2.0", "hklm:software\Far2", "InstallDir"),
    ("FarManager 2.0 x64", "hklm:software\Far2", "InstallDir_x64"),
    ("SlikSvn", "hklm:software\SlikSvn\Install", "Location"),
    # TODO: Figure out how to get the path of KDiff3
    #("KDIff3", "hklm:software\KDiff3", "InstallDir"),
    ("SlikSvn", "hklm:software\SlikSvn\Install", "Location"),
    ("Vim", "hklm:software\Vim\Gvim", "path")
);

# Get our existing path as an array
$pathArray = @()

foreach ($pathItem in [Environment]::GetEnvironmentVariable('Path', 'Machine').Split(';')) {
    # Remove trailing \ if any
    $pathItem = $pathItem.TrimEnd(('\'));
    if ($pathArray -contains $pathItem) {
        "Removing duplicate item: " + $pathItem;
    }
    else {
        "Keeping item: " + $pathItem;
        $pathArray += $pathItem
    }
}

# Append new paths.
foreach ($pathInfo in $newPaths) {
    #TODO: encapsulate to a function
    if (Test-Path $pathInfo[1]) {
        
        [string] $path = (Get-ItemProperty $pathInfo[1]).($pathInfo[2])
        if (-not [string]::IsNullOrEmpty($path)) {
            $pathInfo[0] + " found"
            if ($pathArray -notcontains $path ) {
                $path = $path.TrimEnd(('\'));
                "   Appending " + $path + " to path"
                $pathArray += $path
            }
            else {
                "    " + $path + "  already in path"
            }
        }
    }
    else {
        $pathInfo[0] + " not found"
    }
}

""
"Old Path: " + $ENV:Path
""
""
[string] $newPath = [string]::Join(';', $pathArray);
# This is where the breakage happens
[Environment]::SetEnvironmentVariable('Path', $newPath, 'Machine');
"New Path: " + [Environment]::GetEnvironmentVariable('Path', 'Machine')