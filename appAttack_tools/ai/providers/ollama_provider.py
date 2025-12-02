import json
import subprocess
import requests
from typing import Any, Dict
from .base import BaseProvider, ProviderError
from ..config_manager import get_api_key


class OllamaProvider(BaseProvider):
    name = "ollama"

    def __init__(self, host: str = "http://localhost:11434", model: str = "ollama/gpt-4o"):
        self.host = host
        self.model = model

    def available(self) -> bool:
        # check HTTP endpoint
        try:
            r = requests.get(self.host, timeout=1)
            return r.status_code < 500
        except Exception:
            # fall back to checking ollama CLI
            try:
                out = subprocess.check_output(["ollama", "ls"], stderr=subprocess.DEVNULL, timeout=2)
                return True
            except Exception:
                return False

    def generate(self, prompt: str, timeout: int = 30) -> Dict[str, Any]:
        # try HTTP API first (common Ollama server path /api/generate)
        url = f"{self.host}/api/generate"
        payload = {"model": self.model, "prompt": prompt}
        try:
            resp = requests.post(url, json=payload, timeout=timeout)
            if resp.status_code >= 400:
                # treat 5xx as transient, 4xx as permanent
                if resp.status_code >= 500:
                    raise ProviderError("server_error", f"Ollama server returned {resp.status_code}", transient=True)
                raise ProviderError("server_error", f"Ollama server returned {resp.status_code}", transient=False)
            try:
                return resp.json()
            except Exception:
                return {"text": resp.text}
        except requests.RequestException as e:
            # network/timeouts -> transient
            net_err = ProviderError("network_error", str(e), transient=True)
            # fallback to ollama CLI
            try:
                proc = subprocess.run(["ollama", "generate", self.model, prompt], capture_output=True, text=True, timeout=timeout)
                if proc.returncode != 0:
                    raise ProviderError("cli_error", proc.stderr.strip() or "unknown", transient=False)
                # cli returns raw text
                return {"text": proc.stdout}
            except subprocess.TimeoutExpired:
                raise ProviderError("timeout", "Ollama CLI timed out", transient=True)
            except FileNotFoundError:
                raise ProviderError("not_installed", "Ollama CLI not installed and HTTP endpoint unreachable", transient=False)
