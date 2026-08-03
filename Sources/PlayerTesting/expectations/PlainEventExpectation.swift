import BitmovinPlayerCore
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
