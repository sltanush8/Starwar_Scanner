#!/bin/bash

# Check if film argument is provided
if [ -z "$1" ]; then
    echo "Usage: $0 <film_name_or_number>"
    exit 1
fi

FILM_QUERY=$(echo "$1" | tr '[:upper:]' '[:lower:]' | tr ' ' '-')

# Fetch films from SWAPI
FILM_DATA=$(curl -s "https://swapi.dev/api/films/")
FILM_URL=$(echo "$FILM_DATA" | jq -r --arg FILM_QUERY "$FILM_QUERY" '.results[] | select(.title | ascii_downcase | gsub(" "; "-") == $FILM_QUERY) | .url')

if [ -z "$FILM_URL" ]; then
    echo "Film not found!"
    exit 1
fi

# Fetch starships and pilots
STARSHIPS=$(curl -s "$FILM_URL" | jq -r '.starships[]')

echo "["

FIRST=1
for STARSHIP in $STARSHIPS; do
    SHIP_DATA=$(curl -s "$STARSHIP")
    SHIP_NAME=$(echo "$SHIP_DATA" | jq -r '.name')
    PILOTS=$(echo "$SHIP_DATA" | jq -r '.pilots[]')

    PILOT_NAMES=()
    for PILOT in $PILOTS; do
        PILOT_NAME=$(curl -s "$PILOT" | jq -r '.name')
        PILOT_NAMES+=("\"$PILOT_NAME\"")
    done

    # Print JSON output
    [ $FIRST -eq 0 ] && echo ","
    FIRST=0
    echo "{ \"starship\": \"$SHIP_NAME\", \"pilots\": [${PILOT_NAMES[*]}] }"
done

echo "]"

