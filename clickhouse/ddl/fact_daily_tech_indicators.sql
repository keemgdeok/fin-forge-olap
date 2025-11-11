-- Technical indicator fact table built from daily price series.
CREATE TABLE IF NOT EXISTS dw.fact_daily_tech_indicators
(
  date        Date                   NOT NULL,
  symbol      LowCardinality(String) NOT NULL,

  sma_20      Nullable(Decimal(12, 4)),
  sma_60      Nullable(Decimal(12, 4)),
  sma_120     Nullable(Decimal(12, 4)),
  ema_20      Nullable(Decimal(12, 4)),
  ema_60      Nullable(Decimal(12, 4)),
  return_1d   Nullable(Float32),
  return_5d   Nullable(Float32),
  return_20d  Nullable(Float32),
  log_return_1d Nullable(Float32),

  envelope_mid_20_3   Nullable(Decimal(12, 4)),
  envelope_upper_20_3 Nullable(Decimal(12, 4)),
  envelope_lower_20_3 Nullable(Decimal(12, 4)),

  rsi_14      Nullable(Float32),
  rsi_ema6    Nullable(Float32),
  macd_12_26  Nullable(Decimal(10, 6)),
  macd_signal_9 Nullable(Decimal(10, 6)),
  macd_hist_12_26_9 Nullable(Decimal(10, 6)),
  macd_pct_12_26    Nullable(Float32),

  bollinger_middle_20_2 Nullable(Decimal(12, 4)),
  bollinger_upper_20_2  Nullable(Decimal(12, 4)),
  bollinger_lower_20_2  Nullable(Decimal(12, 4)),
  bb_width_20_2         Nullable(Float32),
  bb_percent_b_20_2     Nullable(Float32),

  williams_r_14 Nullable(Float32),
  slow_k_14_3   Nullable(Float32),
  slow_d_14_3   Nullable(Float32),

  ichimoku_tenkan   Nullable(Decimal(12, 4)),
  ichimoku_kijun    Nullable(Decimal(12, 4)),
  ichimoku_senkou_a Nullable(Decimal(12, 4)),
  ichimoku_senkou_b Nullable(Decimal(12, 4)),
  ichimoku_chikou   Nullable(Decimal(12, 4)),

  atr_14  Nullable(Decimal(8, 4)),
  atrp_14 Nullable(Float32),

  adx_14     Nullable(Float32),
  plus_di_14 Nullable(Float32),
  minus_di_14 Nullable(Float32),

  cci_20        Nullable(Float32),
  cci_signal_10 Nullable(Float32),

  obv      Nullable(Int64),
  cmf_20   Nullable(Float32),
  adi      Nullable(Int64),

  mfi_14   Nullable(Float32),
  roc_6    Nullable(Float32),
  roc_12   Nullable(Float32),
  roc_20   Nullable(Float32),

  realized_vol_10d     Nullable(Float32),
  realized_vol_20d     Nullable(Float32),
  realized_vol_60d     Nullable(Float32),
  realized_vol_20d_ann Nullable(Float32),
  parkinson_vol_20     Nullable(Float32),
  gk_vol_20            Nullable(Float32),

  vwap_d  Nullable(Decimal(12, 4)),
  rvol_20 Nullable(Float32),
  beta_60 Nullable(Float32),
  corr_mkt_60 Nullable(Float32),

  is_validated  UInt8                NOT NULL DEFAULT 0,
  quality_score UInt8                NOT NULL DEFAULT 0,
  batch_id      UInt64               NOT NULL DEFAULT 0,
  created_at    DateTime64(3, 'UTC') NOT NULL DEFAULT now64(3, 'UTC'),
  updated_at    DateTime64(3, 'UTC') NOT NULL DEFAULT now64(3, 'UTC'),

  CHECK (date <= today()),
  CHECK (is_validated IN (0, 1)),
  CHECK (quality_score BETWEEN 0 AND 100),
  CHECK (updated_at >= created_at),

  CHECK (sma_20  IS NULL OR sma_20  >= 0),
  CHECK (sma_60  IS NULL OR sma_60  >= 0),
  CHECK (sma_120 IS NULL OR sma_120 >= 0),
  CHECK (ema_20  IS NULL OR ema_20  >= 0),
  CHECK (ema_60  IS NULL OR ema_60  >= 0),

  CHECK (envelope_mid_20_3   IS NULL OR envelope_mid_20_3   >= 0),
  CHECK (envelope_upper_20_3 IS NULL OR envelope_upper_20_3 >= 0),
  CHECK (envelope_lower_20_3 IS NULL OR envelope_lower_20_3 >= 0),
  CHECK (
    envelope_upper_20_3 IS NULL OR envelope_mid_20_3 IS NULL OR envelope_lower_20_3 IS NULL OR
    (envelope_upper_20_3 >= envelope_mid_20_3 AND envelope_mid_20_3 >= envelope_lower_20_3)
  ),

  CHECK (bollinger_middle_20_2 IS NULL OR bollinger_middle_20_2 >= 0),
  CHECK (bollinger_upper_20_2  IS NULL OR bollinger_upper_20_2 >= 0),
  CHECK (bollinger_lower_20_2  IS NULL OR bollinger_lower_20_2 >= 0),
  CHECK (bb_width_20_2   IS NULL OR bb_width_20_2 >= 0),
  CHECK (bb_percent_b_20_2 IS NULL OR (bb_percent_b_20_2 BETWEEN 0 AND 1)),
  CHECK (
    bollinger_upper_20_2 IS NULL OR bollinger_middle_20_2 IS NULL OR bollinger_lower_20_2 IS NULL OR
    (bollinger_upper_20_2 >= bollinger_middle_20_2 AND bollinger_middle_20_2 >= bollinger_lower_20_2)
  ),

  CHECK (rsi_14   IS NULL OR (rsi_14 BETWEEN 0 AND 100)),
  CHECK (rsi_ema6 IS NULL OR (rsi_ema6 BETWEEN 0 AND 100)),
  CHECK (williams_r_14 IS NULL OR (williams_r_14 BETWEEN -100 AND 0)),
  CHECK (slow_k_14_3   IS NULL OR (slow_k_14_3 BETWEEN 0 AND 100)),
  CHECK (slow_d_14_3   IS NULL OR (slow_d_14_3 BETWEEN 0 AND 100)),

  CHECK (ichimoku_tenkan   IS NULL OR ichimoku_tenkan   >= 0),
  CHECK (ichimoku_kijun    IS NULL OR ichimoku_kijun    >= 0),
  CHECK (ichimoku_senkou_a IS NULL OR ichimoku_senkou_a >= 0),
  CHECK (ichimoku_senkou_b IS NULL OR ichimoku_senkou_b >= 0),
  CHECK (ichimoku_chikou   IS NULL OR ichimoku_chikou   >= 0),

  CHECK (atr_14  IS NULL OR atr_14  >= 0),
  CHECK (atrp_14 IS NULL OR atrp_14 >= 0),

  CHECK (adx_14     IS NULL OR (adx_14 BETWEEN 0 AND 100)),
  CHECK (plus_di_14 IS NULL OR (plus_di_14 BETWEEN 0 AND 100)),
  CHECK (minus_di_14 IS NULL OR (minus_di_14 BETWEEN 0 AND 100)),

  CHECK (mfi_14 IS NULL OR (mfi_14 BETWEEN 0 AND 100)),

  CHECK (cmf_20 IS NULL OR (cmf_20 BETWEEN -1 AND 1)),
  CHECK (rvol_20 IS NULL OR rvol_20 >= 0),
  CHECK (beta_60 IS NULL OR (beta_60 BETWEEN -3 AND 3)),
  CHECK (corr_mkt_60 IS NULL OR (corr_mkt_60 BETWEEN -1 AND 1)),

  CHECK (realized_vol_10d IS NULL OR realized_vol_10d >= 0),
  CHECK (realized_vol_20d IS NULL OR realized_vol_20d >= 0),
  CHECK (realized_vol_60d IS NULL OR realized_vol_60d >= 0),
  CHECK (realized_vol_20d_ann IS NULL OR realized_vol_20d_ann >= 0),
  CHECK (parkinson_vol_20 IS NULL OR parkinson_vol_20 >= 0),
  CHECK (gk_vol_20 IS NULL OR gk_vol_20 >= 0),

  CHECK (vwap_d IS NULL OR vwap_d >= 0)
)
ENGINE = ReplacingMergeTree(updated_at)
PARTITION BY toYYYYMM(date)
ORDER BY (symbol, date)
TTL toDateTime(date) + INTERVAL 3 YEAR
SETTINGS index_granularity = 8192, allow_nullable_key = 0;
