function android_moveResourceFiles {
    param (
        [Parameter(Mandatory = $true)]
        [string] $srcDir,
        [Parameter(Mandatory = $true)]
        [string] $dstDir
    )
    process {
        ls $srcDir | 
        ls -Filter "*.webp" -File |
        foreach { 
            $dpiDir = Split-Path -Parent $_ | Split-Path -Leaf ; 
            $filename = (Get-Item $_).Name ; 
            Move-Item -Destination (Join-Path $dstDir $dpiDir $filename) -Path $_
        }
    }
}

function android_handleImageSlicesZip {
    [CmdletBinding()]
    param (
        [Parameter(
            Mandatory = $true
        )]
        [string]
        $zipFile,
        [Parameter(
            Mandatory = $true
        )]
        [string]
        $resourceName,
        [Parameter(
            Mandatory = $true
        )]
        [string]
        $dstResDir
    )

    begin {
        $rand = [System.Random]::new()
        $tmpDirRoot = "$HOME/Downloads/lanhu_slices/"
    }

    process {
        if (-not (Test-Path $zipFile)) {
            Write-Error "[Error] zipResFile not found : $zipFile"
        } elseif (-not (Test-Path $dstResDir)) {
            Write-Error "[Error] dstResDir not found : $dstResDir"
        } else {
            $tmpDirName = $rand.Next()
            $tmpDirPath = Join-Path $tmpDirRoot $tmpDirName
            Expand-Archive -Path $zipFile -DestinationPath $tmpDirPath && 
            android_renameResourceFiles -resourceDir $tmpDirPath -newResourceName $resourceName &&
            android_moveResourceFiles -srcDir $tmpDirPath -dstDir $dstResDir &&
            Remove-Item -Recurse -Force -Path $tmpDirPath
        }
    }

}

function android_renameResourceFiles {
    [CmdletBinding()]
    param (
        [Parameter(
            Mandatory = $true
        )]
        [string]
        $resourceDir,
        [Parameter(
            Mandatory = $true
        )]
        [string]
        $newResourceName
    )

    process {
        ls $resourceDir | ls -Filter '*.webp' -File | Rename-Item -NewName "${newResourceName}.webp"
    }
}

function android_handleImageAllImageSliceZip {
    param (
        [Parameter(Mandatory = $true)]
        [string] $srcDir,
        
        [Parameter(Mandatory = $true)]
        [string]
        $projectResourceDir
    )

    
    $srcExists = Test-Path $srcDir 
    $dstExists = Test-Path $projectResourceDir
    if ($srcExists -and $dstExists){
        $src = $srcDir
        $dst = $projectResourceDir
        cd $src
        ls | foreach { cqs_handleImageSlicesZip -zipFile $_ -resourceName $_.BaseName -dstResDir $dst }
    }
    
}

# function watchNewResources {
#     param (
#         [Parameter(Mandatory = $true)]
#         [string]
#         $srcDir,
#         [Parameter(Mandatory = $true)]
#         [string]
#         $dstDir
#     )
# }

Export-ModuleMember -Function android_handleImageSlicesZip, android_moveResourceFiles, android_renameResourceFiles, android_handleImageAllImageSliceZip