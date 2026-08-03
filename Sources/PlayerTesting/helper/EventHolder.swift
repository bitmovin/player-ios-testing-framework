import BitmovinPlayerCore
import Foundation

/// A class that holds the event and the `Source` or the `OfflineContentManager` associated with it if exists
public class EventHolder<T: Event> {
    /// The `Source` which emitted the `event` or nil if it is not specific to a source (e.g. an event emitted through
    /// the `BitmovinPlayer` or an `OfflineEvent`)
    let source: Source?

#if os(iOS)
    /// The `OfflineContentManager` which emitted the `event` or nil if it is not specific to a
    /// `OfflineContentManager`  (e.g. the event is `PlayerEvent` or a `SourceEvent`)
    let offlineContentManager: OfflineContentManager?
#endif

    /// An event of type `T`.
    let event: T

#if os(iOS)
    /// Init `EventHolder` with event and source
    init(
        offlineContentManager: OfflineContentManager?,
        event: T
    ) {
        self.source = nil
        self.offlineContentManager = offlineContentManager
        self.event = event
    }
#endif

    /// Init `EventHolder` with event and source
    init(
        source: Source? = nil,
        event: T
    ) {
        self.source = source
#if os(iOS)
        self.offlineContentManager = nil
#endif
        self.event = event
    }
}
