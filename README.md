# runhs

`runhs` is a wrapper around `runhaskell` that will automatically use a Cabal sandbox with [`turtle`](https://hackage.haskell.org/package/turtle) ([blog post](http://www.haskellforall.com/2015/01/use-haskell-for-shell-scripting.html)).

**Note:** This is an experiment. Only tested with OS X 10.10.2, GHC 7.8.3, and cabal 1.22 so far.


## Requirements

* `curl` (for automated installs only)
* `git` (for automated installs only)
* `runhaskell`
* `cabal`


## Installation

* `curl https://raw.githubusercontent.com/danclien/runhs/master/bin/install.sh | sh`
* Put `runhs` into your `PATH`. Default location is `$HOME/.runhs/bin`.
* Restart your shell to use your new `PATH`.

### Installing to a different directory (experimental)

Set your `RUNHS_DIR` environment variable before running the install script to the
location you want the `runhs` installed.

### Adding more libaries

`runhs-install` is an alias to `cabal install` that will run in this sandbox.

#### Example

```
runhs-install optparse-applicative
```

## Usage

To run a Haskell script directly:

* Include `#!/usr/bin/env runhs` at the top of the script
* Make the script executable using `chmod +x`


## Example

### `test.hs`
```
#!/usr/bin/env runhs

{-# LANGUAGE OverloadedStrings #-}

import Turtle

main = echo "Hello, world!"
```

### Output
```
❯❯❯ ./test.hs
Hello, world!
```

## Uninstall

* Delete `$HOME/.runhs`
* Remove `$HOME/.runhs/bin` from your `PATH`

## TODO

* Add notes on how to do a manual installation.
* Test on other operating systems to make sure it works