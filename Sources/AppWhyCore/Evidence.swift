import Foundation

public enum EvidenceCategory: String, Sendable, Codable {
    case bundle
    case infoPlist
    case signature
    case entitlements
    case launchServices
}

public enum EvidenceValue: Sendable {
    case string(String)
    case bool(Bool)
    case int(Int)
    case stringArray([String])
    case dictionary([String: String])
    case absent
}

extension EvidenceValue: Codable {
    private enum CodingKeys: String, CodingKey {
        case type
        case value
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decode(String.self, forKey: .type)
        switch type {
        case "string":
            self = .string(try container.decode(String.self, forKey: .value))
        case "bool":
            self = .bool(try container.decode(Bool.self, forKey: .value))
        case "int":
            self = .int(try container.decode(Int.self, forKey: .value))
        case "stringArray":
            self = .stringArray(try container.decode([String].self, forKey: .value))
        case "dictionary":
            self = .dictionary(try container.decode([String: String].self, forKey: .value))
        case "absent":
            self = .absent
        default:
            throw DecodingError.dataCorruptedError(forKey: .type, in: container, debugDescription: "Unknown evidence value type")
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .string(let value):
            try container.encode("string", forKey: .type)
            try container.encode(value, forKey: .value)
        case .bool(let value):
            try container.encode("bool", forKey: .type)
            try container.encode(value, forKey: .value)
        case .int(let value):
            try container.encode("int", forKey: .type)
            try container.encode(value, forKey: .value)
        case .stringArray(let value):
            try container.encode("stringArray", forKey: .type)
            try container.encode(value, forKey: .value)
        case .dictionary(let value):
            try container.encode("dictionary", forKey: .type)
            try container.encode(value, forKey: .value)
        case .absent:
            try container.encode("absent", forKey: .type)
        }
    }
}

public struct Evidence: Identifiable, Sendable, Codable {
    public let id: String
    public let category: EvidenceCategory
    public let label: String
    public let value: EvidenceValue
    public let source: String

    public init(
        id: String,
        category: EvidenceCategory,
        label: String,
        value: EvidenceValue,
        source: String
    ) {
        self.id = id
        self.category = category
        self.label = label
        self.value = value
        self.source = source
    }
}
