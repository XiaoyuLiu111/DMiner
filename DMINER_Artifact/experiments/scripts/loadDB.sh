#! /bin/bash
set -e
DUMP_DIR="/dbFiles"
for dump_file in "$DUMP_DIR"/*.dump; do
# load database from dump file
    db_name=$(basename "$dump_file" .dump)
    cat "$dump_file" | neo4j-admin database load \
        --from-stdin "$db_name" \
        --overwrite-destination=true
    echo "Loaded $dump_file into database: $db_name"
done
echo "All dump files loaded into databases."