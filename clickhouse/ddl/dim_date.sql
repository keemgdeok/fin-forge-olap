-- Canonical date dimension with derivations enforced via CHECK constraints.
CREATE TABLE IF NOT EXISTS dw.dim_date
(
  date           Date NOT NULL,

  yyyy           UInt16 NOT NULL,
  quarter        UInt8 NOT NULL,
  month          UInt8 NOT NULL,
  day            UInt8 NOT NULL,
  doy            UInt16 NOT NULL,
  week_iso       UInt16 NOT NULL,

  week_start_mon Date NOT NULL,
  month_start    Date NOT NULL,
  quarter_start  Date NOT NULL,
  year_start     Date NOT NULL,

  is_weekend     UInt8 NOT NULL DEFAULT 0,
  is_month_end   UInt8 NOT NULL DEFAULT 0,
  is_quarter_end UInt8 NOT NULL DEFAULT 0,
  is_year_end    UInt8 NOT NULL DEFAULT 0,

  fiscal_year    UInt16 NOT NULL,
  fiscal_quarter UInt8 NOT NULL,

  created_at     DateTime64(3, 'UTC') NOT NULL DEFAULT now64(3, 'UTC'),
  updated_at     DateTime64(3, 'UTC') NOT NULL DEFAULT now64(3, 'UTC'),

  -- Integrity constraints
  CHECK (date <= today()),
  CHECK (yyyy  = toYear(date)),
  CHECK (quarter BETWEEN 1 AND 4 AND quarter = toQuarter(date)),
  CHECK (month  BETWEEN 1 AND 12 AND month = toMonth(date)),
  CHECK (day    BETWEEN 1 AND 31 AND day = toDayOfMonth(date)),
  CHECK (doy    BETWEEN 1 AND 366 AND doy = toDayOfYear(date)),
  CHECK (week_iso = toISOWeek(date)),
  CHECK (week_start_mon = toMonday(date)),
  CHECK (month_start    = toStartOfMonth(date)),
  CHECK (quarter_start  = toStartOfQuarter(date)),
  CHECK (year_start     = toStartOfYear(date)),
  CHECK (is_weekend     IN (0,1)),
  CHECK (is_month_end   IN (0,1)),
  CHECK (is_quarter_end IN (0,1)),
  CHECK (is_year_end    IN (0,1)),
  CHECK (fiscal_year    = yyyy),
  CHECK (fiscal_quarter = quarter)
)
ENGINE = ReplacingMergeTree(updated_at)
PARTITION BY toYYYYMM(date)
ORDER BY (date)
SETTINGS index_granularity = 8192, allow_nullable_key = 0;
