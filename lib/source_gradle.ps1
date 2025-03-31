# Stop execution if any command fails
$ErrorActionPreference = "Stop"

# Set default Gradle home if environment variable is not set
$gradle_home = if ($env:GRADLE_USER_HOME) { $env:GRADLE_USER_HOME } else { Join-Path $env:USERPROFILE ".gradle" }
$gradle_properties_file = Join-Path $gradle_home "gradle.properties"

# Check if the properties file exists
if (-not (Test-Path $gradle_properties_file)) {
    Write-Error "File $gradle_properties_file does not exist. Cannot source gradle"
    exit 1
}

Write-Output "Found 'gradle.properties' file at $gradle_properties_file"

$GradleProperties = ConvertFrom-StringData (Get-Content $gradle_properties_file -Raw)

# Set environment variables

if(!$GradleProperties.ContainsKey("kitpvpWorldRepositoryUsername")) {
    Write-Error "File $gradle_properties_file does contain property kitpvpWorldRepositoryUsername"
    exit 1
}
$env:repository_username = $GradleProperties."kitpvpWorldRepositoryUsername"
if(!$GradleProperties.ContainsKey("kitpvpWorldRepositoryPassword")) {
    Write-Error "File $gradle_properties_file does contain property kitpvpWorldRepositoryPassword"
    exit 1
}
$env:repository_password = $GradleProperties."kitpvpWorldRepositoryPassword"

Write-Output "Authenticated as '$env:repository_username'"
Write-Output "Saved credentials to environment variables (repository_username, repository_password)"
