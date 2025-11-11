# dim_date Spec

## Column Definitions

| 컬럼           | 타입         | 단위 | NULL | 기본값     | 설명            | 품질 규칙                      |
|---------------|--------------|------|------|------------|-----------------|--------------------------------|
| `date`        | Date         |      | N    |            | 기준일          | `date <= today()`              |
| `yyyy`        | UInt16       |      | N    |            | 연도            | `yyyy = toYear(date)`          |
| `quarter`     | UInt8        |      | N    |            | 분기(1–4)       | `quarter = toQuarter(date)`    |
| `month`       | UInt8        |      | N    |            | 월(1–12)        | `month = toMonth(date)`        |
| `day`         | UInt8        |      | N    |            | 일(1–31)        | `day = toDayOfMonth(date)`     |
| `doy`         | UInt16       |      | N    |            | 연중일(1–366)   | `doy = toDayOfYear(date)`      |
| `week_iso`    | UInt16       |      | N    |            | ISO 주차        | `week_iso = toISOWeek(date)`   |
| `week_start_mon` | Date      |      | N    |            | 해당 주 월요일  | `= toMonday(date)`             |
| `month_start` | Date         |      | N    |            | 월초            | `= toStartOfMonth(date)`       |
| `quarter_start` | Date       |      | N    |            | 분기초          | `= toStartOfQuarter(date)`     |
| `year_start`  | Date         |      | N    |            | 연초            | `= toStartOfYear(date)`        |
| `is_weekend`  | UInt8        |      | N    | `DEFAULT 0`| 주말 여부       | `IN (0, 1)`                    |
| `is_month_end`| UInt8        |      | N    | `DEFAULT 0`| 말일 여부       | `IN (0, 1)`                    |
| `is_quarter_end` | UInt8     |      | N    | `DEFAULT 0`| 분기말 여부     | `IN (0, 1)`                    |
| `is_year_end` | UInt8        |      | N    | `DEFAULT 0`| 연말 여부       | `IN (0, 1)`                    |
| `fiscal_year` | UInt16       |      | N    |            | 회계연도(기준월=1) | `= yyyy`                    |
| `fiscal_quarter` | UInt8     |      | N    |            | 회계분기(1–4)   | `= quarter`                    |
| `created_at`  | DateTime64(3)|      | N    | `now64(3)` | 생성 시각       |                                |
| `updated_at`  | DateTime64(3)|      | N    | `now64(3)` | 갱신 시각       | `updated_at >= created_at`     |

## Table Properties

| 항목            | 값                                                                 |
|-----------------|--------------------------------------------------------------------|
| 파티션 키       | `toYYYYMM(date)`                                                   |
| 정렬 키         | `(date)`                                                           |
| 엔진            | `ReplacingMergeTree(updated_at)`                                   |
| 인덱스          | 없음                                                               |
| 중복제거 전략   | `date` 단위 Type 1, 재처리 시 최신 `updated_at` 유지               |
| 품질 규칙       | `date` 유일(ETL 보장), 모든 파생 컬럼은 CHECK 제약으로 강제, Flag 컬럼은 `IN (0,1)` |
| SCD             | 없음 (Type 1)                                                      |
| 신선도(SLO)     | 연 1회 선생성, 필요 시 패치                                       |
| 메모            | 회계연도 기준월이 달라지면 `fiscal_*` 계산식을 조정해야 함 (+ 운영 변수 `fiscal_year_offset_month`) |

## Operational Guardrails

- **재적재 흐름** – Stage에 신규 스냅샷 적재 → 대상 `date` 범위 `ALTER ... DELETE` → Stage→Target INSERT
- **회계연도 기준월** – 기본 1월, 다른 기준이면 `fiscal_year_offset_month` 파라미터를 로더와 CHECK 식 양쪽에 반영
- **NOT NULL 정책** – Nullable을 명시하지 않는 컬럼은 ClickHouse 기본값으로 NOT NULL 유지, Null 허용 컬럼만 `Nullable(...)` 사용
