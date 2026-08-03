#if os(iOS)
import BitmovinPlayerCore
import Foundation

/// Represents an expectation for a specific scenario involving one [OfflineEvent]
public protocol SingleOfflineEventExpectation {
    var offlineContentManager: OfflineContentManager { get }
}
#endif
