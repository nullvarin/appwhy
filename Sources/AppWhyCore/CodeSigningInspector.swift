import Foundation
import Security

public struct CodeSigningInspector {
    public static func inspect(target: AppTarget) -> [Evidence] {
        var evidence: [Evidence] = []

        var staticCode: SecStaticCode?
        let createStatus = SecStaticCodeCreateWithPath(target.url as CFURL, [], &staticCode)
        guard createStatus == errSecSuccess, let code = staticCode else {
            evidence.append(
                Evidence(
                    id: "signature.present",
                    category: .signature,
                    label: "Code signature present",
                    value: .bool(false),
                    source: "Security"
                )
            )
            evidence.append(
                Evidence(
                    id: "signature.valid",
                    category: .signature,
                    label: "Code signature valid",
                    value: .absent,
                    source: "Security"
                )
            )
            return evidence
        }

        evidence.append(
            Evidence(
                id: "signature.present",
                category: .signature,
                label: "Code signature present",
                value: .bool(true),
                source: "Security"
            )
        )

        var validationError: Unmanaged<CFError>?
        let validationStatus = SecStaticCodeCheckValidityWithErrors(code, [], nil, &validationError)
        let isValid = validationStatus == errSecSuccess
        evidence.append(
            Evidence(
                id: "signature.valid",
                category: .signature,
                label: "Code signature valid",
                value: .bool(isValid),
                source: "Security"
            )
        )

        var signingInfo: CFDictionary?
        let infoStatus = SecCodeCopySigningInformation(code, [], &signingInfo)
        if infoStatus == errSecSuccess, let dict = signingInfo as NSDictionary? {
            if let identifier = dict[kSecCodeInfoIdentifier] as? String {
                evidence.append(
                    Evidence(
                        id: "signature.identifier",
                        category: .signature,
                        label: "Signing identifier",
                        value: .string(identifier),
                        source: "Security"
                    )
                )
            }

            if let teamIdentifier = dict[kSecCodeInfoTeamIdentifier] as? String {
                evidence.append(
                    Evidence(
                        id: "signature.teamIdentifier",
                        category: .signature,
                        label: "Team identifier",
                        value: .string(teamIdentifier),
                        source: "Security"
                    )
                )
            }

            if let flags = dict[kSecCodeInfoFlags] as? UInt32 {
                let signatureFlags = SecCodeSignatureFlags(rawValue: flags)
                let hardenedRuntime = signatureFlags.contains(.runtime)
                let libraryValidation = signatureFlags.contains(.libraryValidation)

                evidence.append(
                    Evidence(
                        id: "signature.hardenedRuntime",
                        category: .signature,
                        label: "Hardened runtime",
                        value: .bool(hardenedRuntime),
                        source: "Security"
                    )
                )

                evidence.append(
                    Evidence(
                        id: "signature.libraryValidation",
                        category: .signature,
                        label: "Library validation",
                        value: .bool(libraryValidation),
                        source: "Security"
                    )
                )
            }

            if let entitlements = dict[kSecCodeInfoEntitlementsDict] as? [String: Any] {
                let sandboxEnabled = (entitlements["com.apple.security.app-sandbox"] as? Bool) ?? false
                evidence.append(
                    Evidence(
                        id: "entitlements.sandboxEnabled",
                        category: .entitlements,
                        label: "App Sandbox enabled",
                        value: .bool(sandboxEnabled),
                        source: "Security"
                    )
                )
            }
        }

        return evidence
    }
}
