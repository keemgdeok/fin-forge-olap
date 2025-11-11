# fact_daily_tech_indicators Spec

## Price & Trend Indicators

| 컬럼 | 타입 | NULL | 기본값 | 설명 | 품질 규칙 |
|------|------|------|--------|------|-----------|
| `date` | Date | N |  | 계산 기준일 | `date <= today()` |
| `symbol` | LowCardinality(String) | N |  | 심볼 | `dim_symbol` 존재 |
| `sma_20` | Decimal(12, 4) | Y |  | 단순이동평균 20 | NULL 또는 `>= 0` |
| `sma_60` | Decimal(12, 4) | Y |  | 단순이동평균 60 | NULL 또는 `>= 0` |
| `sma_120` | Decimal(12, 4) | Y |  | 단순이동평균 120 | NULL 또는 `>= 0` |
| `ema_20` | Decimal(12, 4) | Y |  | 지수이동평균 20 | NULL 또는 `>= 0` |
| `ema_60` | Decimal(12, 4) | Y |  | 지수이동평균 60 | NULL 또는 `>= 0` |
| `return_1d` | Float32 | Y |  | 1일 수익률 % | 제한 없음(±) |
| `return_5d` | Float32 | Y |  | 5일 수익률 % | 제한 없음(±) |
| `return_20d` | Float32 | Y |  | 20일 수익률 % | 제한 없음(±) |
| `log_return_1d` | Float32 | Y |  | 로그수익률 ln(C0/C-1) | 제한 없음(±) |

## Bands & Envelopes

| 컬럼 | 타입 | NULL | 기본값 | 설명 | 품질 규칙 |
|------|------|------|--------|------|-----------|
| `envelope_mid_20_3` | Decimal(12, 4) | Y |  | SMA20 | NULL 또는 `>= 0` |
| `envelope_upper_20_3` | Decimal(12, 4) | Y |  | SMA20×1.03 | NULL 또는 `>= 0` |
| `envelope_lower_20_3` | Decimal(12, 4) | Y |  | SMA20×0.97 | NULL 또는 `>= 0` |
| `bollinger_middle_20_2` | Decimal(12, 4) | Y |  | SMA20 | NULL 또는 `>= 0` |
| `bollinger_upper_20_2` | Decimal(12, 4) | Y |  | SMA20+2σ | NULL 또는 `>= 0` |
| `bollinger_lower_20_2` | Decimal(12, 4) | Y |  | SMA20−2σ | NULL 또는 `>= 0` |
| `bb_width_20_2` | Float32 | Y |  | (Upper−Lower)/Middle×100 | NULL 또는 `>= 0` |
| `bb_percent_b_20_2` | Float32 | Y |  | (C−Lower)/(Upper−Lower) | NULL 또는 `0–1` |

## Oscillators & Momentum

| 컬럼 | 타입 | NULL | 기본값 | 설명 | 품질 규칙 |
|------|------|------|--------|------|-----------|
| `rsi_14` | Float32 | Y |  | RSI(14) | NULL 또는 0–100 |
| `rsi_ema6` | Float32 | Y |  | RSI EMA(6) | NULL 또는 0–100 |
| `macd_12_26` | Decimal(10, 6) | Y |  | EMA12−EMA26 | 제한 없음(±) |
| `macd_signal_9` | Decimal(10, 6) | Y |  | MACD 시그널(9) | 제한 없음(±) |
| `macd_hist_12_26_9` | Decimal(10, 6) | Y |  | MACD−시그널 | 제한 없음(±) |
| `macd_pct_12_26` | Float32 | Y |  | (MACD/Close)×100 | 제한 없음(±) |
| `williams_r_14` | Float32 | Y |  | %R(14) | NULL 또는 −100–0 |
| `slow_k_14_3` | Float32 | Y |  | Stoch %K(14,3) | NULL 또는 0–100 |
| `slow_d_14_3` | Float32 | Y |  | Stoch %D(14,3,3) | NULL 또는 0–100 |
| `adx_14` | Float32 | Y |  | ADX(14) | NULL 또는 0–100 |
| `plus_di_14` | Float32 | Y |  | +DI(14) | NULL 또는 0–100 |
| `minus_di_14` | Float32 | Y |  | −DI(14) | NULL 또는 0–100 |
| `cci_20` | Float32 | Y |  | CCI(20) | 제한 없음(±) |
| `cci_signal_10` | Float32 | Y |  | CCI EMA(10) | 제한 없음(±) |
| `mfi_14` | Float32 | Y |  | Money Flow Index | NULL 또는 0–100 |
| `roc_6/12/20` | Float32 | Y |  | ROC | 제한 없음(±) |

## Ichimoku & Volatility

| 컬럼 | 타입 | NULL | 기본값 | 설명 | 품질 규칙 |
|------|------|------|--------|------|-----------|
| `ichimoku_tenkan` | Decimal(12, 4) | Y |  | 전환선 | NULL 또는 `>= 0` |
| `ichimoku_kijun` | Decimal(12, 4) | Y |  | 기준선 | NULL 또는 `>= 0` |
| `ichimoku_senkou_a` | Decimal(12, 4) | Y |  | 선행스팬A | NULL 또는 `>= 0` |
| `ichimoku_senkou_b` | Decimal(12, 4) | Y |  | 선행스팬B | NULL 또는 `>= 0` |
| `ichimoku_chikou` | Decimal(12, 4) | Y |  | 후행스팬 | NULL 또는 `>= 0` |
| `atr_14` | Decimal(8, 4) | Y |  | ATR(14) | NULL 또는 `>= 0` |
| `atrp_14` | Float32 | Y |  | ATR/Close×100 | NULL 또는 `>= 0` |
| `realized_vol_10d/20d/60d` | Float32 | Y |  | 로그수익률 표준편차 | NULL 또는 `>= 0` |
| `realized_vol_20d_ann` | Float32 | Y |  | 20D 연율 표준편차 | NULL 또는 `>= 0` |
| `parkinson_vol_20` | Float32 | Y |  | Parkinson ×100 | NULL 또는 `>= 0` |
| `gk_vol_20` | Float32 | Y |  | Garman-Klass ×100 | NULL 또는 `>= 0` |

## Liquidity & Others

| 컬럼 | 타입 | NULL | 기본값 | 설명 | 품질 규칙 |
|------|------|------|--------|------|-----------|
| `obv` | Nullable(Int64) | Y |  | On-Balance Volume | 음수 허용 |
| `cmf_20` | Float32 | Y |  | Chaikin Money Flow | NULL 또는 −1–1 |
| `adi` | Nullable(Int64) | Y |  | Accumulation/Distribution Index | 음수 허용 |
| `vwap_d` | Decimal(12, 4) | Y |  | 일중 VWAP | NULL 또는 `>= 0` |
| `rvol_20` | Float32 | Y |  | 상대거래량 (Vol/avg20) | NULL 또는 `>= 0` |
| `beta_60` | Float32 | Y |  | 60D 베타 | NULL 또는 −3–3 |
| `corr_mkt_60` | Float32 | Y |  | 시장 상관계수 | NULL 또는 −1–1 |

## Meta Information

| 컬럼 | 타입 | NULL | 기본값 | 설명 | 품질 규칙 |
|------|------|------|--------|------|-----------|
| `is_validated` | UInt8 | N | `DEFAULT 0` | 검증 여부 | `IN (0,1)` |
| `quality_score` | UInt8 | N | `DEFAULT 0` | 품질 점수 | 0–100 |
| `batch_id` | UInt64 | N | `DEFAULT 0` | 적재 배치 | idempotent |
| `created_at` | DateTime64(3, 'UTC') | N | `now64(3)` | 생성 시각 |  |
| `updated_at` | DateTime64(3, 'UTC') | N | `now64(3)` | 갱신 시각 | `updated_at >= created_at` |

## Table Properties

| 항목 | 값 |
|------|-----|
| 파티션 키 | `toYYYYMM(date)` |
| 정렬 키 | `(symbol, date)` |
| 엔진 | `ReplacingMergeTree(updated_at)` |
| 중복제거 | `(symbol, date)` 유일. 재적재 시 Stage→Target Insert + 최신 `updated_at` 유지 |
| 품질 규칙 | FK(symbol) 검증, 모든 지표 범위는 CHECK + 로더 선검증 |
| TTL | `toDateTime(date) + INTERVAL 3 YEAR` |
| 지연 허용 | D+1 |
| 모니터링 | 결측률, 범위 위반율, `(symbol,date)` 중복 수 |
| 신선도 SLO | EOD T+30m |

## Operational Guardrails

- **계산 시각 정렬** – Ichimoku 선행/후행 값은 로더에서 ±26일 시프트 후, 적용일 기준 `date`로 정규화
- **범위 검증** – RSI/DI/ADX 등 0–100, %B 0–1, CMF −1–1 등은 로더가 먼저 필터링 후 DDL CHECK로 2중 방어
- **FK 관리** – fact 계산 전 `dim_symbol`을 조인해 존재하지 않는 심볼은 결측 큐로 분리
- **배치 재처리** – 동일 `(symbol,date)`에 대한 재계산 시 Stage에서 dedup 후 Target DELETE → INSERT, `batch_id`/`updated_at`로 idempotency 추적
