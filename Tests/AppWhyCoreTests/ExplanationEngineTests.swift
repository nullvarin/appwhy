import XCTest
@testable import AppWhyCore

final class ExplanationEngineTests: XCTestCase {
    func testFindingForMissingBundleIdentifier() {
        let target = makeTarget(bundleIdentifier: nil)
        let evidence: [Evidence] = [
            Evidence(id: "infoPlist.CFBundleIdentifier", category: .infoPlist, label: "CFBundleIdentifier", value: .absent, source: "Info.plist")
        ]

        let findings = ExplanationEngine.generateFindings(
            evidence: evidence,
            target: target
        )

        XCTAssertTrue(findings.contains {
            $0.id == "finding.bundleIdentifier.missing"
                && $0.severity == .warning
                && $0.confidence == .high
        })
    }

    func testFindingForInvalidCodeSignature() {
        let target = makeTarget(bundleIdentifier: "com.example.test")
        let evidence: [Evidence] = [
            Evidence(id: "signature.present", category: .signature, label: "Code signature present", value: .bool(true), source: "Security"),
            Evidence(id: "signature.valid", category: .signature, label: "Code signature valid", value: .bool(false), source: "Security")
        ]

        let findings = ExplanationEngine.generateFindings(
            evidence: evidence,
            target: target
        )

        XCTAssertTrue(findings.contains {
            $0.id == "finding.signature.invalid"
                && $0.severity == .error
                && $0.confidence == .high
        })
    }

    func testFindingForMissingPrimaryExecutable() {
        let target = makeTarget(bundleIdentifier: "com.example.test")
        let evidence: [Evidence] = [
            Evidence(id: "bundle.primaryExecutable.exists", category: .bundle, label: "Primary executable exists", value: .bool(false), source: "Filesystem"),
            Evidence(id: "infoPlist.CFBundleExecutable", category: .infoPlist, label: "CFBundleExecutable", value: .string("TestExecutable"), source: "Info.plist")
        ]

        let findings = ExplanationEngine.generateFindings(
            evidence: evidence,
            target: target
        )

        XCTAssertTrue(findings.contains {
            $0.id == "finding.bundle.primaryExecutableMissing"
                && $0.severity == .error
                && $0.confidence == .high
        })
    }

    func testFindingForLaunchServicesPathMismatch() {
        let target = makeTarget(bundleIdentifier: "com.example.test")
        let evidence: [Evidence] = [
            Evidence(id: "launchServices.pathMatches", category: .launchServices, label: "Path matches", value: .bool(false), source: "NSWorkspace"),
            Evidence(id: "launchServices.resolvedURL", category: .launchServices, label: "Resolved URL", value: .string("/other/App.app"), source: "NSWorkspace"),
            Evidence(id: "infoPlist.CFBundleIdentifier", category: .infoPlist, label: "CFBundleIdentifier", value: .string("com.example.test"), source: "Info.plist")
        ]

        let findings = ExplanationEngine.generateFindings(
            evidence: evidence,
            target: target
        )

        XCTAssertTrue(findings.contains {
            $0.id == "finding.launchServices.pathMismatch"
                && $0.severity == .warning
                && $0.confidence == .high
        })
    }

    private func makeTarget(bundleIdentifier: String?) -> AppTarget {
        AppTarget(
            source: .path(URL(fileURLWithPath: "/tmp/Test.app")),
            url: URL(fileURLWithPath: "/tmp/Test.app"),
            bundleIdentifier: bundleIdentifier
        )
    }
}
