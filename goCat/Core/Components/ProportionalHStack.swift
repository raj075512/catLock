import SwiftUI

/// Lays subviews out side by side, each taking a share of the width in
/// proportion to its `flex` value.
///
/// Home's duration row needs this: the fourth chip is 1.3× a numeric chip
/// while it reads "Custom" and 1.9× once it holds a value like "1h 20m".
/// `layoutPriority` can't express that — it decides who gets space *first*,
/// not in what ratio — and equal `maxWidth: .infinity` frames would clip the
/// long label.
struct ProportionalHStack: Layout {
    struct Flex: LayoutValueKey {
        static let defaultValue: CGFloat = 1
    }

    var spacing: CGFloat

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let height = subviews
            .map { $0.sizeThatFits(.unspecified).height }
            .max() ?? 0
        return CGSize(width: proposal.width ?? 0, height: height)
    }

    func placeSubviews(
        in bounds: CGRect,
        proposal: ProposedViewSize,
        subviews: Subviews,
        cache: inout ()
    ) {
        guard !subviews.isEmpty else { return }

        let totalSpacing = spacing * CGFloat(subviews.count - 1)
        let available = max(0, bounds.width - totalSpacing)
        let totalFlex = subviews.reduce(0) { $0 + $1[Flex.self] }
        guard totalFlex > 0 else { return }

        var x = bounds.minX
        for subview in subviews {
            let width = available * (subview[Flex.self] / totalFlex)
            subview.place(
                at: CGPoint(x: x, y: bounds.midY),
                anchor: .leading,
                proposal: ProposedViewSize(width: width, height: bounds.height)
            )
            x += width + spacing
        }
    }
}

extension View {
    /// This view's share of a `ProportionalHStack`.
    func flex(_ value: CGFloat) -> some View {
        layoutValue(key: ProportionalHStack.Flex.self, value: value)
    }
}
