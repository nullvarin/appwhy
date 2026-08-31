import Foundation

public enum VerificationState: String, Sendable, Codable {
    case valid
    case warning
    case failed
    case notVerifiable
    case notApplicable
}

public struct VerificationCheck: Identifiable, Sendable, Codable {
    public let id: String
    public let title: String
    public let state: VerificationState
    public let detail: String

    public init(id: String, title: String, state: VerificationState, detail: String) {
        self.id = id
        self.title = title
        self.state = state
        self.detail = detail
    }
}

public struct VerificationEngine {
    public static func verify(snapshot: DiagnosticSnapshot) -> [VerificationCheck] {
        let evidence = snapshot.evidence
        var checks: [VerificationCheck] = []

        let bundleLoadable = evidence.first { $0.id == "bundle.loadable" }
        if let loadable = bundleLoadable, case .bool(let value) = loadable.value {
            if value {
                checks.append(VerificationCheck(id: "bundle.loadable", title: "Bundle loadable", state: .valid, detail: "The bundle loaded successfully."))
            } else {
                checks.append(VerificationCheck(id: "bundle.loadable", title: "Bundle loadable", state: .failed, detail: "The bundle could not be loaded."))
            }
        } else {
            checks.append(VerificationCheck(id: "bundle.loadable", title: "Bundle loadable", state: .notVerifiable, detail: "Bundle loading information is not available."))
        }

        let executableExists = evidence.first { $0.id == "bundle.primaryExecutable.exists" }
        if let executable = executableExists {
            switch executable.value {
            case .bool(let exists):
                if exists {
                    checks.append(VerificationCheck(id: "bundle.primaryExecutable.exists", title: "Primary executable exists", state: .valid, detail: "The primary executable exists at the expected location."))
                } else {
                    checks.append(VerificationCheck(id: "bundle.primaryExecutable.exists", title: "Primary executable exists", state: .failed, detail: "The primary executable is missing from Contents/MacOS."))
                }
            case .absent:
                checks.append(VerificationCheck(id: "bundle.primaryExecutable.exists", title: "Primary executable exists", state: .notVerifiable, detail: "CFBundleExecutable is not present, so the primary executable location cannot be determined."))
            default:
                checks.append(VerificationCheck(id: "bundle.primaryExecutable.exists", title: "Primary executable exists", state: .notVerifiable, detail: "The primary executable existence could not be determined from available evidence."))
            }
        } else {
            checks.append(VerificationCheck(id: "bundle.primaryExecutable.exists", title: "Primary executable exists", state: .notVerifiable, detail: "No primary executable evidence is available."))
        }

        let signaturePresent = evidence.first { $0.id == "signature.present" }
        if let present = signaturePresent, case .bool(let value) = present.value {
            if value {
                let signatureValid = evidence.first { $0.id == "signature.valid" }
                if let valid = signatureValid, case .bool(let validValue) = valid.value {
                    if validValue {
                        checks.append(VerificationCheck(id: "signature.valid", title: "Code signature valid", state: .valid, detail: "The code signature is present and passed static validation."))
                    } else {
                        checks.append(VerificationCheck(id: "signature.valid", title: "Code signature valid", state: .failed, detail: "The code signature is present but failed static validation."))
                    }
                } else {
                    checks.append(VerificationCheck(id: "signature.valid", title: "Code signature valid", state: .notVerifiable, detail: "Code signature validation information is not available."))
                }
            } else {
                checks.append(VerificationCheck(id: "signature.present", title: "Code signature present", state: .failed, detail: "The application bundle has no code signature."))
            }
        } else {
            checks.append(VerificationCheck(id: "signature.present", title: "Code signature present", state: .notVerifiable, detail: "Code signature presence could not be determined."))
        }

        let bundleIdentifier = evidence.first { $0.id == "infoPlist.CFBundleIdentifier" }
        if let identifier = bundleIdentifier {
            switch identifier.value {
            case .string(let value):
                if value.isEmpty {
                    checks.append(VerificationCheck(id: "infoPlist.CFBundleIdentifier", title: "Bundle identifier present", state: .warning, detail: "CFBundleIdentifier is empty."))
                } else {
                    checks.append(VerificationCheck(id: "infoPlist.CFBundleIdentifier", title: "Bundle identifier present", state: .valid, detail: "CFBundleIdentifier is present."))
                }
            case .absent:
                checks.append(VerificationCheck(id: "infoPlist.CFBundleIdentifier", title: "Bundle identifier present", state: .warning, detail: "CFBundleIdentifier is missing."))
            default:
                checks.append(VerificationCheck(id: "infoPlist.CFBundleIdentifier", title: "Bundle identifier present", state: .notVerifiable, detail: "CFBundleIdentifier has an unexpected type."))
            }
        } else {
            checks.append(VerificationCheck(id: "infoPlist.CFBundleIdentifier", title: "Bundle identifier present", state: .notVerifiable, detail: "CFBundleIdentifier evidence is not available."))
        }

        if let pathMatches = evidence.first(where: { $0.id == "launchServices.pathMatches" }) {
            switch pathMatches.value {
            case .bool(let matches):
                if matches {
                    checks.append(VerificationCheck(id: "launchServices.pathMatches", title: "Launch Services path matches", state: .valid, detail: "The registered application path matches the requested path."))
                } else {
                    checks.append(VerificationCheck(id: "launchServices.pathMatches", title: "Launch Services path matches", state: .warning, detail: "The registered application path differs from the requested path."))
                }
            default:
                checks.append(VerificationCheck(id: "launchServices.pathMatches", title: "Launch Services path matches", state: .notVerifiable, detail: "Launch Services path matching could not be determined."))
            }
        } else {
            checks.append(VerificationCheck(id: "launchServices.pathMatches", title: "Launch Services path matches", state: .notApplicable, detail: "The target was not resolved from a direct app path, so path matching is not applicable."))
        }

        return checks
    }

    public static func generateReport(snapshot: DiagnosticSnapshot) -> VerificationReport {
        let checks = verify(snapshot: snapshot)
        return VerificationReport(target: snapshot.target, collectedAt: snapshot.collectedAt, checks: checks)
    }
}
