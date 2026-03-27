#!/usr/bin/env bash

connections=$(last -a | grep -i "still logged in" | grep -c "pts/")
percentage="0"
class="normal"
alt="none"

if [ "$connections" != "0" ]; then
    percentage="$connections"
    class="warning"
    alt="some"
fi

printf '{"text": "", "alt": "%s", "tooltip": "connections: %s", "class": "%s", "percentage": %s}' \
    "$alt" "$connections" "$class" "$percentage"
