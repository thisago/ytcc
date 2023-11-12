# Package

version       = "1.1.0"
author        = "Thiago Navarro"
description   = "CLI tool and lib to get Youtube video captions (with chapters)"
license       = "MIT"
srcDir        = "src"
bin           = @["ytcc"]
binDir = "build"

installExt = @["nim"]

# Dependencies

requires "nim >= 1.6.4"
requires "cligen"

requires "ytextractor >= 1.1.1"
requires "util"
