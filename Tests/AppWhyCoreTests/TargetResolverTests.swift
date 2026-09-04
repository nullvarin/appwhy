import XCTest
@testable import AppWhyCore

@MainActor
final class TargetResolverTests: XCTestCase {
    func testResolveExistingAppPath() throws {
        let appURL = try TestAppBundleFactory.makeAppBundle()
        defer { try? TestAppBundleFactory.removeTemporaryBundle(at: appURL) }

        let target = try TargetResolver.resolve(appURL.path)

        if case .path(let resolvedURL) = target.source {
            XCTAssertEqual(
                resolvedURL.standardizedFileURL.path,
                appURL.standardizedFileURL.path
            )
        } else {
            XCTFail("Expected source to be .path")
        }

        XCTAssertEqual(target.url.path, appURL.path)
    }

    func testResolveInvalidBundleIdentifierThrows() {
        XCTAssertThrowsError(
            try TargetResolver.resolve("com.invalid.nonexistent.app")
        ) { error in
            guard case TargetResolutionError.targetNotFound = error else {
                return XCTFail("Expected targetNotFound error")
            }
        }
    }
}
