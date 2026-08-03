#if os(iOS)
import BitmovinPlayerCore

public extension DownloadConfig {
    static var lowestQuality: DownloadConfig {
        let config = DownloadConfig()
        config.minimumBitrate = 0
        return config
    }
}
#endif
