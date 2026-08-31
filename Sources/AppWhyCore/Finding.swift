import Foundation

public enum FindingSeverity: String, Sendable, Codable {
    case error
    case warning
    case info
}

public enum FindingConfidence: String, Sendable, Codable {
    case high
    case medium
    case low
}

public struct Finding: Identifiable, Sendable, Codable {
    public let id: String
    public let severity: FindingSeverity
    public let title: String
    public let summary: String
    public let rationale: String
    public let evidenceIDs: [String]
    public let confidence: FindingConfidence

    public init(
        id: String,
        severity: FindingSeverity,
        title: String,
        summary: String,
        rationale: String,
        evidenceIDs: [String],
        confidence: FindingConfidence
    ) {
        self.id = id
        self.severity = severity
        self.title = title
        self.summary = summary
        self.rationale = rationale
        self.evidenceIDs = evidenceIDs
        self.confidence = confidence
    }
}
