BEGIN TRANSACTION;

-- Inserting docker host.
INSERT INTO
    "main"."docker_host" ("user_id", "docker_daemon", "docker_type", "name")
SELECT
    '1',
    '/var/run/docker.sock',
    'socket',
    'otco'
WHERE
    NOT EXISTS (
        SELECT
            1
        FROM
            "main"."docker_host"
        WHERE
            "name" = 'otco'
    );

-- Inserting proxy configuration.
INSERT INTO "main"."proxy" (
    "user_id", "protocol", "host", "port", "auth", "username",
    "password", "active", "default", "created_date"
)
SELECT
    '1', 'socks', 'tor-proxy', '9050', '0', NULL, NULL, '1', '0', '2024-08-10 10:00:00'
WHERE NOT EXISTS (
    SELECT 1 FROM "main"."proxy" WHERE "host" = 'tor-proxy'
);

COMMIT;
