#!/bin/bash
BASEDIR=$(dirname "$0")
echo "About to execute iBuntu-Builder"
echo "This command needs root privileges to be executed."
echo "Using sudo..."
echo "Enter password at prompt."
sudo python3 $BASEDIR/ibuntu_builder.py
