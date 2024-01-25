# Anyway

## Architecture

https://docs.google.com/presentation/d/1bXkcCgsXUr1FQA7hCZdb5_m7IXIiP1UixuOHuV88sfs/edit?usp=sharing

![](image.png)

### TODO: db-backup-cronjob

## Enable DB Redash read-only user

Start a shell on DB container and run the following to start an sql session:

```
su postgres
psql anyway
```

Run the following to create the readonly user (replace **** with real password):

```
CREATE ROLE readonly;
GRANT CONNECT ON DATABASE anyway TO readonly;
GRANT USAGE ON SCHEMA public TO readonly;
CREATE USER redash WITH PASSWORD '*****';
GRANT readonly TO redash;
```

See [this document](https://github.com/hasadna/anyway/blob/dev/docs/REDASH.md) for how to grant permissions for tables to this user.

## Restore from backup

Production DB has a daily backup which can be used to populate a new environment's DB

Following steps are for restoring to dev environment:

* stop the dev DB by scaling the db deployment down to 0 replicas
* clear the DB data directory (TBD: how to do this?)
* Edit the environment values (e.g. `values-anyway-dev.yaml`) and set `dbRestoreFileName` to the current day's date.
* Deploy the anyway chart - this will cause DB to be recreated from the backup
* The restore can take a long time..
