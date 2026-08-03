import BitmovinPlayerCore
import Foundation
import XCTest

internal class PlayerViewEventListenerProxy: NSObject {
    private var eventRecordings: [String: (Event) -> Void] = [:]
    private var onHeartbeatCallback: (() -> Void)?
    var onEventCallback: ((_ event: Event, _ sender: String) -> Void)?

    func registerEvent<T: Event>(
        _ eventClass: Event.Type,
        eventHandlerBlock: @escaping (T) -> Void
    ) throws {
        let className = String(describing: eventClass)
        if eventRecordings[className] != nil {
            throw EventRecorderError.duplicateEventExpectation(eventName: className)
        }

        let blockWrapper: (Event) -> Void = { event in
            eventHandlerBlock(event as! T)
        }

        eventRecordings[className] = blockWrapper
    }

    func unregisterEvent(
        _ eventClass: Event.Type
    ) {
        let className = String(describing: eventClass)
        eventRecordings[className] = nil
    }

    private func onEvent(_ event: Event, view: PlayerView) {
        onEventCallback?(event, view.readableReference)

        let className = String(describing: type(of: event))
        eventRecordings[className]?(event)
        onHeartbeatCallback?()
    }
}

extension PlayerViewEventListenerProxy: UserInterfaceListener {
    func onFullscreenEnter(_ event: FullscreenEnterEvent, view: PlayerView) {
        onEvent(event, view: view)
    }

    func onFullscreenExit(_ event: FullscreenExitEvent, view: PlayerView) {
        onEvent(event, view: view)
    }

    func onFullscreenEnabled(_ event: FullscreenEnabledEvent, view: PlayerView) {
        onEvent(event, view: view)
    }

    func onFullscreenDisabled(_ event: FullscreenDisabledEvent, view: PlayerView) {
        onEvent(event, view: view)
    }

    func onPictureInPictureEnter(_ event: PictureInPictureEnterEvent, view: PlayerView) {
        onEvent(event, view: view)
    }

    func onPictureInPictureEntered(_ event: PictureInPictureEnteredEvent, view: PlayerView) {
        onEvent(event, view: view)
    }

    func onPictureInPictureExit(_ event: PictureInPictureExitEvent, view: PlayerView) {
        onEvent(event, view: view)
    }

    func onPictureInPictureExited(_ event: PictureInPictureExitedEvent, view: PlayerView) {
        onEvent(event, view: view)
    }

    func onControlsShow(_ event: ControlsShowEvent, view: PlayerView) {
        onEvent(event, view: view)
    }

    func onControlsHide(_ event: ControlsHideEvent, view: PlayerView) {
        onEvent(event, view: view)
    }

    func onScalingModeChanged(_ event: ScalingModeChangedEvent, view: PlayerView) {
        onEvent(event, view: view)
    }

    nonisolated func onPictureInPictureAvailabilityChanged(
        _ event: PictureInPictureAvailabilityChangedEvent,
        view: PlayerView
    ) {
        onEvent(event, view: view)
    }

#if !os(tvOS)
    nonisolated func onVideoBoundsChanged(_ event: VideoBoundsChangedEvent, view: PlayerView) {
        onEvent(event, view: view)
    }
#endif
}

extension PlayerView {
    nonisolated var readableReference: String {
        "PlayerView - \(Unmanaged.passUnretained(self).toOpaque())"
    }
}
