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

Before tagging, commit both privately built disk images in `build/`:
`phantasm-release.hfe` for Gotek and `phantasm-release.img` for floppy drives.

Pushing a version tag creates a draft GitHub release containing both disk
images, the public editor, PDFs and `SHA256SUMS` covering all attachments.
Review the draft, then publish it as Latest in GitHub. The README's
`releases/latest/download/` links become public after publication.

If you add or replace any attachment in the draft afterward, run
`scripts/update-release-checksums.sh v1.2.0` with authenticated GitHub CLI
before publishing. It downloads all draft assets and replaces `SHA256SUMS`.
It refuses published releases and drafts without an `.hfe` image.
