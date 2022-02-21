//
// Bitmovin Player iOS SDK
// Copyright (C) 2021, Bitmovin GmbH, All Rights Reserved
//
// This source code and its use and distribution, is subject to the terms
// and conditions of the applicable license agreement.
//

import OHHTTPStubs

extension PlayerTestCallPlayerApi {
    /// This stubs all requests made via standard iOS network APIs (URLSession, URLConnection)
    /// to return the standard "not connected to internet" error
    func stubNoInternet(_ testBlock: () -> Void) {
        verifyPlayer { player in
            assert(
                player.config.tweaksConfig.isCustomHlsLoadingEnabled,
                "isCustomHlsLoadingEnabled=false results in false positive tests"
            )
        }
        weak var stubDescriptor = stub(
            condition: { request in
                // we have still allow requests with scheme `data:` as those are considered local
                request.url?.scheme != "data"
            },
            response: { _ in
                HTTPStubsResponse(
                    error: NSError(
                        domain: NSURLErrorDomain,
                        code: Int(CFNetworkErrors.cfurlErrorNotConnectedToInternet.rawValue)
                    )
                )
            }
        )
        defer {
            if let stubDescriptor = stubDescriptor {
                HTTPStubs.removeStub(stubDescriptor)
            }
        }
        testBlock()
    }
}
