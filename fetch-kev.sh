#!/usr/bin/bash

cd "$(dirname "$0")"

json_file="cisa.json"
log_file="kev.log"
curl -o "$json_file" https://www.cisa.gov/sites/default/files/feeds/known_exploited_vulnerabilities.json

if [ -n "$(git status --porcelain "$json_file")" ]; then
    git add "$json_file"
    git commit -m "Update $json_file"
    git push origin
    echo "$(date): $json_file has been changed and committed." | tee -a "$log_file"
else
    echo "$(date): No changes in $json_file." | tee -a "$log_file"
fi
