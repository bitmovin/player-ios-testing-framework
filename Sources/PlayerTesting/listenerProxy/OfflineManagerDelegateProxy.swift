//
// Bitmovin Player iOS SDK
// Copyright (C) 2021, Bitmovin GmbH, All Rights Reserved
//
// This source code and its use and distribution, is subject to the terms
// and conditions of the applicable license agreement.
//

import BitmovinPlayer
import Foundation

/// Class which handles `OfflineManagerDelegate` by calling passed callbacks
class OfflineManagerDelegateProxy: NSObject {
    private var onSuspendedDownloadsRestored: (() -> Void)?

    func setSuspendedDownloadsRestoredCallback(_ suspendedDownloadsRestoredCallback: (() -> Void)?) {
        onSuspendedDownloadsRestored = suspendedDownloadsRestoredCallback
    }
}

extension OfflineManagerDelegateProxy: OfflineManagerDelegate {
    func offlineManagerDidRestoreSuspendedDownloads(_ offlineManager: OfflineManager) {
        onSuspendedDownloadsRestored?()
    }
}
