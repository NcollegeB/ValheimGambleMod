param([string]$cmdarg = "")

$TemplateName = "GambleMod"
$TemplateUnityName = "${TemplateName}Unity"
$DefaultValheimPath = "C:\Program Files (x86)\Steam\steamapps\common\Valheim"
$ThunderstoreDeployPath = Join-Path $env:APPDATA "Thunderstore Mod Manager\DataFolder\Valheim\profiles\debug\BepInEx\plugins"

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$repoRoot = Split-Path -Parent $scriptDir
$repoFolderName = Split-Path -Path $repoRoot -Leaf

function Write-EnvironmentProps {
    param(
        [Parameter(Mandatory)]
        [string]$Path,
        [Parameter(Mandatory)]
        [string]$ValheimInstall
    )

    $deployPath = if (Test-Path -Path $ThunderstoreDeployPath) {
        $ThunderstoreDeployPath
    } else {
        '$(VALHEIM_INSTALL)\BepInEx\plugins'
    }

    @(
        '<?xml version="1.0" encoding="utf-8"?>'
        '<Project ToolsVersion="Current" xmlns="http://schemas.microsoft.com/developer/msbuild/2003">'
        '  <PropertyGroup>'
        '    <!-- Needs to be your path to the base Valheim folder -->'
        "    <VALHEIM_INSTALL>$ValheimInstall</VALHEIM_INSTALL>"
        '    <!-- This is the folder where your build gets copied to when using the post-build automations -->'
        "    <MOD_DEPLOYPATH>$deployPath</MOD_DEPLOYPATH>"
        '  </PropertyGroup>'
        '</Project>'
    ) | Set-Content -Path $Path
}

function Update-TextFile {
    param(
        [Parameter(Mandatory)]
        [string]$Path,
        [Parameter(Mandatory)]
        [string]$OldName,
        [Parameter(Mandatory)]
        [string]$NewName
    )

    if (!(Test-Path -Path $Path)) {
        return
    }

    $content = Get-Content -Path $Path -Raw
    $updated = $content -replace [regex]::Escape("${OldName}Unity"), "${NewName}Unity"
    $updated = $updated -replace [regex]::Escape($OldName), $NewName
    $updated = $updated -replace "$OldName has landed", "$NewName has landed"

    if ($updated -ne $content) {
        Set-Content -Path $Path -Value $updated
    }
}

Write-Host ""
Write-Host ""
Write-Host "WELCOME TO GAMBLEMOD RENAMING UTILITY"
Write-Host "-------------------------------------"
Write-Host ""
Write-Host "This script will do the following:"
Write-Host ""
Write-Host "1. Change file names, folder names, and project references from the GambleMod template to your custom solution name."
Write-Host ""
Write-Host "2. Set DoPrebuild.props <ExecutePrebuild> to true."
Write-Host ""
Write-Host "3. Create or refresh Environment.props and point debug builds at your Thunderstore 'debug' profile when available."
Write-Host ""

if ($cmdarg -eq "-nocopy") {
    $Name = $repoFolderName
    $targetRoot = $repoRoot
} else {
    Write-Host "Step 1. Choose one of the following options:"
    Write-Host ""
    Write-Host "1. Rename the solution in this folder to '$repoFolderName'"
    Write-Host ""
    Write-Host "2. Copy this folder to a new folder with a solution name I will choose"
    Write-Host ""
    $selection = Read-Host "Select (1/2)?"

    if ($selection -eq "1") {
        $Name = $repoFolderName
        $targetRoot = $repoRoot
    } else {
        Write-Host ""
        Write-Host "A copy of this folder will be created with a new folder and solution name that you choose."
        $Name = Read-Host "Enter a new name for the solution"
        $parentDir = Split-Path -Parent $repoRoot
        $targetRoot = Join-Path $parentDir $Name

        if (Test-Path -Path $targetRoot) {
            Write-Host ""
            Write-Host "Error: '$targetRoot' already exists."
            Read-Host "Hit Enter to exit"
            Exit 1
        }

        Copy-Item $repoRoot -Destination $targetRoot -Recurse -Exclude @(".vs", ".idea", ".git")
        Write-Host "Created copy at: $targetRoot"
    }
}

if ([string]::IsNullOrWhiteSpace($Name)) {
    Write-Host "Error: empty solution name"
    Read-Host "Hit Enter to exit"
    Exit 1
}

$newUnityName = "${Name}Unity"
$projectDir = Join-Path $targetRoot $TemplateName
$unityDir = Join-Path $targetRoot $TemplateUnityName
$solutionPath = Join-Path $targetRoot "$TemplateName.sln"
$newProjectDir = Join-Path $targetRoot $Name
$newSolutionPath = Join-Path $targetRoot "$Name.sln"

Write-Host ""
Write-Host "     . . . Renaming files and folders to '$Name' . . ."

if (Test-Path -Path $projectDir) {
    Move-Item -Path $projectDir -Destination $newProjectDir
}

if (Test-Path -Path $unityDir) {
    Move-Item -Path $unityDir -Destination (Join-Path $targetRoot $newUnityName)
}

if (Test-Path -Path (Join-Path $newProjectDir "$TemplateName.csproj")) {
    Move-Item -Path (Join-Path $newProjectDir "$TemplateName.csproj") -Destination (Join-Path $newProjectDir "$Name.csproj")
}

if (Test-Path -Path (Join-Path $newProjectDir "$TemplateName.cs")) {
    Move-Item -Path (Join-Path $newProjectDir "$TemplateName.cs") -Destination (Join-Path $newProjectDir "$Name.cs")
}

if (Test-Path -Path $solutionPath) {
    Move-Item -Path $solutionPath -Destination $newSolutionPath
}

Get-ChildItem -Path $targetRoot -File -Recurse |
    Where-Object {
        $_.FullName -notmatch '\\(\.git|\.vs|bin|obj|libraries)\\' -and
        $_.Name -like "*$TemplateName*"
    } |
    Sort-Object FullName -Descending |
    ForEach-Object {
        Rename-Item -Path $_.FullName -NewName ($_.Name.Replace($TemplateName, $Name))
    }

Write-Host "     . . . Replacing internal references to '$TemplateName' with '$Name' . . ."

$filesToUpdate = @(
    $newSolutionPath
    (Join-Path $newProjectDir "$Name.cs")
    (Join-Path $newProjectDir "$Name.csproj")
    (Join-Path $newProjectDir "Properties\AssemblyInfo.cs")
    (Join-Path $targetRoot "README.md")
    (Join-Path $newProjectDir "README.md")
    (Join-Path $newProjectDir "Package\README.md")
    (Join-Path $newProjectDir "Package\manifest.json")
    (Join-Path $targetRoot "scripts\publish.sh")
    (Join-Path $targetRoot "scripts\publish.ps1")
    (Join-Path $targetRoot "scripts\rename.sh")
)

foreach ($file in $filesToUpdate) {
    Update-TextFile -Path $file -OldName $TemplateName -NewName $Name
}

Write-Host ""
Write-Host "Step 2. . . . setting DoPrebuild.props <ExecutePrebuild> to true..."

$prebuildPropsPath = Join-Path $targetRoot "DoPrebuild.props"
if (Test-Path -Path $prebuildPropsPath) {
    ((Get-Content -Path $prebuildPropsPath -Raw) -replace 'False', 'True') | Set-Content -Path $prebuildPropsPath
}

Write-Host ""
Write-Host "Step 3. . . . refreshing Environment.props..."

$environmentPropsPath = Join-Path $targetRoot "Environment.props"
$valheimInstall = $DefaultValheimPath

if (Test-Path -Path $environmentPropsPath) {
    $existingContent = Get-Content -Path $environmentPropsPath -Raw
    $existingMatch = [regex]::Match($existingContent, '<VALHEIM_INSTALL>(.*?)</VALHEIM_INSTALL>')
    if ($existingMatch.Success -and ![string]::IsNullOrWhiteSpace($existingMatch.Groups[1].Value)) {
        $valheimInstall = $existingMatch.Groups[1].Value
    }
}

Write-EnvironmentProps -Path $environmentPropsPath -ValheimInstall $valheimInstall

if (!(Test-Path -Path $ThunderstoreDeployPath)) {
    Write-Host "WARNING: Thunderstore debug profile not found. Environment.props was created with the standard BepInEx plugins path instead."
}

Write-Host ""
Write-Host ""
Write-Host "Success"
Write-Host "-------"
Write-Host ""
Write-Host "The process is complete."
Write-Host "Note that, as stated in the Jotunn docs, the compiler may generate reference errors the first time you build the solution."
Write-Host "If that happens, close Visual Studio, reopen the solution, and build again."
Write-Host ""
Read-Host "Hit Enter to exit"
