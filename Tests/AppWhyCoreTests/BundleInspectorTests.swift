import XCTest
@testable import AppWhyCore

final class BundleInspectorTests: XCTestCase {
    func testInspectValidBundle() throws {
        let appURL = try TestAppBundleFactory.makeAppBundle()
        defer { try? TestAppBundleFactory.removeTemporaryBundle(at: appURL) }

        let target = AppTarget(
            source: .path(appURL),
            url: appURL,
            bundleIdentifier: "com.example.test"
        )

        let evidence = BundleInspector.inspect(target: target)

        XCTAssertTrue(evidenceContainsBool(evidence, id: "bundle.infoPlist.exists", expected: true))
        XCTAssertTrue(evidenceContainsBool(evidence, id: "bundle.loadable", expected: true))
        XCTAssertTrue(evidenceContainsBool(evidence, id: "bundle.primaryExecutable.exists", expected: true))
        XCTAssertTrue(evidenceContainsString(evidence, id: "infoPlist.CFBundleIdentifier", expected: "com.example.test"))
    }

    func testInspectMissingExecutable() throws {
        let appURL = try TestAppBundleFactory.makeAppBundle(
            executableName: "MissingExecutable",
            createExecutable: false
        )
        defer { try? TestAppBundleFactory.removeTemporaryBundle(at: appURL) }

        let target = AppTarget(
            source: .path(appURL),
            url: appURL,
            bundleIdentifier: "com.example.test"
        )

        let evidence = BundleInspector.inspect(target: target)

        XCTAssertTrue(evidenceContainsBool(evidence, id: "bundle.primaryExecutable.exists", expected: false))
    }

    func testInspectMissingInfoPlist() throws {
        let tempDir = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString)
        let appURL = tempDir.appendingPathComponent("Test.app")

        try FileManager.default.createDirectory(
            at: appURL,
            withIntermediateDirectories: true
        )
        defer { try? FileManager.default.removeItem(at: tempDir) }

        let target = AppTarget(
            source: .path(appURL),
            url: appURL,
            bundleIdentifier: nil
        )

        let evidence = BundleInspector.inspect(target: target)

        XCTAssertTrue(evidenceContainsBool(evidence, id: "bundle.infoPlist.exists", expected: false))
    }

    func testInspectMissingBundleIdentifier() throws {
        let appURL = try TestAppBundleFactory.makeAppBundle(
            infoPlist: ["CFBundleExecutable": "TestExecutable"]
        )
        defer { try? TestAppBundleFactory.removeTemporaryBundle(at: appURL) }

        let target = AppTarget(
            source: .path(appURL),
            url: appURL,
            bundleIdentifier: nil
        )

        let evidence = BundleInspector.inspect(target: target)

        let identifier = evidence.first { $0.id == "infoPlist.CFBundleIdentifier" }
        XCTAssertNotNil(identifier)

        if let identifier {
            guard case .absent = identifier.value else {
                return XCTFail("Expected absent CFBundleIdentifier")
            }
        }
    }

    private func evidenceContainsBool(
        _ evidence: [Evidence],
        id: String,
        expected: Bool
    ) -> Bool {
        guard let item = evidence.first(where: { $0.id == id }) else {
            return false
        }

        if case .bool(let value) = item.value {
            return value == expected
        }

        return false
    }

    private func evidenceContainsString(
        _ evidence: [Evidence],
        id: String,
        expected: String
    ) -> Bool {
        guard let item = evidence.first(where: { $0.id == id }) else {
            return false
        }

        if case .string(let value) = item.value {
            return value == expected
        }

        return false
    }
}
