#!/bin/bash

# Folder sumber dan tujuan
SRC_DIR="../../week12/danantara/lib"
DEST_DIR="lib"

# Pastikan folder sumber ada
if [ ! -d "$SRC_DIR" ]; then
    echo "Folder sumber $SRC_DIR tidak ditemukan!"
    exit 1
fi

# Cari semua file .dart di dalam lib
find "$SRC_DIR" -type f -name "*.dart" | while read -r file; do
    # Buat path relatif
    REL_PATH="${file#$SRC_DIR/}"
    
    # Lewati file yang sudah kita buat secara manual tadi
    if [ "$REL_PATH" == "core/constants/app_constants.dart" ] || \
       [ "$REL_PATH" == "core/error/exceptions.dart" ] || \
       [ "$REL_PATH" == "core/network/api_client.dart" ] || \
       [ "$REL_PATH" == "core/services/deeplink_service.dart" ]; then
        continue
    fi

    # Buat direktori tujuan jika belum ada
    mkdir -p "$DEST_DIR/$(dirname "$REL_PATH")"
    
    # Copy file
    cp "$file" "$DEST_DIR/$REL_PATH"
    
    # Ganti package name
    sed -i 's/package:dompet_kampus_global/package:bankling/g' "$DEST_DIR/$REL_PATH"
    
    # Add ke git
    git add "$DEST_DIR/$REL_PATH"
    
    # Buat commit message dalam bahasa indonesia
    FILE_NAME=$(basename "$REL_PATH")
    DIR_NAME=$(dirname "$REL_PATH")
    git commit -m "menambahkan dan menyesuaikan implementasi file $FILE_NAME pada modul $DIR_NAME"
done

echo "Selesai menyalin dan melakukan commit per file."
