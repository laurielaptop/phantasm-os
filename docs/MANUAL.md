# Phantasm player's manual

Phantasm turns the Ensoniq Mirage into a wavetable synthesizer. This manual is
for the person playing it: it says what each control does, in the order you
will need it, and what to do when something goes wrong. Every number in it is
a number the front panel shows.

The printed [parameter card](phantasm-param-card.pdf) is the one-page version of section 11. The sections
run from what the instrument is (1), through switching it on (2) and the panel
(3), to the sound (5 to 9), the level of the sound (10), the reference (11),
MIDI (12) and what the display is telling you (13). If you are new to
wavetable synthesis, read the [quick-start guide](QUICKSTART.md) first: it
explains tables, scanning and the voice in pictures.

## 1. What Phantasm is

Phantasm is an operating system for the Mirage. It replaces the sampler with a
wavetable synthesizer and leaves the instrument's own sound hardware as it
was: the Ensoniq sound chip plays the waves, and the analog filters shape
them.

- **Waves.** A wave is one cycle of a sound, 256 points long. The disk holds
  512 of them. The first 256 are the factory's: analog shapes, harmonics,
  voices, bells and so on. The next 128 are noise. The last 128 are the user
  area, for waves of your own (section 5).
- **Tables.** A wavetable is an ordered list of waves. A patch plays one
  table, and moves along it as you play: with the envelope, the LFO, the
  keys and the wheels (section 5).
- **Voices.** Eight voices, each with two oscillators, A and B, one filter
  and its own envelopes. Poly, mono and unison modes use them differently
  (section 9).
- **Envelopes.** Three: ENV1 shapes the loudness, ENV2 the filter, and ENV3
  is free to move the pitch, the resonance, the LFO or the wave position
  (section 8).
- **Patches.** A hundred, numbered 00 to 99, kept on the disk, one to a
  sector. Everything about a sound is in its patch (section 4).

What it does not have: there is no split or layer (a patch is one sound) and
no LFO sync to MIDI clock. A parameter
changed on the panel is heard at once and lost when another patch is loaded,
unless you save it first.

## 2. Getting started

### What you need

- The Mirage, a Gotek floppy emulator in place of its drive, and a USB stick
  holding the Phantasm disk image, which is a file ending in .hfe.
- Give the file a short name. The Gotek's small display shortens long ones.
- For notes, a MIDI keyboard on the Mirage's MIDI input, or the Mirage's own
  keyboard. The Mirage's own wheels may be noisy on an old unit; a MIDI
  controller's bend and mod wheels are the better test.

### Switching on

1. Put the stick in the Gotek and select the Phantasm image on its display.
2. Switch the Mirage on.
3. Wait. The disk's waves are read into the instrument before it will play, so
   boot takes about 21 seconds and there is little to see on the display
   until it ends. This is not a fault.
4. When boot ends the display shows the version, two digits: 11 for version
   1.1 (a release build shows 1.1 with a dot between them). It stays until you
   touch the panel.

Patch 00 is loaded at boot, and the MIDI channel, omni, master tune and
transpose are restored from the disk if you saved them (section 4).

### Is it working?

Play a note. If you hear it, the disk, the waves and the voices are working.
If the keys are silent, send a note from a MIDI keyboard on the channel
parameter 95 shows, or check that omni (96) is 1.

If the display shows a letter E and a character at boot or after a disk
operation, the disk did not read: see section 13. The instrument cannot be
damaged by a bad disk. It never writes to the disk except when you save.

## 3. The front panel

Phantasm keeps the Mirage's own way of editing: every sound control is a
numbered parameter, a two-digit number from 10 to 98.

### Reading and changing a parameter

1. Press **PARAM** and type the two digits of the parameter number, for
   example 7 0 for the filter cutoff. The display shows the parameter's
   current value.
2. To set a value, press **VALUE** and type two digits: 0 4 sets four. A
   value is always typed as two digits. It takes effect when the second
   digit goes in: there is no Enter to press.
3. Or nudge the value with **On/Up** and **Off/Down**, one step at a time.
   They stop at the top and bottom of the parameter's range.
4. **Cancel** abandons a number or a value you have started and has not yet
   taken effect.

A typed value larger than the parameter's range is clamped to the top of it.
A parameter number that does not exist shows EE.

An edit goes straight into the sound, so you hear it at the next control
step, or at the next note for some parameters (the manual says which). There
is no undo: to go back to the saved sound, load the patch again (section 4).

### Actions

Two numbers are not parameters but one-shot actions. Press **PARAM**, type the
two digits, and the action runs when the second digit goes in.

| Action | What it does |
|---|---|
| **94** | Restarts the wave sequence at its first step (section 5) |
| **93** | Saves the user waves that have changed (section 5) |

### The patch buttons

Four of the Mirage's own buttons choose and save patches: LOAD Upper, LOAD
Lower, SEQ Load and SEQ Save. If your unit's panel does not have them, use
program change and the editor (section 12).

- **LOAD Upper** loads the next patch and **LOAD Lower** the previous one.
  Both wrap round: Upper from 99 goes to 00.
- **SEQ Load**, then two digits, loads that patch. It loads on the second
  digit.
- **SEQ Save** then **Enter** saves over the patch you are on. **SEQ Save**
  then two digits saves a copy under that number (section 4).

While the disk is working the display shows Ld (load) or Sd (save), and then
the patch number, or an error (section 13). Keys and MIDI notes sent while the disk is working are lost, and every voice
is released when it ends. Wait for the number before you play.

## 4. Patches

A patch is one sound: its wavetable, sequence, envelopes, LFO, filter,
oscillators and modes, kept as one sector on the disk. There are 100,
numbered 00 to 99. The factory disk has eight, 00 to 07; 08 to 99 are empty
starting points.

### Loading

Load with LOAD Upper, LOAD Lower or SEQ Load and two digits (section 3), or by
MIDI program change: program p loads patch p, for p up to 99. Programs 100 to
127 are ignored.

A load takes about two seconds. Loading the patch you are already on loads it
again, which is how you throw away edits.

**Unsaved edits are discarded without asking** when another patch loads, from
the panel, a program change or a MIDI editor.

### Saving

1. Make the sound you want with PARAM and VALUE.
2. Press **SEQ Save**. The display shows the number of the patch you are on.
3. Press **Enter** to overwrite that patch. Or type two digits to save a copy
   as that number. There is no prompt, so a number that already holds a patch
   is overwritten.
4. The display shows Sd while the disk works, then the number. After a
   save-as, the number is the copy: it is now the patch you are editing.

**Cancel** before the second digit abandons the save. The save is written and
then read back from the disk, and an error shows if it did not match.

### Saving the instrument settings

The MIDI channel (95), omni (96), master tune (97) and transpose (98) belong
to the instrument, not to a patch. They are written to the disk together with
a patch save, but only when one of them changed since boot. Changing patches
never changes them. A disk saved before master tune and transpose existed
loads with both at 50 (none).

### Notes

- A save is refused (EP) when the disk is write protected (section 13).
- After a failed load the instrument plays a plain default sound and refuses
  to save until a patch loads well, so a read error cannot overwrite a good
  patch with the default. Load a patch that works, then save.
- The Gotek has one image at a time. To work with more than 100 patches,
  swap images.

## 5. Waves, tables and sequences

### The wave bank and the tables

The factory disk's waves 0 to 255 are made from recipes: analog sweeps,
harmonic series, vocal shapes, bells, FM, and so on. A patch does not choose
waves one by one. It chooses a wavetable with parameter **10**, which is
the table's number in the patch's own list, starting at 0, and the table is an
ordered list of waves.

Parameter **12**, wave position, is where in the table a note starts, as a
share of the table: 0 is the first entry and 99 the last, whatever the table's
length, and 50 is the middle. On a table of up to 87 entries every entry has a
value of its own. On a longer one a value now and then steps over an entry (28
of the 128 on the longest), and only a patch from the editor or a bank file
can start on those. Choosing another table with 10 keeps the start at the
same share of the new one.

Changing 12 moves the notes that are sounding, whether it comes from the panel,
a controller (CC 12) or the editor: each moves to the new start at once, and
keeps its own sequence step and its own velocity and key offsets. Loading a
patch does not move them. A patch saved by an earlier release stored an entry
number here, so it now starts nearer the beginning of its table: set 12 again.

Modulation then moves the position away from where the note started:

| Source | Parameter |
|---|---|
| Velocity | 14 |
| Key, higher notes further | 15 |
| ENV3 | 85 set to 5, and its depth 86 |
| LFO | 17 |
| Mod wheel | 38 set to 1, and its depth 36 |
| Channel pressure | 39 set to 1, and its depth 37 |

Parameter **13**, wave wrap: 0 holds the position at the end of the table, 1
wraps it round to the other end.

A scan switches waves directly, with no crossfade, so you hear the steps
between waves. That is the instrument's sound, not a fault.

### Wave sequences

A **sequence** is a list of positions in the table. Parameter **11** chooses
one, and parameter **18** says how it is played, on each note:

| 18 | Mode | What happens |
|---|---|---|
| 0 | Off | Each note starts at the position in 12 |
| 1 | Step | Each note takes the next step in the sequence |
| 2 | Per voice | Each voice has its own place, going round the eight |
| 3 | Random | Each note picks a step at random |
| 4 | LFO | Each voice takes the next step every LFO cycle while its key is held |

The sequence chooses where a note starts, and the modulation above moves it
from there. Parameter **19** restarts the sequence after that much silence
between notes (0 is never). Action **94** restarts it by hand.

In mode 4 a note starts where mode 2 would put it, on its voice's own step, and
from then on the step moves on by one each time the voice's LFO completes a
cycle, wrapping from the last entry to the first. Each voice steps on its own
LFO: with LFO sync (33) at 1 the voices of a chord step together, and at 0 they
drift apart. The LFO rate (parameter 30, 0 holds the step) sets how fast; the
LFO delay (parameter 35) holds the first step until it has run out; and the
step stops when the key is let go. The LFO's depths (17, 31, 34) are separate:
at 17 = 0 the LFO only steps the sequence, and above 0 it also sweeps within
each step. The random LFO shape steps at the LFO rate too.

### The user area

Waves 384 to 511 are 128 places for waves of your own. The factory disk puts
32 waves there: Evolver single-cycle waves in places 384 to 415, played by
patch 07's table, named evolver. The other 96 are empty (a flat line).

To put a wave of your own there you send it from a computer as a MIDI sample
dump (section 12). Then you must save it, or the next boot loads the disk's
waves over it.

1. Send the dump (section 12). Notes are ignored while it arrives, and the
   keys work again when it ends.
2. Press **PARAM 9 3**. The display shows Sd while the changed waves are
   written to the disk, then the patch number.
3. If nothing has changed, 93 writes nothing and the display just shows the
   patch number.

Only the changed waves are written. Each is read back and compared, and if one
does not match the display shows Er, and that one and the ones after it are
tried again at the next save (section 13).

A received wave is played only if a table names it. Patch 07's table, evolver,
names 384 to 415, so a dump to sample numbers 0 to 31 replaces waves that
table plays, and a dump to 32 and up is stored but no factory table plays it.
A MIDI editor can write a patch with a table that names them.

### The noise region

Waves 256 to 383 are noise, not waves to scan. They are played by oscillator
B only, as its source (section 6).

## 6. Oscillators A and B, and noise

Each voice has two oscillators. A plays the wave the table chooses. B plays
the same wave, a little different, or it plays noise.

### Tuning

| Parameter | Controls | Shows | Step |
|---|---|---|---|
| 20 | Coarse A | 38 to 62 | one semitone |
| 21 | Fine A | 29 to 71 | 4.7 cents, about a semitone each way in all |
| 22 | Coarse B | 38 to 62 | one semitone |
| 23 | Fine B | 29 to 71 | 4.7 cents |

For all four, **50 is no shift**. 38 is a whole octave down and 62 a whole
octave up. A fine step is a 256th of an octave, not a cent, so neighbouring
numbers are always different pitches. Tuning is applied at the next note.

**25** sets the bend range, in whole semitones from 0 to 12, for the full
travel of the wheel. 2 is a whole tone and 12 an octave.

### Levels

**27** is A's level (99 is full, 0 is off) and **24** is B's (0 is off). B is
taken from the same level as A, not from what is left, so turning B up makes
the voice louder (section 10).

### Noise and sync on B

**28** chooses what B plays:

| 28 | B plays |
|---|---|
| 0 | The same wave as A |
| 1 | White noise, following the key |
| 2 | Pink noise, following the key |
| 3 | Brown noise, following the key |
| 4 | White noise at a fixed rate |
| 5 | Pink noise at a fixed rate |
| 6 | Brown noise at a fixed rate |
| 7 | The same wave as A, hard-synced to A |

White is the brightest of the three and brown the darkest. In 1 to 3 the noise's
pitch follows the key, so it gets higher up the keyboard; in 4 to 6 the rate
is the same for every key, that of C4, and 22 and 23 still shift it. Pink and brown
take on a pitch towards the top of the keyboard: that is the instrument's
lo-fi character.

For noise on its own, set **27** to 0, so A is silent, and **24** to the level
you want. The filter and envelopes act on noise as on a wave.

**Sync (7).** B plays A's wave and is reset every time A's wave starts over, so
what you hear sits at A's pitch and **22** and **23** change the timbre, not the
pitch: sweeping 22 gives the classic sync sound. The pitch you hear is A's, so
a key played on A and B in unison is one note. B's level (24) and A's level (27)
still act, and the envelopes are as for any wave; set 27 to 0 to hear the
synced B on its own. The sync is set when a note starts, so a change to 28 is
heard at the next note, and a patch with 28 at 0 to 6 sounds as it did.

### Vintage

**26** makes each note drift: at every note, each voice gets a small pitch
and filter offset of its own, held for the note. 0 is off, and at 99 the
pitch spread is about plus or minus 38 cents.

## 7. Filter and amp

### The filter

Every voice has its own low-pass filter, and the voices are added after their
filters. These parameters set it:

| Parameter | Controls |
|---|---|
| 70 | Cutoff |
| 71 | Resonance |
| 72 | How far ENV2 moves the cutoff |
| 45 | How far a soft key takes that away |
| 73 | How far the key moves the cutoff |
| 74 | How far velocity moves the cutoff |
| 34 | How far the LFO moves the cutoff |
| 77 | How far the wave pointer's place in the table moves the cutoff |
| 37 | How far channel pressure moves the cutoff, when 39 is 2 |

Parameter 77 is the one to reach for when a sound scans a wavetable. A table
that runs dull to bright puts its energy higher the further up it you go, and a
cutoff that stays where it was then takes away what the scan added: the bright
end comes out quiet. At 77 = 50 the pointer does nothing to the filter. Above
50 the filter opens as the pointer climbs the table, 0 at the first entry and
the full amount at the last, on a table of 32 entries or of 128 alike, and
below 50 it closes. At 99 the last entry is 98 steps of cutoff above where it
would be, nearly three and a half octaves, and 82 is about 64 steps. The
amount follows where the pointer is when it sounds, after the sequence, the
LFO, ENV3 and the wheel have all moved it, and oscillator B follows the
pointer, so it has no setting of its own. A change to 77 takes effect on the
notes already sounding.

Parameter 45 makes the filter envelope follow how hard the key is struck. At
0, 72 is the depth whatever the velocity. At 99 a key struck at full velocity
gets all of 72, and a softer one the same fraction of it as its velocity is of
the top, so a note at velocity 20 gets about a sixth: a hard key opens the
filter and a soft one barely moves it. In between, 45 at 50 takes off half as
much. Only the envelope's depth is scaled; the cutoff itself (70) and the
velocity term (74) are as they were. Velocity here is the key's own, so the
notes of a mono legato phrase keep the depth of the note they were slurred
onto, and all the voices of a unison note share one. A change to 45 or to 72
takes effect on the notes already sounding.

Parameter 37 with 39 at 2 opens the filter from the pressure of a MIDI
keyboard's aftertouch. At 37 = 99 and full pressure it adds 253 steps of cutoff,
more than the filter's whole range, so a low cutoff opens fully, and 37 at
50 gets about half as far; with no pressure it adds nothing, whatever 37 is. A
note already sounding follows the pressure at once, and a change to 37 or 39
takes effect within a moment.

Resonance can be raised until the filter rings on its own, and it also raises
the level of the sound around the cutoff (section 10).

### The amp

There is no separate amplifier circuit. The loudness is set by the sound
chip's volume, shaped by ENV1.

| Parameter | Controls |
|---|---|
| 75 | Amp level: the loudest a voice gets |
| 76 | Velocity to amp: how much harder keys are louder |
| 50 to 54 | ENV1, the amp envelope (section 8) |

At 76 = 0 every key sounds at the level 75 sets. A change to 75 or 76 takes
effect at the next note you play. Section 10 is the guide to setting them.

## 8. Modulation

### Envelopes

There are three envelopes, and they have the same five parameters in a row:
the first digit is the envelope, the second the stage.

| Envelope | Used for | Parameters |
|---|---|---|
| ENV1 | Loudness | 50 attack, 51 peak, 52 decay, 53 sustain, 54 release |
| ENV2 | Filter cutoff, by 72 | 40 attack, 41 peak, 42 decay, 43 sustain, 44 release |
| ENV3 | Free: the destination in 85, depth in 86 | 80 attack, 81 peak, 82 decay, 83 sustain, 84 release |

Attack, decay and release are times: higher numbers are slower. The peak is
the level the attack reaches, and the sustain is the level held while the key
is down. ENV1's decay and release are exponential and shown 0 to 85.

**Key speed** (47, 57 and 87) makes an envelope faster on higher notes. 50 is
none, and 99 halves the decay and release for every octave above C4 (key 60).

**ENV3's destination (85):**

| 85 | ENV3 moves |
|---|---|
| 0 | The pitch of both oscillators, A and B |
| 1 | The pitch of oscillator A only |
| 2 | The pitch of oscillator B only |
| 3 | The resonance |
| 4 | The LFO's depth |
| 5 | The wave position |

With B source 7 (hard sync, 28), 2 sweeps the synced oscillator against a
fixed master, the classic sync sound, and 1 sweeps the master against a fixed
slave. At 0 the two move together and the ratio between them stays fixed, so
the sweep is a plain transposition. With B off (the B level at 0), 1 sounds as
0 and 2 does nothing.

The depth, **86**, runs both ways: 50 is none, and below 50 reverses the movement.

**ENV3 loop (88)** makes ENV3 a second, drawn LFO. At 0 it runs attack, peak,
decay and rests at its sustain (83), as it always has. At 1, when the decay
has fallen to the sustain level and the key is still down, it climbs again from
there, so the attack, peak, decay and sustain level (80-83) are the four corners
of a cycle: sustain is the cycle's floor, and with the sustain at 0 the loop
sweeps the whole range. Key speed (87) shortens the looped decay up the
keyboard like any decay. Lifting the key releases from wherever the loop is. A
mono legato phrase keeps the loop going as the notes are slurred; a new,
detached note restarts it from nothing. The voices of a unison note loop
together. The setting is read at the end of each decay: changing 88 to 1 under
a note whose ENV3 is already resting takes effect from the next note. 88 has no
MIDI controller number; set it from the panel or by SysEx.

### The LFO

| Parameter | Controls |
|---|---|
| 30 | Rate |
| 31 | How far it moves the pitch |
| 34 | How far it moves the cutoff |
| 17 | How far it moves the wave position |
| 32 | Shape: 0 triangle, 1 ramp up, 2 ramp down, 3 square, 4 random |
| 33 | Sync: 0 free-running (each voice's LFO keeps going between notes), 1 restart at each note, so the same sweep every time the key is pressed; 2 is reserved for MIDI clock and runs as 0 |
| 35 | Delay: how long before it comes in after a note starts |

### Velocity, key and wheels

- **Velocity** moves the wave position (14), the cutoff (74) and the loudness
  (76), and can scale how far ENV2 moves the cutoff (45, section 7).
- **Key** moves the wave position (15) and the cutoff (73).
- **Pitch bend** moves every voice, by the range set in 25.
- **The mod wheel** (CC 1) has its own depth, **36**, and a destination,
  **38**: 0 raises the LFO's depth, and 1 moves the wave position.
- **Channel pressure** (aftertouch, from a MIDI keyboard that sends it) has its
  own depth, **37**, and a destination, **39**: 0 raises the LFO's depth as the
  wheel's 0 does, 1 moves the wave position, 2 opens the filter. It adds to
  the mod wheel's, so the wheel can be on the LFO and pressure on the wave.
  37 at 0 is off. The Mirage's own keyboard does not send pressure. A patch
  starts with none held.
- **The sustain pedal** holds notes, from the Mirage's pedal or CC 64.

## 9. Voice modes

**60** sets how the eight voices are used.

| 60 | Mode | What happens |
|---|---|---|
| 0 | Poly | Up to eight notes at once, oldest note taken first when they run out |
| 1 | Mono, retrigger | One note at a time, the last key played; every new key restarts the envelopes |
| 2 | Mono, legato | As 1, but a key played while another is held changes the pitch only and does not restart the envelopes |

In mono, letting go of the sounding key goes back to the newest key still held.

**Unison, 61**, makes one key sound several voices, 1 to 8: 1 is off. The
voices are spread in pitch by **62**, in steps of 4.7 cents, from 0 to 21.
Eight voices on one key leaves none for chords, because every key uses its
own voices. Unison is louder than a single voice, so see section 10.

**Glide, 63**, slides the pitch to a new note. 0 is off, and 1 to 99 are
slower, from an octave in 22 milliseconds to an octave in 33 seconds. In
mono, glide happens on a legato slur. In poly, every note glides from the
pitch its voice last played.

**Vintage, 26**, is described in section 6.

Mono and unison combine: the mono note is then the group of unison voices.
Voice mode, unison, spread, glide and vintage are part of the patch, so a
mono bass or a unison lead is back as you saved it when you load it.

## 10. Gain staging

Gain staging is setting how loud each part of the sound is, so that the loudest
thing you will play comes out clean. If a patch sounds fine on single notes and
breaks up when you play chords, turn on unison, or add the second oscillator,
the patch is too loud for that material. This section shows where the level
comes from and which control to turn.

### The level chain, in order

1. **Amp level (75)** sets a voice's loudest level. Every factory patch uses
   the same value, which the display shows as 75.
2. **Velocity > amp (76)** lets how hard you play change that level. At 0 every
   key sounds at the level 75 sets. Raised, a softer key sounds quieter, and a
   full-force key stays at the level 75 sets. Velocity never makes a note
   louder than 75 does.
3. **A level (27)** and **B level (24)** then set how much of that level goes
   to each oscillator. A level at 99 passes all of it. B level at 0 turns B
   off, and at 99 gives B about as much as A. B is taken from the same level
   as A, not from what is left, so turning B on makes the voice louder.
4. **ENV1 (50 to 54)** shapes the level over the life of the note.
5. **The filter** (cutoff 70, resonance 71) comes next, one filter for each
   voice. The voices are added together after their filters.
6. **Unison (61)** makes one key sound up to 8 voices, and every key you hold
   sounds its own voices.

### What makes it louder

| Control | What it does to the level |
|---|---|
| **Amp level (75)** | Every voice, every note |
| **B level (24)** | Adds the second oscillator to every voice |
| **A level (27)** | The first oscillator's share; lower it to make room for B |
| **Resonance (71)** | Raises the level of the sound around the cutoff |
| **Unison voices (61)** | One key sounds that many voices; their sum is louder than one voice, by an amount that depends on the key |
| **Notes held** | Every held note adds its voices to the sum |
| **How hard you play** | With Velocity > amp (76) above 0, harder keys are louder |

### Setting the level

1. Pick the densest thing the patch will play: the biggest chord, with unison,
   B and resonance at the settings you will use, and the hardest touch.
2. Play it. If it breaks up, lower **Amp level (75)** a few steps.
3. **Release the keys and play again.** A change to 75 or 76 takes effect at
   the next note you play. Notes that are already sounding keep the level they
   started with, so turning 75 down while a chord rings changes nothing you can
   hear until the next chord.
4. Repeat until the densest passage is clean, then save the patch, because
   75 is part of the patch (see section 4).

### Notes

- **Lower 75, not ENV1's peak (51) and sustain (53).** Those two shape the
  note. Turning them down to tame a chord changes how the note swells and
  holds as well as how loud it is. 75 changes only how loud the note is.
- Lowering 75 lowers single notes too. A patch set up for a big chord will be
  quiet when you play one note. Balance patches against each other at your
  mixer or amplifier, not with 75.
- Patches differ. A patch with unison, B and resonance may need a lower 75
  than a plain one. Set each patch for the most it will be asked to do.

## 11. Parameter reference

This table is made from the instrument's own parameter table, so the numbers
and ranges are the ones the panel shows and the printed card repeats.

- **Number** is the two digits you type after PARAM, and is the same number
  in the MIDI controller column and in a MIDI editor.
- **Shows** is what the display reads, not the stored byte. A detune shows 50
  for no shift; the channel shows 1 to 16; key speed shows 1 to 99 with 50 as
  none. **0 to n** means the last entry of the patch's own list of tables
  (10) or sequences (11).
- **CC** is the MIDI controller that edits it, the same number, with 0 to 127
  scaled onto the range shown. A dash means it has no CC: set it from the
  panel, or from a computer by SysEx (section 12).

| Number | Name | Shows | CC | Notes |
|---|---|---|---|---|
| 10 | Wavetable | 0 to n | - | the patch's tables, 0 first |
| 11 | Wave sequence | 0 to n | - | the patch's sequences, 0 first |
| 12 | Wave position | 0-99 | 12 | start, 0 first entry to 99 last, any table |
| 13 | Wave wrap | 0-1 | 13 | 0 clamp, 1 wrap |
| 14 | Velocity > wave | 0-99 | 14 | - |
| 15 | Key track > wave | 0-99 | 15 | - |
| 17 | LFO > wave | 0-99 | 17 | - |
| 18 | Sequence mode | 0-4 | 18 | 0 off, 1 step, 2 per voice, 3 random, 4 LFO |
| 19 | Sequence reset gap | 0-99 | 19 | silence before restart, 0 never |
| 20 | Coarse A | 38-62 | 20 | semitones, 50 = 0 |
| 21 | Fine A | 29-71 | 21 | 1/256 octave (4.7 cents), 50 = 0 |
| 22 | Coarse B | 38-62 | 22 | semitones, 50 = 0 |
| 23 | Fine B | 29-71 | 23 | 1/256 octave (4.7 cents), 50 = 0 |
| 24 | Oscillator B level | 0-99 | 24 | 0 = off; adds to A, so the voice gets louder |
| 25 | Bend range | 0-12 | 25 | whole semitones, full wheel; 2 is a whole tone, 12 an octave |
| 26 | Vintage | 0-99 | 26 | 0 off; 1-99 more drift: each note-on gives every voice its own pitch and cutoff offset, up to +/-8 steps (+/-38 cents; +/-3.4 semitones of cutoff) at 99 |
| 27 | Oscillator A level | 0-99 | 27 | 99 = full, 0 = off |
| 28 | Oscillator B source | 0-7 | 28 | 0 A's wave, 1 white noise, 2 pink, 3 brown (tracking the key), 4 white, 5 pink, 6 brown (fixed rate, C4), 7 sync (B is A's wave, hard-synced to A) |
| 30 | LFO rate | 0-99 | 30 | - |
| 31 | LFO > pitch | 0-99 | 31 | - |
| 32 | LFO shape | 0-4 | - | 0 triangle, 1 ramp up, 2 ramp down, 3 square, 4 random |
| 33 | LFO sync | 0-2 | - | 0 free-running, 1 restart at note-on, 2 MIDI clock (not built: runs as 0) |
| 34 | LFO > cutoff | 0-99 | 34 | - |
| 35 | LFO delay | 0-99 | 35 | - |
| 36 | Mod wheel depth | 0-99 | 36 | - |
| 37 | Pressure depth | 0-99 | 37 | channel aftertouch, 0 = off |
| 38 | Mod wheel destination | 0-1 | - | 0 LFO depth, 1 wave position |
| 39 | Pressure destination | 0-2 | 39 | 0 LFO depth, 1 wave position, 2 cutoff |
| 40 | ENV2 attack | 0-99 | 40 | - |
| 41 | ENV2 peak | 0-99 | 41 | - |
| 42 | ENV2 decay | 0-99 | 42 | - |
| 43 | ENV2 sustain | 0-99 | 43 | - |
| 44 | ENV2 release | 0-99 | 44 | - |
| 45 | Velocity > ENV2 | 0-99 | 45 | 0 = depth as set (72); 99 scales it by velocity / 127 |
| 47 | ENV2 key speed | 1-99 | 47 | 50 = none; 99 halves decay and release per octave above key 60 |
| 50 | ENV1 attack | 0-99 | 50 | - |
| 51 | ENV1 peak | 0-99 | 51 | - |
| 52 | ENV1 decay | 0-85 | 52 | exponential |
| 53 | ENV1 sustain | 0-99 | 53 | - |
| 54 | ENV1 release | 0-85 | 54 | exponential |
| 57 | ENV1 key speed | 1-99 | 57 | 50 = none; as 47 |
| 60 | Voice mode | 0-2 | 60 | 0 poly, 1 mono retrigger, 2 mono legato |
| 61 | Unison voices | 1-8 | 61 | per note; 1 = off |
| 62 | Unison spread | 0-21 | 62 | 1/256 octave (4.7 cents) a step |
| 63 | Glide | 0-99 | 63 | 0 off; 1-99 slower, an octave in 22 ms to 33 s |
| 70 | Filter cutoff | 0-99 | 70 | - |
| 71 | Resonance | 0-99 | 71 | high settings self-oscillate |
| 72 | ENV2 > cutoff | 0-99 | 72 | - |
| 73 | Key track > cutoff | 0-99 | 73 | - |
| 74 | Velocity > cutoff | 0-99 | 74 | - |
| 75 | Amp level | 0-99 | 75 | lower it if chords or unison distort |
| 76 | Velocity > amp | 0-99 | 76 | - |
| 77 | Wave > cutoff | 1-99 | 77 | bipolar, 50 = none: + opens the filter up the table |
| 80 | ENV3 attack | 0-99 | 80 | - |
| 81 | ENV3 peak | 0-99 | 81 | - |
| 82 | ENV3 decay | 0-99 | 82 | - |
| 83 | ENV3 sustain | 0-99 | 83 | - |
| 84 | ENV3 release | 0-99 | 84 | - |
| 85 | ENV3 destination | 0-5 | 85 | 0 pitch A+B, 1 pitch A, 2 pitch B, 3 resonance, 4 LFO depth, 5 wave position |
| 86 | ENV3 depth | 0-99 | 86 | bipolar, 50 = none |
| 87 | ENV3 key speed | 1-99 | 87 | 50 = none; as 47 |
| 88 | ENV3 loop | 0-1 | - | 0 = off; 1 = restarts from its attack at the end of its decay while the key is held |
| 93 | Save user waves | action | - | the changed ones, at the second digit |
| 94 | Restart sequence | action | - | at the second digit |
| 95 | MIDI channel | 1-16 | - | numbered as a DAW numbers them |
| 96 | Omni | 0-1 | - | 0 off, 1 on |
| 97 | Master tune | 29-71 | - | saved with the channel and omni; 50 = none, 4.7 cents a step |
| 98 | Transpose | 38-62 | - | saved with the channel and omni; 50 = none, semitones |

A number that is not in the table is not a parameter, and entering one shows
EE.

## 12. MIDI

### Channel and omni

Parameter **95** is the channel Phantasm receives on, shown 1 to 16. **96** is
omni: 1 receives on every channel, 0 only on 95's. Both are saved with a patch
save when they have changed (section 4).

### Master tune and transpose

Parameter **97** tunes the whole instrument and **98** transposes it, for
matching the Mirage to another instrument or a track. Both are 50 for none.

- **97, master tune,** is 29 to 71: a step is 1/256 of an octave (4.7 cents),
  up to 21 steps (about 100 cents) either way. 4.7 cents is coarse against a
  reference pitch; it is the pitch unit the engine has, the same as a patch's
  fine tune (A fine).
- **98, transpose,** is 38 to 62: whole semitones, 12 either way.
- Both are applied when a note starts, so a change is heard from the next note
  and a held note stays where it was. A mono legato slur takes the current
  values.
- Transpose moves the pitch and not the filter: the cutoff's key tracking and
  the envelopes' key speed follow the key you play, so a transposed patch keeps
  its brightness. Fixed-rate noise (28 = 4-6) is pitched from C4 whatever the
  key, so transpose does not move it; the master tune does.
- Neither moves the sequence, and neither is a patch parameter: both are saved
  with the channel and omni (section 4), not with a patch.
- They are not on a CC. The editor sets them by SysEx like 95 and 96.

### What it responds to

| Message | Effect |
|---|---|
| Note on and off | Plays, with velocity |
| Pitch bend | Bends every voice, by the range in 25 |
| CC 1 | The mod wheel (36 and 38 set what it does) |
| CC 64 | Sustain pedal |
| Program change 0 to 99 | Loads patch 00 to 99. A disk load of about two seconds |
| CC 120, 123, 124, 125 | Release every voice (120, all sound off, and 123, all notes off, are the same here) |
| CC 121 | Reset all controllers: the bend to centre, the mod wheel and channel pressure to 0, the sustain pedal up (held notes release). The patch is not touched |
| CC 12 to 31, 34 to 37, 39 to 63, 70 to 87 | Edits the parameter with the same number (section 11) |
| Channel pressure | Aftertouch: depth 37, destination 39 (section 8) |
| Polyphonic pressure | Read and ignored |

Every other controller keeps its usual meaning and is ignored, so a DAW's
volume, pan and reverb sends do not change a patch. A CC for a number that has
no parameter is dropped. A CC's 0 to 127 is scaled onto the parameter's own
range, so a controller's centre value is 50 on a detune.

CC 121 is the cure for a bend or wheel left off-centre when a controller is
unplugged mid-phrase. The Mirage's own wheels are read again only when one is
moved, so a reset holds until you touch a wheel.

A CC edits a parameter the same way the panel does, and the display then shows
that parameter. A program change received while the disk is busy is lost, and
so is a note.

### Editing from a computer

A computer can read and set every parameter by SysEx, dump and write the
loaded patch, and select and save patches by number. [Phantasm Editor](../README.md#phantasm-editor), a separate project, is the editor for it. The protocol is in the [MIDI implementation](MIDI-IMPLEMENTATION.md); this firmware speaks SysEx protocol 4.0, which the discovery request reports, and an editor written for an earlier one cannot dump or write a patch to it. The Mirage
only answers: it never sends anything by itself.

A written patch goes to memory only. Nothing reaches the disk until a save,
from the panel or by the editor, so an interrupted transfer cannot damage a
patch. The display is not redrawn after a write to the loaded patch until you
touch the panel.

### Sending your own waves

Phantasm receives the MIDI Sample Dump Standard into the user area (section
5). From a sample editor or a dump program:

- Send **8-bit** samples of **256 points per wave**, so one wave is 256
  samples and a longer sample is that many waves in a row. Sample number n,
  0 to 127, goes to wave 384 plus n.
- It is **one way**. The Mirage sends nothing back, so no handshake: turn the
  sender's handshake or wait-for-ACK off, and leave 2 seconds after the header
  and 20 milliseconds between packets.
- 128 waves take about 35 seconds. The keys and MIDI notes are ignored until
  the dump ends, or for 2.6 seconds after the last packet.
- Waves are written whole or not at all. A bad packet abandons the dump and
  keeps the waves already written.
- Each sample keeps its top 8 bits, and a zero becomes 1. Send each wave as
  one clean cycle, centred and levelled by your editor: the instrument does
  not condition it.
- **The waves are in wave memory only.** Press PARAM 9 3 to save them (section
  5).

Do not send other SysEx while a dump runs: any other SysEx message ends it.

## 13. Display codes and errors

### What the display shows

| Display | Meaning |
|---|---|
| Two digits | The patch number, or a parameter's number or value as you type |
| 11, or 1.1 | The version, from boot until you touch the panel |
| Ld | A patch is loading |
| Sd | A save is writing: a patch, or the user waves |
| EE | A parameter number that does not exist |
| E and a digit or letter | The disk could not be read or written. The character is the drive's last status; only the E carries a message |
| EP | A save was refused because the disk is write protected |
| EU | Action 93 was refused: the loaded disk has no user area |
| Er | Action 93 wrote a wave and read it back different |

### What to do

- **E and a character on a load.** The patch did not read. Try the load
  again. If it fails again, try another patch number, then restart. The
  instrument is playing a plain default sound, and **will refuse to save**
  until a patch loads well, so a read error cannot overwrite a good patch.
  A disk built for an earlier firmware does the same on every load: the
  patch was 72 bytes before SysEx protocol 4.0 and is 96 now, a patch sector
  from before is refused, and the disk has to be rebuilt.
- **E and a character on a save.** The write or its read-back failed. The
  patch may not be on the disk: load it again to see, and save again.
- **EP.** The disk is write protected. Remove the write protection of the image or the stick, restart, and save
  again.
- **EU.** The disk was not made for the user area. It holds fewer than 512
  waves, and the user waves are not saved. Use a disk built for 512.
- **Er.** A user wave did not read back as written. That wave and the ones
  after it are still marked as changed. Press PARAM 9 3 again. If it
  persists, the disk or the drive is at fault.
- **The patch number changed after a failed save-as.** A save-as that fails
  on the disk (EP, or E and a character) still moves the displayed number to
  the number you typed, though the patch may not be there. Load the patch you
  meant to be on. A save-as refused after a failed load leaves the number
  where it was.
- **A MIDI write did not show on the display.** It reached the sound. Touch
  any panel key.
- **Notes are silent.** Check parameter 95 and omni 96, 75 (amp level), and
  that a user-wave dump or a disk transfer is not still running.
- **Nothing appears after boot.** Wait the full half-minute. If it still
  shows nothing, check the Gotek has the Phantasm image selected and restart.
  A bad image cannot hurt the Mirage: its boot ROM is untouched.

### Starting over

Unsaved edits are lost on any load and at power off. Saved patches and saved
user waves are on the disk. If the sound is wrong and you do not know why,
load the patch again.
