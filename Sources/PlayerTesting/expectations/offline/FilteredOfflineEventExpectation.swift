//
// Bitmovin Player iOS SDK
// Copyright (C) 2021, Bitmovin GmbH, All Rights Reserved
//
// This source code and its use and distribution, is subject to the terms
// and conditions of the applicable license agreement.
//

import BitmovinPlayerCore
import Foundation

/// Class to expect an event of a given type with a certain condition to occur for the specified source
public class FilteredOfflineEventExpectation<T: OfflineEvent>: FilteredEventExpectation<T>,
        SingleOfflineEventExpectation {
    public let offlineContentManager: OfflineContentManager

    public init(
        _ offlineContentManager: OfflineContentManager,
        _ eventClass: T.Type,
        _ filterBlock: @escaping (T) -> Bool
    ) {
        self.offlineContentManager = offlineContentManager
        super.init(eventClass, filterBlock)
    }

    override public func maybeFulfillExpectation(receivedEvent: EventHolder<Event>) -> Bool {
        guard receivedEvent.offlineContentManager === offlineContentManager else {
            isFulfilled = false
            return isFulfilled
        }

        return super.maybeFulfillExpectation(receivedEvent: receivedEvent)
    }

    override internal func copy() -> SingleEventExpectation<T> {
        FilteredOfflineEventExpectation(
            offlineContentManager,
            T.self,
            filterBlock
        )
    }
}
