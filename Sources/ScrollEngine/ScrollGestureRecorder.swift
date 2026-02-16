import SwiftUI

/// A view modifier that captures scroll input directly on a view and writes the
/// cumulative pixel offset to a `Binding<Double>`.
///
/// - **macOS**: Captures native scroll-wheel / trackpad events via an invisible
///   `NSView` background and a local `NSEvent` monitor.  No `ScrollView` is
///   involved.
/// - **iOS**: Captures touch-based drag gestures via `DragGesture` applied
///   directly to the content view.  No `ScrollView` is involved.
///
/// The offset accumulates across successive gestures so the caller always sees
/// the total distance scrolled.
public struct ScrollGestureRecorder: ViewModifier {
    @Binding var offset: Double
    let axis: ScrollAxis
    let onEnded: ((Double) -> Void)?

    #if os(iOS)
    @State private var baseOffset: Double = 0
    #endif

    public func body(content: Content) -> some View {
        #if os(macOS)
        content
            .background(
                ScrollWheelCapture(
                    axis: axis,
                    onDelta: { delta in
                        offset += delta
                    },
                    onEnded: onEnded != nil ? { onEnded?(offset) } : nil
                )
            )
        #else
        content
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { value in
                        let translation: Double
                        switch axis {
                        case .vertical:
                            translation = Double(value.translation.height)
                        case .horizontal:
                            translation = Double(value.translation.width)
                        }
                        offset = baseOffset + translation
                    }
                    .onEnded { value in
                        let translation: Double
                        switch axis {
                        case .vertical:
                            translation = Double(value.translation.height)
                        case .horizontal:
                            translation = Double(value.translation.width)
                        }
                        baseOffset += translation
                        offset = baseOffset
                        onEnded?(offset)
                    }
            )
        #endif
    }
}
