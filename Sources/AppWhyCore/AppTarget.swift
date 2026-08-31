import Foundation

public struct AppTarget: Sendable, Codable {
    public enum Source: Sendable {
        case path(URL)
        case bundleIdentifier(String)
        case resolvedPath(URL, requestedBundleIdentifier: String)
    }

    public let source: Source
    public let url: URL
    public let bundleIdentifier: String?

    private enum CodingKeys: String, CodingKey {
        case sourceType
        case path
        case requestedBundleIdentifier
        case url
        case bundleIdentifier
    }

    public init(source: Source, url: URL, bundleIdentifier: String?) {
        self.source = source
        self.url = url
        self.bundleIdentifier = bundleIdentifier
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        url = try container.decode(URL.self, forKey: .url)
        bundleIdentifier = try container.decodeIfPresent(String.self, forKey: .bundleIdentifier)
        let sourceType = try container.decode(String.self, forKey: .sourceType)
        switch sourceType {
        case "path":
            let path = try container.decode(URL.self, forKey: .path)
            source = .path(path)
        case "bundleIdentifier":
            let identifier = try container.decode(String.self, forKey: .requestedBundleIdentifier)
            source = .bundleIdentifier(identifier)
        case "resolvedPath":
            let path = try container.decode(URL.self, forKey: .path)
            let requested = try container.decode(String.self, forKey: .requestedBundleIdentifier)
            source = .resolvedPath(path, requestedBundleIdentifier: requested)
        default:
            throw DecodingError.dataCorruptedError(forKey: .sourceType, in: container, debugDescription: "Unknown source type")
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(url, forKey: .url)
        try container.encodeIfPresent(bundleIdentifier, forKey: .bundleIdentifier)
        switch source {
        case .path(let path):
            try container.encode("path", forKey: .sourceType)
            try container.encode(path, forKey: .path)
        case .bundleIdentifier(let identifier):
            try container.encode("bundleIdentifier", forKey: .sourceType)
            try container.encode(identifier, forKey: .requestedBundleIdentifier)
        case .resolvedPath(let path, let requested):
            try container.encode("resolvedPath", forKey: .sourceType)
            try container.encode(path, forKey: .path)
            try container.encode(requested, forKey: .requestedBundleIdentifier)
        }
    }
}
