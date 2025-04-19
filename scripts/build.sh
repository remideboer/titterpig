#!/bin/bash

# Exit on error
set -e

# Function to run tests
run_tests() {
    echo "Running tests..."
    flutter test
    if [ $? -ne 0 ]; then
        echo "Tests failed! Aborting build."
        exit 1
    fi
}

# Function to run analysis
run_analysis() {
    echo "Running static analysis..."
    flutter analyze
    if [ $? -ne 0 ]; then
        echo "Static analysis failed! Aborting build."
        exit 1
    fi
}

# Main build process
main() {
    local build_type=$1
    
    # Always run analysis and tests first
    run_analysis
    run_tests
    
    echo "Building for $build_type..."
    case $build_type in
        "debug")
            flutter build $2 --debug
            ;;
        "profile")
            flutter build $2 --profile
            ;;
        "release")
            flutter build $2 --release
            ;;
        *)
            echo "Invalid build type. Use: debug, profile, or release"
            exit 1
            ;;
    esac
}

# Check if platform argument is provided
if [ -z "$2" ]; then
    echo "Usage: $0 <build_type> <platform>"
    echo "Example: $0 debug apk"
    echo "Platforms: apk, appbundle, web, windows, macos, linux, ios"
    exit 1
fi

main "$1" "$2" 