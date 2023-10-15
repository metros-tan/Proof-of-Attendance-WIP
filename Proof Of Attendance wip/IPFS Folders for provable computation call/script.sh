#!/bin/bash
curl --silent "https://api.twitter.com/2/users/by/username/$ARG0?user.fields=description" -H "Authorization: Bearer "" \ | jq -r '.data.description'
