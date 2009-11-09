#!/bin/bash

# Part of the oacdp project.  Takes a directory and scales down all 
# images.  This is part of a chain of utilties to create css sprites
# for display on a webpage in a reasonably effecient way.

# ensure we exit upon error
set -e


# gather the input from the user.
SCRIPT_DIR=`dirname $0`
OACDP_ROOT="${PWD}/${SCRIPT_DIR}/.."
OACDP_OVERLAY_ROOT="${OACDP_ROOT}/out"
OACDP_CSS="${OACDP_ROOT}/src/oacdp.css"

# A function to say how to use the script
function USAGE() {
    echo "$0 [-f|-h|--help]"
    echo "  -f: force regeneration of sprites."
    echo "  -h: this page."
}

USERARG="$1"

# check the user's arg.  Sorry we don't do more than one arg :(
if [ "$USERARG" == "-h" -o "$USERARG" == "--help" ]
then
   USAGE
   exit 0
elif [ "$USERARG" == "-f" -o "$USERARG" == "--force" ]
then
   force="true"
fi

# check our values provided by the user... first the source dir.
if [ -z "$OACDP_OVERLAY_ROOT" ]
then
    USAGE
    echo "You need to specify the overlay root directory."
    exit 1
elif [ ! -d "$OACDP_OVERLAY_ROOT" ]
then
    USAGE
    echo "The overlay directory doesn't exist: $OACDP_OVERLAY_ROOT"
    exit 1
fi

# check if we have convert, which is part of imagemagick
if [ -x "`which convert`" ]
then
    CONVERT_BINARY=`which convert`
    echo "Found $CONVERT_BINARY, cool..."
else
    echo "Couldn't find or execute 'convert', which is part of imagemagik."
    exit 1
fi

if [ -x "`which identify`" ]
then
    IDENTIFY_BINARY=`which identify`
    echo "Found $IDENTIFY_BINARY, cool..."
else
    echo "Couldn't find or execute 'identify', which is part of imagemagik."
    exit 1
fi

if [ -x "`which montage`" ]
then
    MONTAGE_BINARY=`which montage`
    echo "Found $MONTAGE_BINARY, cool..."
else
    echo "Couldn't find or execute 'montage', which is part of imagemagik."
    exit 1
fi

if [ ! -f "$OACDP_CSS" ]
then
    USAGE
    echo "You need to supply a base css file to append to"
fi

mainCSS="${OACDP_OVERLAY_ROOT}/style/oacdp.css"

OACDP_DIRS="5054part 5867part ba4 damage ebersp so42 solex tools wog69 wog72"

# Loop over the different directories with images.
for dir in $OACDP_DIRS
do
    echo "Working on $dir..."
    dirSprite="${OACDP_OVERLAY_ROOT}/${dir}.sprite.jpg"
    dirCSS="${OACDP_OVERLAY_ROOT}/${dir}.css.cache"
    if [ ! -f "$dirSprite" -o ! -f "$dirCSS" -o -n "$force" ]
    then
      baseSprite=`basename ${dirSprite}`
      dirTemp=`mktemp -d /tmp/oacdp.XXXX`

      hPos=0 # the initial horizontal sprite position
      vPos=0 # the initial vertical sprite position

      # Clean out any sprite files are left around.
      if [ -f "$dirSprite" ]
      then
	  rm $dirSprite
      fi

      if [ -f "$dirCSS" ]
      then
  	  rm $dirCSS
      fi

      # TRAP rm $dirTemp $dirCSS $dirSprite

      # Loop over the files and shrink them.
      for file in ${OACDP_OVERLAY_ROOT}/${dir}/*
      do	
	  fileDimentions=`${IDENTIFY_BINARY} ${file} | awk '{print $3}'`
	  fileWidth=`echo ${fileDimentions} | awk -F 'x' '{print $1}'`
	  fileHeight=`echo ${fileDimentions} | awk -F 'x' '{print $2}'`

	  if [ "${fileHeight}" -gt "${fileWidth}" ]
	  then
	      fileRatio=`expr ${fileHeight} / ${fileWidth}`
	  else
	      fileRatio=`expr ${fileWidth} / ${fileHeight}`
	  fi

	  if [ "${fileRatio}" -gt "1" ]
	  then
	      IMAGE_SIZE="200x200" # this is for double wide pages.
	  else
	      IMAGE_SIZE="100x100" # for normal sized pages.
	  fi

	  echo "  working on file $file [${fileDimentions} => ${IMAGE_SIZE}]"
	  base=`basename ${file}`

          # strip out any characters we don't want in the CSS class name.
	  stripped_base=`echo $base | sed 's|[\.+#]|_|g'`

	  tempFile="${dirTemp}/${base}.jpg"

	  # convert the image to a smaller jpeg.
  	  $CONVERT_BINARY $file -resize $IMAGE_SIZE $tempFile
	  # add some css to the file to indicate it's position

	  tempFileDimentions=`${IDENTIFY_BINARY} $tempFile | awk '{print $3}'`
	  tempFileWidth=`echo ${tempFileDimentions} | awk -F 'x' '{print $1}'`
	  tempFileHeight=`echo ${tempFileDimentions} | awk -F 'x' '{print $2}'`

	  # add the css for the sprite.
	  echo "#img${dir}${stripped_base} {" >> $dirCSS
	  echo "  width: ${tempFileWidth}px;" >> $dirCSS
	  echo "  height: ${tempFileHeight}px;" >> $dirCSS
	  echo "  background: transparent url('../${baseSprite}') no-repeat -${hPos}px ${vPos}px;" >> $dirCSS
	  echo "}" >> $dirCSS

	  # Prep for the next sprite.
	  hPos=`expr ${hPos} + ${tempFileWidth}`

	  echo "    ... finished with: ${tempFile}"
      done

      echo "You need a montage: $dirSprite"
      $MONTAGE_BINARY $dirTemp/* -tile x1 -geometry +0+0 -background none $dirSprite

      echo "Cleaning up sprites for dir: $dir"
      rm -r $dirTemp
  else
    echo "Found a sprite for $dir."
  fi
done

# combind all the css into a single file.
echo "Assembling the css."
cat ${OACDP_OVERLAY_ROOT}/*.css.cache >> ${mainCSS}

echo "Finishing up."
exit 0
