# Project instructions

## Chapter source

Book chapters live in this Google Drive folder: https://drive.google.com/drive/folders/18iGI4pHgv58Mw-Qg3vyJUwvus-xODwzY (folder ID `18iGI4pHgv58Mw-Qg3vyJUwvus-xODwzY`). Each chapter is a Google Doc titled "Chapter N". Use Google Drive tools to read chapter content when building worksheets.

- When bundling files for download, the bundle folder and file names must be **lowercase with hyphens instead of spaces** (e.g. `user-stories-worksheet.dc.html`, not `User Stories Worksheet.dc.html`).

## Writing style

- **Never use em dashes (—) anywhere.** Rewrite with commas, periods, parentheses, or "such as" instead. This applies to all worksheet copy and all responses.

## Skill: build a b&w print worksheet

When making a `*-bw.dc.html` print version of a worksheet:

1. Build the full bw worksheet (masthead, case-study or blank content, monochrome styling matching the other bw files) and wire it into Table of Contents.dc.html.
2. Remove the footer (byline/links block) entirely, unlike color print versions, which keep it.
3. Then run the b&w image extract skill below, and deliver those as the download.

## Skill: b&w image extract

To break a `*-bw.dc.html` worksheet (or any b&w page, e.g. a figures page) into one PNG per section, white background, for dropping into a chapter doc:

1. Each section's content already lives in its own `<div id="...">` in the page. Reuse those ids, don't add wrappers. Check whether the section div already includes its own header/caption (as in a figures page where each `<div id="fig-4-1">` bundles its own label, title, and caption) — if so, capture the div as-is, header included. Only exclude a separate `<h2>` header when the section div was built to sit below one (the standard worksheet pattern). When excluding that header, the section div itself must still be the capture target (don't crop mid-box) — if the numbered subheader (e.g. "1 Requirements & Planning") sits inside the same div as the content boxes, temporarily hide just that header element (`display:none` via `eval_js_user_view`) before capture rather than cropping pixels, so box tops and bottoms stay intact. Revert it with the rest of the temp DOM changes on reload.
2. Skip the masthead/intro (title, tagline, intro paragraph) and skip the footer (byline/links block, when present) — neither becomes an image.
3. Any other box that sits between the intro and the footer but isn't under a numbered header (e.g. a standalone AI Prompt callout) still gets its own image. Capture it in its natural position in the sequence.
4. `show_to_user` the bw file so it's the active preview.
5. Via `eval_js_user_view`, add ~40px of temporary `paddingBottom` to each section div — at the default `scale: 2`, `snapshot_element` has a rendering bug that clips the last text row on flex/baseline rows; the padding gives it room so nothing gets cut. Never alter the design itself to work around this (no resizing/repositioning content) — if exporting now, the design is meant to be captured as-is. Step 7's trim removes this added padding, so it must not appear as extra whitespace in the delivered PNG; if it still does, tighten the trim's `+ ~12px` margin rather than leaving the gap.
6. For each section div, `snapshot_element` at `scale: 2` (keep full resolution) and `save_to_project_path` into a `<worksheet-name>-frames/` folder, filenames like `1-section-title.png`.
7. Via `run_script`: for each PNG, scan alpha to find the last non-transparent row, trim the canvas back down to that (+ ~12px), and composite onto a white `fillRect` background (the raw capture is transparent). This removes the padding added in step 3 and gives an opaque white background in one pass.
8. `present_fs_item_for_download` on the whole `-frames/` folder.

## Skill: any PNG export via snapshot_element

`snapshot_element` captures a transparent background, and its capture is capped by a pixel budget (scale can get silently clamped, especially on tall elements). Every export must hit **at least 300 DPI** at the image's intended print size:

1. Always composite onto an opaque white background via `run_script` (`fillRect` white, then draw the captured image on top). Never deliver a raw transparent capture.
2. Check the actual clamped scale reported by `snapshot_element`. If the element is tall enough that `scale: 4` gets clamped below what 300 DPI requires, split the element into several sub-sections (wrap sibling groups in temporary marker `<div id="...">`s via `eval_js_user_view`), snapshot each chunk at scale 4 individually, then stitch them into one canvas top-to-bottom via `run_script` before compositing onto white.
3. Delete any temp per-chunk PNGs and reload/reopen the page afterward so the temporary DOM wrappers don't linger in the live view.
