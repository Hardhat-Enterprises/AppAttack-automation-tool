import json
import requests
from typing import Any, Dict
from .base import BaseProvider, ProviderError
from ..config_manager import get_api_key


class GeminiProvider(BaseProvider):
    name = "gemini"

    def __init__(self, api_key: str = None):
        self.api_key = api_key or get_api_key("gemini")

    def available(self) -> bool:
        return bool(self.api_key)

    def generate(self, prompt: str, timeout: int = 30) -> Dict[str, Any]:
        if not self.api_key:
            raise ProviderError("missing_key", "Gemini API key not found")

        url = f"https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key={self.api_key}"
        payload = {
            "contents": [
                {"parts": [{"text": prompt}]}
            ]
        }
        try:
            resp = requests.post(url, json=payload, timeout=timeout)
        except requests.RequestException as e:
            raise ProviderError("network_error", str(e), transient=True)

        if resp.status_code == 401 or resp.status_code == 403:
            raise ProviderError("invalid_key", f"Authentication failed: {resp.status_code}", transient=False)

        if resp.status_code >= 500:
            raise ProviderError("server_error", f"Provider error: {resp.status_code}", transient=True)

        try:
            return resp.json()
        except Exception:
            return {"text": resp.text}
