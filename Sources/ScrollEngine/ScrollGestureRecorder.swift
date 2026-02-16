import SwiftUI

/// A view modifier that attaches a drag-based scroll gesture to a view
/// and writes the translation value to a `Binding<Double>`.
///
/// The recorded value represents the cumulative pixel offset of the
/// current gesture along the chosen axis. When the gesture ends, the
/// final offset is preserved so the caller can use it for animations,
/// transformations, or any other purpose.
public struct ScrollGestureRecorder: ViewModifier {
    @Binding var offset: Double
    let axis: ScrollAxis
    let onEnded: ((Double) -> Void)?

    @State private var baseOffset: Double = 0

    public func body(content: Content) -> some View {
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
    }
}
