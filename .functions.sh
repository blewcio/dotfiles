# Safe remove
rmr() {
  local TRASH
  if [ ! -n "$1" ]; then
     echo "No file to remove"
     return 1
  fi
  if [ ! -e "$1" ]; then
     echo "$1 does not exist"
     return 1
  fi
  TRASH=~/.Trash/
  echo "Moving $1 to $TRASH" 
  mv $1 $TRASH
}

# Create a folder and move into it in one command
mkcd() { mkdir -p "$@" && cd "$_"; }

# Search and cd to most recent directories (param to prefilter)
t() {
  local fasdlist
  fasdlist=$(fasd -d -l -r $1 | \
    fzf --query="$1 " --select-1 --exit-0 --height=25% --reverse --tac --no-sort --cycle) &&
    cd "$fasdlist"
}

# Time now
now() {
  echo -n "Now is "
  date +"%X, %A, %B %-d, %Y"
}

# Status of the computer
status() {
  { echo -e "\nUptime:"
    uptime -p | sed 's/^/\t/'
    echo -e "Active users:"
    users | sed 's/^/\t/'
    echo -e "Open ports:"
    lsof -Pni4 | grep LISTEN | sed 's/^/\t/'
    # echo -e "Memory:"
    # free -hm | sed 's/^/\t/'
    # echo -e "Disk space:"
    # df -h 2> /dev/null | sed 's/^/\t/'
    # echo -e "Disk inodes:"
    # df -i 2> /dev/null | sed 's/^/\t/'
    # echo -e "Block devices:"
    # lsblk | sed 's/^/\t/'
    # if [[ -r /var/log/syslog ]]; then
      # echo -e "Syslog:"
      # tail /var/log/syslog | sed 's/^/\t/'
    # fi
    # if [[ -r /var/log/messages ]]; then
      # echo -e "Messages:"
      # tail /var/log/messages | sed 's/^/\t/'
    # fi
  } 
}

# Use ripgrep and fzf to search file content
# TODO: Should return just the filename
Rg() {
  local selected=$(
    rg --column --line-number --no-heading --color=always --smart-case "$1" |
      fzf --ansi \
          --delimiter : \
          --preview 'bat --style=full --color=always --highlight-line {2} {1}' \
          --preview-window '~3:+{2}+3/2'
  )
  echo "$selected"
  [ -n "$selected" ] && $EDITOR "$selected"
}

# Purge brew packages 
brew-purge () {
echo "Purging all installed brew packages"
while [[ `brew list | wc -l` -ne 0 ]]; do
  for EACH in `brew list`; do
    brew uninstall --force --ignore-dependencies $EACH
  done
done
echo << EOT
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/uninstall.sh)"
EOT
}

# --------- Functions for video concatenation mts-* ---------
# Move all MTS files to one directory
mts-move() {
  local DIR SUFIX
  echo "Info: You can select file extension to use 'mts-move MP4'"
  DIR=MTS #Default
  SUFIX=MP4
  if [ -n "$1" ]; then
     SUFIX=$1
  fi
  if [ -d "$DIR" ]; then
    echo "$DIR already exists. Aborting...."
    return 1
  fi
  for d in $(ls -d */); do
    mv -v $d/*.$SUFIX .
  done
  mkdir $DIR
  mv -v *.$SUFIX $DIR/
  echo "All *.$SUFIX files moved to $DIR."
}

# Convert master file to 540p
mts-to-540() {
  local DIR ENDING ENDIG540 RESOLUTION INPUT OUTPUT
  DIR=${PWD##*/}
  ENDING=_TV_1080p.mp4
  ENDING540=_540p.mov
  RESOLUTION=960x540
  INPUT=$DIR$ENDING
  OUTPUT=$DIR$ENDING540
  if [ ! -f "$INPUT" ]; then
    echo "$INPUT does not exist. Aborting..."
    return 1
  fi
  if [ -f "$OUTPUT" ]; then
    echo "$OUTPUT does exist. Remove it first."
    return 1
  fi
  echo "Converting $INPUT to $RESOLUTION (libx264, crf 28, framee rate 25) as $OUTPUT"
  ffmpeg -i $INPUT -c:v libx264 -preset slower -s $RESOLUTION -crf 28 -r 25 -c:a copy $OUTPUT
}

# Make a list of MTS files for concatenation with ffmpeg
mts-list() {
  local DIR SUFIX LIST
  echo "Info: You can specify the default directory and default file  extension 'mts-list MTS MP4'"
  LIST=all.list
  SUFIX=MP4
  # DIR=MTS #Default
  if [ -n "$2" ]; then
    SUFIX=$2
  fi
  # if [ -n "$1" ]; then
  # DIR=$1
  # fi
  # Loop through all subdirectories
  # if [ ! -d "$DIR" ]; then
  # echo "$DIR does not exist."
  # return 1
  # fi
  for d in */ ; do
    for f in $d/* ; do
      echo file \'$f\' | tee -a $LIST
    done
  done
  echo "List of videos created as $LIST"
}

# Normalize videos to one format, if from different devices
mts-normalize() {
  local IN_SUFIX OUT_SUFIX
  echo "Info: You can specify the file extension 'mts-normalize MTS'"
  IN_SUFIX=MP4 #Default
  OUT_SUFIX=mp4
  #If provided consider othere file sufix then default
  if [ -n "$1" ]; then
     IN_SUFIX=$1
  fi
  echo "Normalising files: *.$IN_SUFIX"
  for f in *.$IN_SUFIX; do
    echo $f
    ffmpeg -i $f -c:v libx264 -preset slow -crf 19 -c:a aac $f.$OUT_SUFIX
  done
}

# Concatenate video files to one
mts-concat() {
  local LIST DIR FILE_ENDING OUTPUT
  LIST=all.list # Default
  DIR=${PWD##*/}
  FILE_ENDING=_TV_1080p.mp4
  OUTPUT=$DIR$FILE_ENDING
  # If provided, replacee input list
  if [ -n "$1" ]; then
     LIST=$1
  fi
  if [ ! -f "$LIST" ]; then
    echo "$LIST does not exist. Aborting..."
    return 1
  fi
  if [ -f "$OUTPUT" ]; then
    echo "$OUTPUT exists already. Remove it first."
    return 1
  fi
  echo "Input list: $LIST -> Output video: $OUTPUT"
  ffmpeg -f concat -safe 0 -i $LIST -c copy $OUTPUT && echo "\nVideo created: $OUTPUT"
}

# Combine all actions to concatenate video
mts-do-all() {
  mts-move && mts-list && mts-concat
}

# Add timestamp to metadata using ffmpeg
mts-add-timestamp() {
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

# Diplay most interesting zsh key mappings
function keys() {
  local color="$1"
  printf "${color}$2\033[0m\n"
  echo "\033[0;90m" "c-f  Move forward"
  echo "\033[0;90m" "c-b  Move backward"
  echo "\033[0;90m" "c-p  Move up"
  echo "\033[0;90m" "c-n  Move down"
  echo "\033[0;90m" "c-a  Jump to beginning of line"
  echo "\033[0;90m" "c-e  Jump to end of line"
  echo "\033[0;90m" "c-d  Delete forward"
  echo "\033[0;90m" "c-h  Delete backward"
  echo "\033[0;90m" "c-k  Delete forward to end of line"
  echo "\033[0;90m" "c-u  Delete entire line"
}

# Determine size of a file or total size of a directory
# from https://github.com/mathiasbynens
function fs() {
	if du -b /dev/null > /dev/null 2>&1; then
		local arg=-sbh;
	else
		local arg=-sh;
	fi
	if [[ -n "$@" ]]; then
		du $arg -- "$@";
	else
		du $arg .[^.]* ./*;
	fi;
}

# `tre` is a shorthand for `tree` with hidden files and color enabled, ignoring
# the `.git` directory, listing directories first. The output gets piped into
# `less` with options to preserve color and line numbers, unless the output is
# small enough for one screen.
function tree2() {
	tree -aC -I '.git|node_modules|bower_components' --dirsfirst "$@" | less -FRNX;
}

# Change working directory to the top-most Finder window location
function cdf() { # short for `cdfinder`
	cd "$(osascript -e 'tell app "Finder" to POSIX path of (insertion location as alias)')";
}
