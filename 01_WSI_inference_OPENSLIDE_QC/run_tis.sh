#!/bin/bash
# setting
SLIDE_FOLDER="/input"
OUTPUT_DIR="/output"

python wsi_tis_detect.py --slide_folder "$SLIDE_FOLDER" --output_dir "$OUTPUT_DIR"

echo "Tissue Segmentation is completed!"
