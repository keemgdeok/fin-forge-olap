# fact_daily_prices Spec

## Column Definitions

| 컬럼             | 타입                             | NULL | 기본값        | 설명             | 품질 규칙                                                                 |
|------------------|----------------------------------|------|---------------|------------------|---------------------------------------------------------------------------|
| `date`           | Date                             | N    |               | 거래일           | `date <= today()`                                                         |
| `symbol`         | LowCardinality(String)           | N    |               | 심볼             | `dim_symbol` 존재 여부 검증                                              |
| `open_price`     | Decimal(18, 2)                   | N    | `DEFAULT 0`   | 시가             | `>= 0`                                                                    |
| `high_price`     | Decimal(18, 2)                   | N    | `DEFAULT 0`   | 고가             | `>= max(open, close)` AND `>= low`                                        |
| `low_price`      | Decimal(18, 2)                   | N    | `DEFAULT 0`   | 저가             | `>= 0` AND `<= min(open, close)` AND `<= high`                            |
| `close_price`    | Decimal(18, 2)                   | N    | `DEFAULT 0`   | 종가             | `>= 0`                                                                    |
| `adj_close`      | Nullable(Decimal(18, 2))         | Y    |               | 조정 종가        | NULL 또는 `>= 0`                                                          |
| `volume`         | UInt64                           | N    | `DEFAULT 0`   | 거래량(주)       | `>= 0`                                                                    |
| `data_source`    | Nullable(LowCardinality(String)) | Y    |               | 공급자           | 운영 허용 리스트                                                         |
| `is_validated`   | UInt8                            | N    | `DEFAULT 0`   | 검증 여부        | `IN (0, 1)`                                                               |
| `quality_score`  | UInt8                            | N    | `DEFAULT 0`   | 품질 점수        | `0–100`                                                                   |
| `batch_id`       | UInt64                           | N    | `DEFAULT 0`   | 적재 배치 ID     | 재처리 시 idempotent 보장                                                |
| `created_at`     | DateTime64(3, 'UTC')             | N    | `now64(3)`    | 생성 시각        |                                                                           |
| `updated_at`     | DateTime64(3, 'UTC')             | N    | `now64(3)`    | 갱신 시각        | `updated_at >= created_at`                                               |

## Table Properties

| 항목            | 값                                                                                           |
|-----------------|----------------------------------------------------------------------------------------------|
| 목표 스키마     | `dw.fact_daily_prices`                                                                        |
| 파티션 키       | `toYYYYMM(date)`                                                                              |
| 정렬 키         | `(symbol, date)`                                                                              |
| 엔진            | `ReplacingMergeTree(updated_at)`                                                              |
| 중복제거 전략   | `(symbol, date)` 유일. stage→target 재적재 시 최신 `updated_at`와 `batch_id` 기준으로 보정     |
| 품질 규칙       | 심볼 FK 검증, 가격/거래량은 음수 불가, 고가/저가 관계 유지, `quality_score` 0–100            |
| TTL             | `date + 3년` (비즈니스 정책에 맞춰 조정 가능)                                                |
| 지연 허용       | D+2 재집계 허용                                                                               |
| 모니터링        | 당일 적재율, 검증 실패율, `(symbol,date)` 중복 건 수                                          |
| 신선도 SLO      | EOD 완료 후 T+30m                                                                             |

## Operational Guardrails

- ** FK 검증** – 적재 전 `dim_symbol`과 조인해 미존재 심볼을 격리하고, 실패 건을 별도 DLQ에 적재
- **재적재 흐름** – Stage에 신규 배치 적재 → 대상 `(symbol,date)` 범위 delete → Stage→Target INSERT
- **품질 체크** – `high>=max(open,close)` / `low<=min(open,close)` / `volume>=0` / `quality_score<=100` 조건을 DAG 단계에서도 선검증
- **타임라인 일관성** – 모든 타임스탬프는 UTC `DateTime64(3)`을 사용하고 로더에서 변환
- **0 기본값 해석** – 가격/거래량이 0이면 휴장 또는 데이터 누락을 의미하므로 일일 모니터링에서 비정상 패턴을 경고
