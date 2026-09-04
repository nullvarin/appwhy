import XCTest
@testable import AppWhyCore

final class CodeSigningInspectorTests: XCTestCase {
    func testUnsignedBundleDoesNotReportValidSignature() throws {
        let appURL = try TestAppBundleFactory.makeAppBundle()
        defer { try? TestAppBundleFactory.removeTemporaryBundle(at: appURL) }

        let target = AppTarget(
            source: .path(appURL),
            url: appURL,
            bundleIdentifier: "com.example.test"
        )

        let evidence = CodeSigningInspector.inspect(target: target)

        let present = evidence.first { $0.id == "signature.present" }
        let valid = evidence.first { $0.id == "signature.valid" }

        XCTAssertNotNil(present)
        XCTAssertNotNil(valid)

        if let present, case .bool(let presentValue) = present.value {
            if presentValue {
                guard let valid, case .bool(let validValue) = valid.value else {
                    return XCTFail("Missing validity evidence for signed-looking target")
                }

                XCTAssertFalse(validValue)
            }
        } else if let present {
            XCTFail("Unexpected signature.present value: \(present.value)")
        }
    }
}
