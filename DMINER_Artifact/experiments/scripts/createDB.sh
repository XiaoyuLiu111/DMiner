#! /bin/bash
set -e
DUMP_DIR="/dbFiles"
neo4j start
for dump_file in "$DUMP_DIR"/*.dump; do
# create database
    db_name=$(basename "$dump_file" .dump)
    cypher-shell -u neo4j -p pswd1234 "CREATE DATABASE $db_name;"
done
neo4j stop
echo "All databases created."