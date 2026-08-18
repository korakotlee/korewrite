import Foundation

/// Defines the classification of a diff segment.
public enum DiffKind: String, Sendable, Equatable {
    case unchanged
    case addition
    case deletion
}

/// Represents a continuous span of text with an associated diff kind.
public struct DiffSegment: Equatable, Sendable, Identifiable {
    public let id: UUID
    public let text: String
    public let kind: DiffKind

    public init(id: UUID = UUID(), text: String, kind: DiffKind) {
        self.id = id
        self.text = text
        self.kind = kind
    }
}

/// Computes word-level differences between original input and rewritten text.
public struct TextDiffEngine: Sendable {
    public init() {}

    /// Tokenizes input string into words and non-word characters.
    public static func tokenize(_ text: String) -> [String] {
        guard !text.isEmpty else { return [] }
        var tokens: [String] = []
        var currentToken = ""
        var isWordChar: Bool?

        for char in text {
            let charIsWord = char.isLetter || char.isNumber
            if let currentIsWord = isWordChar {
                if currentIsWord == charIsWord {
                    currentToken.append(char)
                } else {
                    tokens.append(currentToken)
                    currentToken = String(char)
                    isWordChar = charIsWord
                }
            } else {
                currentToken.append(char)
                isWordChar = charIsWord
            }
        }
        if !currentToken.isEmpty {
            tokens.append(currentToken)
        }
        return tokens
    }

    /// Computes tokenized diff segments between original and rewritten text using LCS.
    public func computeWordDiff(original: String, rewritten: String) -> [DiffSegment] {
        if original.isEmpty && rewritten.isEmpty {
            return []
        }
        if original.isEmpty {
            return [DiffSegment(text: rewritten, kind: .addition)]
        }
        if rewritten.isEmpty {
            return [DiffSegment(text: original, kind: .deletion)]
        }
        if original == rewritten {
            return [DiffSegment(text: original, kind: .unchanged)]
        }

        let a = Self.tokenize(original)
        let b = Self.tokenize(rewritten)

        let m = a.count
        let n = b.count
        var dp = [[Int]](repeating: [Int](repeating: 0, count: n + 1), count: m + 1)

        for i in 0..<m {
            for j in 0..<n {
                if a[i] == b[j] {
                    dp[i + 1][j + 1] = dp[i][j] + 1
                } else {
                    dp[i + 1][j + 1] = max(dp[i + 1][j], dp[i][j + 1])
                }
            }
        }

        var i = m
        var j = n
        var rawSegments: [(String, DiffKind)] = []

        while i > 0 || j > 0 {
            if i > 0 && j > 0 && a[i - 1] == b[j - 1] {
                rawSegments.append((a[i - 1], .unchanged))
                i -= 1
                j -= 1
            } else if j > 0 && (i == 0 || dp[i][j - 1] >= dp[i - 1][j]) {
                rawSegments.append((b[j - 1], .addition))
                j -= 1
            } else if i > 0 && (j == 0 || dp[i][j - 1] < dp[i - 1][j]) {
                rawSegments.append((a[i - 1], .deletion))
                i -= 1
            }
        }
        rawSegments.reverse()

        var merged: [DiffSegment] = []
        for (text, kind) in rawSegments {
            if let last = merged.last, last.kind == kind {
                merged[merged.count - 1] = DiffSegment(text: last.text + text, kind: kind)
            } else {
                merged.append(DiffSegment(text: text, kind: kind))
            }
        }
        return merged
    }
}
