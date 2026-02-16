import SwiftUI

// MARK: - View Extensions

extension View {

    /// Records a scroll gesture on this view and writes the offset to a binding.
    ///
    /// Attach this modifier to any view to begin tracking drag-based scroll
    /// gestures. The cumulative pixel offset along the chosen axis is
    /// continuously written to `offset` while the gesture is active. The value
    /// persists after the gesture ends so it can drive layout, animations, or
    /// any other view transformation.
    ///
    /// ```swift
    /// @State private var scrollValue: Double = 0
    ///
    /// MyContent()
    ///     .scrollGesture(offset: $scrollValue)
    ///     .offset(y: scrollValue)
    /// ```
    ///
    /// - Parameters:
    ///   - offset: A binding that receives the scroll offset in points.
    ///   - axis: The axis to track (`.vertical` by default).
    /// - Returns: A view with the scroll gesture attached.
    public func scrollGesture(
        offset: Binding<Double>,
        axis: ScrollAxis = .vertical
    ) -> some View {
        modifier(ScrollGestureRecorder(offset: offset, axis: axis, onEnded: nil))
    }

    /// Records a scroll gesture and calls a closure with the offset value on
    /// every change.
    ///
    /// This variant is useful when you want to react to scroll changes without
    /// storing state in a binding — for example, to call into a non-SwiftUI
    /// subsystem.
    ///
    /// ```swift
    /// MyContent()
    ///     .scrollGesture(axis: .horizontal) { value in
    ///         print("Scrolled to \(value)")
    ///     }
    /// ```
    ///
    /// - Parameters:
    ///   - axis: The axis to track (`.vertical` by default).
    ///   - onChange: A closure invoked with the current offset every time it
    ///     changes.
    /// - Returns: A view with the scroll gesture attached.
    public func scrollGesture(
        axis: ScrollAxis = .vertical,
        onChange: @escaping (Double) -> Void
    ) -> some View {
        modifier(
            _CallbackScrollRecorder(axis: axis, onChange: onChange)
        )
    }

    /// Records a scroll gesture and writes the offset as an `Int` (rounded
    /// toward zero) to a binding.
    ///
    /// This is a convenience when you need discrete integer values — for
    /// example, to snap content to fixed increments.
    ///
    /// - Parameters:
    ///   - offset: A binding that receives the scroll offset rounded to an `Int`.
    ///   - axis: The axis to track (`.vertical` by default).
    /// - Returns: A view with the scroll gesture attached.
    public func scrollGesture(
        offset: Binding<Int>,
        axis: ScrollAxis = .vertical
    ) -> some View {
        let doubleBinding = Binding<Double>(
            get: { Double(offset.wrappedValue) },
            set: { offset.wrappedValue = Int($0) }
        )
        return modifier(
            ScrollGestureRecorder(offset: doubleBinding, axis: axis, onEnded: nil)
        )
    }
}

// MARK: - Callback-Based Modifier

/// Internal modifier that drives a closure instead of a binding.
struct _CallbackScrollRecorder: ViewModifier {
    let axis: ScrollAxis
    let onChange: (Double) -> Void

    @State private var offset: Double = 0

    func body(content: Content) -> some View {
        content
            .modifier(
                ScrollGestureRecorder(
                    offset: $offset,
                    axis: axis,
                    onEnded: nil
                )
            )
            .onChange(of: offset) { _, newValue in
                onChange(newValue)
            }
    }
}
