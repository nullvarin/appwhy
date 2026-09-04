import XCTest
@testable import AppWhyCore

@MainActor
final class LaunchServicesInspectorTests: XCTestCase {
    func testNilBundleIdentifierProducesAbsentResolvedURL() {
        let appURL = URL(fileURLWithPath: "/tmp/Test.app")
        let target = AppTarget(
            source: .path(appURL),
            url: appURL,
            bundleIdentifier: nil
        )

        let evidence = LaunchServicesInspector.inspect(target: target)

        let resolvedURL = evidence.first { $0.id == "launchServices.resolvedURL" }
        XCTAssertNotNil(resolvedURL)

        if let resolvedURL {
            guard case .absent = resolvedURL.value else {
                return XCTFail("Expected absent resolved URL")
            }
        }
    }

    func testUnregisteredBundleIdentifierDoesNotProducePathMatch() {
        let appURL = URL(fileURLWithPath: "/tmp/Test.app")
        let target = AppTarget(
            source: .path(appURL),
            url: appURL,
            bundleIdentifier: "com.invalid.nonexistent.app"
        )

        let evidence = LaunchServicesInspector.inspect(target: target)

        XCTAssertNil(evidence.first { $0.id == "launchServices.pathMatches" })
    }
}
