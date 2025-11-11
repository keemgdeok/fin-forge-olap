-- Audit table tracks each SQS correlation id processed by the DAG.
CREATE TABLE IF NOT EXISTS audit.load_audit
(
    correlation_id UUID NOT NULL,
    domain LowCardinality(String) NOT NULL,
    table_name LowCardinality(String) NOT NULL,
    stage_rows UInt64 NOT NULL,
    target_rows UInt64 NOT NULL,
    checksum FixedString(64) NOT NULL,
    status LowCardinality(String) NOT NULL,
    bucket String NOT NULL,
    object_key String NOT NULL,
    loaded_at DateTime64(3, 'UTC') NOT NULL
)
ENGINE = MergeTree
ORDER BY (loaded_at, domain, table_name)
TTL loaded_at + INTERVAL 90 DAY
SETTINGS index_granularity = 8192;
