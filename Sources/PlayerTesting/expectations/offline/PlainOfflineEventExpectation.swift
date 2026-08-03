#if os(iOS)
import BitmovinPlayerCore
import Foundation

/// Class to expect an event of a given type to occur for the specified source
public class PlainOfflineEventExpectation<T: OfflineEvent>: PlainEventExpectation<T>, SingleOfflineEventExpectation {
    public let offlineContentManager: OfflineContentManager

    public init(_ offlineContentManager: OfflineContentManager, _ eventClass: T.Type) {
        self.offlineContentManager = offlineContentManager
        super.init(eventClass)
    }

    override public func maybeFulfillExpectation(receivedEvent: EventHolder<Event>) -> Bool {
        guard receivedEvent.offlineContentManager === offlineContentManager else {
            isFulfilled = false
            return isFulfilled
        }

        return super.maybeFulfillExpectation(receivedEvent: receivedEvent)
    }

    override internal func copy() -> SingleEventExpectation<T> {
        PlainOfflineEventExpectation(offlineContentManager, T.self)
    }
}
#endif
