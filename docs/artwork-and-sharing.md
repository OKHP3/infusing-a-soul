# Artwork and sharing

**Prepared September 27, 2026. Assets are present; website metadata and repository social-preview settings have not been applied.**

[Back to the README](../README.md#artwork-and-sharing)

## What the reference gets right

The [Chai Chasers README](https://github.com/OKHP3/glee-fully-chai-chasers/blob/main/README.md) opens with a recognizable image, a short promise, and a direct route into the game. Its voice stays personal while the later sections explain the current build, evidence, and limits. The [game's HTML](https://github.com/OKHP3/glee-fully-chai-chasers/blob/main/index.html) completes the presentation with a canonical URL, Open Graph and Twitter cards, favicon and Apple touch links, and a web app manifest.

This project uses the same sequence: identity, invitation, experience, evidence, and deeper documentation. Its primary destination is the repository's build journal. A game launch button or an installable-app claim would misrepresent what this repository contains.

## Visual system and provenance

The artwork was authored for this repository on September 27, 2026. No Chai Chasers artwork or persona source material was copied into the assets.

- Primary profile: [OverKill Hill v1.1.0](../.agents/skills/okhp3-overkill-hill-brand/references/overkill-hill.yaml), using its declared espresso `#2a2320`, teal `#1c3a34`, amber `#e6a03c`, and paper `#f6f2ee` colors. Confidence is high for the declared palette; the layered-frame and spark composition is a new interpretation.
- Meaning: nested architectural frames reduce toward one distinct spark. The motif connects source material, distillation, and identity without depicting a real person or implying sentience.
- Typography: system sans-serif and monospace fallbacks, rendered with Arial and Consolas. The profile's custom font families are not bundled or required. No font files were redistributed.
- Format: static SVG source plus PNG/ICO exports. No animation, external scripts, embedded network resources, or tracking.
- Legibility: paper carries primary text; amber carries the accent line. Supporting grid lines are decorative. The brand name is a single unbroken text element in the hero and uses nonbreaking spaces in the README footer.

## Asset inventory

| Asset | Dimensions | Purpose |
|---|---|---|
| [social-preview.png](../assets/brand/social-preview.png) | 1200 × 630 | README hero and website sharing card. |
| [social-preview.svg](../assets/brand/social-preview.svg) | 1200 × 630 | Editable source for the card. Use the PNG for social crawlers. |
| [mark.svg](../assets/brand/mark.svg) | 512 × 512 view box | Editable project mark. |
| [icon-192.png](../assets/brand/icon-192.png), [icon-512.png](../assets/brand/icon-512.png) | 192 / 512 square | General project and bookmark artwork. |
| [apple-touch-icon.png](../assets/brand/apple-touch-icon.png) | 180 × 180, opaque | Saved home-screen bookmark icon. |
| [favicon.svg](../assets/brand/favicon.svg) | 32 × 32 view box | Simplified browser-tab mark. |
| [favicon-16.png](../assets/brand/favicon-16.png), [favicon-32.png](../assets/brand/favicon-32.png) | 16 / 32 square | Raster tab icons. |
| [favicon.ico](../assets/brand/favicon.ico) | 16, 32, 48 square | Multi-size browser fallback. |
| [safari-pinned-tab.svg](../assets/brand/safari-pinned-tab.svg) | 32 × 32 view box | Monochrome pinned-tab mask. |

The PNG exports were rasterized from the SVG sources with Sharp; the ICO was assembled with Pillow. These were authoring tools available on the contributor host, not new project dependencies. Future edits should start with the SVGs and regenerate the matching exports. Keep the touch icon opaque and the Safari mask black on transparent.

## GitHub presentation

Relative image links in the README display the committed artwork to readers who can access the repository. They do not change GitHub's favicon or its social-preview setting.

GitHub exposes the separate upload under **Settings → Social preview → Edit**. Its guidance calls for a PNG, JPG, or GIF under 1 MB and recommends 1280 × 640 for best display. The supplied 1200 × 630 PNG exceeds the documented minimum dimensions; inspect GitHub's crop preview when uploading. Public sharing is subject to repository visibility, and GitHub documents restrictions on private-repository uploads. See [GitHub's social-preview instructions](https://docs.github.com/en/repositories/managing-your-repositorys-settings-and-features/customizing-your-repository/customizing-your-repositorys-social-media-preview).

Do not change this repository's visibility to enable a preview. Its private corpus and persona files are outside this artwork handoff.

## Website metadata handoff

The proposed project route is recorded in the [public-page brief](story/project-page-brief.md). A direct request returned the site's 404 page on September 27, 2026. The README therefore links to the working repository journal instead.

The following is a **template for a future published page**, not active configuration. Replace `PUBLIC_PAGE_URL` with the actual HTTPS canonical page URL and `PUBLIC_ASSET_BASE` with the public HTTPS directory containing the approved artwork, without a trailing slash. Neither may point to a private GitHub raw-content URL. Integrate the values into the destination site's existing metadata system instead of adding duplicate tags.

For a page hosted under overkillhill.com, retain the host site's global favicon and touch-icon policy unless the owner chooses a project-specific override. The icon tags below are suitable for an independently branded project page.

```html
<title>Infusing a Soul | OverKill Hill P³</title>
<meta name="description" content="A build journal and persona library for giving local AI a distinct voice, honest tools, and useful work on your own hardware.">
<meta name="author" content="Jamie Hill">
<link rel="canonical" href="PUBLIC_PAGE_URL">
<meta name="theme-color" content="#2a2320">

<link rel="icon" href="PUBLIC_ASSET_BASE/favicon.ico" sizes="16x16 32x32 48x48">
<link rel="icon" type="image/png" sizes="32x32" href="PUBLIC_ASSET_BASE/favicon-32.png">
<link rel="icon" type="image/png" sizes="16x16" href="PUBLIC_ASSET_BASE/favicon-16.png">
<link rel="icon" type="image/svg+xml" sizes="any" href="PUBLIC_ASSET_BASE/favicon.svg">
<link rel="apple-touch-icon" sizes="180x180" href="PUBLIC_ASSET_BASE/apple-touch-icon.png">
<link rel="mask-icon" href="PUBLIC_ASSET_BASE/safari-pinned-tab.svg" color="#c46a2c">

<meta property="og:type" content="website">
<meta property="og:site_name" content="OverKill Hill P³">
<meta property="og:locale" content="en_US">
<meta property="og:url" content="PUBLIC_PAGE_URL">
<meta property="og:title" content="Infusing a Soul">
<meta property="og:description" content="Local AI is generic until you feed it your thinking. Explore the method, the personas, and the build journal.">
<meta property="og:image" content="PUBLIC_ASSET_BASE/social-preview.png">
<meta property="og:image:type" content="image/png">
<meta property="og:image:width" content="1200">
<meta property="og:image:height" content="630">
<meta property="og:image:alt" content="Infusing a Soul: an amber spark inside layered architectural frames on espresso and teal.">

<meta name="twitter:card" content="summary_large_image">
<meta name="twitter:title" content="Infusing a Soul">
<meta name="twitter:description" content="Local AI is generic until you feed it your thinking. Explore the method, the personas, and the build journal.">
<meta name="twitter:image" content="PUBLIC_ASSET_BASE/social-preview.png">
<meta name="twitter:image:alt" content="Infusing a Soul: an amber spark inside layered architectural frames on espresso and teal.">
```

Use the host page's normal character encoding and viewport tags. This kit supplies bookmark imagery, not an app manifest, service worker, offline mode, or installation flow. Metadata cannot turn a documentation repository into an application. Browser icon relationships are described in [MDN's link relationship reference](https://developer.mozilla.org/en-US/docs/Web/HTML/Reference/Attributes/rel).

## Publication checks

1. Publish only the approved public story and artwork through the destination site's normal review process.
2. Confirm the page and every image URL return successfully without authentication. Check actual content, dimensions, and content types, not only status codes.
3. Check the page's canonical, Open Graph, and Twitter URLs in the delivered HTML. No placeholder tokens should remain.
4. Inspect desktop and mobile sharing crops, the 16 px favicon, a saved touch bookmark, and Safari's pinned-tab mask on supported devices. Browser and social-platform behavior remains unverified until this is done on the published page.
5. Update the README's primary destination only when the public page works. Record the publication date separately from asset creation.

No related website, runtime host, repository visibility, or GitHub social-preview setting was changed by this README makeover.
