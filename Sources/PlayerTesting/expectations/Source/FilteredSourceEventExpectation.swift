//
// Bitmovin Player iOS SDK
// Copyright (C) 2021, Bitmovin GmbH, All Rights Reserved
//
// This source code and its use and distribution, is subject to the terms
// and conditions of the applicable license agreement.
//

import BitmovinPlayer
import Foundation

/// Class to expect an event of a given type with a certain condition to occur for the specified source
public class FilteredSourceEventExpectation<T: SourceEvent>: FilteredEventExpectation<T>, SingleSourceEventExpectation {
    public let source: Source

    public init(
        _ source: Source,
        _ eventClass: T.Type,
        _ filterBlock: @escaping (T) -> Bool
    ) {
        self.source = source
        super.init(eventClass, filterBlock)
    }

    override public func maybeFulfillExpectation(receivedEvent: EventHolder<Event>) -> Bool {
        guard receivedEvent.source === source else {
            isFulfilled = false
            return isFulfilled
        }

        return super.maybeFulfillExpectation(receivedEvent: receivedEvent)
    }

    override internal func copy() -> SingleEventExpectation<T> {
        FilteredSourceEventExpectation(source, T.self, filterBlock)
    }
}
