//
// Bitmovin Player iOS SDK
// Copyright (C) 2023, Bitmovin GmbH, All Rights Reserved
//
// This source code and its use and distribution, is subject to the terms
// and conditions of the applicable license agreement.
//

import BitmovinPlayerCore
import Foundation
import XCTest

internal class PlayerViewEventListenerProxy: NSObject {
    private var eventRecordings: [String: (Event) -> Void] = [:]
    private var onHeartbeatCallback: (() -> Void)?
    var onEventCallback: ((_ event: Event) -> Void)?

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
        onEventCallback?(event)

        let className = String(describing: type(of: event))
        eventRecordings[className]?(event)
        onHeartbeatCallback?()
    }
}

extension PlayerViewEventListenerProxy: UserInterfaceListener {
    public func onFullscreenEnter(_ event: FullscreenEnterEvent, view: PlayerView) {
        onEvent(event, view: view)
    }

    public func onFullscreenExit(_ event: FullscreenExitEvent, view: PlayerView) {
        onEvent(event, view: view)
    }

    public func onFullscreenEnabled(_ event: FullscreenEnabledEvent, view: PlayerView) {
        onEvent(event, view: view)
    }

    public func onFullscreenDisabled(_ event: FullscreenDisabledEvent, view: PlayerView) {
        onEvent(event, view: view)
    }

    public func onPictureInPictureEnter(_ event: PictureInPictureEnterEvent, view: PlayerView) {
        onEvent(event, view: view)
    }

    public func onPictureInPictureEntered(_ event: PictureInPictureEnteredEvent, view: PlayerView) {
        onEvent(event, view: view)
    }

    public func onPictureInPictureExit(_ event: PictureInPictureExitEvent, view: PlayerView) {
        onEvent(event, view: view)
    }

    public func onPictureInPictureExited(_ event: PictureInPictureExitedEvent, view: PlayerView) {
        onEvent(event, view: view)
    }

    public func onControlsShow(_ event: ControlsShowEvent, view: PlayerView) {
        onEvent(event, view: view)
    }

    public func onControlsHide(_ event: ControlsHideEvent, view: PlayerView) {
        onEvent(event, view: view)
    }

    public func onScalingModeChanged(_ event: ScalingModeChangedEvent, view: PlayerView) {
        onEvent(event, view: view)
    }
}
