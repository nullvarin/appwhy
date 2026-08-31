import Foundation
import AppWhyCore

enum OutputFormatter {
    static func printEvidence(snapshot: DiagnosticSnapshot, verbose: Bool) {
        print("Target: \(snapshot.target.url.path)")
        if let bundleIdentifier = snapshot.target.bundleIdentifier {
            print("Bundle Identifier: \(bundleIdentifier)")
        }
        print("Collected At: \(snapshot.collectedAt)")
        print()
        print("Evidence:")
        for item in snapshot.evidence {
            let valueText: String
            switch item.value {
            case .string(let value): valueText = value
            case .bool(let value): valueText = value ? "true" : "false"
            case .int(let value): valueText = "\(value)"
            case .stringArray(let values): valueText = values.joined(separator: ", ")
            case .dictionary(let dict): valueText = dict.map { "\($0.key)=\($0.value)" }.joined(separator: ", ")
            case .absent: valueText = "absent"
            }
            print("  [\(item.category.rawValue)] \(item.label): \(valueText)")
            if verbose {
                print("    id: \(item.id)")
                print("    source: \(item.source)")
            }
        }
    }

    static func printFindings(snapshot: DiagnosticSnapshot, verbose: Bool) {
        print("Target: \(snapshot.target.url.path)")
        if let bundleIdentifier = snapshot.target.bundleIdentifier {
            print("Bundle Identifier: \(bundleIdentifier)")
        }
        print("Collected At: \(snapshot.collectedAt)")
        print()
        if snapshot.findings.isEmpty {
            print("No findings.")
            return
        }
        print("Findings:")
        for finding in snapshot.findings {
            print("  [\(finding.severity.rawValue)] \(finding.title)")
            print("    \(finding.summary)")
            if verbose {
                print("    Rationale: \(finding.rationale)")
                print("    Confidence: \(finding.confidence.rawValue)")
                print("    Evidence: \(finding.evidenceIDs.joined(separator: ", "))")
                print("    ID: \(finding.id)")
            }
        }
    }

    static func printVerificationReport(_ report: VerificationReport, verbose: Bool) {
        print("Target: \(report.target.url.path)")
        if let bundleIdentifier = report.target.bundleIdentifier {
            print("Bundle Identifier: \(bundleIdentifier)")
        }
        print("Collected At: \(report.collectedAt)")
        print()
        print("Verification Checks:")
        for check in report.checks {
            print("  [\(check.state.rawValue)] \(check.title): \(check.detail)")
            if verbose {
                print("    ID: \(check.id)")
            }
        }
    }

    static func json<T: Encodable>(_ value: T) throws -> String {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        encoder.dateEncodingStrategy = .iso8601
        let data = try encoder.encode(value)
        return String(data: data, encoding: .utf8) ?? "{}"
    }
}
