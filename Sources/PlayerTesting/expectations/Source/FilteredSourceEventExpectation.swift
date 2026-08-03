import BitmovinPlayerCore
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
