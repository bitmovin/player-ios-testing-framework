//
// Bitmovin Player iOS SDK
// Copyright (C) 2025, Bitmovin GmbH, All Rights Reserved
//
// This source code and its use and distribution, is subject to the terms
// and conditions of the applicable license agreement.
//

import BitmovinPlayerCore

extension Source {
    var readableReference: String {
        "Source - \(Unmanaged.passUnretained(self).toOpaque())"
    }
}
