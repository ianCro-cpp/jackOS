# jackOS (Alpha v.0.0)
## What is jackOS
  jackOS is a simple interactive 'toy-box' operating system using the [Motorola 68000 series processors](https://en.wikipedia.org/wiki/Motorola_68000_series). For the current version, it has basic functionality of reading and writing to registers and memory and running simple 68K programs, but I would like to implements a simple [fast floating point library](http://www.easy68k.com/codeLibrary.htm) for various purposes

  This project is the software implementation for a university project designing our own microcomputer using the 68K. Another repository will come later discussing the old designs I have made on 'The Smiler' along with a better revision.
## Current Version
  jackOS is currently within alpha v0.0. For now it operates within 6 basic commands:
  - Reading and outputting the 68K registers
  - Writing into 68K registers
  - Reading into ROM and RAM memory
  - Writing into RAM memory
  - Loading and Running [SREC files](https://en.wikipedia.org/wiki/SREC_(file_format)) (For now, they load files using 16 and 24 bit addresses)
## Future Plans
- Cleaning up and debugging commands
  * Fixing word writing issue
  * Better error checking on address inputs
- implementing 32 bit addressing for SREC file loading
- implementing better ASCII graphics and possibly extended ASCII/UTF-8
## Future Programs to Demo on Software
- Hammurabi (based upon Doug Dyment's text-based BASIC game in 1968)
- Interactive Unit Circle
- 68Karnage: a basic first-person ray tracing demo
