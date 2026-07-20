#!/usr/bin/env python3
"""Report changes to the external technology snapshot in the inventory."""

import json
import re
import sys
import urllib.request


SNAPSHOT = {
    "openclaw": ("2026.7.1", "https://api.github.com/repos/openclaw/openclaw/releases/latest"),
    "ollama": ("0.32.1", "https://api.github.com/repos/ollama/ollama/releases/latest"),
    "qdrant": ("1.18.3", "https://api.github.com/repos/qdrant/qdrant/releases/latest"),
    "lm-studio": ("0.4.19", "https://lmstudio.ai/download"),
}


def get(url):
    request = urllib.request.Request(url, headers={"User-Agent": "infusing-a-soul-version-audit"})
    with urllib.request.urlopen(request, timeout=20) as response:
        return response.read().decode("utf-8")


def latest_github_release(url):
    payload = json.loads(get(url))
    return payload["tag_name"].lstrip("v")


def latest_lm_studio(url):
    page = get(url)
    versions = re.findall(r"\b0\.\d+\.\d+\b", page)
    if not versions:
        raise RuntimeError("LM Studio download page did not expose a stable version")
    return max(versions, key=lambda version: tuple(int(part) for part in version.split(".")))


def main():
    drift = False
    for name, (known, source) in SNAPSHOT.items():
        try:
            actual = latest_lm_studio(source) if name == "lm-studio" else latest_github_release(source)
            status = "current"
            if actual != known:
                drift = True
                status = "UPDATE_AVAILABLE"
            print(f"{name}: snapshot={known} latest={actual} status={status} source={source}")
        except Exception as error:
            drift = True
            print(f"{name}: ERROR {error} source={source}", file=sys.stderr)

    # SearXNG is intentionally not included: it has no GitHub releases and must
    # be tracked by the actual image digest or commit on the service host.
    print("searxng: manual-check-required reason=no GitHub stable releases")
    return 2 if drift else 0


if __name__ == "__main__":
    raise SystemExit(main())
