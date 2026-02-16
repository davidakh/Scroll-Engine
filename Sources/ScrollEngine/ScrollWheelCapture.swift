#if os(macOS)
import AppKit
import SwiftUI

/// An invisible `NSView` placed as a background behind content that captures
/// native scroll-wheel / trackpad events via a local event monitor.
///
/// This approach:
/// - Does **not** use `ScrollView`.
/// - Captures real macOS scroll events (trackpad two-finger, mouse wheel,
///   Magic Mouse surface scroll) directly on the view's bounds.
/// - Returns nil from `hitTest` so clicks pass through to the content.
/// - Uses a local `NSEvent` monitor scoped to the view's frame so only
///   scroll events over this view are processed.
struct ScrollWheelCapture: NSViewRepresentable {
    let axis: ScrollAxis
    let onDelta: (Double) -> Void
    let onEnded: (() -> Void)?

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    func makeNSView(context: Context) -> NSView {
        let view = NSView(frame: .zero)
        let coordinator = context.coordinator
        coordinator.view = view
        coordinator.axis = axis
        coordinator.onDelta = onDelta
        coordinator.onEnded = onEnded
        coordinator.installMonitor()
        return view
    }

    func updateNSView(_ nsView: NSView, context: Context) {
        let coordinator = context.coordinator
        coordinator.axis = axis
        coordinator.onDelta = onDelta
        coordinator.onEnded = onEnded
    }

    // MARK: - Coordinator

    /// Coordinator owns the `NSEvent` local monitor and forwards scroll deltas
    /// that land within the associated view's bounds.
    final class Coordinator: @unchecked Sendable {
        var axis: ScrollAxis = .vertical
        var onDelta: ((Double) -> Void)?
        var onEnded: (() -> Void)?
        weak var view: NSView?
        private var monitor: Any?

        func installMonitor() {
            guard monitor == nil else { return }
            monitor = NSEvent.addLocalMonitorForEvents(matching: .scrollWheel) { [weak self] event in
                self?.handleScrollWheel(event)
                return event // pass the event through so other responders still see it
            }
        }

        private func handleScrollWheel(_ event: NSEvent) {
            guard let view = view, view.window != nil else { return }
            let locationInView = view.convert(event.locationInWindow, from: nil)
            guard view.bounds.contains(locationInView) else { return }

            let delta: Double
            switch axis {
            case .vertical:
                delta = Double(event.scrollingDeltaY)
            case .horizontal:
                delta = Double(event.scrollingDeltaX)
            }

            if delta != 0 {
                onDelta?(delta)
            }

            let gestureEnded = event.phase == .ended || event.phase == .cancelled
            let momentumEnded = event.momentumPhase == .ended
            if gestureEnded || momentumEnded {
                onEnded?()
            }
        }

        deinit {
            if let monitor = monitor {
                NSEvent.removeMonitor(monitor)
            }
        }
    }
}
#endif
