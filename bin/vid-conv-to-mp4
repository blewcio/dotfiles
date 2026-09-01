#!/bin/bash

# Video conversion script to H.264, AAC, MP4 with metadata preservation
# Usage: ./convert_video.sh [file or pattern]
# Examples:
#   ./convert_video.sh video.avi
#   ./convert_video.sh *.avi
#   ./convert_video.sh

set -e  # Exit on error

# Color output for messages
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Default file extensions if no argument provided
PATTERN="${1:-./*.{mp4,avi,mkv,mov,flv,wmv,webm}}"

# Counter for processed files
PROCESSED=0
FAILED=0

# Function to convert a single file
convert_video() {
    local file="$1"
    local output="${file%.*}.mp4"
    
    # Skip if file doesn't exist
    if [ ! -e "$file" ]; then
        echo -e "${RED}Error: File not found: $file${NC}"
        ((FAILED++))
        return 1
    fi
    
    # Skip if output file already exists
    if [ -e "$output" ]; then
        echo -e "${YELLOW}Skipping: Output file already exists: $output${NC}"
        return 0
    fi
    
    # Skip if input and output are the same
    if [ "$file" = "$output" ]; then
        echo -e "${YELLOW}Skipping: Input is already MP4: $file${NC}"
        return 0
    fi
    
    echo -e "${GREEN}Converting: $file${NC}"
    
    if ffmpeg -i "$file" \
        -c:v libx264 \
        -crf 18 \
        -preset slow \
        -c:a aac \
        -b:a 192k \
        -movflags +faststart \
        -map_metadata 0 \
        -map_metadata:s:v 0:s:v \
        -map_metadata:s:a 0:s:a \
        "$output"; then
        echo -e "${GREEN}✓ Successfully converted: $output${NC}"
        ((PROCESSED++))
    else
        echo -e "${RED}✗ Failed to convert: $file${NC}"
        ((FAILED++))
        return 1
    fi
}

# Enable extended globbing for pattern matching
shopt -s nullglob
shopt -s extglob

## Main entry / process files
if [ $# -eq 0 ]; then
    # No arguments: show usage information
    echo -e "${YELLOW}Usage: $0 <file(s)>${NC}"
    echo "Examples:"
    echo "  $0 video.avi           # Convert single file"
    echo "  $0 *.avi               # Convert all AVI files"
    echo "  $0 file1.avi file2.mkv # Convert multiple specific files"
    exit 0
else
    # One or more arguments: process all provided files
    for file in "$@"; do
        convert_video "$file"
    done
fi

# Summary
echo ""
echo "=========================================="
echo -e "Conversion Summary:"
echo -e "${GREEN}Processed: $PROCESSED${NC}"
echo -e "${RED}Failed: $FAILED${NC}"
echo "=========================================="

if [ $FAILED -gt 0 ]; then
    exit 1
fi
