# Functions for video processing

# Internal helper func for video transcoding
# unset in the bottom of the file
_vid_transcode () {
  local in_file out_file res fps crf preset
  local cmd cmd_bitrate

  if [ $# -lt 5 ]; then echo "Wrong number of arguments"; return -1; fi
  if [ -n "$1" ]; then in_file=$1; fi
  if [ -n "$2" ]; then res=$2; fi
  if [ -n "$3" ]; then fps=$3; fi
  if [ -n "$4" ]; then crf=$4; fi
  if [ -n "$5" ]; then preset=$5; fi
  if [ -n "$6" ]; then maxrate=$6; fi
  if [ -n "$7" ]; then bufsize=$7; fi

  if [ ! -f "$in_file" ]; then
    echo "'$in_file' does not exist. Aborting..."
    return -1
  fi

  out_file=$res-$1
  if [ -f "$out_file" ]; then
    echo "'$out_file' already exists. Remove it first."
    return -1
  fi

  # Optional bitrate command
  if [ -n "$bufsize" ]; then
    cmd_bitrate="-maxrate $maxrate -bufsize $bufsize"
  fi

  # ffmpeg -i $1 -c:v libx264 -maxrate $MAX_RATE -bufsize $BUF_SIZE -vf "scale=$RESOLUTION" -crf $CRF -preset $PRESET -c:a copy $out_file
  #TODO: Set default codec to l264?
  cmd="ffmpeg -i $in_file -vf \"scale=$res,fps=$fps\" -crf $crf -preset $preset -c:a copy $cmd_bitrate $out_file" 
  echo $cmd
  eval $cmd
}

# Convert file to 1080 mts_to_1080 
# Usage: filename [optional_new_name]
vid_to_1080 () {
  if [ $# -lt 1 ]; then echo "Usage: command ARGUMENT"; return -1; fi
  local in_file=$1
  local res=1920x1080
  local fps="25/1"
  local suffix=1080p
  local crf=21
  local preset=slow

  _vid_transcode $in_file $res $fps $crf $preset
}

# Convert file to 720 mts_to_720 
# Usage: filename [optional_new_name]
vid_to_720 () {
  if [ $# -lt 1 ]; then echo "Usage: command ARGUMENT"; return -1; fi
  local in_file=$1
  local res=1280x720
  local fps="30/1"
  local suffix=720p_30fps
  local crf=21
  local preset=slow

  _vid_transcode $in_file $res $fps $crf $preset
}

# Convert file to 540 mts_to_540 
vid_to_540 () {
  if [ $# -lt 1 ]; then echo "Usage: command ARGUMENT"; return -1; fi
  local in_file=$1
  local res=960x540
  local fps="25/1"
  local suffix=540p
  local crf=21 # 0 Best, 23 default, 50 worst
  local preset=slow
  local max_rate=1050k # 1050k for 540, 2350-3000 for 1080p
  local buf_size=2100k # How frequently to check bitrate

  _vid_transcode $in_file $res $fps $crf $preset $max_rate $buf_size
}

vid_to_aac () {
  if [ $# -lt 1 ]; then echo "Usage: command ARGUMENT"; return -1; fi
  ffmpeg -i $1 -c:v copy -c:a aac -ac 2 -b:a 192k $1_192aac.mp4
}

# Get video file resolution as a string
vid_get_res () {
  if [ $# -ne 1 ]; then echo "Usage: command ARGUMENT"; return -1; fi
  if [ ! -f "$1" ]; then echo "'$1' does not exist. Aborting..."; return 1; fi
  # From https://superuser.com/questions/841235/how-do-i-use-ffmpeg-to-get-the-video-resolution
  # Tail -1, because of parsing problems with some MTS files
  ffprobe -v error -select_streams v:0 -show_entries stream=width,height -of csv=s=x:p=0 $1 | tail -1
}

# Get video file framerate as a string
vid_get_fps () {
  if [ $# -ne 1 ]; then echo "Usage: command ARGUMENT"; return -1; fi
  if [ ! -f "$1" ]; then echo "'$1' does not exist. Aborting..."; return 1; fi
  # Tail -1, because of parsing problems with some MTS files
  ffprobe -v error -select_streams v:0 -show_entries stream=avg_frame_rate -of default=noprint_wrappers=1:nokey=1 $1 | tail -1 | bc -l
}

# Make a list of MTS files for concatenation with ffmpeg
vid_make_playlist() {
  if [ $# -lt 1 ]; then echo "Usage: command DIR1 DIR2 DIR3. It will append output to the play.list file."; return -1; fi
  local default_file=play.list
  for d in $@ ; do
    for f in $d/* ; do # Pull files from subdirectories
      ext="${f##*.}"
      if [ $ext = 'mp4' ] || [ "$ext" = "MP4" ] || [ "$ext" = "MTS" ] || [ "$ext" = "mov" ] || [ "$ext" = "MOV" ]; then
        echo "file '$f'" | tee -a $default_file
      fi
    done
  done
  echo "Playlist created as '$default_file'"
}

# Set location, reuse exif implementation for pic_
vid_set_location() {
  pic_set_location $@
}

# Set location, reuse exif implementation for pic_
vid_get_location() {
  pic_get_location $@
}

# Dump dates, reuse exif implementation for pic_
vid_dump_dates() {
  pic_dump_dates $@
}

# Dump times, reuse exif implementation for pic_
vid_dump_times() {
  pic_dump_times $@
}

# Set create date, reuse exif implementation for pic_
vid_set_createdate() {
  pic_set_createdate $@
}

# Add timestamp to metadata using ffmpeg
# Old ffmpeg based code, not sure if it not transcoding
vid_set_timestamp_old() {
  echo "This function should not be used without checking it again!"
  if [ ! -n "$1" ]; then
     echo "Usage: mts-add-timestamp filename"
     return -1
  fi
  if [ ! -f "$1" ]; then
    echo "$1 does not exist. Aborting..."
    return -1
  fi
  DATE_FFMPEG=$(stat -f "%Sm" -t "%Y%m%dT%H%M%SZ" $1)
  DATE_TOUCH=$(date -r $1 +'%Y%m%d%H%M.%S')
  ffmpeg -i $1 -c copy -map 0 -metadata creation_time="$DATE_FFMPEG" $1.mp4
  # echo "ffmpeg date = $DATE_FFMPEG"
  echo "Timestamp: $DATE_TOUCH"
  touch -t $DATE_TOUCH $1.mp4
}

# Concatenate video files (of the same format)
vid_concat() {
  if [ $# -ne 2 ]; then echo "Usage: command PLAYLIST OUTPUTFILE"; return -1; fi
  local playlist out_file

  if [ -n "$1" ]; then playlist=$1; fi
  if [ -n "$2" ]; then out_file=$2; fi

  if [ ! -f "$playlist" ]; then echo "'$1' does not exist. Aborting..."; return 1; fi
  if [ -f "$out_file" ]; then echo "'$1' exists. Remove it first..."; return 1; fi

  cmd="ffmpeg -f concat -safe 0 -i $playlist -c copy $out_file"
  echo $cmd
  eval $cmd
}
