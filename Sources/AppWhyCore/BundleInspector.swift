import Foundation

public struct BundleInspector {
    public static func inspect(target: AppTarget) -> [Evidence] {
        var evidence: [Evidence] = []

        let fileManager = FileManager.default
        let bundleURL = target.url

        let infoPlistExists = fileManager.fileExists(atPath: bundleURL.appendingPathComponent("Contents/Info.plist").path)
        evidence.append(
            Evidence(
                id: "bundle.infoPlist.exists",
                category: .bundle,
                label: "Info.plist exists",
                value: .bool(infoPlistExists),
                source: "Filesystem"
            )
        )

        guard let bundle = Bundle(url: bundleURL) else {
            evidence.append(
                Evidence(
                    id: "bundle.loadable",
                    category: .bundle,
                    label: "Bundle loadable",
                    value: .bool(false),
                    source: "Bundle"
                )
            )
            return evidence
        }

        evidence.append(
            Evidence(
                id: "bundle.loadable",
                category: .bundle,
                label: "Bundle loadable",
                value: .bool(true),
                source: "Bundle"
            )
        )

        let infoKeys: [(String, String)] = [
            ("CFBundleIdentifier", "infoPlist.CFBundleIdentifier"),
            ("CFBundleName", "infoPlist.CFBundleName"),
            ("CFBundleDisplayName", "infoPlist.CFBundleDisplayName"),
            ("CFBundleExecutable", "infoPlist.CFBundleExecutable"),
            ("CFBundlePackageType", "infoPlist.CFBundlePackageType"),
            ("CFBundleShortVersionString", "infoPlist.CFBundleShortVersionString"),
            ("CFBundleVersion", "infoPlist.CFBundleVersion"),
            ("LSMinimumSystemVersion", "infoPlist.LSMinimumSystemVersion")
        ]

        for (key, id) in infoKeys {
            if let value = bundle.object(forInfoDictionaryKey: key) {
                if let stringValue = value as? String {
                    evidence.append(
                        Evidence(
                            id: id,
                            category: .infoPlist,
                            label: key,
                            value: .string(stringValue),
                            source: "Info.plist"
                        )
                    )
                } else {
                    evidence.append(
                        Evidence(
                            id: id,
                            category: .infoPlist,
                            label: key,
                            value: .absent,
                            source: "Info.plist"
                        )
                    )
                }
            } else {
                evidence.append(
                    Evidence(
                        id: id,
                        category: .infoPlist,
                        label: key,
                        value: .absent,
                        source: "Info.plist"
                    )
                )
            }
        }

        if let executableName = bundle.object(forInfoDictionaryKey: "CFBundleExecutable") as? String {
            let executableURL = bundleURL.appendingPathComponent("Contents/MacOS").appendingPathComponent(executableName)
            let executableExists = fileManager.fileExists(atPath: executableURL.path)
            evidence.append(
                Evidence(
                    id: "bundle.primaryExecutable.exists",
                    category: .bundle,
                    label: "Primary executable exists",
                    value: .bool(executableExists),
                    source: "Filesystem"
                )
            )
        } else {
            evidence.append(
                Evidence(
                    id: "bundle.primaryExecutable.exists",
                    category: .bundle,
                    label: "Primary executable exists",
                    value: .absent,
                    source: "Filesystem"
                )
            )
        }

        return evidence
    }
}
