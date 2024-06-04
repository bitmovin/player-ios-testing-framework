//
// Bitmovin Player iOS SDK
// Copyright (C) 2022, Bitmovin GmbH, All Rights Reserved
//
// This source code and its use and distribution, is subject to the terms
// and conditions of the applicable license agreement.
//

import Foundation

extension PlayerWorld {
    internal func stubNoInternet(_ testBlock: TestContinuationBlock) async throws {
        try await currentPlayerTest.stubNoInternet(testBlock)
    }
}
