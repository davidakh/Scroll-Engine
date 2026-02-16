import Testing
import SwiftUI
@testable import ScrollEngine

@Suite("ScrollAxis")
struct ScrollAxisTests {
    @Test("vertical and horizontal are distinct")
    func axisValues() {
        let v = ScrollAxis.vertical
        let h = ScrollAxis.horizontal
        #expect(v != h)
    }
}

@Suite("ScrollGestureRecorder")
struct ScrollGestureRecorderTests {
    @Test("modifier initialises with vertical axis")
    func defaultAxis() {
        var value: Double = 0
        let binding = Binding(get: { value }, set: { value = $0 })
        let recorder = ScrollGestureRecorder(offset: binding, axis: .vertical, onEnded: nil)
        #expect(recorder.axis == .vertical)
    }

    @Test("modifier initialises with horizontal axis")
    func horizontalAxis() {
        var value: Double = 0
        let binding = Binding(get: { value }, set: { value = $0 })
        let recorder = ScrollGestureRecorder(offset: binding, axis: .horizontal, onEnded: nil)
        #expect(recorder.axis == .horizontal)
    }

    @Test("onEnded callback is stored")
    func onEndedStored() {
        var value: Double = 0
        let binding = Binding(get: { value }, set: { value = $0 })
        var called = false
        let recorder = ScrollGestureRecorder(
            offset: binding,
            axis: .vertical,
            onEnded: { _ in called = true }
        )
        recorder.onEnded?(42)
        #expect(called)
    }
}

@Suite("View extension API")
struct ViewExtensionTests {
    @Test("scrollGesture with Double binding compiles and produces a view")
    func doubleBindingAPI() {
        var value: Double = 0
        let binding = Binding(get: { value }, set: { value = $0 })
        let view = Color.clear.scrollGesture(offset: binding)
        #expect(type(of: view) != Never.self)
    }

    @Test("scrollGesture with Int binding compiles and produces a view")
    func intBindingAPI() {
        var value: Int = 0
        let binding = Binding(get: { value }, set: { value = $0 })
        let view = Color.clear.scrollGesture(offset: binding)
        #expect(type(of: view) != Never.self)
    }

    @Test("scrollGesture with callback compiles and produces a view")
    func callbackAPI() {
        let view = Color.clear.scrollGesture { (_: Double) in }
        #expect(type(of: view) != Never.self)
    }

    @Test("scrollGesture with horizontal axis compiles")
    func horizontalAPI() {
        var value: Double = 0
        let binding = Binding(get: { value }, set: { value = $0 })
        let view = Color.clear.scrollGesture(offset: binding, axis: .horizontal)
        #expect(type(of: view) != Never.self)
    }
}

#if os(macOS)
@Suite("macOS ScrollWheelCapture")
struct ScrollWheelCaptureTests {
    @Test("ScrollWheelCapture coordinator installs without error")
    func coordinatorCreation() {
        let coordinator = ScrollWheelCapture.Coordinator()
        #expect(coordinator.view == nil)
        // Coordinator exists and is safe to use before a view is attached
    }
}
#endif
