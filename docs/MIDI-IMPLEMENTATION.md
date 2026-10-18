# Phantasm MIDI implementation

**Protocol 4.0, schema 1.17**, Phantasm v1.2.0.

Everything Phantasm receives and sends over MIDI: control changes, the SysEx
protocol used by [Phantasm Editor](../README.md#phantasm-editor), and the
Sample Dump receive for user waves. For a player's summary, see section 12 of
the [player's manual](MANUAL.md#12-midi); this document is for anyone writing
an editor, a librarian or a controller map. The one-page
[parameter card](phantasm-param-card.pdf) doubles as the CC chart.

## 1. Parameters and numbering

One number per parameter. The number keyed on the panel, the CC number and the
SysEx parameter number are the same, and the printed [parameter card](phantasm-param-card.pdf)
is also the CC chart. Numbers are decimal 0 to 99. On the wire they go in
binary (40 → `28`), never as `PARAM_TAB`'s BCD.

- **66 parameters**, every `PARAM_TAB` row: 62 are patch bytes, and 95 (MIDI
  channel), 96 (omni), 97 (master tune) and 98 (transpose) are instrument globals. (Until #74 the table also held
  90 and 91, the slot load and store, which SysEx counted as actions; #87 took
  out 16, which stays unassigned.)
- **Actions** have numbers but hold no data, and no `PARAM_TAB` row: 93 (save
  the user area, #82) and 94 (restart sequence) are keypad actions, and SysEx
  refuses them (NAK `03`), as it does 90 to 92, which no longer exist. A patch
  is saved to disk over SysEx by `23` (§4.3); the user area only from the
  panel (§6).
- **Display values.** A parameter's value is always the number the panel
  shows: SIGNED rows show 50 ± their range, CHAN shows 1 to 16, and a PC_ONE
  row starts at 1. TIME (0 to 99) and TIMEX (0 to 85) are display positions on
  the envelope curves, not rates.
- **SELECT** (10 wavetable, 11 sequence) indexes a list in the loaded patch's
  palette. Its ceiling is the list's length minus one, which discovery reports (§4.1).
- **Raw bytes** appear only in patch dumps (§4.3). `paramtab.curves()` gives the
  display ↔ stored mapping of the curve classes, so the editor can decode a
  dump: TIME stores a 16-bit rate big-endian at the row's offset, and TIMEX
  stores a coefficient in the low byte of the word, with the high byte 0.
- **DIRECT rows** (the plain 0-99 parameters: cutoff, resonance, glide, vintage,
  the levels and the rest) store one byte, 0-255. A dump or a host write carries
  that byte, where a parameter set carries the display value. The engine's
  pair (`PARAM_SET_DIRECT` and the DIRECT branch of `PARAM_GET`), exact for every display value:

  - display *d* to byte: `(d × 660 + 128) >> 8`, so 0 is 0, 1 is 3, 25 is 64,
    50 is 129 and 99 is 255;
  - byte *v* to display: `(v × 99 + 128) >> 8`, so a byte the editor did not
    write still reads as the nearest display value (255 is 99, 128 is 50).

  The two round-trip for every *d* from 0 to 99 (`direct-check` proves it on
  the engine).

  **Parameter 12's byte is a fraction of the table** (schema 1.8, #88), not an
  entry: on a table of *L* entries (the palette's length for the patch's table,
  parameter 10) a note starts at entry `(byte × L) >> 8`, plus its sequence
  step, saturated at 127 and held in the table. Byte 0 is the first entry and
  255 the last on every length, and the 256 bytes reach every entry. The 100
  display values reach every entry on tables of up to 87 entries; from 88 to
  128 they step over one entry now and then (never two in a row), which only a
  byte from a dump or a sector write reaches. An editor can show "entry *n* of
  *L*" from the byte and the palette in the sector dump. The other stored forms are plain: an ENUM row stores its display
  value as it is, a SIGNED row stores `display − 50` as a signed byte, and a
  CHAN row stores `display − 1`.
- **Editor inputs (#121; host-side text, no firmware, protocol or schema
  change).** `engine/tools/param-values.tsv` holds one label per display value
  of every ENUM parameter whose values are names (13, 18, 28, 32, 33, 38, 39,
  60, 85, 88, 96), and one unit line for every SIGNED parameter and numeric
  ENUM (25, 61, 62): the unit, the neutral display value (`50` for SIGNED) and
  the cents one display step moves. `make param-values-check` holds the file
  to `PARAM_TAB` (a value without a label, a label past `aux`, a SIGNED row
  without a unit all fail) and writes `engine/build/phantasm-editor-inputs.json`
  with the labels, units and the **init patch**. The init patch is the image's
  own `ENG_PATCH` (map symbol; `PP_SIZE` live bytes, then the sector's reserved
  bytes as zero, 96 in all, in the stored form a `21` carries), a 16-byte zero
  name (`name_hex`), and the palette of whatever sector it is written into:
  `PP_TABLE` and `PP_SEQ` are 0, the first wavetable and sequence of that
  palette, so an editor keeps the loaded patch's palette. It is the patch every
  unused disk slot is seeded with.

## 2. Control changes

A CC *n* on the basic channel edits parameter *n* through `PARAM_SET`, the same
path as the panel, with the 0 to 127 value scaled to the parameter's range.
`CC_NUM_RX` arms 12 to 31, 34 to 37, 39 to 63 and 70 to 87: 56 of the 66
parameters (CC 16 is armed and finds no row, so it changes nothing). `paramtab.cc_mapped()` reads the armed set from the image. CCs stay
for hardware controllers. The editor sends every edit as SysEx, which reaches
every parameter at full resolution.

Two channel-mode messages are handled since #113, on the same channel test as
any controller. **CC 120** (all sound off) releases every voice, as **CC 123**
(all notes off, with 124 and 125) does: the DOC has no faster silence than the
release, so they are the same. **CC 121** (reset all controllers) puts the
engine's bend to centre and its mod wheel and channel pressure to 0, and lifts
the sustain pedal as CC 64 = 0 does (held notes release; the mono stack
empties). It does not touch the patch or glide's last pitch. The Mirage's own
wheels overwrite the bend and the mod wheel only when they move, so a reset
holds until a wheel is touched. Both work under running status.

## 3. SysEx frame and encoding

```
F0 7D 50 dd cc <data> F7
```

- `7D` is MIDI's non-commercial manufacturer ID, and `50` ("P") marks Phantasm
  among other `7D` users.
- `dd` is the device: the basic channel 0 to 15 (parameter 95 minus one), or
  `7F` for any device. A reply carries the channel in force when it is sent,
  after the edit that it acknowledges.
- `cc` is the command.
- Every data byte is 7-bit. A stored byte in a patch dump goes as two nibbles,
  high nibble first (`0h 0l`). A parameter value goes as `vh vl` =
  value ÷ 128, value mod 128. Every value is 0 to 99 today, so `vh` is 0.

A message not addressed to this device is ignored. A message cut short by an
overrun or a framing error is abandoned without a reply (the #35 rule), and no
note is released.

## 4. Messages

| Command | Direction | Data | Reply |
|---|---|---|---|
| `01` discovery request | host → | none | `02` |
| `02` discovery response | → host | `pv pv' sv sv' ph pl pc np wt sq om on rf` | — |
| `10` set parameter | host → | `pn vh vl` | `7E 10` or `7F 10 er` |
| `11` read parameter | host → | `pn` | `12` or `7F 11 er` |
| `12` parameter value | → host | `pn vh vl` | — |
| `20` sector request | host → | none | `21` or `7F 20 er` |
| `21` sector dump | both | `<2 × sector size nibbles> cs` (sector size: 616) | from the host: `7E 21` or `7F 21 er` |
| `22` select patch | host → | `nn` | `7D 22`, then `7E 22` or `7F 22 er`; or `7F 22 er` alone |
| `23` save the edit buffer as patch | host → | `nn` | `7D 23`, then `7E 23` or `7F 23 er`; or `7F 23 er` alone |
| `7D` BUSY | → host | `cc` | — |
| `7E` ACK | → host | `cc` | — |
| `7F` NAK | → host | `cc er` | — |

### 4.1 Discovery

`02` carries: protocol version major and minor (`pv pv'`), schema version major
and minor (`sv sv'`), the sector size a `21` carries, in bytes, as
`ph × 128 + pl` (616), the parameter count (`pc`), the patches on a disk (`np`,
100, numbered 00 to 99), and the loaded palette's wavetable and sequence
counts (`wt sq`). The table above writes `np` where 1.x had `bs`.
**Protocol 2.1 (#84)** appends the firmware's version, three bytes at the end:
the OS version's major and minor (`om on`, 1 and 1 for v1.1) and a release flag
(`rf`: 1 on a release build, 0 on any other). It is the number the boot display
shows, from the same source (`engine/VERSION`). A 2.0 reader that takes the
first ten data bytes reads a 2.1 reply unchanged; the new bytes are a minor
bump by this document's rule (a new message or field, nothing moved).

**Compatibility (owner, 2026-10-10).** The editor works with a device whose
protocol and schema each have the same major version as the editor's
`schema-identity.json` and a minor version at or above it; with any other, it
stays read-only. It reads the bytes of `02` it knows and ignores any after
them, and edits only the parameters its schema has. A later schema can make
one of the editor's reserved patch bytes live, so a sector the editor writes
back carries every byte it does not know as the dump it read had it, never
zero.

A patch loaded from the panel or by program change
changes `wt` and `sq`, so the editor runs discovery again to refresh the
ranges of parameters 10 and 11. So does a select, or a sector write, since
each brings its own palette.

### 4.2 Parameters

`10 pn vh vl` sets parameter `pn` to a display value. The panel task applies it
through `PARAM_SET`, and the ACK is sent only after the edit has been applied,
so it is evidence of the edit, not of receipt (the way `CC_APPLY` works). As
with a CC, `pn` becomes the selected parameter and the display shows its new
value. A value outside the parameter's range is refused with NAK `04` and is not
clamped. `11 pn` reads a parameter, and the reply is `12 pn vh vl`. Globals 95
to 98 are read and set the same way.

### 4.3 The sector, select and save

A disk holds patches 00 to 99, each in a sector of its own with its own
palette (DISK-FORMAT §12). The edit buffer is the loaded patch with any
edits, and the palette in RAM is the loaded sector's.

**`20` → `21`, the sector dump.** `20` has no data. The reply is the sector
as a disk holds it, its first 616 bytes: the palette (504 bytes, DISK-FORMAT
§0.2 and §4), then the edit buffer's patch (96 bytes: 81 live, then 15
reserved, sent as zero), then the patch's name (16 bytes, DISK-FORMAT §0.2),
each byte as two nibbles, 1,232 of them, then the
checksum. That makes 1,239 bytes on the wire with the frame. The patch is
always the **stored** form, as a save would write it: parameters 10 and 11
are list indices into this sector's palette, in the low byte of their word
(the high byte 0). The Mirage converts the edit buffer to and from its live
pointers itself.

**The name** is the sector's last 16 bytes on the wire (sector offset `$258`,
RAM `$BE58`; `$240` and `$BE40` before 4.0): printable ASCII, NUL-padded, all zero meaning unnamed, and a
16-character name has no terminator. The Mirage never shows it and never
validates it: a `21` stores whatever 16 bytes it brings, and phantasmeditor
owns the character set. It is not an edit-buffer parameter: it travels with the
sector, so a `23` save and a `22` select, SEQ Save and a user-area save all
move it. A `22` whose load fell back may leave the previous patch's name in RAM;
a save is refused (NAK `09`) while the fallback is loaded, so it cannot be
written. Factory patches 00-07 carry names (`banks/factory.toml` `label`);
08-99 are all zero.

**`21` from the host, the sector write**, replaces the palette and the edit
buffer **in memory only**; the ACK follows. It is checked for its length
(NAK `02`), then its checksum (`01`), and it is received into a staging area
(617 bytes of the OS image's own RAM, since #79) and copied in only when both pass, so **a corrupt
or truncated write leaves the loaded sector intact** (a truncated one is
abandoned without a reply, §3). Then the sector is taken as a disk load takes
it: a palette whose wavetable or sequence count is outside 1-8 is refused
with NAK `08`, and the instrument is left with the fallback palette, as after
a bad disk sector. The patch's fields are not range-checked: the host writes
only what the schema allows, and an index past its list plays entry 0. The
reserved bytes are summed in the checksum like the rest and then ignored
(schema 1.3; 1.4 to 1.17 made `$3F` to `$50` live): they are stored, and dumped back, as zeros. A write that is
accepted makes the RAM a good sector, so it may be saved even after a failed
load, and the display follows it: the selected parameter's value from the
written patch is on the display within one panel sweep (#91).

A write is an edit to the engine, as a `10` is: notes still sounding move to
the written patch's parameter 12 at once, each on its own table and at its own
sequence step (#88). A `22` select is a patch load and does not move them,
though its disk access releases every held note (§4.3's BUSY) and they finish
in their release where they were.

**`22 nn`, select**, loads patch `nn` from the disk into the edit buffer,
as LOAD and program change do: unsaved edits are discarded silently, and the
display shows the number. **`23 nn`, save**, writes the edit buffer and the
palette to patch `nn` and reads it back, as SEQ Save does: the instrument's
loaded number becomes `nn` (a save-as; a save refused with NAK `09` after a
failed load leaves it), and the globals sector is written
too if the globals changed (§4.2). A number past 99 is refused at once with
NAK `05`, and a length other than one data byte with NAK `02`, without a
BUSY or a disk access. Otherwise:

1. The instrument sends **BUSY**, `7D cc`, before the disk is touched.
2. **The host sends nothing until the reply.** The floppy code resets the
   ACIA during the transfer, so anything sent is lost, and part of it may be
   read as the start of a message.
3. The reply: ACK `7E cc` once the patch is loaded, or saved and read back
   the same; or NAK `7F cc 08` for a select that fell back (the sector would
   not read, or was not a patch), or `7F cc 09` for a save that failed: the
   disk is write-protected, the read-back differed, or the RAM is the
   fallback after a failed load and the save was refused. The fallback after
   a select is loaded, as after LOAD, so the host should not then save
   without first writing a sector.

A select takes about 2 s, a save about 3 s, and a save that also writes the
globals about 1 s more (§5's timeouts).

There is no bank command. A bank, on the host, is the 100 sectors: read one
with `22 nn` and `20`, write one with `21` and `23 nn`. A sector `.syx` file
is one `21`.

**Checksum** (dumps only): `cs` makes the sum of every data byte after `cc`,
`cs` included, a multiple of 128.

### 4.4 NAK codes

| `er` | Meaning |
|---|---|
| `01` | Checksum |
| `02` | Length |
| `03` | Unknown parameter: an unused number or an action |
| `04` | Value out of range |
| `05` | Bad patch number (past 99) |
| `06` | Reserved (was "busy"; never sent) |
| `07` | Unknown command |
| `08` | The patch fell back: a select's sector would not load, or a written sector's palette counts are out of range |
| `09` | The save failed: write-protected, the read-back differed, or refused over the fallback |

## 5. Flow and pacing

- One request outstanding at a time. The next is sent only after a reply or a
  timeout: 500 ms; 1,500 ms for a `20` or a `21` (a sector is 0.37 s on the
  wire each way); for `22` and `23`, 500 ms for the BUSY and then **6 s** for
  the reply, during which the host sends nothing (§4.3).
- Reads (`01`, `11`, `20`) may be retried up to twice. Writes (`21`, `23`) and
  selects are never retried blindly: the host re-reads them.
- At least 100 ms between sector writes. The receive path costs about 205
  cycles per SysEx byte, and more for a `21`'s nibbles, each decoded into
  wave RAM as it lands (`engine/FINDINGS.md`), most of the machine at the
  wire rate for the 0.37 s of a sector.
- The instrument sends nothing unsolicited. A panel edit reaches the editor on
  the editor's next read.
- A Sample Dump (§6) is paced by the sender alone: 2 s after its header and
  20 ms after each packet.

## 6. Sample Dump: user waves (#81)

The instrument also **receives the MIDI Sample Dump Standard** into the user
area, waves 384-511 (owner's decisions, 2026-10-10). This section is what
a sender needs; the byte layouts are those of the MIDI Sample Dump Standard.

- **Not a Phantasm message.** `F0 7E` (Universal Non-Real-Time) is told from
  `F0 7D 50` at its second byte. SDS does not move the protocol version and
  **discovery does not report SDS**: an editor tries it.
- **One way, open loop. The instrument sends nothing**: no ACK, NAK, WAIT or
  CANCEL, no answer to a Dump Request. The sender waits as the standard tells
  a sender that hears nothing: **at least 2 s after the header, and at least
  20 ms after each packet's `F7`**. `engine/tools/sds-send.py` is the
  reference sender.
- **The header** (`01`) is accepted if `dd` is the basic channel or `7F`, the
  sample number *n* is 0-127, the word width is 8-28 bits, and the length is
  256 × *k* words with *k* ≥ 1 and *n* + *k* ≤ 128. Anything else is ignored,
  with its packets. Sample *n* is wave 384 + *n*; the *k* waves follow in
  order. The period, loop points and loop type are ignored.
- **The packets** (`02`) must come in order from 0, each whole, for this
  device, with a good checksum. **Each word keeps its top 8 bits** (no
  rounding; dither on the host if wanted), and `$00` becomes `$01`. Send 8-bit
  words: they take the fewest packets (547 for all 128 waves, about 35 s).
- **A wave is written whole or not at all**, when the packet holding its
  256th word passes. A bad checksum, a packet out of order or missing, or
  **any other SysEx message** abandons the dump: the waves already written
  stay, the one in progress is not written. A Phantasm message is then
  handled as usual, except one that arrives within about one panel sweep
  (~20 ms) of a packet that finished a wave: it is dropped, and the host's
  timeout and retry (§5) cover it. A new header starts a new dump.
- **Silence during a dump.** An accepted header releases every voice, and
  note-ons from the keys and MIDI are ignored until the last packet the
  length needs, an abandon, or about **2.6 s with no packet** (a sender that
  stopped). Nothing hangs and no note sticks. Notes sent to the Mirage during
  a dump would also cut the packet they land in (a status byte ends a SysEx
  message), so a host does not mix them.
- **The waves are not conditioned on the instrument**: the host removes DC,
  rotates each cycle to a rising zero crossing and normalises it, as
  `tools/wavebank.py` does for a pool (SDS.md §8).
- **They live in wave RAM until a save.** Keypad action 93 writes the
  changed sectors to the disk (#82); there is no SysEx command for it, and
  unsaved waves are lost at the next boot, which reloads the pool.
