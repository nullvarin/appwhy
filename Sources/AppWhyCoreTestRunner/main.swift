import Foundation
import AppWhyCore

@MainActor
var failures: [String] = []

@MainActor
func check(_ condition: Bool, _ message: String) {
    if !condition {
        failures.append(message)
    }
}

@MainActor
func testBundleInspectorValidBundle() {
    let tempDir = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
    let appURL = tempDir.appendingPathComponent("Test.app")
    let contentsURL = appURL.appendingPathComponent("Contents")
    let macOSURL = contentsURL.appendingPathComponent("MacOS")
    let infoPlistURL = contentsURL.appendingPathComponent("Info.plist")
    let executableName = "TestExecutable"

    do {
        try FileManager.default.createDirectory(at: macOSURL, withIntermediateDirectories: true)
        FileManager.default.createFile(atPath: macOSURL.appendingPathComponent(executableName).path, contents: Data())

        let infoPlist: [String: Any] = [
            "CFBundleIdentifier": "com.example.test",
            "CFBundleExecutable": executableName
        ]
        let plistData = try PropertyListSerialization.data(fromPropertyList: infoPlist, format: .xml, options: 0)
        try plistData.write(to: infoPlistURL)
        defer { try? FileManager.default.removeItem(at: tempDir) }

        let target = AppTarget(source: .path(appURL), url: appURL, bundleIdentifier: "com.example.test")
        let evidence = BundleInspector.inspect(target: target)

        check(evidenceContainsBool(evidence, id: "bundle.infoPlist.exists", expected: true), "testBundleInspectorValidBundle: Info.plist should exist")
        check(evidenceContainsBool(evidence, id: "bundle.loadable", expected: true), "testBundleInspectorValidBundle: Bundle should be loadable")
        check(evidenceContainsBool(evidence, id: "bundle.primaryExecutable.exists", expected: true), "testBundleInspectorValidBundle: Primary executable should exist")
    } catch {
        failures.append("testBundleInspectorValidBundle threw error: \(error)")
    }
}

@MainActor
func testBundleInspectorMissingExecutable() {
    let tempDir = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
    let appURL = tempDir.appendingPathComponent("Test.app")
    let contentsURL = appURL.appendingPathComponent("Contents")
    let macOSURL = contentsURL.appendingPathComponent("MacOS")
    let infoPlistURL = contentsURL.appendingPathComponent("Info.plist")
    let executableName = "MissingExecutable"

    do {
        try FileManager.default.createDirectory(at: macOSURL, withIntermediateDirectories: true)

        let infoPlist: [String: Any] = [
            "CFBundleIdentifier": "com.example.test",
            "CFBundleExecutable": executableName
        ]
        let plistData = try PropertyListSerialization.data(fromPropertyList: infoPlist, format: .xml, options: 0)
        try plistData.write(to: infoPlistURL)
        defer { try? FileManager.default.removeItem(at: tempDir) }

        let target = AppTarget(source: .path(appURL), url: appURL, bundleIdentifier: "com.example.test")
        let evidence = BundleInspector.inspect(target: target)

        check(evidenceContainsBool(evidence, id: "bundle.primaryExecutable.exists", expected: false), "testBundleInspectorMissingExecutable: Primary executable should not exist")
    } catch {
        failures.append("testBundleInspectorMissingExecutable threw error: \(error)")
    }
}

@MainActor
func testVerificationAllValid() {
    let target = AppTarget(source: .path(URL(fileURLWithPath: "/tmp/Test.app")), url: URL(fileURLWithPath: "/tmp/Test.app"), bundleIdentifier: "com.example.test")
    let evidence: [Evidence] = [
        Evidence(id: "bundle.loadable", category: .bundle, label: "Bundle loadable", value: .bool(true), source: "Bundle"),
        Evidence(id: "bundle.primaryExecutable.exists", category: .bundle, label: "Primary executable exists", value: .bool(true), source: "Filesystem"),
        Evidence(id: "signature.present", category: .signature, label: "Code signature present", value: .bool(true), source: "Security"),
        Evidence(id: "signature.valid", category: .signature, label: "Code signature valid", value: .bool(true), source: "Security"),
        Evidence(id: "infoPlist.CFBundleIdentifier", category: .infoPlist, label: "CFBundleIdentifier", value: .string("com.example.test"), source: "Info.plist"),
        Evidence(id: "launchServices.pathMatches", category: .launchServices, label: "Path matches", value: .bool(true), source: "NSWorkspace")
    ]
    let snapshot = DiagnosticSnapshot(target: target, evidence: evidence, findings: [])
    let checks = VerificationEngine.verify(snapshot: snapshot)

    check(checks.first { $0.id == "bundle.loadable" }?.state == .valid, "testVerificationAllValid: bundle.loadable should be valid")
    check(checks.first { $0.id == "bundle.primaryExecutable.exists" }?.state == .valid, "testVerificationAllValid: primaryExecutable should be valid")
    check(checks.first { $0.id == "signature.valid" }?.state == .valid, "testVerificationAllValid: signature.valid should be valid")
    check(checks.first { $0.id == "infoPlist.CFBundleIdentifier" }?.state == .valid, "testVerificationAllValid: bundle identifier should be valid")
    check(checks.first { $0.id == "launchServices.pathMatches" }?.state == .valid, "testVerificationAllValid: path match should be valid")
}

@MainActor
func testVerificationFailed() {
    let target = AppTarget(source: .path(URL(fileURLWithPath: "/tmp/Test.app")), url: URL(fileURLWithPath: "/tmp/Test.app"), bundleIdentifier: "com.example.test")
    let evidence: [Evidence] = [
        Evidence(id: "bundle.loadable", category: .bundle, label: "Bundle loadable", value: .bool(false), source: "Bundle"),
        Evidence(id: "bundle.primaryExecutable.exists", category: .bundle, label: "Primary executable exists", value: .bool(false), source: "Filesystem"),
        Evidence(id: "signature.present", category: .signature, label: "Code signature present", value: .bool(false), source: "Security"),
        Evidence(id: "infoPlist.CFBundleIdentifier", category: .infoPlist, label: "CFBundleIdentifier", value: .absent, source: "Info.plist")
    ]
    let snapshot = DiagnosticSnapshot(target: target, evidence: evidence, findings: [])
    let checks = VerificationEngine.verify(snapshot: snapshot)

    check(checks.first { $0.id == "bundle.loadable" }?.state == .failed, "testVerificationFailed: bundle.loadable should be failed")
    check(checks.first { $0.id == "bundle.primaryExecutable.exists" }?.state == .failed, "testVerificationFailed: primaryExecutable should be failed")
    check(checks.first { $0.id == "signature.present" }?.state == .failed, "testVerificationFailed: signature.present should be failed")
    check(checks.first { $0.id == "infoPlist.CFBundleIdentifier" }?.state == .warning, "testVerificationFailed: bundle identifier should be warning")
}

@MainActor
func testVerificationNotVerifiable() {
    let target = AppTarget(source: .path(URL(fileURLWithPath: "/tmp/Test.app")), url: URL(fileURLWithPath: "/tmp/Test.app"), bundleIdentifier: nil)
    let evidence: [Evidence] = [
        Evidence(id: "bundle.loadable", category: .bundle, label: "Bundle loadable", value: .absent, source: "Bundle"),
        Evidence(id: "bundle.primaryExecutable.exists", category: .bundle, label: "Primary executable exists", value: .absent, source: "Filesystem"),
        Evidence(id: "signature.present", category: .signature, label: "Code signature present", value: .absent, source: "Security"),
        Evidence(id: "infoPlist.CFBundleIdentifier", category: .infoPlist, label: "CFBundleIdentifier", value: .absent, source: "Info.plist")
    ]
    let snapshot = DiagnosticSnapshot(target: target, evidence: evidence, findings: [])
    let checks = VerificationEngine.verify(snapshot: snapshot)

    check(checks.first { $0.id == "bundle.loadable" }?.state == .notVerifiable, "testVerificationNotVerifiable: bundle.loadable should be notVerifiable")
    check(checks.first { $0.id == "bundle.primaryExecutable.exists" }?.state == .notVerifiable, "testVerificationNotVerifiable: primaryExecutable should be notVerifiable")
    check(checks.first { $0.id == "signature.present" }?.state == .notVerifiable, "testVerificationNotVerifiable: signature.present should be notVerifiable")
    check(checks.first { $0.id == "launchServices.pathMatches" }?.state == .notApplicable, "testVerificationNotVerifiable: pathMatches should be notApplicable")
}

@MainActor
func testExplanationMissingBundleIdentifier() {
    let evidence: [Evidence] = [
        Evidence(id: "infoPlist.CFBundleIdentifier", category: .infoPlist, label: "CFBundleIdentifier", value: .absent, source: "Info.plist")
    ]
    let target = AppTarget(source: .path(URL(fileURLWithPath: "/tmp/Test.app")), url: URL(fileURLWithPath: "/tmp/Test.app"), bundleIdentifier: nil)
    let findings = ExplanationEngine.generateFindings(evidence: evidence, target: target)

    check(findings.contains { $0.id == "finding.bundleIdentifier.missing" && $0.severity == .warning && $0.confidence == .high }, "testExplanationMissingBundleIdentifier: missing identifier finding should be warning/high")
}

@MainActor
func testExplanationInvalidCodeSignature() {
    let evidence: [Evidence] = [
        Evidence(id: "signature.present", category: .signature, label: "Code signature present", value: .bool(true), source: "Security"),
        Evidence(id: "signature.valid", category: .signature, label: "Code signature valid", value: .bool(false), source: "Security")
    ]
    let target = AppTarget(source: .path(URL(fileURLWithPath: "/tmp/Test.app")), url: URL(fileURLWithPath: "/tmp/Test.app"), bundleIdentifier: "com.example.test")
    let findings = ExplanationEngine.generateFindings(evidence: evidence, target: target)

    check(findings.contains { $0.id == "finding.signature.invalid" && $0.severity == .error && $0.confidence == .high }, "testExplanationInvalidCodeSignature: invalid signature should be error/high")
}

@MainActor
func testExplanationMissingPrimaryExecutable() {
    let evidence: [Evidence] = [
        Evidence(id: "bundle.primaryExecutable.exists", category: .bundle, label: "Primary executable exists", value: .bool(false), source: "Filesystem"),
        Evidence(id: "infoPlist.CFBundleExecutable", category: .infoPlist, label: "CFBundleExecutable", value: .string("TestExecutable"), source: "Info.plist")
    ]
    let target = AppTarget(source: .path(URL(fileURLWithPath: "/tmp/Test.app")), url: URL(fileURLWithPath: "/tmp/Test.app"), bundleIdentifier: "com.example.test")
    let findings = ExplanationEngine.generateFindings(evidence: evidence, target: target)

    check(findings.contains { $0.id == "finding.bundle.primaryExecutableMissing" && $0.severity == .error && $0.confidence == .high }, "testExplanationMissingPrimaryExecutable: missing executable should be error/high")
}

@MainActor
func testExplanationLaunchServicesPathMismatch() {
    let evidence: [Evidence] = [
        Evidence(id: "launchServices.pathMatches", category: .launchServices, label: "Path matches", value: .bool(false), source: "NSWorkspace"),
        Evidence(id: "launchServices.resolvedURL", category: .launchServices, label: "Resolved URL", value: .string("/other/App.app"), source: "NSWorkspace"),
        Evidence(id: "infoPlist.CFBundleIdentifier", category: .infoPlist, label: "CFBundleIdentifier", value: .string("com.example.test"), source: "Info.plist")
    ]
    let target = AppTarget(source: .path(URL(fileURLWithPath: "/tmp/Test.app")), url: URL(fileURLWithPath: "/tmp/Test.app"), bundleIdentifier: "com.example.test")
    let findings = ExplanationEngine.generateFindings(evidence: evidence, target: target)

    check(findings.contains { $0.id == "finding.launchServices.pathMismatch" && $0.severity == .warning && $0.confidence == .high }, "testExplanationLaunchServicesPathMismatch: path mismatch should be warning/high")
}

@MainActor
private func evidenceContainsBool(_ evidence: [Evidence], id: String, expected: Bool) -> Bool {
    guard let item = evidence.first(where: { $0.id == id }) else { return false }
    if case .bool(let value) = item.value {
        return value == expected
    }
    return false
}

@main
struct TestRunner {
    @MainActor
    static func main() {
        testBundleInspectorValidBundle()
        testBundleInspectorMissingExecutable()
        testVerificationAllValid()
        testVerificationFailed()
        testVerificationNotVerifiable()
        testExplanationMissingBundleIdentifier()
        testExplanationInvalidCodeSignature()
        testExplanationMissingPrimaryExecutable()
        testExplanationLaunchServicesPathMismatch()

        if failures.isEmpty {
            print("All tests passed.")
            exit(0)
        } else {
            print("\(failures.count) test(s) failed:")
            for failure in failures {
                print("  - \(failure)")
            }
            exit(1)
        }
    }
}
