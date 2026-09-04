# Contributing

Contributions are welcome.

## Development environment

- macOS 26.0 or later
- Swift 6.3.3

The project uses SwiftPM and does not require an Xcode project.

## Building

```bash
swift build
```

## Testing

Run the XCTest suite:

```bash
swift test
```

Do not add custom test runners. Use XCTest for new tests.

## Style

Keep the codebase small and focused. Prefer clear naming over comments. Comments should only explain non-obvious system behavior.

The project intentionally avoids third-party dependencies.

## Scope

Before adding a feature, consider whether it helps explain how macOS sees or treats an application. If not, it likely does not belong in appwhy.
