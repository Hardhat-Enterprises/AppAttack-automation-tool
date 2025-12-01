from typing import Any, Dict, Optional


class ProviderError(Exception):
    def __init__(self, code: str, message: str, transient: bool = False):
        """
        code: short error code string
        message: human message
        transient: True if the error is transient (retryable)
        """
        super().__init__(message)
        self.code = code
        self.message = message
        self.transient = transient


class BaseProvider:
    """Minimal provider interface all adapters should implement."""

    name: str = "base"

    def connect(self) -> None:
        """Optional connect/handshake step."""
        return None

    def available(self) -> bool:
        """Return True if provider appears available (authentication, local server up)."""
        return True

    def generate(self, prompt: str, timeout: int = 30) -> Dict[str, Any]:
        """Generate a response for the prompt.

        Should return a provider-specific dict. Raise ProviderError on permanent failure.
        """
        raise NotImplementedError()
