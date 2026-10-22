---
name: Playwright browser hosts
description: Replit NixOS may not satisfy the Ubuntu library sonames required by Playwright WebKit.
---

Playwright downloaded Chromium, Firefox, and WebKit successfully in this Replit workspace. Chromium and Firefox ran the workbench suite. WebKit failed before tests started because its Ubuntu build could not resolve required libraries, including ICU 74, GTK 4, GStreamer, Vulkan, Graphene, Opus, and related media/rendering sonames. Adding available Nix packages did not satisfy Playwright's WebKit host validation.

**Why:** Browser binaries can install correctly while the host still lacks the exact runtime library sonames expected by WebKit.

**How to apply:** When Playwright reports `browserType.launch` missing libraries, classify it as a host compatibility blocker rather than an application test failure. Preserve the traces, run the full browser matrix on an Ubuntu CI runner with `playwright install --with-deps`, and only upgrade a browser runtime after all requested engines actually execute.
