# Define your paths here
$sourceDir = "gv"
$targetDir = "svg"

# Ensure the source path ends with a backslash for clean string slicing
$sourceDir = (Resolve-Path $sourceDir).Path
if (-not $sourceDir.EndsWith("\")) { $sourceDir += "\" }

Get-ChildItem -Path $sourceDir -Recurse -Include *.dot, *.gv | ForEach-Object {
    # 1. Get the directory name of the current file
    $currentFileDir = $_.DirectoryName
    
    # 2. Strip the $sourceDir prefix to get the strictly relative path
    if ($currentFileDir.StartsWith($sourceDir, [System.StringComparison]::OrdinalIgnoreCase)) {
        $relativePath = $currentFileDir.Substring($sourceDir.Length)
    } else {
        $relativePath = ""
    }
    
    # 3. Combine with target directory
    $destinationFolder = Join-Path $targetDir $relativePath
    
    # 4. Create the nested directory structure if it doesn't exist yet
    if (-not (Test-Path $destinationFolder)) {
        New-Item -ItemType Directory -Path $destinationFolder -Force | Out-Null
    }
    
    # 5. Convert the file
    $outputFile = Join-Path $destinationFolder ($_.BaseName + ".svg")
    dot -Tsvg $_.FullName -o $outputFile
}
