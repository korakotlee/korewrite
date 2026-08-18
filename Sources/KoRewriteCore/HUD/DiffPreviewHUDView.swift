import SwiftUI

/// Visual theme and token definitions for the diff preview HUD.
public enum HUDTheme {
    public static let additionBackground = Color.green.opacity(0.18)
    public static let additionForeground = Color.green
    public static let deletionBackground = Color.red.opacity(0.18)
    public static let deletionForeground = Color.red
    public static let panelCornerRadius: CGFloat = 16
    public static let headerFont = Font.system(.headline, design: .default).weight(.semibold)
    public static let bodyFont = Font.system(.body, design: .default)
    public static let diffFont = Font.system(.body, design: .monospaced)
    public static let captionFont = Font.system(.caption, design: .monospaced)
}

/// SwiftUI View presenting visual text diffs, loading status, or error recovery banners.
public struct DiffPreviewHUDView: View {
    @Bindable public var state: HUDViewState
    @State private var isSpinning = false

    public init(state: HUDViewState) {
        self.state = state
    }

    public var body: some View {
        VStack(spacing: 0) {
            headerView
            Divider()
            contentView
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            Divider()
            footerView
        }
        .frame(minWidth: 540, idealWidth: 620, maxWidth: 720, minHeight: 340, idealHeight: 400, maxHeight: 520)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: HUDTheme.panelCornerRadius, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: HUDTheme.panelCornerRadius, style: .continuous)
                .stroke(Color.primary.opacity(0.1), lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.25), radius: 24, x: 0, y: 12)
        .padding(16)
    }

    // MARK: - Header
    @ViewBuilder
    private var headerView: some View {
        HStack(spacing: 8) {
            Image(systemName: headerIcon)
                .foregroundColor(headerColor)
                .font(.system(size: 14, weight: .bold))

            Text(headerTitle)
                .font(HUDTheme.headerFont)

            Spacer()

            if case .loading = state.status {
                ProgressView()
                    .controlSize(.small)
            }
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 14)
        .background(Color.primary.opacity(0.03))
    }

    private var headerIcon: String {
        switch state.status {
        case .idle: return "sparkles"
        case .loading: return "hourglass"
        case .preview: return "text.badge.checkmark"
        case .error: return "exclamationmark.triangle.fill"
        }
    }

    private var headerTitle: String {
        switch state.status {
        case .idle: return "KoRewrite"
        case .loading: return "Generating Rewrite..."
        case .preview: return "Rewrite Preview"
        case .error: return "Rewrite Failed"
        }
    }

    private var headerColor: Color {
        switch state.status {
        case .idle: return .secondary
        case .loading: return .accentColor
        case .preview: return .accentColor
        case .error: return .red
        }
    }

    // MARK: - Content
    @ViewBuilder
    private var contentView: some View {
        switch state.status {
        case .idle:
            VStack(spacing: 12) {
                Image(systemName: "sparkles")
                    .font(.system(size: 36))
                    .foregroundColor(.secondary)
                Text("Ready to rewrite")
                    .font(HUDTheme.bodyFont)
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

        case let .loading(originalText):
            VStack(spacing: 16) {
                ProgressView()
                    .scaleEffect(1.2)
                Text("Transforming text with AI backend...")
                    .font(HUDTheme.headerFont)
                    .foregroundColor(.primary)

                if !originalText.isEmpty {
                    ScrollView {
                        Text(originalText)
                            .font(HUDTheme.diffFont)
                            .foregroundColor(.secondary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(12)
                            .background(Color.primary.opacity(0.04))
                            .cornerRadius(8)
                    }
                    .frame(maxHeight: 140)
                    .padding(.horizontal, 20)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding(20)

        case let .preview(originalText, rewrittenText, diffSegments):
            diffPreviewView(original: originalText, rewritten: rewrittenText, diffSegments: diffSegments)

        case let .error(message):
            errorView(message: message)
        }
    }

    // MARK: - Diff Preview Layout
    @ViewBuilder
    private func diffPreviewView(original: String, rewritten: String, diffSegments: [DiffSegment]) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            // Diff segmented output
            ScrollView {
                VStack(alignment: .leading, spacing: 10) {
                    Text("Highlighted Changes")
                        .font(HUDTheme.captionFont)
                        .foregroundColor(.secondary)

                    FlowDiffView(segments: diffSegments)
                        .padding(12)
                        .background(Color.primary.opacity(0.03))
                        .cornerRadius(8)

                    Text("Result Preview")
                        .font(HUDTheme.captionFont)
                        .foregroundColor(.secondary)
                        .padding(.top, 4)

                    Text(rewritten)
                        .font(HUDTheme.diffFont)
                        .foregroundColor(.primary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(12)
                        .background(Color.primary.opacity(0.04))
                        .cornerRadius(8)
                }
                .padding(.horizontal, 18)
                .padding(.vertical, 12)
            }
        }
    }

    // MARK: - Error View
    @ViewBuilder
    private func errorView(message: String) -> some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.circle.fill")
                .font(.system(size: 40))
                .foregroundColor(.red)

            Text("Execution Error")
                .font(HUDTheme.headerFont)

            Text(message)
                .font(HUDTheme.diffFont)
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
                .padding(12)
                .background(Color.red.opacity(0.08))
                .cornerRadius(8)
                .padding(.horizontal, 24)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(20)
    }

    // MARK: - Footer Actions
    @ViewBuilder
    private var footerView: some View {
        HStack {
            Button(role: .cancel, action: { state.cancel() }) {
                HStack(spacing: 4) {
                    Text("Cancel")
                    Text("⎋")
                        .font(HUDTheme.captionFont)
                        .foregroundColor(.secondary)
                }
            }
            .keyboardShortcut(.cancelAction)

            Spacer()

            if case .preview = state.status {
                Button(action: { state.copyText() }) {
                    HStack(spacing: 4) {
                        Text("Copy")
                        Text("⌘C")
                            .font(HUDTheme.captionFont)
                            .foregroundColor(.secondary)
                    }
                }
                .keyboardShortcut("c", modifiers: .command)

                Button(action: { state.apply() }) {
                    HStack(spacing: 4) {
                        Text("Apply Rewrite")
                        Text("↵")
                            .font(HUDTheme.captionFont)
                    }
                }
                .buttonStyle(.borderedProminent)
                .keyboardShortcut(.defaultAction)
            } else if case .error = state.status {
                Button("Dismiss") {
                    state.cancel()
                }
                .keyboardShortcut(.defaultAction)
            }
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 12)
        .background(Color.primary.opacity(0.03))
    }
}

/// Renders diff segments with colored highlights.
public struct FlowDiffView: View {
    public let segments: [DiffSegment]

    public init(segments: [DiffSegment]) {
        self.segments = segments
    }

    public var body: some View {
        Text(attributedDiff)
            .font(HUDTheme.diffFont)
            .lineSpacing(4)
            .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var attributedDiff: AttributedString {
        var result = AttributedString()
        for segment in segments {
            var attr = AttributedString(segment.text)
            switch segment.kind {
            case .unchanged:
                attr.foregroundColor = .primary
            case .addition:
                attr.backgroundColor = HUDTheme.additionBackground
                attr.foregroundColor = HUDTheme.additionForeground
            case .deletion:
                attr.backgroundColor = HUDTheme.deletionBackground
                attr.foregroundColor = HUDTheme.deletionForeground
                attr.inlinePresentationIntent = .strikethrough
            }
            result.append(attr)
        }
        return result
    }
}
