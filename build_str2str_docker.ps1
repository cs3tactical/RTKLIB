# Build str2str using Docker on Windows (PowerShell)

# Stop on error
$ErrorActionPreference = 'Stop'

# Define image and container names
$imageName = "rtklib-str2str-builder"

# Build the Docker image
$dockerfile = @"
FROM debian:stable-slim

RUN apt-get update && \
    apt-get install -y git build-essential make && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /RTKLIB
COPY . /RTKLIB
WORKDIR /RTKLIB/app/consapp/str2str/gcc
RUN make
"@

$dockerfilePath = "./Dockerfile.str2str"
Set-Content -Path $dockerfilePath -Value $dockerfile -Encoding UTF8

docker build -f $dockerfilePath -t $imageName .

# Remove Dockerfile after build
Remove-Item $dockerfilePath

# Output path for Windows
$outputPath = Join-Path $PWD 'str2str_docker_build'

# Remove any previous output
if (Test-Path $outputPath) { Remove-Item $outputPath }

# Create a container from the image
$containerId = docker create $imageName

# Fix: Ensure $outputPath is an absolute Windows path for docker cp
$outputPathWin = $outputPath -replace "/", "\\"

# Use docker cp with correct path quoting and variable expansion
# On Windows, docker cp expects a Windows path, not Unix-style
# Also, ensure the file extension is .exe for Windows

docker cp "$containerId:/RTKLIB/app/consapp/str2str/gcc/str2str" "$outputPathWin"
docker rm $containerId | Out-Null

Write-Host "str2str built and copied to $outputPathWin"
