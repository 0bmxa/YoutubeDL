# YoutubeDL

This is a Swift wrapper around the amazing
[youtube-dl](https://github.com/rg3/youtube-dl/) Python library.

It consists of a (more or less) platform-indepentent wrapper around the library,
as well as a macOS and (`// TODO`) iOS app target.

### How do I use it?
You have to build it yourself (using Xcode), but everything should be rather
straight forward.

### What sites does this work with?
In theory everything site that is supported by youtube-dl
([See here](https://rg3.github.io/youtube-dl/supportedsites.html)). In practice,
I've only tested with very few sites so far, so feel free to report issues.

### Python wrapper
To make it possible especially more convenient to call from Swift into Python,
this project includes a (basic, but generic) Swift wrapper around the
[Python C API](https://docs.python.org/2.7/c-api/).