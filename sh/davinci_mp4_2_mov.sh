for f in *.mp4; do
  ffmpeg -hwaccel cuda -i "$f" \
    -c:v dnxhd -profile:v dnxhr_hq -pix_fmt yuv422p \
    -c:a pcm_s16le \
    "${f%.mp4}.mov"
done
