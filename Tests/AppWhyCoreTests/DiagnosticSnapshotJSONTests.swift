import XCTest
@testable import AppWhyCore

final class DiagnosticSnapshotJSONTests: XCTestCase {
    func testSnapshotJSONRoundTrip() throws {
        let target = AppTarget(
            source: .path(URL(fileURLWithPath: "/tmp/Test.app")),
            url: URL(fileURLWithPath: "/tmp/Test.app"),
            bundleIdentifier: "com.example.test"
        )

        let evidence: [Evidence] = [
            Evidence(
                id: "bundle.loadable",
                category: .bundle,
                label: "Bundle loadable",
                value: .bool(true),
                source: "Bundle"
            )
        ]

        let findings: [Finding] = [
            Finding(
                id: "finding.test",
                severity: .info,
                title: "Test finding",
                summary: "A test finding",
                rationale: "Used for testing",
                evidenceIDs: ["bundle.loadable"],
                confidence: .high
            )
        ]

        let snapshot = DiagnosticSnapshot(
            target: target,
            collectedAt: Date(timeIntervalSince1970: 0),
            evidence: evidence,
            findings: findings
        )

        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        encoder.dateEncodingStrategy = .iso8601

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601

        let data = try encoder.encode(snapshot)
        let decoded = try decoder.decode(DiagnosticSnapshot.self, from: data)

        XCTAssertEqual(decoded.target.url, snapshot.target.url)
        XCTAssertEqual(decoded.target.bundleIdentifier, snapshot.target.bundleIdentifier)
        XCTAssertEqual(decoded.evidence.count, snapshot.evidence.count)
        XCTAssertEqual(decoded.evidence.first?.id, "bundle.loadable")
        XCTAssertEqual(decoded.findings.first?.id, "finding.test")
    }
}
