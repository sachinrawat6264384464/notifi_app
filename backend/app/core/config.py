from typing import List, Union
from pydantic import AnyHttpUrl, field_validator
from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    model_config = SettingsConfigDict(
        env_file=".env",
        env_file_encoding="utf-8",
        extra="ignore"
    )

    API_V1_STR: str = "/api/v1"
    PROJECT_NAME: str = "Smart Personal Scheduler & Reminder API"
    APP_ENV: str = "development"
    SECRET_KEY: str = "default_secret_key_change_in_production_32_chars"

    # Database
    DATABASE_URL: str = "postgresql://postgres:postgres@localhost:5432/smart_scheduler"

    # Redis & Celery
    REDIS_URL: str = "redis://localhost:6379/0"
    CELERY_BROKER_URL: str = "redis://localhost:6379/0"
    CELERY_RESULT_BACKEND: str = "redis://localhost:6379/1"

    # Firebase Admin SDK
    FIREBASE_PROJECT_ID: str = ""
    FIREBASE_CLIENT_EMAIL: str = ""
    FIREBASE_PRIVATE_KEY: str = ""
    FIREBASE_CREDENTIALS_FILE: str = ""

    # CORS
    CORS_ORIGINS: List[str] = ["*"]

    @field_validator("CORS_ORIGINS", mode="before")
    @classmethod
    def assemble_cors_origins(cls, v: Union[str, List[str]]) -> List[str]:
        if isinstance(v, str) and not v.startswith("["):
            return [i.strip() for i in v.split(",")]
        elif isinstance(v, (list, str)):
            return v
        raise ValueError(v)


settings = Settings()
