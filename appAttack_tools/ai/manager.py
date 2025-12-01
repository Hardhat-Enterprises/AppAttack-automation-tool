from typing import Any, Dict, Optional
from .config_manager import load_config, get_api_key
from .providers.base import ProviderError
from .providers.gemini_provider import GeminiProvider
from .providers.ollama_provider import OllamaProvider
import time


class NormalizedResponse(Dict[str, Any]):
    pass


def _normalize(provider_name: str, provider_type: str, raw: Any) -> NormalizedResponse:
    # Basic normalization: try to extract a text from common fields
    text = None
    tokens = None
    if isinstance(raw, dict):
        # common fields
        text = raw.get("text") or raw.get("content") or raw.get("answer")
        # nested candidate
        if not text:
            # try openai/gemini style
            candidates = raw.get("candidates") or raw.get("choices")
            if candidates and isinstance(candidates, list) and len(candidates) > 0:
                first = candidates[0]
                text = first.get("content") or first.get("text") or first.get("message")
        # tokens
        usage = raw.get("usage") or raw.get("token_usage")
        if isinstance(usage, dict):
            tokens = usage.get("total_tokens") or usage.get("prompt_tokens")
    else:
        # raw might be a string
        text = str(raw)

    # normalize error if present in raw
    error_obj = None
    if isinstance(raw, dict) and raw.get("error"):
        e = raw.get("error")
        # e may be dict or object
        if isinstance(e, dict):
            code = e.get("code")
            message = e.get("message")
            transient = e.get("transient") if "transient" in e else None
        else:
            code = getattr(e, "code", None)
            message = getattr(e, "message", str(e))
            transient = getattr(e, "transient", None)
        error_obj = {"code": code, "message": message, "transient": bool(transient)}

    return NormalizedResponse({
        "text": text or "",
        "tokens_used": tokens,
        "provider_type": provider_type,
        "provider_name": provider_name,
        "raw": raw,
        "error": error_obj
    })


def get_ai_response(prompt: str, timeout: int = 30) -> NormalizedResponse:
    """Simple router. Currently uses config to decide routing but adapters not yet implemented.

    This scaffold returns a placeholder response so shell scripts can be migrated to call
    this function in the future.
    """
    cfg = load_config()
    mode = cfg.get("mode", "hybrid")
    provider = cfg.get("cloud_provider", "gemini")

    api_key = get_api_key(provider)

    def _attempt_provider_call(provider_obj, provider_name, provider_type, max_retries=2):
        attempt = 0
        backoff = 0.5
        while True:
            try:
                raw = provider_obj.generate(prompt, timeout=timeout)
                return _normalize(provider_name, provider_type, raw)
            except ProviderError as e:
                attempt += 1
                if e.transient and attempt <= max_retries:
                    time.sleep(backoff)
                    backoff *= 2
                    continue
                # return structured error including transient flag
                return _normalize(provider_name, provider_type, {"text": "", "error": {"code": e.code, "message": e.message, "transient": bool(getattr(e, 'transient', False))}})

    # If cloud-only mode, attempt cloud and return error if it fails
    if mode == "cloud":
        if provider == "gemini":
            prov = GeminiProvider(api_key)
            return _attempt_provider_call(prov, provider, "cloud")

    # If local-only mode, attempt Ollama
    if mode == "local":
        oll = OllamaProvider(**cfg.get("local", {}).get("ollama", {}))
        try:
            raw = oll.generate(prompt, timeout=timeout)
            return _normalize("ollama", "local", raw)
        except ProviderError as e:
            return _normalize("ollama", "local", {"text": "", "error": {"code": e.code, "message": e.message, "transient": bool(getattr(e, 'transient', False))}})

    # hybrid mode: try cloud first, fallback to local
    if mode == "hybrid":
        if provider == "gemini" and api_key:
            prov = GeminiProvider(api_key)
            cloud_resp = _attempt_provider_call(prov, provider, "cloud")
            if cloud_resp.get("text"):
                return cloud_resp
            # cloud returned an error -> try local
            oll = OllamaProvider(**cfg.get("local", {}).get("ollama", {}))
            local_resp = _attempt_provider_call(oll, "ollama", "local")
            # if local returned text use it, otherwise return cloud_resp error
            if local_resp.get("text"):
                # attach cloud error info into raw for debugging
                if isinstance(local_resp.get("raw"), dict):
                    local_resp["raw"].setdefault("_fallback_info", {})
                    local_resp["raw"]["_fallback_info"]["cloud_error"] = cloud_resp.get("error")
                return local_resp
            return cloud_resp

        # if no api key for cloud, use local
        raw = {"content": f"(simulated local reply) {prompt[:200]}"}
        return _normalize("ollama", "local", raw)

    # default fallback
    raw = {"content": f"(simulated local reply) {prompt[:200]}"}
    return _normalize("ollama", "local", raw)
