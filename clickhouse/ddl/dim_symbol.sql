-- Slowly changing dimension for reference symbols with strict quality checks.
CREATE TABLE IF NOT EXISTS dw.dim_reference_symbol
(
  symbol         LowCardinality(String)   NOT NULL,
  name           String                   NOT NULL,
  asset_class    LowCardinality(String)   NOT NULL,
  sector         Nullable(LowCardinality(String)),
  industry       Nullable(LowCardinality(String)),
  exchange       LowCardinality(String)   NOT NULL,
  currency       LowCardinality(String)   NOT NULL,
  is_active      UInt8                    NOT NULL DEFAULT 1,
  listing_date   Nullable(Date),
  delisting_date Nullable(Date),
  valid_from     DateTime64(3, 'UTC')     NOT NULL,
  valid_to       Nullable(DateTime64(3, 'UTC')),
  is_current     UInt8                    NOT NULL DEFAULT 1,
  created_at     DateTime64(3, 'UTC')     NOT NULL DEFAULT now64(3, 'UTC'),
  updated_at     DateTime64(3, 'UTC')     NOT NULL DEFAULT now64(3, 'UTC'),

  CHECK (match(symbol, '^[A-Z0-9._-]+$')),
  CHECK (lengthUTF8(trim(BOTH ' ' FROM name)) > 0),
  CHECK (asset_class IN ('equity','etf','crypto','fx','index','commodity')),
  CHECK (exchange IN ('NASDAQ','NYSE','AMEX','KRX','LSE','TSX')),
  CHECK (lengthUTF8(currency) = 3),
  CHECK (is_active IN (0,1)),
  CHECK (is_current IN (0,1)),
  CHECK (listing_date IS NULL OR listing_date <= today()),
  CHECK (delisting_date IS NULL OR listing_date IS NULL OR delisting_date >= listing_date),
  CHECK (valid_to IS NULL OR valid_to > valid_from),
  CHECK ((is_current = 1 AND valid_to IS NULL) OR (is_current = 0 AND valid_to IS NOT NULL)),
  CHECK (updated_at >= created_at)
)
ENGINE = ReplacingMergeTree(updated_at)
PARTITION BY toYYYYMM(valid_from)
ORDER BY (symbol, valid_from)
SETTINGS index_granularity = 8192, allow_nullable_key = 0;
