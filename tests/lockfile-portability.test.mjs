import assert from "node:assert/strict";
import test from "node:test";
import {
  checkLockfileText,
  INTERNAL_PREFIX,
  normalizeLockfileText,
  REGISTRY_PREFIX,
} from "../scripts/check-lockfile-portability.mjs";

function fixture(resolved) {
  return JSON.stringify({
    name: "fixture",
    lockfileVersion: 3,
    packages: {
      "": {},
      "node_modules/example": {
        version: "1.2.3",
        resolved,
        integrity: "sha512-example-integrity",
      },
    },
  }, null, 2) + "\n";
}

test("normalization changes only the approved prefix and preserves version/integrity", () => {
  const original = fixture(`${INTERNAL_PREFIX}example/-/example-1.2.3.tgz`);
  const { text, normalizedCount } = normalizeLockfileText(original);
  const before = JSON.parse(original).packages["node_modules/example"];
  const after = JSON.parse(text).packages["node_modules/example"];

  assert.equal(normalizedCount, 1);
  assert.equal(after.resolved, `${REGISTRY_PREFIX}example/-/example-1.2.3.tgz`);
  assert.equal(after.version, before.version);
  assert.equal(after.integrity, before.integrity);
  assert.equal(checkLockfileText(text).resolvedCount, 1);
});

test("normalization is idempotent", () => {
  const original = fixture(`${INTERNAL_PREFIX}example/-/example-1.2.3.tgz`);
  const once = normalizeLockfileText(original);
  const twice = normalizeLockfileText(once.text);
  assert.equal(twice.normalizedCount, 0);
  assert.equal(twice.text, once.text);
});

test("refuses unexpected registries instead of rewriting them", () => {
  assert.throws(
    () => normalizeLockfileText(fixture("https://packages.example.invalid/example.tgz")),
    /expected an HTTPS URL on registry\.npmjs\.org/,
  );
});
