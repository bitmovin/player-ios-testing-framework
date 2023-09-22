//
// Bitmovin Player iOS SDK
// Copyright (C) 2020, Bitmovin GmbH, All Rights Reserved
//
// This source code and its use and distribution, is subject to the terms
// and conditions of the applicable license agreement.
//

import BitmovinPlayer
import Foundation

/// Class to expect an event of a given type to occur
public class PlainEventExpectation<T: Event>: SingleEventExpectation<T> {
    override public init(_ eventClass: T.Type) {
        super.init(eventClass)
    }

    override public func maybeFulfillExpectation(receivedEvent: EventHolder<Event>) -> Bool {
        isFulfilled = receivedEvent.event is T
        return isFulfilled
    }

    override internal func copy() -> SingleEventExpectation<T> {
        PlainEventExpectation(T.self)
    }
}
