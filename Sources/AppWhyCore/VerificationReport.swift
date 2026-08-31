import Foundation

public struct VerificationReport: Sendable, Codable {
    public let target: AppTarget
    public let collectedAt: Date
    public let checks: [VerificationCheck]

    public init(target: AppTarget, collectedAt: Date = Date(), checks: [VerificationCheck]) {
        self.target = target
        self.collectedAt = collectedAt
        self.checks = checks
    }
}
