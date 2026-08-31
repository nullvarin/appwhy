import Foundation

public struct DiagnosticSnapshot: Sendable, Codable {
    public let target: AppTarget
    public let collectedAt: Date
    public let evidence: [Evidence]
    public let findings: [Finding]

    public init(
        target: AppTarget,
        collectedAt: Date = Date(),
        evidence: [Evidence],
        findings: [Finding]
    ) {
        self.target = target
        self.collectedAt = collectedAt
        self.evidence = evidence
        self.findings = findings
    }

    @MainActor
    public static func build(target: AppTarget) -> DiagnosticSnapshot {
        var evidence: [Evidence] = []
        evidence.append(contentsOf: BundleInspector.inspect(target: target))
        evidence.append(contentsOf: CodeSigningInspector.inspect(target: target))
        evidence.append(contentsOf: LaunchServicesInspector.inspect(target: target))

        let findings = ExplanationEngine.generateFindings(evidence: evidence, target: target)
        return DiagnosticSnapshot(target: target, evidence: evidence, findings: findings)
    }
}
