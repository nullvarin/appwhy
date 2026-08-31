import Foundation
import AppKit

public enum TargetResolutionError: Error, CustomStringConvertible {
    case targetNotFound(String)
    case cannotResolveBundleIdentifier(String)

    public var description: String {
        switch self {
        case .targetNotFound(let value):
            return "No application found for target: \(value)"
        case .cannotResolveBundleIdentifier(let identifier):
            return "Could not resolve bundle identifier: \(identifier)"
        }
    }
}

public struct TargetResolver {
    @MainActor
    public static func resolve(_ input: String) throws -> AppTarget {
        let fileManager = FileManager.default

        if input.hasSuffix(".app") {
            let inputURL = URL(fileURLWithPath: input)
            if fileManager.fileExists(atPath: inputURL.path) {
                let bundleIdentifier = bundleIdentifier(at: inputURL)
                return AppTarget(
                    source: .path(inputURL),
                    url: inputURL,
                    bundleIdentifier: bundleIdentifier
                )
            }
        }

        if let url = NSWorkspace.shared.urlForApplication(withBundleIdentifier: input) {
            let bundleIdentifier = bundleIdentifier(at: url) ?? input
            return AppTarget(
                source: .resolvedPath(url, requestedBundleIdentifier: input),
                url: url,
                bundleIdentifier: bundleIdentifier
            )
        }

        throw TargetResolutionError.targetNotFound(input)
    }

    private static func bundleIdentifier(at url: URL) -> String? {
        return Bundle(url: url)?.bundleIdentifier
    }
}
