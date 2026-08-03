import OHHTTPStubs
import OHHTTPStubsSwift

extension PlayerTestCallPlayerApi {
    func stubNoInternet(_ testBlock: TestContinuationBlock) async throws {
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
            if let stubDescriptor {
                HTTPStubs.removeStub(stubDescriptor)
            }
        }
        try await testBlock()
    }
}
