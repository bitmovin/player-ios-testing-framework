//
// Bitmovin Player iOS SDK
// Copyright (C) 2020, Bitmovin GmbH, All Rights Reserved
//
// This source code and its use and distribution, is subject to the terms
// and conditions of the applicable license agreement.
//

import BitmovinPlayerCore
import Foundation

/// Class to expect multiple events in any order
public class EventBagExpectation: MultipleEventsExpectation {
    override var expectedFulfillmentCount: Int {
        singleExpectations.count
    }

    override public func isNextExpectationMet(receivedEvent: EventHolder<Event>) -> Bool {
        let nextSingleEventExpectation = singleExpectations
            .first { !$0.isFulfilled && $0.maybeFulfillExpectation(receivedEvent: receivedEvent) }

        return nextSingleEventExpectation?.isFulfilled ?? false
    }
}

extension EventBagExpectation: CustomStringConvertible {
    public var description: String {
        singleExpectations
            .map { $0.description }
            .joined(separator: " - ")
    }
}
