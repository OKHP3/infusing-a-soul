import assert from "node:assert/strict";
import { mkdir, mkdtemp, readFile, rm, writeFile } from "node:fs/promises";
import os from "node:os";
import path from "node:path";
import test from "node:test";
import { generatePublicContent } from "../scripts/generate-public-content.mjs";

const validMethodology = {
  methodology: [
    {
      title: "Collect the voice",
      body: "Gather documented writing samples and operating habits.",
      tag: "corpus",
    },
  ],
};

function persona(order = 1, overrides = {}) {
  return {
    name: `Persona ${order}`,
    mark: "PS",
    order,
    state: "authored",
    status: "Drafted; not deployed",
    voice: "Documented voice summary",
    ...overrides,
  };
}

function metadataBlock(value) {
  return `<!-- public-meta\n${JSON.stringify(value, null, 2)}\n-->`;
}

async function fixture(t, { rootMarkdown, personas = [persona()] } = {}) {
  const root = await mkdtemp(path.join(os.tmpdir(), "public-content-test-"));
  t.after(() => rm(root, { recursive: true, force: true }));
  await mkdir(path.join(root, "souls"), { recursive: true });
  await writeFile(
    path.join(root, "README.md"),
    rootMarkdown ?? `Root prose sentinel.\n\n${metadataBlock(validMethodology)}\n`,
  );

  for (const entry of personas) {
    const { directory: directoryName, markdown, metadata, ...personaMetadata } = entry;
    const directory = path.join(root, "souls", directoryName ?? `persona-${entry.order}`);
    await mkdir(directory, { recursive: true });
    await writeFile(
      path.join(directory, "README.md"),
      markdown ?? `Persona prose sentinel.\n\n${metadataBlock(metadata ?? personaMetadata)}\n`,
    );
  }
  return root;
}

test("generates only approved README metadata, excluding workspace and private prose", async (t) => {
  const root = await fixture(t);
  await mkdir(path.join(root, "souls/persona-1/workspace"), { recursive: true });
  await mkdir(path.join(root, "corpus"), { recursive: true });
  await writeFile(
    path.join(root, "souls/persona-1/workspace/TOOLS.md"),
    "PRIVATE_WORKSPACE_TOOLS_SENTINEL",
  );
  await writeFile(path.join(root, "corpus/private.md"), "PRIVATE_CORPUS_SENTINEL");

  const result = await generatePublicContent({ root });
  const output = await readFile(result.outputPath, "utf8");

  assert.equal(result.personaCount, 1);
  assert.match(output, /Collect the voice/);
  assert.match(output, /Persona 1/);
  assert.doesNotMatch(output, /Root prose sentinel|Persona prose sentinel/);
  assert.doesNotMatch(output, /PRIVATE_WORKSPACE_TOOLS_SENTINEL|PRIVATE_CORPUS_SENTINEL/);
});

test("rejects extra methodology metadata keys", async (t) => {
  const rootMarkdown = metadataBlock({ ...validMethodology, privateSource: "not allowed" });
  const root = await fixture(t, { rootMarkdown });
  await assert.rejects(
    generatePublicContent({ root }),
    /metadata keys must be exactly: methodology/,
  );
});

test("rejects extra persona metadata keys", async (t) => {
  const root = await fixture(t, {
    personas: [persona(1, { privateSource: "not allowed" })],
  });
  await assert.rejects(
    generatePublicContent({ root }),
    /metadata keys must be exactly: mark, name, order, state, status, voice/,
  );
});

test("rejects missing metadata in a source README", async (t) => {
  const root = await fixture(t, { rootMarkdown: "# No approved metadata\n" });
  await assert.rejects(
    generatePublicContent({ root }),
    /README\.md: missing required/,
  );
});

test("rejects malformed metadata JSON", async (t) => {
  const root = await fixture(t, {
    rootMarkdown: "<!-- public-meta {broken json} -->\n",
  });
  await assert.rejects(
    generatePublicContent({ root }),
    /metadata must be valid JSON/,
  );
});

test("rejects missing metadata in a persona README", async (t) => {
  const root = await fixture(t, {
    personas: [{ order: 1, markdown: "# Persona without metadata\n" }],
  });
  await assert.rejects(
    generatePublicContent({ root }),
    /souls[/\\]persona-1[/\\]README\.md: missing required/,
  );
});

test("rejects duplicate persona order values", async (t) => {
  const root = await fixture(t, {
    personas: [persona(1), { ...persona(1), directory: "persona-duplicate" }],
  });
  await assert.rejects(
    generatePublicContent({ root }),
    /persona "order" values must be unique/,
  );
});
