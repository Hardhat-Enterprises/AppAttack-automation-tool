import subprocess
import pytest

from appAttack_tools.ai.providers.ollama_provider import OllamaProvider


class DummyResp:
    def __init__(self, status_code=200, text='ok'):
        self.status_code = status_code
        self._text = text

    def json(self):
        return {"text": self._text}


def test_ollama_http(monkeypatch):
    def fake_post(url, json=None, timeout=None):
        return DummyResp(200, text='http ok')

    monkeypatch.setattr('requests.post', fake_post)
    o = OllamaProvider(host='http://fakehost:11434', model='test')
    out = o.generate('hello')
    assert isinstance(out, dict)


def test_ollama_cli_fallback(monkeypatch):
    # make requests.post raise
    def fake_post(url, json=None, timeout=None):
        raise Exception('no http')

    monkeypatch.setattr('requests.post', fake_post)

    class P:
        returncode = 0
        stdout = 'cli ok'
        stderr = ''

    monkeypatch.setattr('subprocess.run', lambda *a, **k: P)
    o = OllamaProvider(host='http://fakehost:11434', model='test')
    out = o.generate('hello')
    assert 'cli ok' in out.get('text','')
