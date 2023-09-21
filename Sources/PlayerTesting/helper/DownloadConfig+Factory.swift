//
// Bitmovin Player iOS SDK
// Copyright (C) 2023, Bitmovin GmbH, All Rights Reserved
//
// This source code and its use and distribution, is subject to the terms
// and conditions of the applicable license agreement.
//

import BitmovinPlayerCore

public extension DownloadConfig {
    static var lowestQuality: DownloadConfig {
        let config = DownloadConfig()
        config.minimumBitrate = 0
        return config
    }
}
