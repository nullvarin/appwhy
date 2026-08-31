# Contributing

Contributions are welcome.

## Development environment

- macOS 26.0 or later
- Swift 6.3 or later

Xcode is not required. The Swift toolchain from the Command Line Tools is sufficient.

## Building

```text
swift build
```

## Testing

Run the custom test runner:

```text
swift run AppWhyCoreTestRunner
```

Do not add XCTest imports or require `swift test`.

## Style

Keep the codebase small and focused. Prefer clear naming over comments. Comments should only explain non-obvious system behavior.

The project intentionally avoids third-party dependencies.

## Scope

Before adding a feature, consider whether it helps explain how macOS sees or treats an application. If not, it likely does not belong in appwhy.
