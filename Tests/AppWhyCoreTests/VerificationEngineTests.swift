import XCTest
@testable import AppWhyCore

final class VerificationEngineTests: XCTestCase {
    func testAllValidChecks() {
        let target = makeTarget(bundleIdentifier: "com.example.test")
        let evidence: [Evidence] = [
            Evidence(id: "bundle.loadable", category: .bundle, label: "Bundle loadable", value: .bool(true), source: "Bundle"),
            Evidence(id: "bundle.primaryExecutable.exists", category: .bundle, label: "Primary executable exists", value: .bool(true), source: "Filesystem"),
            Evidence(id: "signature.present", category: .signature, label: "Code signature present", value: .bool(true), source: "Security"),
            Evidence(id: "signature.valid", category: .signature, label: "Code signature valid", value: .bool(true), source: "Security"),
            Evidence(id: "infoPlist.CFBundleIdentifier", category: .infoPlist, label: "CFBundleIdentifier", value: .string("com.example.test"), source: "Info.plist"),
            Evidence(id: "launchServices.pathMatches", category: .launchServices, label: "Path matches", value: .bool(true), source: "NSWorkspace")
        ]

        let snapshot = DiagnosticSnapshot(
            target: target,
            evidence: evidence,
            findings: []
        )

        let checks = VerificationEngine.verify(snapshot: snapshot)

        XCTAssertEqual(checks.first { $0.id == "bundle.loadable" }?.state, .valid)
        XCTAssertEqual(checks.first { $0.id == "bundle.primaryExecutable.exists" }?.state, .valid)
        XCTAssertEqual(checks.first { $0.id == "signature.valid" }?.state, .valid)
        XCTAssertEqual(checks.first { $0.id == "infoPlist.CFBundleIdentifier" }?.state, .valid)
        XCTAssertEqual(checks.first { $0.id == "launchServices.pathMatches" }?.state, .valid)
    }

    func testFailedAndWarningChecks() {
        let target = makeTarget(bundleIdentifier: "com.example.test")
        let evidence: [Evidence] = [
            Evidence(id: "bundle.loadable", category: .bundle, label: "Bundle loadable", value: .bool(false), source: "Bundle"),
            Evidence(id: "bundle.primaryExecutable.exists", category: .bundle, label: "Primary executable exists", value: .bool(false), source: "Filesystem"),
            Evidence(id: "signature.present", category: .signature, label: "Code signature present", value: .bool(false), source: "Security"),
            Evidence(id: "infoPlist.CFBundleIdentifier", category: .infoPlist, label: "CFBundleIdentifier", value: .absent, source: "Info.plist")
        ]

        let snapshot = DiagnosticSnapshot(
            target: target,
            evidence: evidence,
            findings: []
        )

        let checks = VerificationEngine.verify(snapshot: snapshot)

        XCTAssertEqual(checks.first { $0.id == "bundle.loadable" }?.state, .failed)
        XCTAssertEqual(checks.first { $0.id == "bundle.primaryExecutable.exists" }?.state, .failed)
        XCTAssertEqual(checks.first { $0.id == "signature.present" }?.state, .failed)
        XCTAssertEqual(checks.first { $0.id == "infoPlist.CFBundleIdentifier" }?.state, .warning)
    }

    func testNotVerifiableAndNotApplicableChecks() {
        let target = makeTarget(bundleIdentifier: nil)
        let evidence: [Evidence] = [
            Evidence(id: "bundle.loadable", category: .bundle, label: "Bundle loadable", value: .absent, source: "Bundle"),
            Evidence(id: "bundle.primaryExecutable.exists", category: .bundle, label: "Primary executable exists", value: .absent, source: "Filesystem"),
            Evidence(id: "signature.present", category: .signature, label: "Code signature present", value: .absent, source: "Security"),
            Evidence(id: "infoPlist.CFBundleIdentifier", category: .infoPlist, label: "CFBundleIdentifier", value: .absent, source: "Info.plist")
        ]

        let snapshot = DiagnosticSnapshot(
            target: target,
            evidence: evidence,
            findings: []
        )

        let checks = VerificationEngine.verify(snapshot: snapshot)

        XCTAssertEqual(checks.first { $0.id == "bundle.loadable" }?.state, .notVerifiable)
        XCTAssertEqual(checks.first { $0.id == "bundle.primaryExecutable.exists" }?.state, .notVerifiable)
        XCTAssertEqual(checks.first { $0.id == "signature.present" }?.state, .notVerifiable)
        XCTAssertEqual(checks.first { $0.id == "launchServices.pathMatches" }?.state, .notApplicable)
    }

    private func makeTarget(bundleIdentifier: String?) -> AppTarget {
        AppTarget(
            source: .path(URL(fileURLWithPath: "/tmp/Test.app")),
            url: URL(fileURLWithPath: "/tmp/Test.app"),
            bundleIdentifier: bundleIdentifier
        )
    }
}
