#!/bin/sh


ASM=nasm
LD=ld

rm -rf obj/ build/
mkdir obj/ build/

CFILES="$(find src/ -name "*.asm")"
OBJS=""

for f in $CFILES; do
	OBJNAME="$(echo "$f" | sed -e "s/\.s/\.o/" -e "s/src/obj/")"
	$ASM -felf64 $f -o $OBJNAME
	OBJS="$OBJS $OBJNAME"
done

$LD $OBJS -o build/shell -N
