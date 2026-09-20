#!/usr/bin/env python3
"""Audit upstream releases, not installed services. Uses the standard library only."""

import argparse
import gzip
import hashlib
import json
import os
from pathlib import Path
import re
import sys
from datetime import datetime, timezone
import urllib.request
from urllib.parse import urlparse

ROOT = Path(__file__).resolve().parents[1]
TITLE = "Technology version audit: review external updates"
MARKER = "<!-- infusing-a-soul-technology-audit -->"


def version_key(value):
    """Accept stable numeric releases and Git for Windows' stable suffix only."""
    match = re.fullmatch(r"(?:docker-)?v?(\d+(?:\.\d+)*)(?:\.windows\.(\d+))?", value)
    if not match:
        raise ValueError(f"Not a supported stable version: {value!r}")
    parts = tuple(map(int, match[1].split(".")))
    return parts + ((int(match[2]),) if match[2] else ())


def get(url, method="GET", payload=None):
    if urlparse(url).scheme != "https":
        raise ValueError("Release and GitHub API sources must use HTTPS")
    headers = {"User-Agent": "infusing-a-soul-version-audit", "Accept-Encoding": "gzip"}
    token = None
    # Never forward the GitHub credential to vendor websites or package registries.
    if urlparse(url).netloc == "api.github.com":
        token = os.environ.get("GITHUB_TOKEN")
        headers["Accept"] = "application/vnd.github+json"
        headers["X-GitHub-Api-Version"] = "2022-11-28"
    body = None
    if payload is not None:
        headers["Content-Type"] = "application/json"
        body = json.dumps(payload).encode("utf-8")
    request = urllib.request.Request(url, data=body, headers=headers, method=method)
    if token:
        request.add_unredirected_header("Authorization", f"Bearer {token}")
    with urllib.request.urlopen(request, timeout=20) as response:
        data = response.read()
        if data.startswith(b"\x1f\x8b"):
            data = gzip.decompress(data)
        return data.decode("utf-8")


def latest_version(technology, fetch=get):
    kind = technology["kind"]
    raw = fetch(technology["source"])
    if kind == "github-release":
        release = json.loads(raw)
        if release.get("draft") is not False or release.get("prerelease") is not False:
            raise ValueError("Source did not explicitly identify a stable published release")
        version = release["tag_name"]
    elif kind in ("node-current", "node-lts"):
        releases = json.loads(raw)
        candidates = [r["version"] for r in releases
                      if (kind == "node-current" or r.get("lts"))
                      and re.fullmatch(r"v\d+\.\d+\.\d+", r["version"])]
        version = max(candidates, key=version_key)
    elif kind == "npm":
        version = json.loads(raw)["version"]
    elif kind == "python":
        # Match the entire label, so 3.15.0rc1 is never read as 3.15.0.
        candidates = re.findall(r">Python (\d+\.\d+\.\d+)</a>", raw)
        version = max(candidates, key=version_key)
    elif kind == "lm-studio":
        candidates = set(re.findall(r'href="/changelog/lmstudio-v(\d+\.\d+\.\d+)"', raw))
        if len(candidates) != 1:
            raise ValueError("Download page has no unambiguous stable changelog link")
        version = candidates.pop()
    elif kind == "docker-desktop":
        headings = re.findall(r"<h2\b[^>]*>(.*?)</h2>", raw, re.DOTALL)
        labels = [re.sub(r"<[^>]+>", "", heading).strip() for heading in headings]
        candidates = [label for label in labels if re.fullmatch(r"\d+\.\d+\.\d+", label)]
        version = max(candidates, key=version_key)
    else:
        raise ValueError(f"Unknown source parser: {kind}")
    version_key(version)
    return re.sub(r"^(?:docker-)?v", "", version)


def audit(manifest, fetch=get):
    results = []
    cached = {}

    def cached_fetch(url):
        if url not in cached:
            cached[url] = fetch(url)
        return cached[url]

    for technology in manifest["technologies"]:
        row = dict(technology)
        row["latest"] = None
        if technology["kind"] == "manual":
            row["status"] = "MANUAL_CHECK"
        else:
            try:
                row["latest"] = latest_version(technology, cached_fetch)
                latest = version_key(row["latest"])
                reviewed = version_key(technology["reviewed_version"])
                row["status"] = ("NEW_RELEASE" if latest > reviewed else
                                 "SOURCE_REGRESSION" if latest < reviewed else "UNCHANGED")
            except Exception as error:
                row["status"] = "SOURCE_ERROR"
                row["error"] = f"{type(error).__name__}: release could not be verified"
        results.append(row)
    return results


def exit_code(results):
    if any(row["status"] in ("SOURCE_ERROR", "SOURCE_REGRESSION") for row in results):
        return 1
    return 2 if any(row["status"] == "NEW_RELEASE" for row in results) else 0


def cell(value):
    return str(value if value is not None else "Unknown").replace("|", "\\|").replace("\n", " ")


def render(results, checked_at):
    lines = ["# Technology version audit", "", f"Checked at: {checked_at}", "",
             "UNCHANGED compares upstream with the reviewed release baseline. It does not verify installed versions.",
             "Recorded versions are dated observations; check the evidence before planning an upgrade.", "",
             "| Technology | Recorded version / context | Reviewed upstream | Latest retrieved | Result |",
             "| --- | --- | --- | --- | --- |"]
    for row in results:
        recorded = f"{row.get('recorded_version') or 'Unknown'} ({row['evidence']})"
        lines.append("| " + " | ".join(map(cell, [row["name"], recorded,
                     row.get("reviewed_version"), row["latest"], row["status"]])) + " |")
    lines += ["", "## Sources and follow-up", ""]
    for row in results:
        lines.append(f"- {row['name']}: [{row['source']}]({row['source']}). {row['follow_up']}")
        if "error" in row:
            lines.append(f"  Source failure: {row['error']}.")
    lines += ["", "External services require a dated host version, backup, compatibility review, upgrade,",
              "and smoke test. Changing reviewed_version acknowledges research only, never installation.", ""]
    return "\n".join(lines)


def sync_issue(results, report, repository, api=get):
    """Maintain one bot-owned issue; unchanged findings do not generate edits."""
    if not re.fullmatch(r"[A-Za-z0-9_.-]+/[A-Za-z0-9_.-]+", repository):
        raise ValueError("GITHUB_REPOSITORY must be owner/name")
    if not exit_code(results):
        return "No new release or source failure; no issue mutation"
    fingerprint = hashlib.sha256(json.dumps(results, sort_keys=True).encode()).hexdigest()
    stamp = f"<!-- findings:{fingerprint} -->"
    base = f"https://api.github.com/repos/{repository}/issues"
    matches = []
    page = 1
    while True:
        issues = json.loads(api(f"{base}?state=open&per_page=100&page={page}"))
        matches += [i for i in issues if "pull_request" not in i and i["title"] == TITLE
                    and i.get("user", {}).get("login") == "github-actions[bot]"]
        if len(issues) < 100:
            break
        page += 1
    if len(matches) > 1:
        raise ValueError("Multiple bot-owned tracking issues; consolidate before updating")
    body = f"{MARKER}\n{stamp}\n\n{report}"
    if matches:
        issue = matches[0]
        if stamp in (issue.get("body") or ""):
            return "Tracking issue already contains these findings"
        api(f"{base}/{issue['number']}", method="PATCH", payload={"body": body})
        return f"Updated tracking issue #{issue['number']}"
    issue = json.loads(api(base, method="POST", payload={"title": TITLE, "body": body}))
    return f"Created tracking issue #{issue['number']}"


def main(argv=None):
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--manifest", type=Path, default=ROOT / "docs/technology-versions.json")
    parser.add_argument("--output-dir", type=Path, default=ROOT / ".local/technology-audit")
    parser.add_argument("--update-issue", action="store_true",
                        help="Write the bot-owned tracking issue using GITHUB_TOKEN")
    args = parser.parse_args(argv)
    manifest = json.loads(args.manifest.read_text(encoding="utf-8"))
    results = audit(manifest)
    checked_at = datetime.now(timezone.utc).isoformat(timespec="seconds")
    report = render(results, checked_at)
    args.output_dir.mkdir(parents=True, exist_ok=True)
    (args.output_dir / "version-audit.md").write_text(report, encoding="utf-8")
    (args.output_dir / "version-audit.json").write_text(
        json.dumps({"checked_at": checked_at, "results": results}, indent=2) + "\n", encoding="utf-8")
    for row in results:
        print(f"{row['id']}: latest={row['latest']} status={row['status']}")
    if args.update_issue:
        if not os.environ.get("GITHUB_TOKEN"):
            raise RuntimeError("GITHUB_TOKEN is required for --update-issue")
        print(sync_issue(results, report, os.environ.get("GITHUB_REPOSITORY", "")))
    return exit_code(results)


if __name__ == "__main__":
    sys.exit(main())
