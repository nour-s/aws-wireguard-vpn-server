#!/bin/bash

# Set the maximum number of attempts to check the verification status
MAX_ATTEMPTS=10

# Set the initial number of attempts
attempts=1

status=""

echo "You should have received an email from AWS asking you to verify your email address so we can send you an emaill with the keys ..."

while true; do
    echo "Trying" $attempts
    status="$(aws ses get-identity-verification-attributes --identities $EMAIL_ADDRESS | grep -o '"VerificationStatus": "[^"]*' | grep -o '[^"]*$')"

    if [ $status == "Success" ]; then
        echo "Email was approved"
        break;
    fi

    if [ $attempts -eq $MAX_ATTEMPTS ]; then
        echo "Tried and failed"
        break;
    fi

    # Wait for one minute before checking the verification status again
    sleep 10
    echo "Still not verified"

    # Increment the number of attempts
    attempts=$(( attempts + 1 ))
done

if [ $status == "Success" ]; then
    echo "Sending email"
    ./scripts/client-config > client.con
    aws ses send-email --from "$EMAIL_ADDRESS" --to "$EMAIL_ADDRESS" --subject "Your wireguard keys" --text "$(cat ./client.conf)"
fi
