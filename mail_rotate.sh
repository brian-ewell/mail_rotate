#!/bin/sh

# Simple bash script that compresses and rotates mbox formatted mailboxes

HOLD=hold
DAYS=1096
CURRENT=current
DIR=/var/spool/mailarchive
CP=xz
CL=9

# Set the year and date for the file we're working with (yesterday)
date "+%Y %Y-%m-%d" -d yesterday | read YEAR DATE

# Only move and compress the mbox file if it exists
if [ -f $DIR/$CURRENT ]; then

        # Create the year directory if it doesn't exist
        if [ ! -e $DIR/$YEAR ]; then
                mkdir $DIR/$YEAR
        fi

        # Find a suitable destination filename
        DST=$DIR/$YEAR/$DATE
        if [ -e $DST ] || [ -e $DST.$CP ]; then
                SUFFIX=0
                while [ -e $DST.$SUFFIX ] || [ -e $DST.$SUFFIX.$CP ]; do
                        SUFFIX=`expr $SUFFIX + 1`
                done

                DST=$DST.$SUFFIX
        fi

        # Move and compress the file
        mv $DIR/$CURRENT $DST
        $CP $DST -$CL
fi

# Only delete old archive files if the hold file isn't present
if [ ! -e $DIR/$HOLD ]; then
        # Remove all files with modification times longer than $DAYS
        find $DIR/ -type f -mtime +$DAYS -exec rm "{}" \;

        # Remove all empty directories
        rmdir --ignore-fail-on-non-empty $DIR/[0-9][0-9][0-9][0-9]
fi
