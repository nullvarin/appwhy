# Installation

appwhy is distributed as a single executable built with SwiftPM.

## Requirements

- macOS 26.0 or later
- Swift 6.3 or later toolchain

Xcode is not required. The Swift toolchain available through the Command Line Tools is sufficient.

## Homebrew

Install using the official tap:

```text
brew tap nullvarin/appwhy
brew install appwhy
```

The formula installs the release binary and places it on `PATH`.

## Manual installation

Clone the repository:

```text
git clone https://github.com/nullvarin/appwhy.git
cd appwhy
```

Build the release binary:

```text
swift build -c release
```

The binary is produced at:

```text
.build/release/appwhy
```

To make it available on `PATH`, copy or symlink it to a suitable directory:

```text
cp .build/release/appwhy /usr/local/bin/appwhy
```

If `/usr/local/bin` is not on `PATH` or is not writable, choose another directory and add it to your shell configuration.

## Verifying the installation

Confirm the version:

```text
appwhy --version
```

Expected output:

```text
appwhy 0.1.0
```

## Uninstalling

For Homebrew:

```text
brew uninstall appwhy
brew untap nullvarin/appwhy
```

For manual installation, remove the copied or symlinked binary.
