#!/bin/sh

echo "awful.tag.viewonly(anki_tag)" | awesome-client
terminator  --title anki_french_term -e "bash -i -c \"anki-french\""
