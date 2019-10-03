# YoutubeDL

This is a Swift wrapper around the amazing
[youtube-dl](https://github.com/rg3/youtube-dl/) Python library.

It consists of a (more or less) platform-indepentent wrapper around the library,
as well as a macOS and (`// TODO`) iOS app target.

## How to use

You have to build it yourself (using Xcode), but everything should be rather
straight forward.

## Supported sites

In theory everything site that is supported by youtube-dl
([See here](https://rg3.github.io/youtube-dl/supportedsites.html)). In practice,
I've only tested with very few sites so far, so feel free to report issues.

## Executing Python

As the core smartness of this project (the `youtube-dl` library) is written in
Python, I needed to somehow be able to execute Python inside this project.

### Framework

The easiest way to do so is probably to simply use Apple's `Python.framework`,
which comes as part of macOS. Sadly, this is 1) only Python 2.7, and 2) only
available on macOS, not iOS. To overcome this, I started building the official
CPython implementation as a framework myself. For this, see my
[PythonFrameworkBuilder](https://github.com/0bmxa/PythonFrameworkBuilder/)
project.

### Wrapper

CPython exposes all Python features via its
[C API](https://docs.python.org/3.7/c-api/), which comes with the typical
effects of using a C API. To make the usage of this a bit more safe (in terms of
memory leaks and such) and convenient, I added a (very basic, but generic) Swift
wrapper around the C API. For details see the source code in
[Shared/Python](Shared/Python), and its usage in
[Shared/YoutubeDL/YoutubeDL.swift](Shared/YoutubeDL/YoutubeDL.swift)

If youre interested in this, I'm happy to answer any questions, make it more
generically usable, or simply write (better) documentation.

## Credits

This started off as a fork of
[pieter/YoutubeDL-iOS](https://github.com/pieter/YoutubeDL-iOS) (see my fork
[here](https://github.com/0bmxa/YoutubeDL-iOS)), but as I realized
I started rewriting everything, I set this up as a new project.
No code of the original project is used anymore, but I definitely have to
mention this here as the source of motivation.
