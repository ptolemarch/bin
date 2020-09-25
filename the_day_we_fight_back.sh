#! /bin/bash

function now
{
    date +%s
}

function later
{
    date -j -f \
          "%Y %m/%d %H:%M:%S %z" \
        "2014 02/11 00:00:00 -0600" \
        +%s
}

#pattern='widget.min.js\|thedaywefightback'
pattern='thedaywefightback'
domains=(
        stackoverflow.com
        quora.com
        aol.com
        google.com
        microsoft.com
        yahoo.com
        facebook.com
        twitter.com
        reddit.com
        ibm.com
)

while [[ $(now) < $(later) ]]; do
    date
    for domain in "${domains[@]}"; do
        echo $domain
        if curl -sL http://$domain | grep -ie "$pattern"; then
            say "The Day We Fight Back: $domain"
        fi
    done
    sleep 10
done
