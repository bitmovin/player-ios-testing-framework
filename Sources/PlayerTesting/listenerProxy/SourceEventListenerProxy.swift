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

/// Class which handles adding and removing closures to a given event type for a given source
/// - Note: Since we have a delegate approach for adding and removing listeners we can't just pass
///         a block for a specific event like in Android or Web. This class simulates this behaviour by
///         storing the blocks and calling them when an event occurs.
internal class SourceEventListenerProxy: NSObject {
    private var eventRecordings: [String: (SourceEvent, Source) -> Void] = [:]
    var onEventCallback: ((_ event: Event) -> Void)?

    func registerEvent<T: SourceEvent>(
        _ eventClass: Event.Type,
        eventHandlerBlock: @escaping (T, Source) -> Void
    ) throws {
        let className = String(describing: eventClass)
        if eventRecordings[className] != nil {
            throw EventRecorderError.duplicateEventExpectation(eventName: className)
        }

        let blockWrapper: (SourceEvent, Source) -> Void = { event, source in
            eventHandlerBlock(event as! T, source)
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

extension SourceEventListenerProxy: SourceListener {
    func onEvent(_ event: SourceEvent, source: Source) {
        onEventCallback?(event)

        let className = String(describing: type(of: event))
        eventRecordings[className]?(event, source)
    }
}
