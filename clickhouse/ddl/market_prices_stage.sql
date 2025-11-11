-- Stage table retains raw curated rows keyed by correlation_id for deduplication.
CREATE TABLE IF NOT EXISTS raw_market_stage.prices_stage
(
    symbol String NOT NULL,
    price Decimal(18, 6) NOT NULL,
    currency FixedString(3) NOT NULL,
    ds Date NOT NULL,
    correlation_id UUID NOT NULL,
    ingestion_ts DateTime64(3, 'UTC') DEFAULT now64(3, 'UTC')
)
ENGINE = ReplacingMergeTree(ingestion_ts)
PARTITION BY toYYYYMMDD(ds)
ORDER BY (correlation_id, symbol)
TTL ds + INTERVAL 7 DAY
SETTINGS index_granularity = 8192;
