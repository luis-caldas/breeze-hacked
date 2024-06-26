#!/usr/bin/env bash

cd "$(dirname "${BASH_SOURCE[0]}")"
RAWSVG="src/cursors.svg"
INDEX="src/index.theme"
ALIASES="src/cursorList"
OUTPUT_PARENT="out"

echo -ne "Checking Requirements...\\r"
if [ ! -f $RAWSVG ]; then
	echo -e "\\nFAIL: '$RAWSVG' missing in /src"
	exit 1
fi

if [ ! -f $INDEX ]; then
	echo -e "\\nFAIL: '$INDEX' missing in /src"
	exit 1
fi

if ! type "inkscape" >/dev/null; then
	echo -e "\\nFAIL: inkscape must be installed"
	exit 1
fi

if ! type "xcursorgen" >/dev/null; then
	echo -e "\\nFAIL: xcursorgen must be installed"
	exit 1
fi
echo -e "Checking Requirements... DONE"

echo -ne "Making Folders... $BASENAME\\r"
DIR2X="build/x2"
DIR1X="build/x1"
OUTPUT="$(grep --only-matching --perl-regex "(?<=Name\=).*$" $INDEX)"
OUTPUT="$OUTPUT_PARENT/$OUTPUT"
OUTPUT=${OUTPUT// /_}
mkdir -p "$DIR2X"
mkdir -p "$DIR1X"
mkdir -p "$OUTPUT/cursors"
echo 'Making Folders... DONE'

for CUR in src/config/*.cursor; do
	BASENAME=$CUR
	BASENAME=${BASENAME##*/}
	BASENAME=${BASENAME%.*}

	echo -ne "\033[0KGenerating simple cursor pixmaps... $BASENAME\\r"

	if [ "$DIR1X/$BASENAME.png" -ot $RAWSVG ]; then
		inkscape $RAWSVG -i $BASENAME -d 90 --export-filename "$DIR1X/$BASENAME.png" 2>/dev/null
	fi

	if [ "$DIR2X/$BASENAME.png" -ot $RAWSVG ]; then
		inkscape $RAWSVG -i $BASENAME -d 180 --export-filename "$DIR2X/$BASENAME.png" 2>/dev/null
	fi
done
echo -e "\033[0KGenerating simple cursor pixmaps... DONE"

for i in 01 02 03 04 05 06 07 08 09 10 11 12 13 14 15 16 17 18 19 20 21 22 23; do
	echo -ne "\033[0KGenerating animated cursor pixmaps... $i / 23 \\r"

	if [ "$DIR1X/progress-$i.png" -ot $RAWSVG ]; then
		inkscape $RAWSVG -i progress-$i -d 90 --export-filename "$DIR1X/progress-$i.png" 2>/dev/null
	fi

	if [ "$DIR2X/progress-$i.png" -ot $RAWSVG ]; then
		inkscape $RAWSVG -i progress-$i -d 180 --export-filename "$DIR2X/progress-$i.png" 2>/dev/null
	fi

	if [ "$DIR1X/wait-$i.png" -ot $RAWSVG ]; then
		inkscape $RAWSVG -i wait-$i -d 90 --export-filename "$DIR1X/wait-$i.png" 2>/dev/null
	fi

	if [ "$DIR2X/wait-$i.png" -ot $RAWSVG ]; then
		inkscape $RAWSVG -i wait-$i -d 180 --export-filename "$DIR2X/wait-$i.png" 2>/dev/null
	fi
done
echo -e "\033[0KGenerating animated cursor pixmaps... DONE"

echo -ne "Generating cursor theme...\\r"
for CUR in src/config/*.cursor; do
	BASENAME=$CUR
	BASENAME=${BASENAME##*/}
	BASENAME=${BASENAME%.*}

	ERR="$(xcursorgen -p build "$CUR" "$OUTPUT/cursors/$BASENAME" 2>&1)"

	if [[ "$?" -ne "0" ]]; then
		echo "FAIL: $CUR $ERR"
	fi
done
echo -e "Generating cursor theme... DONE"

echo -ne "Generating shortcuts...\\r"
while read ALIAS; do
	FROM=${ALIAS% *}
	TO=${ALIAS#* }

	if [ -e "$OUTPUT/cursors/$FROM" ]; then
		continue
	fi

	ln -s "$TO" "$OUTPUT/cursors/$FROM"
done <$ALIASES
echo -e "\033[0KGenerating shortcuts... DONE"

echo -ne "Copying Theme Index...\\r"
if ! [ -e "$OUTPUT/$INDEX" ]; then
	cp $INDEX "$OUTPUT/index.theme"
fi
echo -e "\033[0KCopying Theme Index... DONE"

echo "COMPLETE!"
