#Requires -Version 5.1 # Optional: Specify minimum required PowerShell version

# Stop script on first error
$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

if (!(Test-Path -Path "languages.toml" -PathType Leaf))
{
    cd ..
}

$downloadHash = "49b2b1a1408b6a3bc71cde227fb16d00c558cda4"
$downloadUrl = "https://maven.kitpvp.world/snapshots/world/kitpvp/translation-compiler/${downloadHash}/translation-compiler-win-x64.exe"
$outputFile = "bin/translation-compiler-${downloadHash}.exe"

New-Item -ErrorAction SilentlyContinue -ItemType HardLink -Path "lib/translation-compiler.exe" -Target "$outputFile"

# --- Check if file already exists ---
if (Test-Path -Path $outputFile -PathType Leaf)
{
    Write-Host "INFO: '$outputFile' binary is already present."
    exit 0
}

# --- Cleanup and Directory Creation ---
Write-Host "INFO: Cleaning up old files"
New-Item -Path "bin" -ItemType Directory -Force | Out-Null
Get-ChildItem -Path "bin" | Remove-Item -Force -Recurse -ErrorAction SilentlyContinue

# --- Perform Download ---
Write-Host "INFO: Preparing to download from URL: $downloadUrl"

if ( [string]::IsNullOrEmpty($env:repository_username))
{
    if (-not [string]::IsNullOrEmpty($env:REPO_KITPVP_USERNAME))
    {
        $env:repository_username = $env:REPO_KITPVP_USERNAME
    }
    else
    {
        Write-Error "'repository_username' is not set, and fallback 'REPO_KITPVP_USERNAME' is also not set or empty."
        exit 1 # Exit with an error
    }
}

if ( [string]::IsNullOrEmpty($env:repository_password))
{
    if (-not [string]::IsNullOrEmpty($env:REPO_KITPVP_PASSWORD))
    {
        $env:repository_username = $env:REPO_KITPVP_PASSWORD
    }
    else
    {
        Write-Error "'repository_password' is not set, and fallback 'REPO_KITPVP_PASSWORD' is also not set or empty."
        exit 1 # Exit with an error
    }
}

# Create credentials object for basic authentication
# Note: Storing/passing passwords in plaintext env vars is insecure. Consider alternatives if possible.
$securePassword = ConvertTo-SecureString -String $env:repository_password -AsPlainText -Force
$credential = New-Object System.Management.Automation.PSCredential($env:repository_username, $securePassword)

Try
{
    # Use Invoke-WebRequest for downloading
    # -UseBasicParsing is often faster for binary downloads
    # -MaximumRedirection handles redirects similar to curl -L
    Invoke-WebRequest -Uri $downloadUrl -Credential $credential -OutFile $outputFile -UseBasicParsing -MaximumRedirection 5
}
Catch
{
    Write-Error "Download failed.`nUri: $downloadUrl`nOutput File: $outputFile`nError Details: $( $_.Exception.Message )"
    # Clean up potentially incomplete file on error
    if (Test-Path -Path $outputFile -PathType Leaf)
    {
        Remove-Item -Path $outputFile -Force -ErrorAction SilentlyContinue
    }
    exit 1
}
