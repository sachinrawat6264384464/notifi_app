import json
import firebase_admin
from firebase_admin import credentials, auth
from app.core.config import settings
from app.core.logging import logger

_firebase_app = None


def initialize_firebase():
    global _firebase_app
    if _firebase_app:
        return _firebase_app

    try:
        if settings.FIREBASE_CREDENTIALS_FILE:
            cred = credentials.Certificate(settings.FIREBASE_CREDENTIALS_FILE)
            _firebase_app = firebase_admin.initialize_app(cred)
            logger.info("Firebase initialized using credentials file.")
        elif settings.FIREBASE_PRIVATE_KEY and settings.FIREBASE_CLIENT_EMAIL:
            key_dict = {
                "type": "service_account",
                "project_id": settings.FIREBASE_PROJECT_ID,
                "private_key": settings.FIREBASE_PRIVATE_KEY.replace("\\n", "\n"),
                "client_email": settings.FIREBASE_CLIENT_EMAIL,
            }
            cred = credentials.Certificate(key_dict)
            _firebase_app = firebase_admin.initialize_app(cred)
            logger.info("Firebase initialized using environment credentials.")
        else:
            # Fallback initialization for local dev/testing without credentials
            _firebase_app = firebase_admin.initialize_app()
            logger.info("Firebase initialized with default app.")
    except Exception as e:
        logger.warning(f"Firebase initialization warning: {str(e)}. Mocking/fallback may be active.")
    return _firebase_app


def verify_firebase_token(id_token: str) -> dict:
    """
    Verifies Firebase ID token using Firebase Admin SDK.
    Returns decoded token dictionary containing uid, email, name, etc.
    Supports mock tokens in development/testing mode (e.g. 'mock_token_uid_123').
    """
    if settings.APP_ENV in ["development", "testing"] and id_token.startswith("mock_token_"):
        parts = id_token.split("_")
        uid = parts[2] if len(parts) > 2 else "test_user_uid"
        return {
            "uid": uid,
            "email": f"{uid}@example.com",
            "name": f"User {uid}",
            "firebase": {"sign_in_provider": "password"}
        }

    initialize_firebase()
    try:
        decoded_token = auth.verify_id_token(id_token)
        return decoded_token
    except Exception as e:
        logger.error(f"Failed to verify Firebase ID token: {str(e)}")
        raise e
