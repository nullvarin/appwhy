# appwhy

appwhy is a native macOS command-line tool that explains how macOS sees and treats an application.

It inspects an app bundle, its Info.plist, code signature, entitlements, and Launch Services registration. It then produces deterministic findings that correlate that evidence. The goal is to help developers understand why macOS may behave differently for a specific app build.

appwhy is not a generic system information tool. It is focused on application diagnostics.

## Supported macOS version

appwhy requires macOS 26.0 or later. It uses modern public Apple APIs and does not support older macOS releases.

## Installation

### Homebrew

Install appwhy with Homebrew using the official tap:

```text
brew tap nullvarin/appwhy
brew install appwhy
```

### Manual installation

Clone the repository and build a release binary with SwiftPM:

```text
git clone https://github.com/nullvarin/appwhy.git
cd appwhy
swift build -c release
```

The resulting executable is located at:

```text
.build/release/appwhy
```

Copy or symlink it into a directory on your `PATH`, for example:

```text
cp .build/release/appwhy /usr/local/bin/appwhy
```

Adjust the destination to match your preferred local bin directory.

## Usage

Run appwhy with one of the supported subcommands:

```text
appwhy inspect <target> [--format text|json] [--verbose]
appwhy verify <target> [--format text|json] [--verbose]
appwhy explain <target> [--format text|json] [--verbose]
```

`<target>` can be an absolute or relative path to an `.app` bundle, or a bundle identifier such as `com.example.MyApp`.

When a bundle identifier is supplied, appwhy resolves it through Launch Services.

### Commands

#### inspect

Collects and displays application evidence. This includes bundle structure, key Info.plist values, code signature details, entitlements, and Launch Services resolution.

#### verify

Runs a set of deterministic verification checks. Each check reports one of these states:

- `valid`
- `warning`
- `failed`
- `notVerifiable`
- `notApplicable`

`verify` exits with status `0` when no check reports `failed`. It exits with status `1` when at least one check reports `failed`.

#### explain

Produces a small set of high-confidence, evidence-backed findings. Each finding includes a title, summary, rationale, supporting evidence, and confidence level.

### Output formats

The default output format is human-readable text. Use `--format json` for machine-readable output.

JSON output is derived from the same underlying diagnostic snapshot as text output.

### Verbose output

Pass `--verbose` or `-v` to include additional detail such as evidence IDs, sources, and rationale.

## Exit codes

- `0`: command succeeded; for `verify`, no failed findings
- `1`: `verify` found at least one failed finding
- `2`: command-line usage error
- `3`: target could not be resolved
- `4`: evidence collection failed in a way that prevented meaningful output

## Troubleshooting

### `swift build` fails with missing XCTest

This project intentionally does not use XCTest because it must work without Xcode. Tests are run using a small custom test runner:

```text
swift run AppWhyCoreTestRunner
```

If you see an error about `XCTest`, make sure you are not running `swift test`. Use the custom runner command instead.

### Target not found

If appwhy exits with code `3`, the supplied target could not be resolved as a path or bundle identifier. Check that the path exists and ends with `.app`, or that the bundle identifier is correct.

### Code signature validation reports unexpected failures

appwhy uses Apple's public Security framework APIs with `kSecCSDefaultFlags`. It does not add additional validation flags. Nested code or unusual bundle layouts may still produce results that require manual inspection.

## Development

Build the debug executable:

```text
swift build
```

Run the test runner:

```text
swift run AppWhyCoreTestRunner
```

Build a release executable:

```text
swift build -c release
```

The project does not require Xcode. Swift and the Command Line Tools are sufficient.

## Architecture

The project is a SwiftPM package with two main targets:

- `AppWhyCore`: inspection, verification, and explanation logic
- `appwhy`: command-line interface and output formatting

An additional `AppWhyCoreTestRunner` target provides a lightweight test runner that does not depend on XCTest.

See `docs/architecture.md` for more detail.

## Contributing

See `CONTRIBUTING.md` for contribution guidance.

## License

appwhy is released under the MIT License. See `LICENSE` for details.
