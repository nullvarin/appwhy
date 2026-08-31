import Foundation

enum OutputFormat {
    case text
    case json
}

enum Command {
    case inspect(target: String, format: OutputFormat, verbose: Bool)
    case verify(target: String, format: OutputFormat, verbose: Bool)
    case explain(target: String, format: OutputFormat, verbose: Bool)
    case help
    case version
}

enum CommandParseError: LocalizedError {
    case missingCommand
    case unknownCommand(String)
    case missingTarget(String)
    case unexpectedArgument(String)
    case unknownOption(String)
    case invalidFormat(String)

    var errorDescription: String? {
        switch self {
        case .missingCommand:
            return "Missing command. Use --help for usage."
        case .unknownCommand(let command):
            return "Unknown command: \(command). Use --help for usage."
        case .missingTarget(let command):
            return "Command \(command) requires a target app path or bundle identifier."
        case .unexpectedArgument(let argument):
            return "Unexpected argument: \(argument)"
        case .unknownOption(let option):
            return "Unknown option: \(option)"
        case .invalidFormat(let value):
            return "Invalid output format: \(value). Use text or json."
        }
    }
}

struct CommandParser {
    static func parse(_ arguments: [String]) throws -> Command {
        guard !arguments.isEmpty else {
            throw CommandParseError.missingCommand
        }

        switch arguments[0] {
        case "--help", "-h":
            return .help
        case "--version", "-V":
            return .version
        case "inspect", "verify", "explain":
            let subcommand = arguments[0]
            var rest = Array(arguments.dropFirst())
            var target: String?
            var format: OutputFormat = .text
            var verbose = false

            while !rest.isEmpty {
                let arg = rest.removeFirst()
                if arg == "--format" || arg == "-f" {
                    guard !rest.isEmpty else {
                        throw CommandParseError.invalidFormat("missing value")
                    }
                    let formatValue = rest.removeFirst()
                    switch formatValue {
                    case "text":
                        format = .text
                    case "json":
                        format = .json
                    default:
                        throw CommandParseError.invalidFormat(formatValue)
                    }
                } else if arg.hasPrefix("--format=") {
                    let value = String(arg.dropFirst("--format=".count))
                    switch value {
                    case "text":
                        format = .text
                    case "json":
                        format = .json
                    default:
                        throw CommandParseError.invalidFormat(value)
                    }
                } else if arg == "--verbose" || arg == "-v" {
                    verbose = true
                } else if arg.hasPrefix("-") {
                    throw CommandParseError.unknownOption(arg)
                } else if target == nil {
                    target = arg
                } else {
                    throw CommandParseError.unexpectedArgument(arg)
                }
            }

            guard let target = target else {
                throw CommandParseError.missingTarget(subcommand)
            }

            switch subcommand {
            case "inspect":
                return .inspect(target: target, format: format, verbose: verbose)
            case "verify":
                return .verify(target: target, format: format, verbose: verbose)
            case "explain":
                return .explain(target: target, format: format, verbose: verbose)
            default:
                throw CommandParseError.unknownCommand(subcommand)
            }
        default:
            throw CommandParseError.unknownCommand(arguments[0])
        }
    }
}
