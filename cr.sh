#!/bin/bash
cd ~/AirTag
while true; do
    # Replace the following line with the command to run your app
    python3 py_parser.py

    # Sleep for 1 minute (60 seconds) before running again
    echo -n "."
    sleep 60
done