#!/usr/bin/env python3
"""Build the public manual from docs/MANUAL.md with a branded cover.

Requires reportlab, pypdf, Node.js and sharp. PHANTASM_DIR (or argv[1])
provides the upstream manual renderer; no upstream files are modified.
"""
import io
import os
from pathlib import Path
import re
import subprocess
import sys
import tempfile

from pypdf import PdfReader, PdfWriter
from reportlab.pdfgen import canvas
from reportlab.lib.utils import ImageReader

root = Path(__file__).resolve().parents[1]
upstream = Path(sys.argv[1] if len(sys.argv) > 1 else os.environ.get('PHANTASM_DIR', root.parent / 'phantasm'))
source = (root / 'docs/MANUAL.md').read_text()
# The upstream renderer accepts plain Markdown, without HTML or inline links.
source = source[source.index('# Phantasm player'):]
source = re.sub(r'\[([^\]]+)\]\(([^)]+)\)', lambda m: m[1] + (' (MIDI-IMPLEMENTATION.md)' if m[2] == 'MIDI-IMPLEMENTATION.md' else ''), source)
with tempfile.TemporaryDirectory() as tmp:
    tmp = Path(tmp)
    md, body, logo = tmp / 'MANUAL.md', tmp / 'body.pdf', tmp / 'logo.png'
    md.write_text(source)
    subprocess.run([sys.executable, str(upstream / 'engine/tools/manual.py'), str(md), str(body)], check=True)
    subprocess.run([sys.executable, str(upstream / 'engine/tools/manual-check.py'), str(md), str(body)], check=True)
    subprocess.run(['node', '-e', 'require("sharp")(process.argv[1], {density: 300}).png().toFile(process.argv[2]).catch(e => { console.error(e); process.exit(1); });', str(root / 'docs/assets/brand/PH-LOGO-003-lockup-black.svg'), str(logo)], check=True)
    reader = PdfReader(body)
    width, height = map(float, (reader.pages[0].mediabox.width, reader.pages[0].mediabox.height))
    cover = io.BytesIO()
    c = canvas.Canvas(cover, pagesize=(width, height), invariant=1)
    logo_width = 420
    c.drawImage(ImageReader(logo), (width-logo_width)/2, height-240, width=logo_width, height=logo_width*256/1048, mask='auto')
    c.setFillColorRGB(18/255, 18/255, 18/255)
    c.setFont('Helvetica-Oblique', 16)
    c.drawCentredString(width/2, height-275, 'Embrace the glitch!')
    c.setFont('Helvetica-Bold', 24)
    c.drawCentredString(width/2, height-355, "Player's manual")
    c.setFont('Helvetica', 13)
    c.drawCentredString(width/2, height-390, 'Phantasm v1.2.0 - Ensoniq Mirage')
    c.setFont('Helvetica', 10)
    c.drawCentredString(width/2, 110, 'Original documentation: CC BY 4.0. Brand artwork: all rights reserved.')
    c.drawCentredString(width/2, 94, 'See LICENSE.md and BRAND.md in the accompanying documentation.')
    c.save()
    writer = PdfWriter()
    writer.append(PdfReader(cover))
    writer.append(reader)
    writer.add_metadata({'/Title': "Phantasm v1.2.0 - Player's manual", '/Author': 'laurielaptop'})
    with (root / 'docs/phantasm-manual.pdf').open('wb') as output:
        writer.write(output)
