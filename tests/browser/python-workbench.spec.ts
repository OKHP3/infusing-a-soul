import { expect, test } from "@playwright/test";

const PYODIDE_SCRIPT = "**/pyodide.js";
const FAKE_RUNTIME = `({
  runPythonAsync: async () => "retry succeeded",
  setStdout: () => {},
  setStderr: () => {}
})`;
const FAKE_LOADER_SCRIPT = `window.loadPyodide = async () => ${FAKE_RUNTIME};`;

test.beforeEach(async ({ page }) => {
  await page.route(
    /^https:\/\/(www\.googletagmanager\.com|fonts\.googleapis\.com|fonts\.gstatic\.com)\//,
    (route) => route.abort(),
  );
});

test.describe("Python workbench", () => {
  test("runs the default coherence sample", async ({ page }) => {
    await page.goto(".");

    await page.getByRole("button", { name: "Run Python" }).click();

    await expect(page.locator(".output")).toContainText("Soul coherence: 78%", {
      timeout: 60_000,
    });
    await expect(page.locator(".output")).toContainText("Signal map:");
    await expect(page.locator(".runtime-status")).toContainText("ready");
  });

  test("renders Python execution errors", async ({ page }) => {
    await page.goto(".");
    await page
      .getByRole("textbox", { name: "Python code editor" })
      .fill('raise RuntimeError("workbench failure")');

    await page.getByRole("button", { name: "Run Python" }).click();

    await expect(page.locator(".output")).toContainText(
      "RuntimeError: workbench failure",
      { timeout: 60_000 },
    );
    await expect(page.locator(".runtime-status")).toContainText("error");
  });

  test("shows a network failure and retries successfully", async ({ page }) => {
    let attempts = 0;
    await page.route(PYODIDE_SCRIPT, async (route) => {
      attempts += 1;
      if (attempts === 1) {
        await route.abort();
      } else {
        await route.fulfill({ contentType: "text/javascript", body: FAKE_LOADER_SCRIPT });
      }
    });

    await page.goto(".");
    await page.getByRole("button", { name: "Run Python" }).click();
    await expect(page.locator(".output")).toContainText("Could not load Pyodide");
    await expect(page.locator(".runtime-status")).toContainText("error");
    const retry = page.getByRole("button", { name: "Retry Python" });
    await expect(retry).toBeEnabled();
    await retry.click();
    await expect(page.locator(".output")).toContainText("retry succeeded");
    await expect(page.locator(".runtime-status")).toContainText("ready");
  });

  test("times out a stalled script request and ignores its late response", async ({ page }) => {
    let releaseResponse!: () => void;
    const heldResponse = new Promise<void>((resolve) => {
      releaseResponse = resolve;
    });
    await page.route(PYODIDE_SCRIPT, async (route) => {
      await heldResponse;
      await route.fulfill({ contentType: "text/javascript", body: FAKE_LOADER_SCRIPT }).catch(() => {});
    });

    await page.goto(".");
    await page.getByRole("button", { name: "Run Python" }).click();
    await expect(page.locator(".output")).toContainText("script loading timed out", { timeout: 25_000 });
    const retry = page.getByRole("button", { name: "Retry Python" });
    await expect(retry).toBeEnabled();

    releaseResponse();
    await page.waitForTimeout(250);
    await expect(page.locator(".runtime-status")).toContainText("error");
    await expect(retry).toBeEnabled();
  });

  test("times out stalled initialization and ignores its late completion", async ({ page }) => {
    await page.route(PYODIDE_SCRIPT, (route) =>
      route.fulfill({
        contentType: "text/javascript",
        body: `let attempts = 0;
          window.loadPyodide = () => {
            attempts += 1;
            if (attempts === 1) return new Promise(resolve => { window.__resolveFirstPyodide = resolve; });
            return Promise.resolve(${FAKE_RUNTIME});
          };`,
      }),
    );

    await page.goto(".");
    await page.getByRole("button", { name: "Run Python" }).click();
    await expect(page.locator(".output")).toContainText("initialization timed out", { timeout: 25_000 });
    await page.evaluate(() => {
      (window as Window & { __resolveFirstPyodide?: (runtime: unknown) => void })
        .__resolveFirstPyodide?.({ runPythonAsync: async () => "late result" });
    });
    await page.waitForTimeout(250);
    await expect(page.locator(".runtime-status")).toContainText("error");

    await page.getByRole("button", { name: "Retry Python" }).click();
    await expect(page.locator(".output")).toContainText("retry succeeded");
    await expect(page.locator(".runtime-status")).toContainText("ready");
  });
});