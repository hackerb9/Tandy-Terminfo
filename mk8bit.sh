#!/bin/bash
# mk8bit.sh

# Print a quick table of so called "high ASCII" characters, that is,
# all bytes from 0x80 to 0xFF. This is useful for testing locales such
# as Latin-1 which use a single 8-bit byte instead of Unicode.

# Output is sized to fit on a 40x16 terminal (for Tandy-200).

# On a terminal with an 8-bit locale, such as Latin-1:
#	mk8bit.sh	# Show 0x80 to 0xFF 
#	mk8bit.sh -a	# Show 0x20 to 0xFF (adds 7-bit ASCII).
#	mk8bit.sh -A	# Show 0x00 to 0xFF (also sends control characters).

# On a Unicode capable terminal:
# 	mk8bit.sh -f l1		# Show Latin-1 characterset
# 	mk8bit.sh -a -f t200	# Show Tandy-200 characterset

fflag=cat
while [[ "$1" ]]; do
    case "$1" in
	-a) aflag=$(echo {2..7}); shift ;;
	-A) aflag=$(echo {0..7}); shift ;;
	-f) fflag="iconv -f $2"; shift 2 ;;
	*) shift ;;
    esac
done

echo -n "   "
for b in {0..9} {A..F}; do
    echo -n "${b} "
done
echo

for a in $aflag {8..9} {A..F}; do
    echo -n "${a}_ " 
    for b in {0..9} {A..F}; do
	printf "\\x$a$b "
    done
    echo
done | $fflag
