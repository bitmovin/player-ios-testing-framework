//
// Bitmovin Player iOS SDK
// Copyright (C) 2021, Bitmovin GmbH, All Rights Reserved
//
// This source code and its use and distribution, is subject to the terms
// and conditions of the applicable license agreement.
//

import BitmovinPlayer
import Foundation
import XCTest

/// Class which handles adding and removing closures to a given event type for a given `OfflineContentManager`
/// - Note: Since we have a delegate approach for adding and removing listeners we can't just pass
/// a block for a specific event like in Android or Web. This class simulates this behaviour by
/// storing the blocks and calling them when an event occurs.
class OfflineContentManagerEventListenerProxy: NSObject {
    private var eventRecordings: [String: (OfflineEvent, OfflineContentManager) -> Void] = [:]

    func registerEvent<T: Event>(
        _ eventClass: Event.Type,
        eventHandlerBlock: @escaping (T, OfflineContentManager) -> Void
    ) throws {
        let className = String(describing: eventClass)
        if eventRecordings[className] != nil {
            throw EventRecorderError.duplicateEventExpectation(eventName: className)
        }

        let blockWrapper: (OfflineEvent, OfflineContentManager) -> Void = { event, offlineContentManager in
            eventHandlerBlock(event as! T, offlineContentManager)
        }

        eventRecordings[className] = blockWrapper
    }

    func unregisterEvent(
        _ eventClass: Event.Type
    ) {
        let className = String(describing: eventClass)
        eventRecordings[className] = nil
    }
}

extension OfflineContentManagerEventListenerProxy: OfflineContentManagerListener {
    func onEvent(_ event: OfflineEvent, offlineContentManager: OfflineContentManager) {
        print("[PlayerTesting] received offline event: '\(event.name)'")

        var eventName = event.name
        // Remove "on" from the start of the string
        eventName = "\(eventName.dropFirst(2))"
        eventName = "BMP\(eventName)Event"

        eventRecordings[eventName]?(event, offlineContentManager)
    }
}
