#!/bin/bash
# Decrypt the configuration file
openssl enc -d -aes-256-cbc -pass pass:$DECRYPTION_PASSWORD -base64 -A -in config.enc -out config.txt

# Read the bearer token from the decrypted file
export TWITTER_BEARER_TOKEN=$(cat config.txt)

# Clean up the decrypted file (optional)
rm config.txt

# Execute your main script
./script.sh