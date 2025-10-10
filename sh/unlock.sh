#!/bin/bash

#####################################################
#                                                   #
#   This script unlocks sheets lock of Excel file   #
#                                                   #
#   Usage:                                          #
#   $ bash unlock.sh <path to Excel file>           #
#                                                   #
#####################################################

TEMP_DIR="temp/"

fileExt=$(echo "$1" | grep -Eo '\..+$')
outFileName=out$fileExt

if [ "$1" = "-h" ]; then
	echo "Usage: $0 <path to Excel file>"
	exit
fi
if [ -z "$1" ]; then
	echo "[Missing argument] Usage: $0 <path to Excel file>"
	exit 1
fi
if [ ! -f "$1" ]; then
	echo "[Excel file doesn't exist] Usage: $0 <path to Excel file>"
	exit 1
fi
if [ "$fileExt" != ".xlsm" -a "$fileExt" != ".xlsx" ]; then
	echo "[File extension must be .xlsx or .xlsm] Usage: $0 <path to Excel file>"
	exit 1
fi


rm -r "$TEMP_DIR"

echo "Start unlocking..."

unzip -oq $1 -d "$TEMP_DIR" > /dev/null
sheets=(`ls -1 "$TEMP_DIR"xl/worksheets/sheet*.xml`)
for sheet in "${sheets[@]}"; do
	echo "${sheet}"
	cat "${sheet}" | sed 's/<sheetProtection.*\/>//' | tee  "${sheet}" > /dev/null
done

cd "$TEMP_DIR"
zip -rq ../$outFileName *

echo 
echo "Unlocked Excel file: $outFileName"
