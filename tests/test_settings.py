"""Tests for the settings module."""

from __future__ import annotations

from typing import TYPE_CHECKING

import pytest

from settings import settings

if TYPE_CHECKING:
    pass


def test_settings_defaults() -> None:
    """Ensure required settings provide sane defaults."""

    if not settings.clickhouse_host:
        pytest.fail("ClickHouse host must not be empty")
    if settings.dbt_threads <= 0:
        pytest.fail("dbt threads must be positive")
