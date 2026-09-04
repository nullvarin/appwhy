# Changelog

## 0.2.0

- Migrated tests from the custom `AppWhyCoreTestRunner` to XCTest using a standard SwiftPM test target
- Removed the custom test runner target and source
- Added XCTest coverage for target resolution, bundle inspection, code signing, launch services, verification, explanation, and JSON serialization
- Replaced environment-dependent tests with controlled temporary fixtures
- Updated development documentation to use `swift test`
- Bumped CLI version to 0.2.0
- Preserved existing product behavior and public APIs

## 0.1.0

Initial release.

- `inspect` command for bundle, Info.plist, code signature, entitlement, and Launch Services evidence
- `verify` command with deterministic checks and distinct verification states
- `explain` command with a small set of high-confidence findings
- Text and JSON output formats
- SwiftPM-only build with no Xcode requirement
- Custom test runner independent of XCTest
- macOS 26.0 or later
