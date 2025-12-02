#!/usr/bin/env python3
"""Simple CLI for the AI subsystem.

Commands:
  get --prompt "..."    # returns JSON normalized response
  set-key <provider>     # prompts for API key and stores it
  set-mode <mode>        # cloud/local/hybrid
  status                 # prints config
"""
import argparse
import json
import getpass
from .manager import get_ai_response
from .config_manager import load_config, save_config, store_api_key, get_api_key


def cmd_get(args):
    resp = get_ai_response(args.prompt, timeout=args.timeout)
    print(json.dumps(resp, indent=2))


def cmd_set_key(args):
    key = getpass.getpass(f"Enter API key for {args.provider}: ")
    store_api_key(args.provider, key)
    print("Key stored (using keyring if available).")


def cmd_set_mode(args):
    cfg = load_config()
    if args.mode not in ("cloud", "local", "hybrid"):
        print("Invalid mode. Choose cloud/local/hybrid")
        return
    cfg["mode"] = args.mode
    save_config(cfg)
    print("Mode updated")


def cmd_status(args):
    cfg = load_config()
    # Do not print secrets
    cfg_safe = dict(cfg)
    print(json.dumps(cfg_safe, indent=2))


def main():
    parser = argparse.ArgumentParser(prog="ai_cli")
    sub = parser.add_subparsers(dest="cmd")

    p_get = sub.add_parser("get")
    p_get.add_argument("--prompt", required=True)
    p_get.add_argument("--timeout", type=int, default=30)

    p_set = sub.add_parser("set-key")
    p_set.add_argument("provider", help="provider name (eg. gemini, openai)")

    p_mode = sub.add_parser("set-mode")
    p_mode.add_argument("mode", help="cloud|local|hybrid")

    sub.add_parser("status")

    args = parser.parse_args()
    if args.cmd == "get":
        cmd_get(args)
    elif args.cmd == "set-key":
        cmd_set_key(args)
    elif args.cmd == "set-mode":
        cmd_set_mode(args)
    elif args.cmd == "status":
        cmd_status(args)
    else:
        parser.print_help()


if __name__ == "__main__":
    main()
