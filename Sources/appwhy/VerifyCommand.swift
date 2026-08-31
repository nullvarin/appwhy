import Foundation
import AppWhyCore

enum VerifyCommand {
    @MainActor
    static func run(target: String, format: OutputFormat, verbose: Bool) throws -> Int32 {
        let resolvedTarget = try TargetResolver.resolve(target)
        let snapshot = DiagnosticSnapshot.build(target: resolvedTarget)
        let report = VerificationEngine.generateReport(snapshot: snapshot)

        switch format {
        case .text:
            OutputFormatter.printVerificationReport(report, verbose: verbose)
        case .json:
            print(try OutputFormatter.json(report))
        }

        let hasFailed = report.checks.contains { $0.state == .failed }
        return hasFailed ? 1 : 0
    }
}
