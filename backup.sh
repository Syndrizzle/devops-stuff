#!/bin/bash

# 📦 Backup Script

# Usage: ./backup.sh [source_directory] [destination_directory] [-c] [-e exclude_pattern]

# Check for required dependencies
REQUIRED_CMDS=("tar" "rsync" "du" "df")
for cmd in "${REQUIRED_CMDS[@]}"; do
    if ! command -v "$cmd" >/dev/null 2>&1; then
        echo "❌ Error: Required command '$cmd' is not installed. Please install it first."
        exit 1
    fi
done

# Display help if insufficient arguments are provided
if [ $# -lt 2 ]; then
    echo "🤔 Insufficient arguments supplied."
    echo "💬 Usage: $0 [source_directory] [destination_directory] [-c] [-e exclude_pattern]"
    echo "💡 Use '-c' flag to compress the backup into a .tar.gz file."
    echo "💡 Use '-e' to specify patterns or files to exclude."
    exit 1
fi

# Variables
SOURCE_DIR="$1"
shift
DEST_DIR="$1"
shift
COMPRESS_FLAG=""
EXCLUDE_PATTERN=""
LOG_FILE="backup.log"
TIMESTAMP=$(date +"%Y-%m-%d_%H-%M-%S")
SOURCE_NAME=$(basename "$SOURCE_DIR")
TRUNCATED_NAME=$(echo "$SOURCE_NAME" | cut -c1-25)

# Parse optional flags
while (( "$#" )); do
    case "$1" in
        -c)
            COMPRESS_FLAG="true"
            shift
            ;;
        -e)
            EXCLUDE_PATTERN="$2"
            shift 2
            ;;
        *)
            echo "❌ Unknown option: $1"
            exit 1
            ;;
    esac
done

# Logging function
log_message() {
    echo "$TIMESTAMP : $1" | tee -a "$LOG_FILE"
}

# Check if source directory exists
if [ ! -d "$SOURCE_DIR" ]; then
    log_message "❌ Source directory '$SOURCE_DIR' does not exist."
    exit 1
else
    log_message "✅ Source directory found: '$SOURCE_DIR'"
fi

# Check if destination directory exists; create if it doesn't
if [ ! -d "$DEST_DIR" ]; then
    log_message "📂 Destination directory '$DEST_DIR' does not exist."
    log_message "🛠️  Creating destination directory..."
    mkdir -p "$DEST_DIR"
    if [ $? -eq 0 ]; then
        log_message "✅ Destination directory created."
    else
        log_message "❌ Failed to create destination directory."
        exit 1
    fi
else
    log_message "✅ Destination directory found: '$DEST_DIR'"
fi

# Disk space check
REQUIRED_SPACE=$(du -s "$SOURCE_DIR" | awk '{print $1}')
AVAILABLE_SPACE=$(df "$DEST_DIR" | tail -1 | awk '{print $4}')
if [ "$AVAILABLE_SPACE" -lt "$REQUIRED_SPACE" ]; then
    log_message "❌ Not enough disk space in destination directory."
    exit 1
fi

# Backup process
if [ "$COMPRESS_FLAG" == "true" ]; then
    BACKUP_FILE="$DEST_DIR/${TRUNCATED_NAME}_$TIMESTAMP.tar.gz"
    log_message "🗜️ Compressing and backing up files..."
    if [ -n "$EXCLUDE_PATTERN" ]; then
        log_message "🚫 Excluding pattern: '$EXCLUDE_PATTERN'"
        tar -czf "$BACKUP_FILE" --exclude="$EXCLUDE_PATTERN" "$SOURCE_DIR" 2>>"$LOG_FILE" &
    else
        tar -czf "$BACKUP_FILE" "$SOURCE_DIR" 2>>"$LOG_FILE" &
    fi
    PID=$!
else
    log_message "📥 Copying files to destination..."
    if [ -n "$EXCLUDE_PATTERN" ]; then
        log_message "🚫 Excluding pattern: '$EXCLUDE_PATTERN'"
        rsync -avh --progress --exclude="$EXCLUDE_PATTERN" "$SOURCE_DIR"/ "$DEST_DIR"/ 2>>"$LOG_FILE"
    else
        rsync -avh --progress "$SOURCE_DIR"/ "$DEST_DIR"/ 2>>"$LOG_FILE"
    fi
fi

# Progress indicator for compression
if [ "$COMPRESS_FLAG" == "true" ]; then
    log_message "⌛ Backup in progress..."
    wait $PID
    if [ $? -eq 0 ]; then
        log_message "✅ Backup compressed and saved to '$BACKUP_FILE'."
    else
        log_message "❌ Compression failed."
        exit 1
    fi
fi

# Cleanup: Remove backups older than 7 days
OLD_BACKUPS=$(find "$DEST_DIR" -type f -name "${TRUNCATED_NAME}_*.tar.gz" -mtime +7)
if [ -n "$OLD_BACKUPS" ]; then
    log_message "🧹 Cleaning up old backups..."
    find "$DEST_DIR" -type f -name "${TRUNCATED_NAME}_*.tar.gz" -mtime +7 -exec rm {} \;
    log_message "✅ Old backups removed."
fi

log_message "🎉 Backup process completed successfully!"

exit 0