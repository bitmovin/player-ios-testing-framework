//
// Bitmovin Player iOS SDK
// Copyright (C) 2020, Bitmovin GmbH, All Rights Reserved
//
// This source code and its use and distribution, is subject to the terms
// and conditions of the applicable license agreement.
//

import BitmovinPlayerCore
import Foundation

/// Class to expect an event of a given type with a certain condition to occur
public class FilteredEventExpectation<T: Event>: PlainEventExpectation<T> {
    internal let filterBlock: (T) -> Bool

    public init(_ eventClass: T.Type, _ filterBlock: @escaping (T) -> Bool) {
        self.filterBlock = filterBlock
        super.init(eventClass)
    }

    override public func maybeFulfillExpectation(receivedEvent: EventHolder<Event>) -> Bool {
        if super.maybeFulfillExpectation(receivedEvent: receivedEvent) {
            isFulfilled = filterBlock(receivedEvent.event as! T)
        }
        return isFulfilled
    }

    override internal func copy() -> SingleEventExpectation<T> {
        FilteredEventExpectation(T.self, filterBlock)
    }
}
