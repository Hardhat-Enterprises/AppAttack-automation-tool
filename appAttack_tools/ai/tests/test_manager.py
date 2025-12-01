from appAttack_tools.ai.manager import get_ai_response


def test_get_ai_response_shape():
    resp = get_ai_response("hello test prompt")
    assert isinstance(resp, dict)
    assert "text" in resp
    assert "provider_name" in resp
    assert "provider_type" in resp
