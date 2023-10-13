# Encrypt the bearer token and write it to a file
echo -n "YOUR_BEARER_TOKEN" | openssl enc -aes-256-cbc -pass pass:your_password -base64 -A > config.enc