#!/bin/bash
. monitor.cfg
FILEBOT_HOME="/opt/filebot"
LOG_FILE="$FILEBOT_HOME/monitor.log"
WATCH_BASE="/mnt/local/downloads/nzbs/nzbget/completed"
OUTPUT_DIR="/mnt/local/Media"
#MEDIA_DIRS=("Movies" "Movies4K" "MoviesRemux")
MEDIA_DIRS=(${MEDIA_DIRS[@]/#/$WATCH_BASE/})
QUOTE_FIXER='replaceAll(/[\`\u00b4\u2018\u2019\u02bb]/, "'"'"'").replaceAll(/[\u201c\u201d]/, '"'"'""'"'"')'
echo "Monitoring: ${MEDIA_DIRS[@]}" >> $LOG_FILE
inotifywait ${MEDIA_DIRS[@]} -m -e create -e moved_to -e modify --exclude '(/_unpack)\|/[.@])' --format '%w%f' | stdbuf -oL uniq | while read -r FILE; do
    echo "###########################################################################" >> $LOG_FILE
    echo "New item: "$FILE"" >> $LOG_FILE
    RETRIES=0
    while [ -n "$(find "$FILE" -mindepth 1 -type d -name '_unpack')" ]
    do
        if [ "$RETRIES" -eq "$MAX_RETRIES" ]; then
            echo "exceeded max retries, failing" >> $LOG_FILE
            break
        else
            echo "waiting for unpack to complete...Retries: $RETRIES" >> $LOG_FILE
            RETRIES=$((RETRIES+1))
            sleep 10
        fi
    done
    if [ "$RETRIES" -lt "$MAX_RETRIES" ]; then
        # e.g. video.mp4: video/mp4
        if file --mime-type "$FILE" | egrep "directory|video|audio|empty|octet-stream"; then

                FOLDER=$(echo "$FILE" | grep -o "Movies[^/]*\|TV[^/]*")
                LABEL=""
                case "$FOLDER" in
                *Movie*)
                    LABEL="Movie"
                    ;;
                *TV*)
                    LABEL="TV"
                    ;;
                esac
                "$FILEBOT_HOME/bin/filebot.sh" \
                -script fn:amc \
                --action move \
                --conflict auto -non-strict \
                --log-file "$FILEBOT_HOME/amc.log" \
                --output "$OUTPUT_DIR" \
                --def \
                unsorted=y \
                music=n \
                artwork=n \
                clean=y \
                minFileSize=104857600 \
                ut_label=$LABEL \
                movieFormat="$FOLDER/{n} ({y})/{n.$QUOTE_FIXER} ({y}) {' CD'+pi}" \
                $PLEX_CONFIG \
                "$FILE"
        fi
    else
        echo "timed out waiting for unpack to complete" >> $LOG_FILE
    fi
    echo "###########################################################################" >> $LOG_FILE
done