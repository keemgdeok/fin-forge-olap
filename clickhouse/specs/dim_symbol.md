# dim_symbol Spec

## Column Definitions

| 컬럼             | 타입                         | NULL | 기본값        | 설명                 | 품질 규칙                                                                 |
|------------------|------------------------------|------|---------------|----------------------|---------------------------------------------------------------------------|
| `symbol`         | LowCardinality(String)       | N    |               | 심볼 자연키          | 공백 금지, 허용 패턴 `^[A-Z0-9._-]+$`, 테이블 내 고유                    |
| `name`           | String                       | N    |               | 종목명               | 공백 금지                                                                 |
| `asset_class`    | LowCardinality(String)       | N    |               | 자산군               | 허용값 집합(`equity`,`etf`,`crypto`,`fx`,`index`,`commodity`)              |
| `sector`         | Nullable(LowCardinality(String)) | Y |               | 섹터 코드           | 코드북 매핑                                                               |
| `industry`       | Nullable(LowCardinality(String)) | Y |               | 산업 코드           | 코드북 매핑                                                               |
| `exchange`       | LowCardinality(String)       | N    |               | 거래소 코드          | 허용값 집합(예: `NASDAQ`,`NYSE`,`KRX`, 필요 시 운영 변수)                |
| `currency`       | LowCardinality(String)       | N    |               | 거래 통화            | ISO 4217, 정확히 3자                                                      |
| `is_active`      | UInt8                        | N    | `DEFAULT 1`   | 활성 여부            | `IN (0,1)`                                                                |
| `listing_date`   | Nullable(Date)               | Y    |               | 상장일               | NULL 또는 과거/현재                                                       |
| `delisting_date` | Nullable(Date)               | Y    |               | 폐지일               | NULL 또는 `>= listing_date`                                              |
| `valid_from`     | DateTime64(3, 'UTC')         | N    |               | SCD2 시작            | `valid_from <= valid_to` (when valid_to not null)                         |
| `valid_to`       | Nullable(DateTime64(3, 'UTC')) | Y |               | SCD2 종료            | NULL 또는 `> valid_from`                                                 |
| `is_current`     | UInt8                        | N    | `DEFAULT 1`   | 현재 행 플래그       | `IN (0,1)`, `is_current=1 ⇒ valid_to IS NULL`                             |
| `created_at`     | DateTime64(3, 'UTC')         | N    | `now64(3)`    | 생성 시각            |                                                                           |
| `updated_at`     | DateTime64(3, 'UTC')         | N    | `now64(3)`    | 갱신 시각            | `updated_at >= created_at`                                               |

## Table Properties

| 항목            | 값                                                                                               |
|-----------------|--------------------------------------------------------------------------------------------------|
| 목표 스키마     | `dw.dim_reference_symbol`                                                                        |
| 파티션 키       | `toYYYYMM(valid_from)`                                                                           |
| 정렬 키         | `(symbol, valid_from)`                                                                           |
| 엔진            | `ReplacingMergeTree(updated_at)`                                                                 |
| 중복제거 전략   | SCD2(Type 2): `(symbol, valid_from)` 조합 고유, 최신 `updated_at`로 보정                         |
| 품질 규칙       | `symbol` 고유, `currency` 3자, Flag 컬럼은 0/1, 허용값 집합은 운영 변수로 관리                  |
| 지연 허용       | 월간 증분 D+2                                                                                    |
| 모니터링        | 신규/폐지 심볼 수, `is_current`/`is_active` 불일치 건수                                         |
| 신선도 SLO      | 월 1회 완료                                                                                      |
| 재적재 전략     | 임시 stage에 신규 스냅샷 적재 → 대상 심볼 범위 delete → stage→target INSERT                      |
| 비고            | 허용값 리스트(`asset_class_allowlist`, `exchange_allowlist`)는 `.env` 또는 코드에서 주입         |

## Operational Guardrails

- **SCD 무결성** – `symbol` + `valid_from` 중복 금지, `is_current=1` 단일 행 유지, 배치 후 `countIf` 검증
- **허용값 관리** – 자산군·거래소 리스트를 Config/ENV에서 주입하고 로더에서 선검증, 필요 시 CHECK 값 ALTER
- **타임존 일관성** – 모든 DateTime을 UTC(`DateTime64(3, 'UTC')`)로 고정, 소스 데이터는 로더에서 변환
- **폐지 처리** – `delisting_date` 입력 시 `is_active/is_current`를 동기화하고 업서트 시 flag 불일치가 없도록 검증
