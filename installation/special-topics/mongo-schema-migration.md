# Mongo Schema Migration

When upgrading a customer with large amounts of data, the mongo schema migrations can take a very long time. In these cases it may be useful to run the schema migrations manually outside of the upgrade window rather than automatically as part of the upgrade. The steps to skip mongo schema migrations during an install and apply them manually are outlined below.

1. Run the DataRobot install without applying the mongo schema migrations:
    #### Docker Install
    ```bash
    ./bin/datarobot install --skip-mongo-schema-migrations
    ```
    #### RPM Install
    ```bash
    ./bin/datarobot install --post-configure --skip-mongo-schema-migrations
    ```
    Once the install has completed successfully, **the schema migrations must be applied manually**. If you do not care to monitor the progress of the schema migrations as they are applied, skip to step 5.

2. To monitor the progress of the mongo schema migrations, you need to manually run them from the `app` host. The following command will wrap the migration command in a `nohup` and direct the output to a logfile called `mongo_schema_migrations.log`:
    #### Docker Install
    ```bash
    nohup docker exec -i app /entrypoint bash -c "sbin/datarobot-migrate-db" > mongo_schema_migrations.log &
    ```
    #### RPM Install
    ```bash
    nohup /opt/datarobot/sbin/datarobot-migrate-db > mongo_schema_migrations.log &
    ```

3. While the command is running, you can check the progress of the migration by tailing the log file:
    ```bash
    tail -f mongo_schema_migrations.log
    ```

4. The migration is complete once you see the "Done!" message in the logs:
    ```bash
    DRJSON {"@message": "Done!", "@timestamp": "2021-11-30T22:52:13.932974Z", "@source_host": "ip-10-94-161-184.ec2.internal", "@fields": {"name": "root", "args": [], "levelname": "INFO", "levelno": 20, "pathname": "/opt/datarobot-runtime/app/DataRobot/support/migrate_db.py", "filename": "migrate_db.py", "module": "migrate_db", "stack_info": null, "lineno": 232, "funcName": "do_migrations", "created": 1638312733.932943, "msecs": 932.9431056976318, "relativeCreated": 5385.732889175415, "thread": 139854560929600, "threadName": "MainThread", "processName": "MainProcess", "process": 1167, "datarobot_service_id": "default"}}
    ```

5. Run the mongo schema migrations ansible playbook to ensure all required migrations are complete:
    ```bash
    ./bin/datarobot migrate-mongo-schema
    ```
    _Note: Step 5 should be done even if the schema migrations were applied manually using steps 2-4 above._
