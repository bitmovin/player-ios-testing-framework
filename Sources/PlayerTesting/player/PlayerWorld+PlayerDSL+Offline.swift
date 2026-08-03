import Foundation

extension PlayerWorld {
    func stubNoInternet(_ testBlock: TestContinuationBlock) async throws {
        try await currentPlayerTest.stubNoInternet(testBlock)
    }
}
