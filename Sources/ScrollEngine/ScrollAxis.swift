import SwiftUI

/// The axis along which a scroll gesture is tracked.
public enum ScrollAxis: Sendable {
    /// Track vertical scroll gestures (up/down).
    case vertical
    /// Track horizontal scroll gestures (left/right).
    case horizontal
}
