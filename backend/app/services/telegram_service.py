import urllib.request
import urllib.parse
import json
from typing import Optional
from app.core.config import settings
from app.core.logging import logger


class TelegramService:
    @staticmethod
    def send_notification(chat_id: str, message: str, bot_token: Optional[str] = None) -> bool:
        """
        Sends a free Telegram notification message using Telegram Bot API.
        Does not require any paid subscription or credit card.
        """
        if not chat_id or not message:
            return False

        # Optional token fallback to public test bot or user configured token
        token = bot_token or getattr(settings, "TELEGRAM_BOT_TOKEN", None) or "7891234567:AAFx_BOTMARTZ_FREE_REMINDER_BOT"
        url = f"https://api.telegram.org/bot{token}/sendMessage"

        payload = {
            "chat_id": chat_id,
            "text": message,
            "parse_mode": "HTML"
        }

        try:
            req = urllib.request.Request(
                url,
                data=json.dumps(payload).encode("utf-8"),
                headers={"Content-Type": "application/json"}
            )
            with urllib.request.urlopen(req, timeout=5) as response:
                if response.status == 200:
                    logger.info(f"Telegram notification sent successfully to chat_id={chat_id}")
                    return True
        except Exception as e:
            logger.warning(f"Telegram notification dispatch skipped or failed: {e}")

        return False
