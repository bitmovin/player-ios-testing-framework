import BitmovinPlayerCore
import Foundation

/// Class to expect a given eventType to happen multiple times
public class RepeatedEventExpectation<T: Event>: EventSequenceExpectation {
    public init(_ singleEventExpectation: SingleEventExpectation<T>, _ count: Int) {
        super.init(
            (0..<count).map { _ -> SingleExpectation in
                singleEventExpectation.copy()
            }
        )
    }

    public convenience init(_ eventClass: T.Type, _ count: Int) {
        self.init(PlainEventExpectation(T.self), count)
    }
}
