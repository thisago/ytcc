# Package

version       = "0.1.0"
author        = "Thiago Navarro"
description   = "CLI tool to get Youtube video captions (with chapters)"
license       = "MIT"
srcDir        = "src"
bin           = @["ytcc"]
binDir = "build"


# Dependencies

requires "nim >= 1.6.4"
requires "ytextractor"
requires "cligen"
