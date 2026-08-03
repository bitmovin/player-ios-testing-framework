#if os(iOS)
import BitmovinPlayerCore
import Foundation

/// Class which handles `OfflineManagerDelegate` by calling passed callbacks
internal class OfflineManagerDelegateProxy: NSObject {
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
#endif
