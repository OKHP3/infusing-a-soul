import { readFileSync, writeFileSync } from "node:fs";
import { resolve } from "node:path";
import { pathToFileURL } from "node:url";

export const INTERNAL_PREFIX = "http://package-firewall.replit.internal/npm/";
export const REGISTRY_PREFIX = "https://registry.npmjs.org/";

export function parseLockfile(text) {
  const lock = JSON.parse(text);
  if (!lock.packages || typeof lock.packages !== "object") {
    throw new Error("package-lock.json has no packages map.");
  }
  return lock;
}

export function checkLockfileText(text) {
  const lock = parseLockfile(text);
  const resolved = Object.entries(lock.packages)
    .filter(([, record]) => typeof record.resolved === "string");
  const internalCount = resolved.filter(([, record]) =>
    record.resolved.startsWith(INTERNAL_PREFIX)).length;
  if (internalCount) {
    throw new Error(
      `${internalCount} package-lock resolved URL(s) use Replit's internal package firewall. ` +
      "Run npm run normalize:lockfile, inspect the lockfile diff, then rerun this check.",
    );
  }

  const unexpected = resolved.find(([, record]) => {
    try {
      const url = new URL(record.resolved);
      return url.protocol !== "https:" || url.hostname !== "registry.npmjs.org";
    } catch {
      return true;
    }
  });
  if (unexpected) {
    throw new Error(
      `Unexpected resolved URL host in package-lock.json at ${unexpected[0]}; ` +
      "expected an HTTPS URL on registry.npmjs.org.",
    );
  }
  return { resolvedCount: resolved.length };
}

export function normalizeLockfileText(text) {
  const before = parseLockfile(text);
  const packageRecords = Object.entries(before.packages);
  const internal = packageRecords.filter(([, record]) =>
    typeof record.resolved === "string" && record.resolved.startsWith(INTERNAL_PREFIX));
  const prefixOccurrences = text.split(INTERNAL_PREFIX).length - 1;
  if (prefixOccurrences !== internal.length) {
    throw new Error("Internal URL occurrence count does not match resolved package records; refusing to edit.");
  }

  for (const [path, record] of internal) {
    if (!record.version || !record.integrity) {
      throw new Error(`Internal registry record lacks a locked version or integrity value: ${path}`);
    }
  }

  const normalized = text.replaceAll(INTERNAL_PREFIX, REGISTRY_PREFIX);
  const after = parseLockfile(normalized);
  const expected = structuredClone(before);
  for (const [, record] of Object.entries(expected.packages)) {
    if (typeof record.resolved === "string" && record.resolved.startsWith(INTERNAL_PREFIX)) {
      record.resolved = REGISTRY_PREFIX + record.resolved.slice(INTERNAL_PREFIX.length);
    }
  }
  if (JSON.stringify(expected) !== JSON.stringify(after)) {
    throw new Error("Normalization changed package-lock data beyond the exact resolved URL prefix; refusing to write.");
  }
  checkLockfileText(normalized);
  return { text: normalized, normalizedCount: internal.length };
}

function main() {
  const lockPath = resolve("package-lock.json");
  const mode = process.argv[2] ?? "--check";
  const text = readFileSync(lockPath, "utf8");

  if (mode === "--normalize") {
    const result = normalizeLockfileText(text);
    if (result.normalizedCount) writeFileSync(lockPath, result.text);
    console.log(
      result.normalizedCount
        ? `Normalized ${result.normalizedCount} resolved URL prefix(es); versions and integrity values are unchanged.`
        : "No internal package URLs found; lockfile is already normalized.",
    );
    return;
  }
  if (mode !== "--check") throw new Error("Use --check or --normalize.");
  const result = checkLockfileText(text);
  console.log(`Lockfile portability check passed (${result.resolvedCount} resolved package URLs).`);
}

if (process.argv[1] && import.meta.url === pathToFileURL(resolve(process.argv[1])).href) {
  try {
    main();
  } catch (error) {
    console.error(error.message);
    process.exitCode = 1;
  }
}
