//
// Bitmovin Player iOS SDK
// Copyright (C) 2020, Bitmovin GmbH, All Rights Reserved
//
// This source code and its use and distribution, is subject to the terms
// and conditions of the applicable license agreement.
//

import BitmovinPlayer
import Foundation

/// A class that holds the event and the `Source` or the `OfflineContentManager` associated with it if exists
public class EventHolder<T: Event> {
    /// The `Source` which emitted the `event` or nil if it is not specific to a source (e.g. an event emitted through
    /// the `BitmovinPlayer` or an `OfflineEvent`)
    let source: Source?

    /// The `OfflineContentManager` which emitted the `event` or nil if it is not specific to a
    /// `OfflineContentManager`  (e.g. the event is `PlayerEvent` or a `SourceEvent`)
    let offlineContentManager: OfflineContentManager?

    /// An event of type `T`.
    let event: T

    /// Init `EventHolder` with event and source
    init(
        source: Source? = nil,
        offlineContentManager: OfflineContentManager? = nil,
        event: T
    ) {
        self.offlineContentManager = offlineContentManager
        self.source = source
        self.event = event
    }
}
