# Usage

appwhy is invoked with a subcommand and a target.

## Target resolution

A target can be:

- A path to an `.app` bundle, for example `/Applications/MyApp.app`
- A bundle identifier, for example `com.example.MyApp`

If a path ends with `.app` and exists, appwhy treats it as a direct bundle URL.

Otherwise, appwhy treats the argument as a bundle identifier and resolves it through `NSWorkspace`.

## inspect

Collect and print evidence about the application.

```bash
appwhy inspect /Applications/MyApp.app
appwhy inspect com.example.MyApp
```

Add `--verbose` to see evidence IDs and source descriptions.

Use `--format json` for machine-readable JSON output.

## verify

Run deterministic verification checks.

```bash
appwhy verify /Applications/MyApp.app
```

Example output:

```text
Target: /Applications/MyApp.app
Bundle Identifier: com.example.MyApp
Collected At: 2026-08-31 11:24:24 +0000

Verification Checks:
  [valid] Bundle loadable: The bundle loaded successfully.
  [valid] Primary executable exists: The primary executable exists at the expected location.
  [valid] Code signature valid: The code signature is present and passed static validation.
  [valid] Bundle identifier present: CFBundleIdentifier is present.
  [valid] Launch Services path matches: The registered application path matches the requested path.
```

If any check reports `failed`, the exit code is `1`. Warning and `notVerifiable` checks do not affect the exit code.

## explain

Print deterministic findings based on collected evidence.

```bash
appwhy explain /Applications/MyApp.app
```

If no findings are present, the output reports `No findings.`

Each finding includes:

- severity
- title
- summary
- supporting evidence
- confidence

## JSON output

All commands accept `--format json`.

Example:

```bash
appwhy inspect /Applications/MyApp.app --format json
```

The output is a single JSON object. Dates are encoded using ISO 8601.

## Verbose mode

Pass `--verbose` or `-v` to include additional detail.

For `inspect`, verbose output includes evidence IDs and sources.

For `explain`, verbose output includes the full rationale, confidence, and evidence IDs.

For `verify`, verbose output includes check IDs.

## Help and version

Display help:

```bash
appwhy --help
```

Display version:

```bash
appwhy --version
```
