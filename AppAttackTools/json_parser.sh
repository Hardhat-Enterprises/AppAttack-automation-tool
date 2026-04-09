#!/bin/bash

# This script parses a JSON string and returns the result of a jq query.

# Arguments:
# $1: The JSON string to parse.
# $2: The jq query.

# Example:
# ./json_parser.sh '{"name": "John", "age": 30}' '.name'

if [ -z "$1" ] || [ -z "$2" ]; then
    echo "Usage: ./json_parser.sh <json_string> <jq_query>"
    exit 1
fi

json_string=$1
jq_query=$2

result=$(echo "$json_string" | jq -r "$jq_query")

if [ $? -ne 0 ]; then
    echo "Error: Failed to parse JSON or execute jq query."
    exit 1
fi

echo "$result"
