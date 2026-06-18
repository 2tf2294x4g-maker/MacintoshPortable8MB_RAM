#!/bin/sh
# Program an ATF1502AS via a Tigard (FT2232H) JTAG adapter using OpenOCD.
#
#   Usage:  ./program.sh PortableRAM8.svf
#
# Prereqs:
#   brew install open-ocd
#   Tigard JTAG header wired to board J2:  TDI=pin1  TMS=pin7  TCK=pin26  TDO=pin32
#   plus GND and a +5V sense; board powered (5V) during programming.
#
# Device facts (from the generated SVF): ATF1502AS, IR length 10, IDCODE 0x0150203f.
set -e
SVF="${1:-PortableRAM8.svf}"
openocd -f interface/ftdi/tigard.cfg \
  -c "transport select jtag; adapter speed 200; reset_config none" \
  -c "jtag newtap atf1502 tap -irlen 10 -expected-id 0x0150203f" \
  -c "init; svf ${SVF}; shutdown"
