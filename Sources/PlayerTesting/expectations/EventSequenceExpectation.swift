import BitmovinPlayerCore
import Foundation

/// Class to expect an given event sequence in a given order
public class EventSequenceExpectation: MultipleEventsExpectation {
    override var expectedFulfillmentCount: Int {
        singleExpectations.count
    }

    override public func isNextExpectationMet(receivedEvent: EventHolder<Event>) -> Bool {
        guard let nextSingleEventExpectation = singleExpectations.first(where: { !$0.isFulfilled }) else {
            log(.warning("[EventSequenceExpectation] no unfulfilled expectation left"))
            return true
        }

        return nextSingleEventExpectation.maybeFulfillExpectation(receivedEvent: receivedEvent)
    }
}

extension EventSequenceExpectation: CustomStringConvertible {
    public var description: String {
        let firstUnfulfilledIndex = singleExpectations.firstIndex { !$0.isFulfilled } ?? singleExpectations.count

        return singleExpectations
            .enumerated()
            .map { index, element in
                element.description { isFulfilled in
                    guard index <= firstUnfulfilledIndex else {
                        return .invalid
                    }
                    return isFulfilled ? .fulfilled : .unfulfilled
                }
            }
            .joined(separator: " - ")
    }
}
