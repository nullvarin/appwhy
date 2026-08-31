import Foundation
import AppWhyCore

enum InspectCommand {
    @MainActor
    static func run(target: String, format: OutputFormat, verbose: Bool) throws {
        let resolvedTarget = try TargetResolver.resolve(target)
        let snapshot = DiagnosticSnapshot.build(target: resolvedTarget)

        switch format {
        case .text:
            OutputFormatter.printEvidence(snapshot: snapshot, verbose: verbose)
        case .json:
            print(try OutputFormatter.json(snapshot))
        }
    }
}
