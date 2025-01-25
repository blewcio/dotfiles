# ls pictures with metadata information
# Sort by second column
lspics() {
  if ! [ -x "$(command -v exiftool)" ]; then "exiftool not installed"; return -1; fi

  CMD="exiftool -T -FileName -CreateDate -GPSPosition -c '%.6f' -FileSize -FileCreateDate"
  SORT="| sort -k 2"

  if [ $# -eq 0 ]; then 
    for f in JPG jpg jpeg mp4 mov; do
      count=$(eval "ls -1 *.$f" 2>/dev/null | wc -l | xargs)
      if [ $count != 0 ]; then
        eval "$CMD *.$f $SORT"
        echo ""
      fi
    done
  else
    eval "$CMD $@ $SORT"
  fi
}

#Convert timestamp to readable date
epoch2date() {
  if [ $# -ne 1 ]; then echo "Usage: epoch2date TIMESTAMP"; return -1; fi
  date -j -f %s $1 +"%Y-%m-%dT%H:%M:%SZ"
}

# Rename all pics in a dir by date
pic_rename_to_createdate()
{
  if ! [ -x "$(command -v exiftool)" ]; then "exiftool not installed"; return -1; fi
  if [ $# -ne 1 ]; then echo "Usage: command DIR"; return -1; fi

  exiftool -d '%Y%m%d-%H%M%%-03.c.%%e' '-filename<CreateDate' $@
}


# Get create date from metadata
# TODO: CreateDate vs DateTimeOriginal
pic_get_createdate() {
  if ! [ -x "$(command -v exiftool)" ]; then "exiftool not installed"; return -1; fi

  exiftool -T -CreateDate $@
}

# Get create year from metadata
pic_get_createyear () {
  if ! [ -x "$(command -v exiftool)" ]; then "exiftool not installed"; return -1; fi

  exiftool -d "%Y" -DateTimeOriginal -S -s $@
}

# Calculate time difference between two pictures
pic_diff_createdate () {
  if ! [ -x "$(command -v datediff)" ]; then "datediff not installed"; return -1; fi
  if [ $# -ne 2 ]; then echo "Usage: command FILE1 FILE2"; return -1; fi

  d1=$(pic_get_createdate $1)
  d2=$(pic_get_createdate $2)
  datediff -f "%Y:%m:%d %H:%M:%S" -i "%Y:%m:%d %H:%M:%S" "$d1" "$d2"
}

# Set picture location
pic_get_location() {
  exiftool -T -GPSPosition -c '%.9f' $@
}

# Set picture location
pic_set_location() {
  if ! [ -x "$(command -v exiftool)" ]; then "exiftool not installed"; return -1; fi

   for i in "$@"; do
    case $i in
      --lon)
        LON="$2"
        shift # past value
        shift # past value
        ;;
      --lat)
        LAT="$2"
        shift # past value
        shift # past value
        ;;
      -*|--*)
        if [ $# -ne 1 ]; then echo "Usage: command --lon XX.XXXXX --lat XX.XXXXX file"; return -1; fi
        return -1
        ;;
      *)
        ;;
    esac
  done

  echo "WARNING: N E lon/lat are pre-defined!"

  if [ -z $LON ]; then echo "Longitude not set. Example: ./command -lon XX.XXXXX -lat XX.XXXXX test.jpg"; return -1; fi
  if [ -z $LAT ]; then echo "Latitude not set. Example: ./command -lon XX.XXXXX -lat XX.XXXXX est.jpg"; return -1; fi

   exiftool -gpslatitude=$LAT -gpslongitude=$LON -gpslatituderef=N -gpslongituderef=E $@
}

# Scan dupliates, but strip exif metadata
# Note: it displays all files grouped by checksum
pic_scan_dupes_no_metadata() {
  if ! [ -x "$(command -v fclones)" ]; then "fclones not installed"; return -1; fi
  if ! [ -x "$(command -v exiv2)" ]; then "exiv2 not installed"; return -1; fi

  fclones group $@ -i --transform 'exiv2 -d a $IN' --in-place 
}

# Scan duplicates (no preprocessing
pic_scan_dupes() {
  if ! [ -x "$(command -v fclones)" ]; then "fclones not installed"; return -1; fi

  fclones group $@
}

# Set create date in metadata
pic_set_createdate () {
  if ! [ -x "$(command -v exiftool)" ]; then "exiftool not installed"; return -1; fi

  for i in "$@"; do
    case $i in
      -d|--date)
        DATE="$2"
        shift # past argument
        shift # past value
        ;;
      -*|--*)
        if [ $# -ne 1 ]; then echo "Usage: command -d 'date' files. Example: ./command -d '2017-07-28T20:58:25Z' test.jpg"; return -1; fi
        return -1
        ;;
      *)
        ;;
    esac
  done

  if [ -z $DATE ]; then echo "Date not set. Example: ./command -d '2017-07-28T20:58:25Z' test.jpg"; return -1; fi

  exiftool -AllDates=$DATE $@
}

# Change create date in metadata by offset value
pic_offset_date () {
  if ! [ -x "$(command -v exiftool)" ]; then "exiftool not installed"; return -1; fi

  for i in "$@"; do
    case $i in
      -b|--backwards)
        DIRECTION="-"
        shift
        ;;
      -f|--forewards)
        DIRECTION="+"
        shift
        ;;
      -d|--date)
        DATE="$2"
        shift # past argument
        shift # past value
        ;;
      -*|--*)
        if [ $# -ne 1 ]; then echo "Usage: command -b||-f -d 'date' files. Example: ./command -f -d '0:0:1 00:40:0' test.jpg"; return -1; fi
        return -1
        ;;
      *)
        ;;
    esac
  done

  if [ -z $DATE ]; then echo "Date or direction not set. Example: ./command -b||-f -d '0:0:149 20:48:0' test.jpg"; return -1; fi
  if [ -z $DIRECTION ]; then echo "Direction not set (forewards or backwards). Example: ./command -b||-f -d '0:0:149 20:48:0' test.jpg"; return -1; fi

  exiftool -AllDates$DIRECTION=$DATE $@
}

# Copy create date
pic_copy_createdate () {
  if ! [ -x "$(command -v exiftool)" ]; then "exiftool not installed"; return -1; fi
  if [ $# -lt 2 ]; then echo "Usage: command master_file modify_files"; return -1; fi

  master_file=$1
  shift

  exiftool -tagsfromfile $master_file -AllDates $@
}

# Copy pictures location
pic_copy_location () {
  if ! [ -x "$(command -v exiftool)" ]; then "exiftool not installed"; return -1; fi
  if [ $# -lt 2 ]; then echo "Usage: command master_file modify_files"; return -1; fi

  master_file=$1
  shift

  exiftool -tagsfromfile $master_file -gps:all $@
}

# Set files times to metadata times
pic_correct_filedate () {
  if ! [ -x "$(command -v exiftool)" ]; then "exiftool not installed"; return -1; fi

  exiftool '-filemodifydate<datetimeoriginal' -r -if '$datetimeoriginal ne substr($filemodifydate,0,19)' $@
}

# Dump all dates from file
pic_dump_dates () {
  if ! [ -x "$(command -v exiftool)" ]; then "exiftool not installed"; return -1; fi

  exiftool -AllDates -FileCreateDate -FileModifyDate -FileAccessDate $@
}

# Dump all times from file
pic_dump_times () {
  if ! [ -x "$(command -v exiftool)" ]; then "exiftool not installed"; return -1; fi
  
  exiftool -s -time:all $@
}
