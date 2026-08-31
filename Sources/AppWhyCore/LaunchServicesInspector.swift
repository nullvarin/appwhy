import Foundation
import AppKit

public struct LaunchServicesInspector {
    @MainActor
    public static func inspect(target: AppTarget) -> [Evidence] {
        var evidence: [Evidence] = []

        guard let bundleIdentifier = target.bundleIdentifier else {
            evidence.append(
                Evidence(
                    id: "launchServices.resolvedURL",
                    category: .launchServices,
                    label: "Resolved application URL",
                    value: .absent,
                    source: "NSWorkspace"
                )
            )
            return evidence
        }

        if let resolvedURL = NSWorkspace.shared.urlForApplication(withBundleIdentifier: bundleIdentifier) {
            evidence.append(
                Evidence(
                    id: "launchServices.resolvedURL",
                    category: .launchServices,
                    label: "Resolved application URL",
                    value: .string(resolvedURL.path),
                    source: "NSWorkspace"
                )
            )

            if case .path(let requestedPath) = target.source {
                let matches = resolvedURL.standardizedFileURL.path == requestedPath.standardizedFileURL.path
                evidence.append(
                    Evidence(
                        id: "launchServices.pathMatches",
                        category: .launchServices,
                        label: "Registered path matches requested path",
                        value: .bool(matches),
                        source: "NSWorkspace"
                    )
                )
            }
        } else {
            evidence.append(
                Evidence(
                    id: "launchServices.resolvedURL",
                    category: .launchServices,
                    label: "Resolved application URL",
                    value: .absent,
                    source: "NSWorkspace"
                )
            )
        }

        return evidence
    }
}
