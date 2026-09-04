import Foundation

enum TestAppBundleFactory {
    static func makeAppBundle(
        executableName: String = "TestExecutable",
        createExecutable: Bool = true,
        infoPlist: [String: Any]? = nil
    ) throws -> URL {
        let tempDir = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString)
        let appURL = tempDir.appendingPathComponent("Test.app")
        let contentsURL = appURL.appendingPathComponent("Contents")
        let macOSURL = contentsURL.appendingPathComponent("MacOS")

        try FileManager.default.createDirectory(
            at: macOSURL,
            withIntermediateDirectories: true
        )

        if createExecutable {
            FileManager.default.createFile(
                atPath: macOSURL.appendingPathComponent(executableName).path,
                contents: Data()
            )
        }

        let plist: [String: Any]
        if let infoPlist {
            plist = infoPlist
        } else {
            plist = [
                "CFBundleIdentifier": "com.example.test",
                "CFBundleExecutable": executableName
            ]
        }

        let plistData = try PropertyListSerialization.data(
            fromPropertyList: plist,
            format: .xml,
            options: 0
        )
        try plistData.write(to: contentsURL.appendingPathComponent("Info.plist"))

        return appURL
    }

    static func removeTemporaryBundle(at appURL: URL) throws {
        try FileManager.default.removeItem(
            at: appURL.deletingLastPathComponent()
        )
    }
}
