# restic-pg-dump

Docker image that runs `pg_dump` individually for every database on a given
server and saves incremental encrypted backups via
[restic](https://restic.net).

By default:

- Uses S3 as restic repository backend.
- Runs every hour via cron job.
- Keeps 24 latest, 7 daily, 4 weekly, and 12 monthly snapshots.
- Prunes old snapshots every week.

**NOTE:** Pruning requires an exclusive lock, and should be done infrequently from a single host.

# Usage

Run:

    $ docker run \
      -d \
      -e AWS_ACCESS_KEY_ID='...' \
      -e AWS_SECRET_ACCESS_KEY='...' \
      -e PGHOST='...' \
      -e PGPASSWORD='...' \
      -e PGUSER='...' \
      -e RESTIC_PASSWORD='...' \
      -e RESTIC_REPOSITORY='s3:s3.amazonaws.com/...' \
      --name restic-pg-dump \
      --restart always \
      ghcr.io/christophersjchow/restic-pg-dump-docker:main

You can also pass the following environment variables to override the defaults:

    -e RESTIC_BACKUP_SCHEDULE='0 * * * *'  # Hourly
    -e RESTIC_PRUNE_SCHEDULE='0 14 * * 0'  # Sunday midnight, AEST. Use '' to disable.
    -e PGPORT='5432'
    -e RESTIC_KEEP_HOURLY='24'
    -e RESTIC_KEEP_DAILY='7'
    -e RESTIC_KEEP_WEEKLY='4'
    -e RESTIC_KEEP_MONTHLY='12'

You can backup 5 different database clusters with `PG*_[1..5]`, and assign an arbitrary hostname with `HOSTNAME_[1..5]` (if `PGHOST` is not a fully qualified domain name) environment variables.

    -e HOSTNAME_2='...'
    -e PGHOST_2='...'
    -e PGPASSWORD_2='...'
    -e PGPORT_2='5432'
    -e PGUSER_2='...'
