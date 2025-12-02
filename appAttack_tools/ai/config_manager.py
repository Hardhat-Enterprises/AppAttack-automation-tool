import json
import os
from typing import Dict, Any, Optional

try:
    import keyring
except Exception:
    keyring = None

try:
    from cryptography.fernet import Fernet, InvalidToken
except Exception:
    Fernet = None
    InvalidToken = Exception

CONFIG_PATH = os.path.join(os.path.dirname(__file__), "config.json")
KEYS_ENC_PATH = os.path.join(os.path.dirname(__file__), ".keys.enc")
MASTER_KEY_PATH = os.path.join(os.path.dirname(__file__), "master.key")


class ConfigError(Exception):
    pass


def load_config() -> Dict[str, Any]:
    if not os.path.exists(CONFIG_PATH):
        # return defaults
        return {
            "mode": "hybrid",
            "cloud_provider": "gemini",
            "providers": {
                "gemini": {"api_key_stored": False},
                "openai": {"api_key_stored": False}
            },
            "local": {"ollama": {"host": "http://localhost:11434", "model": "ollama/gpt-4o"}},
            "local_with_web_access": False
        }
    with open(CONFIG_PATH, "r", encoding="utf-8") as f:
        try:
            return json.load(f)
        except Exception as e:
            raise ConfigError(f"Failed to parse config: {e}")


def save_config(cfg: Dict[str, Any]) -> None:
    with open(CONFIG_PATH, "w", encoding="utf-8") as f:
        json.dump(cfg, f, indent=2)


def store_api_key(provider: str, api_key: str) -> None:
    """Store API key encrypted with a local master key. If cryptography isn't
    available, fall back to keyring if present, or to environment file (less secure).
    """
    # Prefer Fernet encryption
    if Fernet:
        # ensure master key exists
        if not os.path.exists(MASTER_KEY_PATH):
            key = Fernet.generate_key()
            with open(MASTER_KEY_PATH, "wb") as f:
                f.write(key)
            os.chmod(MASTER_KEY_PATH, 0o600)
        else:
            with open(MASTER_KEY_PATH, "rb") as f:
                key = f.read()
        f = Fernet(key)
        # load existing dict
        data = {}
        if os.path.exists(KEYS_ENC_PATH):
            try:
                with open(KEYS_ENC_PATH, "rb") as ef:
                    blob = ef.read()
                raw = f.decrypt(blob).decode("utf-8")
                data = json.loads(raw)
            except Exception:
                data = {}
        data[provider] = api_key
        encrypted = f.encrypt(json.dumps(data).encode("utf-8"))
        with open(KEYS_ENC_PATH, "wb") as ef:
            ef.write(encrypted)
        os.chmod(KEYS_ENC_PATH, 0o600)
        return

    # fallback to keyring
    if keyring:
        keyring.set_password("appattack_ai", provider, api_key)
        return

    # final fallback: environment-style .keys file (least secure)
    keys_file = os.path.join(os.path.dirname(__file__), ".keys")
    lines = []
    if os.path.exists(keys_file):
        with open(keys_file, "r", encoding="utf-8") as f:
            lines = f.readlines()
    new_lines = [l for l in lines if not l.startswith(provider + "=" )]
    new_lines.append(f"{provider}={api_key}\n")
    with open(keys_file, "w", encoding="utf-8") as f:
        f.writelines(new_lines)
    os.chmod(keys_file, 0o600)


def get_api_key(provider: str) -> Optional[str]:
    # Try encrypted file first
    if Fernet and os.path.exists(MASTER_KEY_PATH) and os.path.exists(KEYS_ENC_PATH):
        try:
            with open(MASTER_KEY_PATH, "rb") as f:
                key = f.read()
            fernet = Fernet(key)
            with open(KEYS_ENC_PATH, "rb") as ef:
                blob = ef.read()
            raw = fernet.decrypt(blob).decode("utf-8")
            data = json.loads(raw)
            return data.get(provider)
        except Exception:
            # decryption failed or corrupted file
            return None

    # fallback to keyring
    if keyring:
        try:
            return keyring.get_password("appattack_ai", provider)
        except Exception:
            return None

    # fallback to plain .keys
    keys_file = os.path.join(os.path.dirname(__file__), ".keys")
    if os.path.exists(keys_file):
        with open(keys_file, "r", encoding="utf-8") as f:
            for line in f:
                if line.startswith(provider + "="):
                    return line.split("=",1)[1].strip()
    # final fallback: environment variable
    return os.environ.get(provider.upper() + "_API_KEY")
