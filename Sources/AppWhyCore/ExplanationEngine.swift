import Foundation

public struct ExplanationEngine {
    public static func generateFindings(evidence: [Evidence], target: AppTarget) -> [Finding] {
        var findings: [Finding] = []

        if let loadable = evidence.first(where: { $0.id == "bundle.loadable" }), case .bool(let value) = loadable.value, !value {
            findings.append(
                Finding(
                    id: "finding.bundle.notLoadable",
                    severity: .error,
                    title: "Bundle is not loadable",
                    summary: "The application bundle could not be loaded.",
                    rationale: "The bundle at \(target.url.path) could not be initialized by Foundation. This usually indicates a missing or invalid Info.plist.",
                    evidenceIDs: ["bundle.loadable"],
                    confidence: .high
                )
            )
        }

        if let executableExists = evidence.first(where: { $0.id == "bundle.primaryExecutable.exists" }), case .bool(let value) = executableExists.value, !value {
            findings.append(
                Finding(
                    id: "finding.bundle.primaryExecutableMissing",
                    severity: .error,
                    title: "Primary executable missing",
                    summary: "The bundle declares an executable, but it does not exist at Contents/MacOS/.",
                    rationale: "The CFBundleExecutable value in Info.plist does not correspond to a file at the expected location. macOS will be unable to launch this application.",
                    evidenceIDs: ["bundle.primaryExecutable.exists", "infoPlist.CFBundleExecutable"],
                    confidence: .high
                )
            )
        }

        if let signatureValid = evidence.first(where: { $0.id == "signature.valid" }), case .bool(let value) = signatureValid.value, !value {
            findings.append(
                Finding(
                    id: "finding.signature.invalid",
                    severity: .error,
                    title: "Code signature invalid",
                    summary: "The application's code signature failed static validation.",
                    rationale: "SecStaticCodeCheckValidityWithErrors reported an invalid code signature. macOS may refuse to launch the application or may apply restrictions.",
                    evidenceIDs: ["signature.valid", "signature.present"],
                    confidence: .high
                )
            )
        }

        if let bundleIdentifier = evidence.first(where: { $0.id == "infoPlist.CFBundleIdentifier" }) {
            switch bundleIdentifier.value {
            case .string(let value) where value.isEmpty:
                findings.append(
                    Finding(
                        id: "finding.bundleIdentifier.empty",
                        severity: .warning,
                        title: "Bundle identifier is empty",
                        summary: "CFBundleIdentifier exists but is empty.",
                        rationale: "An empty bundle identifier may prevent Launch Services from registering the application correctly.",
                        evidenceIDs: ["infoPlist.CFBundleIdentifier"],
                        confidence: .high
                    )
                )
            case .absent:
                findings.append(
                    Finding(
                        id: "finding.bundleIdentifier.missing",
                        severity: .warning,
                        title: "Bundle identifier missing",
                        summary: "The application has no CFBundleIdentifier.",
                        rationale: "macOS relies on CFBundleIdentifier to identify and track the application. Its absence may cause inconsistent Launch Services behavior.",
                        evidenceIDs: ["infoPlist.CFBundleIdentifier"],
                        confidence: .high
                    )
                )
            default:
                break
            }
        }

        if let pathMatches = evidence.first(where: { $0.id == "launchServices.pathMatches" }), case .bool(let value) = pathMatches.value, !value {
            findings.append(
                Finding(
                    id: "finding.launchServices.pathMismatch",
                    severity: .warning,
                    title: "Registered path differs from requested path",
                    summary: "Launch Services has a different app path registered for the same bundle identifier.",
                    rationale: "The requested app bundle exists, but NSWorkspace resolved the same bundle identifier to a different application URL. macOS may launch the other copy when the identifier is used.",
                    evidenceIDs: ["launchServices.resolvedURL", "launchServices.pathMatches", "infoPlist.CFBundleIdentifier"],
                    confidence: .high
                )
            )
        }

        return findings
    }
}
