#!/usr/bin/env bash

cd "$(dirname "$0")"
git pull -r

json_file="cisa.json"
log_file="kev.log"
curl -o "$json_file" https://www.cisa.gov/sites/default/files/feeds/known_exploited_vulnerabilities.json

# Check for JSON lint errors introduced in downloading from cisa.gov
if ! jq empty "$json_file" >/dev/null 2>&1; then
    echo "$(date): JSON lint error in $json_file. Commit aborted." | tee -a "$log_file"
    git checkout -- "$json_file"
    exit 1
fi

# If we're here we're all good for processing."
if [ -n "$(git status --porcelain "$json_file")" ]; then
    git add "$json_file"
    git commit -m "Update $json_file"
    git push origin

    # Only keep trailing six months of logs
    tmp_file=$(mktemp /tmp/kev.log.XXXXXX) && tail -n 5039 "$log_file" > "$tmp_file" && mv "$tmp_file" "$log_file"
    echo "$(date): $json_file has been changed and committed." | tee -a "$log_file"

else
    echo "$(date): No changes in $json_file." | tee -a "$log_file"
fi

