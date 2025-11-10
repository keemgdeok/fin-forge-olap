from __future__ import annotations

import configparser
import os
from collections.abc import Callable
from dataclasses import dataclass, field
from pathlib import Path
from typing import Any, TypeVar

from dotenv import load_dotenv

# Load environment variables from .env if present
load_dotenv()


def _env_path(var: str, default: str) -> Path:
    return Path(os.getenv(var, default)).resolve()


def _env_str(var: str, default: str = "") -> str:
    return os.getenv(var, default)


def _env_int(var: str, default: str) -> int:
    return int(os.getenv(var, default))


def _env_bool(var: str, default: str) -> bool:
    return os.getenv(var, default).lower() == "true"


T = TypeVar("T")


def _partial_env(func: Callable[..., T], *args: Any, **kwargs: Any) -> Callable[[], T]:
    def _factory() -> T:
        return func(*args, **kwargs)

    return _factory


@dataclass(frozen=True)
class Settings:
    """Collection of strongly-typed configuration values."""

    airflow_home: Path = field(default_factory=_partial_env(_env_path, "AIRFLOW_HOME", ".airflow"))
    clickhouse_host: str = field(
        default_factory=_partial_env(_env_str, "CLICKHOUSE_HOST", "localhost")
    )
    clickhouse_port: int = field(default_factory=_partial_env(_env_int, "CLICKHOUSE_PORT", "9440"))
    clickhouse_http_port: int = field(
        default_factory=_partial_env(_env_int, "CLICKHOUSE_HTTP_PORT", "8443")
    )
    clickhouse_user: str = field(
        default_factory=_partial_env(_env_str, "CLICKHOUSE_USER", "default")
    )
    clickhouse_password: str = field(
        default_factory=_partial_env(_env_str, "CLICKHOUSE_PASSWORD", "")
    )
    clickhouse_database: str = field(
        default_factory=_partial_env(_env_str, "CLICKHOUSE_DATABASE", "analytics")
    )
    clickhouse_schema: str = field(
        default_factory=_partial_env(_env_str, "CLICKHOUSE_SCHEMA", "analytics")
    )
    clickhouse_secure: bool = field(
        default_factory=_partial_env(_env_bool, "CLICKHOUSE_SECURE", "true")
    )
    clickhouse_secure_http: bool = field(
        default_factory=_partial_env(_env_bool, "CLICKHOUSE_SECURE_HTTP", "true")
    )
    clickhouse_verify: bool = field(
        default_factory=_partial_env(_env_bool, "CLICKHOUSE_VERIFY", "false")
    )
    clickhouse_dsn: str = field(default_factory=_partial_env(_env_str, "CLICKHOUSE_DSN", ""))
    dbt_target: str = field(default_factory=_partial_env(_env_str, "DBT_TARGET", "dev"))
    dbt_threads: int = field(default_factory=_partial_env(_env_int, "DBT_THREADS", "4"))
    fastapi_host: str = field(default_factory=_partial_env(_env_str, "FASTAPI_HOST", "127.0.0.1"))
    fastapi_port: int = field(default_factory=_partial_env(_env_int, "FASTAPI_PORT", "8000"))

    def __post_init__(self) -> None:
        if not self.clickhouse_dsn:
            dsn = (
                f"clickhouse://{self.clickhouse_user}:{self.clickhouse_password}"
                f"@{self.clickhouse_host}:{self.clickhouse_port}/{self.clickhouse_database}"
            )
            object.__setattr__(self, "clickhouse_dsn", dsn)


settings = Settings()


def _sync_cosmos_section() -> None:
    """Ensure the Airflow config contains a [cosmos] section with sane defaults."""

    airflow_cfg = settings.airflow_home / "airflow.cfg"
    template_path = Path(__file__).parent / "airflow" / "cosmos" / "cosmos.conf"
    if not airflow_cfg.exists() or not template_path.exists():
        return

    parser = configparser.ConfigParser()
    parser.read(airflow_cfg)
    template = configparser.ConfigParser()
    template.read(template_path)

    updated = False
    for section in template.sections():
        if section not in parser.sections():
            parser.add_section(section)
            updated = True
        for key, value in template[section].items():
            if not parser[section].get(key):
                parser[section][key] = value
                updated = True

    if updated:
        with airflow_cfg.open("w", encoding="utf-8") as cfg_file:
            parser.write(cfg_file)


_sync_cosmos_section()
