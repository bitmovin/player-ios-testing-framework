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
            .map(\.description)
            .joined(separator: " - ")
    }
}
