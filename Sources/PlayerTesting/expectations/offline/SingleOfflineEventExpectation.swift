//
// Bitmovin Player iOS SDK
// Copyright (C) 2021, Bitmovin GmbH, All Rights Reserved
//
// This source code and its use and distribution, is subject to the terms
// and conditions of the applicable license agreement.
//

#if os(iOS)
import BitmovinPlayerCore
import Foundation

/// Represents an expectation for a specific scenario involving one [OfflineEvent]
public protocol SingleOfflineEventExpectation {
    var offlineContentManager: OfflineContentManager { get }
}
#endif
