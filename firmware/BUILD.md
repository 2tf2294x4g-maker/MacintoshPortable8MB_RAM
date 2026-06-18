# CPLD Firmware Build — CUPL toolchain (Mac + Linux server)

WinCUPL is Windows-only, so we compile on the Ubuntu server under Wine.
Applies to both PortableRAM.pld (v0.2 4MB) and PortableRAM8.pld (v2 8MB).

## Where it's set up (server 192.168.0.52)
- Wine prefix: `~/.wine-cupl` (WINEARCH=win32) with WinCUPL installed at `C:\Wincupl`
- Fitters upgraded to **v1918** (from Atmel ProChip 5.0.1) in `C:\Wincupl\WinCupl\Fitters`
- `5vcomp` wrapper (from github peterzieba/5Vpld) at `/usr/local/bin/5vcomp`
- Working dir: `~/cupl-build`

## To compile
```
scp firmware/PortableRAM.pld matthew@192.168.0.52:~/cupl-build/
ssh matthew@192.168.0.52 'cd cupl-build; WINEPREFIX=$HOME/.wine-cupl xvfb-run -a 5vcomp PortableRAM.pld'
scp matthew@192.168.0.52:~/cupl-build/PortableRAM.jed firmware/
```
Outputs: `.jed` (program this), `.fit` (CHECK pin assignments + "JTAG = ON"), `.err`.

## .PLD source rules (CUPL is picky — these caused real failures)
1. **Pure ASCII only** — no em-dashes (—), smart quotes, etc. CUPL chokes on UTF-8.
2. **CRLF line endings** — LF-only makes the cuplx preprocessor abort.
3. **No `*/` inside comments** — e.g. write `UDS*, LDS*` NOT `UDS*/LDS*`; the `*/`
   closes the C-style comment early and the rest parses as code.
4. **`PROPERTY ATMEL { jtag = on };`** — keeps JTAG pins live so the Tigard can
   re-program. (Default is ON for the ispTQFP44 device, but be explicit.)

## Programming (when boards arrive) — Tigard + OpenOCD
1. Convert `.jed` -> `.svf` (via ATMISP, or a jed2svf path — TODO, set up at program time).
2. `brew install open-ocd` on the Mac.
3. Wire Tigard JTAG to J2: TDI=pin1, TMS=pin7, TCK=pin26, TDO=pin32 (+GND, +5V sense).
4. `openocd -f interface/ftdi/tigard.cfg -c "transport select jtag" -f <atf1502-tap.cfg> -c "init; svf PortableRAM.svf; shutdown"`
5. Board must be powered (5V) during programming.
