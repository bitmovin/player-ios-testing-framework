//
// Bitmovin Player iOS SDK
// Copyright (C) 2020, Bitmovin GmbH, All Rights Reserved
//
// This source code and its use and distribution, is subject to the terms
// and conditions of the applicable license agreement.
//

import Foundation
import XCTest

public class Condition {
    var isCancelled: Bool = false
    var isFulfilled: Bool {
        expectation.expectedFulfillmentCount == actualFulfillmentCount
    }
    var description: String {
        get {
            expectation.expectationDescription
        }
        set {
            expectation.expectationDescription = newValue
        }
    }
    private let expectation: XCTestExpectation
    private var actualFulfillmentCount: Int = 0
    var expectedFulfillmentCount: Int {
        get {
            expectation.expectedFulfillmentCount
        }
        set {
            expectation.expectedFulfillmentCount = newValue
        }
    }

    init(description: String, expectedFulfillmentCount: Int = 1) {
        expectation = XCTestExpectation(description: description)
        expectation.expectedFulfillmentCount = expectedFulfillmentCount
    }

    func fulfill() {
        if isFulfilled {
            return
        }
        actualFulfillmentCount += 1
        expectation.fulfill()
    }

    func cancel() {
        if isCancelled {
            return
        }
        isCancelled = true
        expectation.fulfill()
    }

    func wait(timeout: TimeInterval) {
        _ = XCTWaiter.wait(for: [expectation], timeout: timeout)
    }
}
