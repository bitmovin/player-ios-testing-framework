//
// Bitmovin Player iOS SDK
// Copyright (C) 2020, Bitmovin GmbH, All Rights Reserved
//
// This source code and its use and distribution, is subject to the terms
// and conditions of the applicable license agreement.
//

import BitmovinPlayerCore
import Foundation
import XCTest

/// Class which handles adding and removing closures to a given event type
/// - Note: Since we have a delegate approach for adding and removing listeners we can't just pass
///         a block for a specific event like in Android or Web. This class simulates this behaviour by
///         storing the blocks and calling them when an event occurs.
internal class EventListenerProxy: NSObject {
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

    func setHeartbeatCallback(_ heartbeatCallback: (() -> Void)?) {
        onHeartbeatCallback = heartbeatCallback
    }
}

extension EventListenerProxy: PlayerListener {
    func onEvent(_ event: Event, player: Player) {
        onEventCallback?(event)

        let className = String(describing: type(of: event))
        eventRecordings[className]?(event)
        onHeartbeatCallback?()
    }
}

internal enum EventRecorderError: Error {
    case duplicateEventExpectation(eventName: String)
}
