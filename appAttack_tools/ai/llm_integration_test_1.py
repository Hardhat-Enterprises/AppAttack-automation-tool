"""
Hybrid LLM integration test script.

This file adapts an existing Ollama-only script to support a Local (Ollama)
or Global (cloud) selection and routes accordingly.

Usage: python llm_integration_test_1.py
"""
import sys
import time
from typing import Optional

try:
    import ollama
except Exception:
    ollama = None

from appAttack_tools.ai.manager import get_ai_response


def analyze_original():
    """Return a short analysis of the original functions (for developer visibility)."""
    return {
        "choose_llm": "Lists installed Ollama models, optionally pulls models, returns chosen model name or None",
        "chat_with_llm": "Streams chat output from ollama.chat with messages list and prints chunks",
        "notes": "Original script assumed Ollama client available and didn't support cloud providers or normalization."
    }


def choose_llm() -> Optional[str]:
    """List installed Ollama models and let user pick one. Returns the model name or None."""
    if ollama is None:
        print("Ollama SDK not available in this environment.")
        return None

    models_info = ollama.list()
    model_names = []

    print("The models you have installed on your machine are:")
    for model in models_info.get('models', []):
        name = model.get('model')
        print('-', name)
        model_names.append(name)

    if len(model_names) == 0:
        print("None installed.")
        resp = input('Would you like to install a model? (y/n): ').strip().lower()
        while resp not in ['y', 'n']:
            resp = input('Please answer y or n: ').strip().lower()
        if resp == 'n':
            return None
        print('Select model number 1 if you have ~8GB VRAM, model 2 if you have larger resources')
        choice = input('Choose 1 or 2: ').strip()
        while choice not in ['1', '2']:
            choice = input('Please choose 1 or 2: ').strip()
        if choice == '1':
            print('Pulling deepseek-r1:8b...')
            ollama.pull('deepseek-r1:8b')
        else:
            print('Pulling gpt-oss:20b...')
            ollama.pull('gpt-oss:20b')

    # Choose from installed models
    print('\nInput the name of the model you would like to run:')
    user_selected_model = input().strip()
    while user_selected_model not in model_names:
        user_selected_model = input('Invalid model name, try again: ').strip()
    return user_selected_model


def chat_with_ollama(user_selected_model: str, prompt: str):
    """Chat using the Ollama streaming API (original behavior)."""
    if ollama is None:
        raise RuntimeError('Ollama SDK not installed')

    stream = ollama.chat(
        model=user_selected_model,
        messages=[{'role': 'user', 'content': prompt}],
        stream=True,
    )
    for chunk in stream:
        # Some Ollama SDKs return nested structures; guard reads
        msg = chunk.get('message') if isinstance(chunk, dict) else None
        content = None
        if isinstance(msg, dict):
            content = msg.get('content')
        if content is None:
            # fallback printing raw chunk
            print(chunk, end='', flush=True)
        else:
            print(content, end='', flush=True)
    print('\n')


def chat_with_cloud(prompt: str):
    """Route prompt to `manager.get_ai_response` (cloud/local routing managed there).

    This uses the configured cloud provider in the ai config (e.g., gemini) and
    returns the normalized response.
    """
    resp = get_ai_response(prompt)
    # resp is a NormalizedResponse with fields: text, tokens_used, provider_type, provider_name, raw, error
    if resp.get('error'):
        err = resp['error']
        print(f"Error from provider {resp.get('provider_name')}: {err.get('code')}: {err.get('message')} (transient={err.get('transient')})")
        return resp
    print(resp.get('text') or '')
    return resp


def startup_menu():
    print('Choose LLM mode:')
    print('1) Local (Ollama)')
    print('2) Global (Cloud LLM via manager)')
    choice = input('Enter 1 or 2: ').strip()
    while choice not in ['1', '2']:
        choice = input('Please enter 1 or 2: ').strip()
    return 'local' if choice == '1' else 'global'


def main():
    print('Hybrid LLM demo')
    print('Analysis of original script:')
    print(analyze_original())

    mode = startup_menu()
    prompt = 'Why is the sky blue?'

    if mode == 'local':
        model = choose_llm()
        if not model:
            print('No model selected or Ollama unavailable; exiting.')
            return
        try:
            chat_with_ollama(model, prompt)
        except Exception as e:
            print(f'Local LLM error: {e}')
    else:
        try:
            chat_with_cloud(prompt)
        except Exception as e:
            print(f'Cloud LLM error: {e}')


if __name__ == '__main__':
    try:
        main()
    except KeyboardInterrupt:
        print('\nInterrupted')
        sys.exit(0)
