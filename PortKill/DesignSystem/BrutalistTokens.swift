import SwiftUI

/// Design tokens for the brutalist/minimalist visual language.
/// Rules: solid borders, no shadows, no gradients, no glass effects,
/// monospace for data, high contrast, utilitarian feel.
enum BrutalistTokens {

    // MARK: - Colors

    static let background       = Color.white
    static let surface          = Color(white: 0.955)  // alternate row background

    static let text             = Color.black
    static let textSecondary    = Color(white: 0.42)

    static let border           = Color(white: 0.15)   // near-black, used for major dividers
    static let borderLight      = Color(white: 0.80)   // row dividers

    // Action buttons
    static let killBg           = Color(red: 0.82, green: 0.06, blue: 0.06)
    static let killFg           = Color.white
    static let refreshBg        = Color(white: 0.08)
    static let refreshFg        = Color.white

    // System process indicator (non-killable)
    static let systemBg         = Color(white: 0.88)
    static let systemFg         = Color(white: 0.42)

    // Error banner
    static let errorBg          = Color(red: 0.80, green: 0.06, blue: 0.06)
    static let errorFg          = Color.white

    // Protocol badges
    static let badgeBorder      = Color(white: 0.72)
    static let badgeFg          = Color(white: 0.30)

    // Tabs
    static let tabActiveBg      = Color(white: 0.08)
    static let tabActiveFg      = Color.white
    static let tabInactiveFg    = Color(white: 0.42)

    // New entry highlight
    static let newEntryAccent   = Color(red: 0.13, green: 0.72, blue: 0.37)

    // MARK: - Typography

    static let appTitleFont     = Font.system(.callout, design: .monospaced).weight(.bold)
    static let processNameFont  = Font.system(.callout, design: .monospaced).weight(.semibold)
    static let portNumberFont   = Font.system(.title3, design: .monospaced).weight(.bold)
    static let monoSmallFont    = Font.system(.caption, design: .monospaced)
    static let labelFont        = Font.system(size: 11, weight: .bold)
    static let footerFont       = Font.system(size: 10, weight: .semibold)

    // MARK: - Layout

    static let rowPaddingH: CGFloat      = 14
    static let rowPaddingV: CGFloat      = 10
    static let buttonPaddingH: CGFloat   = 9
    static let buttonPaddingV: CGFloat   = 4

    // MARK: - Shape

    static let cornerRadius: CGFloat     = 2
    static let borderWidth: CGFloat      = 1
}
