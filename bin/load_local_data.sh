#!/usr/bin/env bash

set -e
set -o pipefail

script_path="$(dirname "$(realpath "$0")")"

curl --location 'http://localhost:8080/fhir' \
--header 'Content-Type: application/json' \
--header 'Cookie: _session_id=96c7ac4450f29cfce417b26a0f163267' \
-d @"$script_path/data/data-1.json"

curl --location 'http://localhost:8082/fhir' \
--header 'Content-Type: application/json' \
--header 'Cookie: _session_id=96c7ac4450f29cfce417b26a0f163267' \
-d @"$script_path/data/data-2.json"