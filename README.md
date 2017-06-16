# Gambattye
[![Travis](https://img.shields.io/travis/Ben10do/Gambattye.svg?label=Gambattye)](https://travis-ci.org/Ben10do/Gambattye) [![Travis](https://img.shields.io/travis/Ben10do/gambatte.svg?label=libgambatte)](https://travis-ci.org/Ben10do/gambatte)

Gambattye is a Game Boy Color emulator for macOS, powered by a [fork of Gambatte](https://github.com/Ben10do/gambatte).

Unlike Gambatte's QT or SDL frontends, Gambattye is a native Mac app. It also contains additional features, including support for larger saves (used, for example, by Little Sound DJ).

At present, the core emulation works nicely. Some features you may expect, such as save states, aren't yet available, but I'm planning on implementing these (as well as some features you may not expect) in due course.

## Installing
To download Gambattye, head to the [releases page](https://github.com/Ben10do/Gambattye/releases) and grab the latest version.

Download the top zip file, decompress it if necessary, and then drag Gambattye to your Applications folder.

To upgrade to subsequent versions, you can use Gambattye's built-in updater.

## Building
If you want to make changes, get the latest mid-development version, or just like compiling things from source code, then it's pretty straightforward to build Gambattye. You'll need [CocoaPods](https://cocoapods.org) and [Xcode](https://itunes.apple.com/gb/app/xcode/id497799835) installed.

First, clone this repository (making sure to also clone the submodules), then run `pod install`. From there, you can build and run Gambattye using Xcode. `libgambatte` will be automatically built if necessary.

## Controls
The controls can be customised in the Preferences. By default, they are currently based on bgb's, and are:

| Game Boy | Keyboard   |
| -------- | ---------- |
| D-Pad    | Arrow keys |
| A        | S          |
| B        | A          |
| START    | Enter      |
| SELECT   | Shift      |

## Licence
Gambattye is licenced under the GNU General Public Licence v2. See the about box and [LICENCE](https://github.com/Ben10do/Gambattye/blob/master/LICENCE) for more information.
