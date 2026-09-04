# Installation

appwhy is distributed as a single executable built with SwiftPM.

## Requirements

- macOS 26.0 or later
- Swift 6.3.3

Xcode is not required for building the executable. XCTest tests use the standard SwiftPM test workflow.

## Homebrew

Install using the official tap:

```bash
brew tap nullvarin/appwhy
brew install appwhy
```

The formula installs the release binary and places it on `PATH`.

## Manual installation

Clone the repository:

```bash
git clone https://github.com/nullvarin/appwhy.git
cd appwhy
```

Build the release binary:

```bash
swift build -c release
```

The binary is produced at:

```text
.build/release/appwhy
```

To make it available on `PATH`, copy or symlink it to a directory that is already in your `PATH`. Common locations include `/usr/local/bin` and `$HOME/.local/bin`. For example:

```bash
cp .build/release/appwhy /usr/local/bin/appwhy
```

If the destination is not on `PATH` or is not writable, choose another directory and add it to your shell configuration.

## Verifying the installation

Confirm the version:

```bash
appwhy --version
```

Expected output:

```text
appwhy 0.2.0
```

## Uninstalling

For Homebrew:

```bash
brew uninstall appwhy
brew untap nullvarin/appwhy
```

For manual installation, remove the copied or symlinked binary.
