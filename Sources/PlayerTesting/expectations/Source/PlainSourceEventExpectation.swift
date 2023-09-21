//
// Bitmovin Player iOS SDK
// Copyright (C) 2020, Bitmovin GmbH, All Rights Reserved
//
// This source code and its use and distribution, is subject to the terms
// and conditions of the applicable license agreement.
//

import BitmovinPlayerCore
import Foundation

/// Class to expect an event of a given type to occur for the specified source
public class PlainSourceEventExpectation<T: SourceEvent>: PlainEventExpectation<T>, SingleSourceEventExpectation {
    public let source: Source

    public init(_ source: Source, _ eventClass: T.Type) {
        self.source = source
        super.init(eventClass)
    }

    override public func maybeFulfillExpectation(receivedEvent: EventHolder<Event>) -> Bool {
        guard receivedEvent.source === source else {
            isFulfilled = false
            return isFulfilled
        }

        return super.maybeFulfillExpectation(receivedEvent: receivedEvent)
    }

    override internal func copy() -> SingleEventExpectation<T> {
        PlainSourceEventExpectation(source, T.self)
    }
}
