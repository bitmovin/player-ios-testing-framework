import XCTest

internal class PlayerTestExpectation {
    /// The number of times reject() must be called before the test fails..
    /// Default is 1.
    var assertAtRejectCount = 1

    private var rejectsCount = 0

    /// Reject the expectation.
    /// When the assertAtRejectCount value is reached it will fail the test.
    func reject(_ reason: String, file: StaticString = #file, line: UInt = #line) {
        rejectsCount += 1

        if rejectsCount >= assertAtRejectCount {
            XCTFail(reason, file: file, line: line)
        }
    }
}
