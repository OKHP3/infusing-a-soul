"""Network-free regression checks for release selection and GitHub issue updates."""

import gzip
import importlib.util
import json
import os
from pathlib import Path
import tempfile
import unittest
from unittest.mock import patch, MagicMock

ROOT = Path(__file__).resolve().parents[1]
SPEC = importlib.util.spec_from_file_location("version_audit", ROOT / "scripts/check-technology-versions.py")
audit = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(audit)


def technology(kind="github-release", reviewed="1.9.0"):
    return {"id": "example", "name": "Example", "kind": kind,
            "source": "https://api.github.com/repos/example/example/releases/latest",
            "reviewed_version": reviewed, "recorded_version": None,
            "evidence": "Installed version unknown", "follow_up": "Verify on host"}


def release(version="v1.10.0", **flags):
    return json.dumps(dict(tag_name=version, draft=False, prerelease=False, **flags))


class ReleaseTests(unittest.TestCase):
    def companion(self, reviewed="2026.9.8"):
        return dict(technology(reviewed=reviewed), id="companion",
                    source="https://api.github.com/repos/openclaw/openclaw-windows-node/releases/latest")

    def test_companion_numeric_revision_is_compared_and_preserved(self):
        for version, reviewed, status in [
                ("v2026.9.8-1", "2026.9.8", "NEW_RELEASE"),
                ("v2026.9.8-10", "2026.9.8-2", "NEW_RELEASE"),
                ("v2026.9.8-2", "2026.9.8-2", "UNCHANGED"),
                ("v2026.9.8-1", "2026.9.8-2", "SOURCE_REGRESSION"),
                ("v2026.9.8", "2026.9.8-1", "SOURCE_REGRESSION"),
                ("v2026.9.9", "2026.9.8-10", "NEW_RELEASE")]:
            with self.subTest(version=version, reviewed=reviewed):
                rows = audit.audit({"technologies": [self.companion(reviewed)]},
                                   lambda _: release(version))
                self.assertEqual(rows[0]["latest"], version.removeprefix("v"))
                self.assertEqual(rows[0]["status"], status)
                self.assertEqual(audit.exit_code(rows),
                                 {"NEW_RELEASE": 2, "UNCHANGED": 0, "SOURCE_REGRESSION": 1}[status])

    def test_companion_revision_support_is_publisher_scoped(self):
        rows = [technology(), dict(self.companion(), id="other"),
                dict(self.companion(), source=technology()["source"]),
                dict(self.companion(), kind="npm")]
        for row in rows:
            payload = release("v2026.9.8-1") if row["kind"] == "github-release" else json.dumps({"version": "2026.9.8-1"})
            with self.subTest(row=row):
                result = audit.audit({"technologies": [row]}, lambda _: payload)[0]
                self.assertEqual(result["status"], "SOURCE_ERROR")
        with self.assertRaises(ValueError):
            audit.version_key("2026.9.8-1")

    def test_companion_rejects_prerelease_flags_and_unsupported_suffixes(self):
        for tag in ["v2026.9.8-rc.1", "v2026.9.8-1-beta", "v2026.9.8-1+dev",
                    "v2026.9.8--1", "v2026.9.8-", "v1.2.3-1"]:
            with self.subTest(tag=tag), self.assertRaises(ValueError):
                audit.latest_version(self.companion(), lambda _: release(tag))
        for flags in [{"draft": True, "prerelease": False},
                      {"draft": False, "prerelease": True}, {}]:
            payload = dict(tag_name="v2026.9.8-1", **flags)
            with self.subTest(flags=flags), self.assertRaises(ValueError):
                audit.latest_version(self.companion(), lambda _: json.dumps(payload))

    def test_numeric_comparison_and_supported_prefixes(self):
        self.assertGreater(audit.version_key("1.10.0"), audit.version_key("1.9.9"))
        self.assertEqual(audit.version_key("docker-v29.8.1"), (29, 8, 1))
        self.assertEqual(audit.version_key("v2.55.0.windows.5"), (2, 55, 0, 5))

    def test_prerelease_tags_are_rejected(self):
        for value in ["1.0.0rc1", "1.0.0-beta.1", "nightly", "v1.0.0+dev"]:
            with self.subTest(value=value), self.assertRaises(ValueError):
                audit.version_key(value)

    def test_github_requires_stable_flags(self):
        for payload in [{"tag_name": "v1.0.0"},
                        {"tag_name": "v1.0.0", "draft": True, "prerelease": False},
                        {"tag_name": "v1.0.0", "draft": False, "prerelease": True}]:
            with self.subTest(payload=payload), self.assertRaises(ValueError):
                audit.latest_version(technology(), lambda _: json.dumps(payload))

    def test_python_does_not_select_rc_or_older_security_branch(self):
        page = '<a>Python 3.15.0rc1</a><a>Python 3.14.7</a><a>Python 3.13.15</a>'
        self.assertEqual(audit.latest_version(technology("python"), lambda _: page), "3.14.7")

    def test_node_current_and_lts_are_separate(self):
        data = json.dumps([{"version": "v26.9.0", "lts": False},
                           {"version": "v24.21.0", "lts": "Krypton"},
                           {"version": "v27.0.0-rc.1", "lts": False}])
        self.assertEqual(audit.latest_version(technology("node-current"), lambda _: data), "26.9.0")
        self.assertEqual(audit.latest_version(technology("node-lts"), lambda _: data), "24.21.0")

    def test_lm_studio_uses_changelog_link_not_largest_page_number(self):
        page = '<a href="/changelog/lmstudio-v0.4.24">release</a> 9.99.99'
        self.assertEqual(audit.latest_version(technology("lm-studio"), lambda _: page), "0.4.24")
        with self.assertRaises(ValueError):
            audit.latest_version(technology("lm-studio"), lambda _: page + '<a href="/changelog/lmstudio-v0.4.25">next</a>')

    def test_docker_handles_minified_heading_and_rejects_preview(self):
        page = '<h2 id=4910><a href=#4910>4.91.0</a></h2><h2>4.92.0-beta</h2><p>9.99.99</p>'
        self.assertEqual(audit.latest_version(technology("docker-desktop"), lambda _: page), "4.91.0")

    def test_new_equal_and_regressed_sources(self):
        for version, status, code in [("1.10.0", "NEW_RELEASE", 2),
                                      ("1.9.0", "UNCHANGED", 0),
                                      ("1.8.0", "SOURCE_REGRESSION", 1)]:
            rows = audit.audit({"technologies": [technology()]}, lambda _: release(version))
            self.assertEqual(rows[0]["status"], status)
            self.assertEqual(audit.exit_code(rows), code)

    def test_one_source_failure_does_not_hide_other_results(self):
        other = dict(technology(), id="other", source="https://other.example/releases")
        def fetch(url):
            if "api.github.com" in url:
                raise TimeoutError("private details must not leak")
            return release()
        rows = audit.audit({"technologies": [technology(), other, technology("manual")]}, fetch)
        self.assertEqual([r["status"] for r in rows], ["SOURCE_ERROR", "NEW_RELEASE", "MANUAL_CHECK"])
        self.assertEqual(audit.exit_code(rows), 1)
        report = audit.render(rows, "test-date")
        self.assertNotIn("private details", report)
        self.assertIn("Installed version unknown", report)

    def test_manual_track_does_not_fetch_or_claim_current(self):
        fetch = MagicMock(side_effect=AssertionError("No request expected"))
        rows = audit.audit({"technologies": [technology("manual")]}, fetch)
        self.assertEqual(rows[0]["status"], "MANUAL_CHECK")
        fetch.assert_not_called()

    def test_gzip_response_and_token_scope(self):
        response = MagicMock()
        response.__enter__.return_value.read.return_value = gzip.compress(b'{"ok":true}')
        with patch.dict(os.environ, {"GITHUB_TOKEN": "test-only"}), patch.object(audit.urllib.request, "urlopen", return_value=response) as opened:
            self.assertEqual(audit.get("https://vendor.example/"), '{"ok":true}')
            self.assertIsNone(opened.call_args.args[0].get_header("Authorization"))
            audit.get("https://api.github.com/repos/example/example/releases/latest")
            request = opened.call_args.args[0]
            self.assertEqual(request.get_header("Authorization"), "Bearer test-only")
            redirected = audit.urllib.request.HTTPRedirectHandler().redirect_request(
                request, None, 302, "Found", {}, "https://vendor.example/")
            self.assertIsNone(redirected.get_header("Authorization"))

    def test_manifest_contract(self):
        manifest = json.loads((ROOT / "docs/technology-versions.json").read_text())
        ids = [r["id"] for r in manifest["technologies"]]
        self.assertEqual(len(ids), len(set(ids)))
        for row in manifest["technologies"]:
            for key in ["name", "source", "evidence", "follow_up"]:
                self.assertTrue(row[key])
            self.assertTrue(row["source"].startswith("https://"))
            if row["kind"] != "manual":
                audit.release_key(row, row["reviewed_version"])

    def test_direct_npm_dependencies_are_tracked_at_locked_versions(self):
        package = json.loads((ROOT / "package.json").read_text())
        lock = json.loads((ROOT / "package-lock.json").read_text())
        manifest = json.loads((ROOT / "docs/technology-versions.json").read_text())
        direct = {**package.get("dependencies", {}), **package.get("devDependencies", {})}
        tracked = {
            row["name"].removeprefix("npm package: "): row
            for row in manifest["technologies"]
            if row["kind"] == "npm" and row["name"].startswith("npm package: ")
        }
        self.assertEqual(set(tracked), set(direct))
        for name in direct:
            with self.subTest(package=name):
                locked = lock["packages"][f"node_modules/{name}"]["version"]
                self.assertEqual(tracked[name]["recorded_version"], locked)
                self.assertEqual(tracked[name]["source"],
                                 f"https://registry.npmjs.org/{name.replace('@', '%40').replace('/', '%2F')}/latest")

    def test_manifest_contract_accepts_reviewed_companion_revision(self):
        manifest = json.loads((ROOT / "docs/technology-versions.json").read_text())
        companion = next(row for row in manifest["technologies"] if row["id"] == "companion")
        companion["reviewed_version"] = "2026.9.8-1"
        with patch.object(Path, "read_text", return_value=json.dumps(manifest)):
            self.test_manifest_contract()


class IssueTests(unittest.TestCase):
    def setUp(self):
        self.rows = audit.audit({"technologies": [technology()]}, lambda _: release())
        self.report = audit.render(self.rows, "test-date")

    def test_create_once_then_skip_unchanged_findings(self):
        calls = []
        def create(url, **kwargs):
            calls.append((url, kwargs))
            return json.dumps({"number": 7}) if kwargs else "[]"
        self.assertEqual(audit.sync_issue(self.rows, self.report, "o/r", create), "Created tracking issue #7")
        body = calls[-1][1]["payload"]["body"]
        api = MagicMock(return_value=json.dumps([{"number": 7, "title": audit.TITLE, "body": body,
                                                  "user": {"login": "github-actions[bot]"}}]))
        audit.sync_issue(self.rows, "New timestamp only", "o/r", api)
        self.assertEqual(api.call_count, 1)

    def test_exact_bot_owned_match_and_pagination(self):
        existing = {"number": 123, "title": audit.TITLE, "body": "old findings",
                    "user": {"login": "github-actions[bot]"}}
        unrelated = {"number": 1, "title": audit.TITLE + " extra", "user": {"login": "github-actions[bot]"}}
        human = {"number": 2, "title": audit.TITLE, "user": {"login": "owner"}}
        pr = dict(existing, number=3, pull_request={})
        calls = []
        def api(url, **kwargs):
            calls.append((url, kwargs))
            if kwargs:
                return "{}"
            return json.dumps([unrelated] * 100 if url.endswith("&page=1") else [human, pr, existing])
        audit.sync_issue(self.rows, self.report, "o/r", api)
        self.assertEqual(calls[-1][0], "https://api.github.com/repos/o/r/issues/123")
        self.assertEqual(calls[-1][1]["method"], "PATCH")

    def test_no_mutation_on_clean_results(self):
        api = MagicMock()
        audit.sync_issue([dict(self.rows[0], status="UNCHANGED")], self.report, "o/r", api)
        api.assert_not_called()

    def test_cli_preserves_machine_and_human_error_reports(self):
        with tempfile.TemporaryDirectory() as folder:
            rows = [dict(self.rows[0], status="SOURCE_ERROR", latest=None)]
            with patch.object(audit, "audit", return_value=rows):
                self.assertEqual(audit.main(["--output-dir", folder]), 1)
            self.assertTrue((Path(folder) / "version-audit.md").exists())
            report = json.loads((Path(folder) / "version-audit.json").read_text())
            self.assertEqual(report["results"][0]["status"], "SOURCE_ERROR")


if __name__ == "__main__":
    unittest.main()
