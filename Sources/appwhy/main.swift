import Foundation
import AppWhyCore

func printHelp() {
    print("""
    appwhy 0.1.0

    Usage:
      appwhy inspect <target> [--format text|json] [--verbose]
      appwhy verify <target> [--format text|json] [--verbose]
      appwhy explain <target> [--format text|json] [--verbose]
      appwhy --help
      appwhy --version

    Commands:
      inspect   Collect and display application evidence.
      verify    Run verification checks and return non-zero if any fail.
      explain   Display deterministic findings with supporting evidence.

    Options:
      --format text|json   Output format (default: text).
      -f text|json         Short form of --format.
      --verbose            Include additional detail.
      -v                   Short form of --verbose.
    """)
}

func printVersion() {
    print("appwhy 0.1.0")
}

let arguments = Array(CommandLine.arguments.dropFirst())

do {
    let command = try CommandParser.parse(arguments)
    switch command {
    case .help:
        printHelp()
        exit(0)
    case .version:
        printVersion()
        exit(0)
    case .inspect(let target, let format, let verbose):
        try InspectCommand.run(target: target, format: format, verbose: verbose)
        exit(0)
    case .verify(let target, let format, let verbose):
        let exitCode = try VerifyCommand.run(target: target, format: format, verbose: verbose)
        exit(exitCode)
    case .explain(let target, let format, let verbose):
        try ExplainCommand.run(target: target, format: format, verbose: verbose)
        exit(0)
    }
} catch let error as CommandParseError {
    FileHandle.standardError.write(Data("Error: \(error.localizedDescription)\n".utf8))
    exit(2)
} catch TargetResolutionError.targetNotFound {
    FileHandle.standardError.write(Data("Error: target not found.\n".utf8))
    exit(3)
} catch {
    FileHandle.standardError.write(Data("Error: \(error.localizedDescription)\n".utf8))
    exit(4)
}
