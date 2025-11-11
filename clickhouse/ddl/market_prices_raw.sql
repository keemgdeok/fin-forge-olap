-- Target table surfaces deduplicated curated data for dbt sources.
CREATE TABLE IF NOT EXISTS raw_market.prices_raw
(
    symbol String NOT NULL,
    price Decimal(18, 6) NOT NULL,
    currency FixedString(3) NOT NULL,
    ds Date NOT NULL,
    correlation_id UUID NOT NULL,
    loaded_at DateTime64(3, 'UTC') DEFAULT now64(3, 'UTC')
)
ENGINE = ReplacingMergeTree(loaded_at)
PARTITION BY toYYYYMMDD(ds)
ORDER BY (ds, symbol, correlation_id)
TTL ds + INTERVAL 30 DAY
SETTINGS index_granularity = 8192;
