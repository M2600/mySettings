#!/bin/sh

mapfile -t files < <(find . -type f -name "*.webm" -o -name "*.mp4" -mindepth 1 -maxdepth 1)

echo ${files[@]}

for file in "${files[@]}"; do
	echo "Processing file: $file"
	if [ -f "$file" ]; then
		echo "Converting $file to MP3..."
		ffmpeg -i "$file" -q:a 0 "${file%.*}.mp3" > /dev/null 2>&1
		if [ $? -eq 0 ]; then
			echo "Conversion successful: ${file%.*}.mp3"
		else
			echo "Conversion failed for $file"
		fi
	else
		echo "File not found: $file"
	fi
done
