-- Daily OHLCV fact table sourced from curated market data loads.
CREATE TABLE IF NOT EXISTS dw.fact_daily_prices
(
  date           Date                         NOT NULL,
  symbol         LowCardinality(String)       NOT NULL,
  open_price     Decimal(18, 2)               NOT NULL DEFAULT 0,
  high_price     Decimal(18, 2)               NOT NULL DEFAULT 0,
  low_price      Decimal(18, 2)               NOT NULL DEFAULT 0,
  close_price    Decimal(18, 2)               NOT NULL DEFAULT 0,
  adj_close      Nullable(Decimal(18, 2)),
  volume         UInt64                       NOT NULL DEFAULT 0,
  data_source    Nullable(LowCardinality(String)),
  is_validated   UInt8                        NOT NULL DEFAULT 0,
  quality_score  UInt8                        NOT NULL DEFAULT 0,
  batch_id       UInt64                       NOT NULL DEFAULT 0,
  created_at     DateTime64(3, 'UTC')         NOT NULL DEFAULT now64(3, 'UTC'),
  updated_at     DateTime64(3, 'UTC')         NOT NULL DEFAULT now64(3, 'UTC'),

  CHECK (date <= today()),
  CHECK (open_price >= 0 AND high_price >= 0 AND low_price >= 0 AND close_price >= 0),
  CHECK (adj_close IS NULL OR adj_close >= 0),
  CHECK (volume >= 0),
  CHECK (quality_score BETWEEN 0 AND 100),
  CHECK (is_validated IN (0,1)),
  CHECK (high_price >= greatest(open_price, close_price)),
  CHECK (low_price  <= least(open_price, close_price)),
  CHECK (high_price >= low_price),
  CHECK (updated_at >= created_at)
)
ENGINE = ReplacingMergeTree(updated_at)
PARTITION BY toYYYYMM(date)
ORDER BY (symbol, date)
TTL toDateTime(date) + INTERVAL 3 YEAR
SETTINGS index_granularity = 8192, allow_nullable_key = 0;
