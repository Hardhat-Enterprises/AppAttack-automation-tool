import json
import types
import pytest

from appAttack_tools.ai.providers.gemini_provider import GeminiProvider


class DummyResp:
    def __init__(self, status_code=200, data=None):
        self.status_code = status_code
        self._data = data or {"candidates": [{"content": "ok"}], "usage": {"total_tokens": 5}}

    def json(self):
        return self._data


def test_gemini_generate_success(monkeypatch):
    def fake_post(url, json=None, timeout=None):
        return DummyResp(200)

    monkeypatch.setattr('requests.post', fake_post)
    prov = GeminiProvider(api_key='fakekey')
    out = prov.generate('hello')
    assert isinstance(out, dict)


def test_manager_uses_gemini(monkeypatch):
    # ensure get_api_key returns a key
    import appAttack_tools.ai.manager as mgr

    monkeypatch.setattr('appAttack_tools.ai.config_manager.get_api_key', lambda p: 'fakekey')

    # monkeypatch GeminiProvider.generate to return predictable raw
    class FakeProv:
        def __init__(self, api_key=None):
            pass
        def generate(self, prompt, timeout=30):
            return {"candidates": [{"content": "manager ok"}], "usage": {"total_tokens": 3}}

    monkeypatch.setattr('appAttack_tools.ai.manager.GeminiProvider', FakeProv)
    got = mgr.get_ai_response('hello')
    assert got['provider_type'] == 'cloud'
    assert 'manager ok' in got['text']


def test_hybrid_fallback_on_transient(monkeypatch):
    import appAttack_tools.ai.manager as mgr
    from appAttack_tools.ai.providers.base import ProviderError

    monkeypatch.setattr('appAttack_tools.ai.config_manager.get_api_key', lambda p: 'fakekey')

    class TransientProv:
        def __init__(self, api_key=None):
            self.called = 0
        def generate(self, prompt, timeout=30):
            self.called += 1
            # first two calls transient fail
            if self.called <= 2:
                raise ProviderError('network_error', 'timeout', transient=True)
            return {"candidates": [{"content": "late success"}], "usage": {"total_tokens": 2}}

    class LocalProv:
        def __init__(self, **k):
            pass
        def generate(self, prompt, timeout=30):
            return {"text": "local ok"}

    monkeypatch.setattr('appAttack_tools.ai.manager.GeminiProvider', TransientProv)
    monkeypatch.setattr('appAttack_tools.ai.manager.OllamaProvider', LocalProv)

    got = mgr.get_ai_response('hello')
    # should return local fallback
    assert got['provider_type'] == 'local'
    assert 'local ok' in got['text']


def test_both_fail_returns_error(monkeypatch):
    import appAttack_tools.ai.manager as mgr
    from appAttack_tools.ai.providers.base import ProviderError

    monkeypatch.setattr('appAttack_tools.ai.config_manager.get_api_key', lambda p: 'fakekey')

    class PermanentProv:
        def __init__(self, api_key=None):
            pass
        def generate(self, prompt, timeout=30):
            raise ProviderError('invalid_key', 'bad key', transient=False)

    class LocalPermanent:
        def __init__(self, **k):
            pass
        def generate(self, prompt, timeout=30):
            raise ProviderError('not_installed', 'no cli', transient=False)

    monkeypatch.setattr('appAttack_tools.ai.manager.GeminiProvider', PermanentProv)
    monkeypatch.setattr('appAttack_tools.ai.manager.OllamaProvider', LocalPermanent)

    got = mgr.get_ai_response('hello')
    # both failed -> normalized cloud error returned
    assert got['provider_type'] == 'cloud'
    assert got['error'] and got['error']['transient'] is False
