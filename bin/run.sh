#!/bin/bash

set -e

for var in AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY RESTIC_PASSWORD RESTIC_REPOSITORY; do
	eval [[ -z \${$var+1} ]] && {
		>&2 echo "ERROR: Missing required environment variable: $var"
		exit 1
	}
done

if ! restic snapshots --no-lock; then
	restic init
fi

pg_dump.sh

echo "Pruning old snapshots"
while ! restic forget \
		--prune \
		--keep-hourly="${RESTIC_KEEP_HOURLY:-24}" \
		--keep-daily="${RESTIC_KEEP_DAILY:-7}" \
		--keep-weekly="${RESTIC_KEEP_WEEKLY:-4}" \
		--keep-monthly="${RESTIC_KEEP_MONTHLY:-12}"; do
	echo "Sleeping for 1 second before retry..."
	sleep 1
done

restic check --no-lock

echo 'Finished backup successfully'
