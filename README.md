# Gambattye
Gambattye is a Game Boy Color emulator for macOS, powered by a [fork](https://github.com/Ben10do/gambatte) of [Gambatte](https://github.com/sinamas/gambatte). It's a native Mac app, unlike Gambatte's QT or SDL frontends.

At present, the core emulation works just fine. Additional features and customisation options aren't yet available, but I'm certainly planning on adding more to this in the future.

## Building
To build Gambattye, open Xcode and build as you'd expect. `libgambatte` will be automatically built if necessary – just make sure that you clone the submodules when cloning Gambattye!

## Controls
These aren't yet customisable, although this is something I'd like to add in the future. The controls are currently based on bgb's.

| Game Boy | Keyboard   |
| -------- | ---------- |
| D-Pad    | Arrow keys |
| A        | S          |
| B        | A          |
| START    | Enter      |
| SELECT   | Shift      |
