//
// Bitmovin Player iOS SDK
// Copyright (C) 2021, Bitmovin GmbH, All Rights Reserved
//
// This source code and its use and distribution, is subject to the terms
// and conditions of the applicable license agreement.
//

import BitmovinPlayerCore
import Foundation

/// Class to expect at least one out of multiple events
public class AnyEventExpectation: MultipleEventsExpectation {
    override var expectedFulfillmentCount: Int {
        1
    }

    override public func isNextExpectationMet(receivedEvent: EventHolder<Event>) -> Bool {
        let nextSingleEventExpectation = singleExpectations
            .first { $0.maybeFulfillExpectation(receivedEvent: receivedEvent) }
        return nextSingleEventExpectation?.isFulfilled ?? false
    }
}

extension AnyEventExpectation: CustomStringConvertible {
    public var description: String {
        singleExpectations
            .map(\.description)
            .joined(separator: " - ")
    }
}
