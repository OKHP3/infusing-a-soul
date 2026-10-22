import { expect, test } from "@playwright/test";

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
});