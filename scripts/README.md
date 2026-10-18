# Preparing public release files

Run `sync-from-source.sh v1.2.0` with the private Phantasm and Phantasm Editor
repositories checked out as siblings. Build the firmware parameter card at
that tag first. The sync rebuilds the public manual from `docs/MANUAL.md`,
adds the approved identity cover, and rebuilds and checks the standalone editor.

The manual builder requires Python with `reportlab` and `pypdf`, plus Node.js
with `sharp` available to `require`. Set `PYTHON` and `NODE_PATH` if those
packages live in a separate runtime. To rebuild only the manual, run:

```sh
python3 scripts/render-public-manual.py ../phantasm
```

The source renderer verifies that all manual body text is preserved and fits
within page boundaries. Visually review the resulting PDF before committing it.
The cover is unnumbered; body pagination starts at page 1.

A version tag creates a draft GitHub release containing the public editor,
PDFs and their initial checksums. To finalize it:

1. Attach the privately built `.hfe` disk image and any other release assets.
2. Run `scripts/update-release-checksums.sh v1.2.0` with authenticated GitHub CLI.
   It downloads all draft assets and replaces `SHA256SUMS`, including the disk
   image. It refuses published releases and drafts without an `.hfe` image.
3. Review the draft, asset list and checksums before publishing. Repeat step 2
   after adding or replacing any asset.
