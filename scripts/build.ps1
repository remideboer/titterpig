# Function to run tests
function Run-Tests {
    Write-Host "Running tests..."
    flutter test
    if ($LASTEXITCODE -ne 0) {
        Write-Host "Tests failed! Aborting build."
        exit 1
    }
}

# Function to run analysis
function Run-Analysis {
    Write-Host "Running static analysis..."
    flutter analyze
    if ($LASTEXITCODE -ne 0) {
        Write-Host "Static analysis failed! Aborting build."
        exit 1
    }
}

# Main build process
function Main {
    param (
        [string]$BuildType,
        [string]$Platform
    )
    
    # Always run analysis and tests first
    Run-Analysis
    Run-Tests
    
    Write-Host "Building for $BuildType..."
    switch ($BuildType) {
        "debug" {
            flutter build $Platform --debug
        }
        "profile" {
            flutter build $Platform --profile
        }
        "release" {
            flutter build $Platform --release
        }
        default {
            Write-Host "Invalid build type. Use: debug, profile, or release"
            exit 1
        }
    }
}

# Check if arguments are provided
if ($args.Count -lt 2) {
    Write-Host "Usage: .\build.ps1 <build_type> <platform>"
    Write-Host "Example: .\build.ps1 debug apk"
    Write-Host "Platforms: apk, appbundle, web, windows, macos, linux, ios"
    exit 1
}

Main $args[0] $args[1] 