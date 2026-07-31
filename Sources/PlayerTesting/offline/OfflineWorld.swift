//
// Bitmovin Player iOS SDK
// Copyright (C) 2023, Bitmovin GmbH, All Rights Reserved
//
// This source code and its use and distribution, is subject to the terms
// and conditions of the applicable license agreement.
//

#if os(iOS)
import BitmovinPlayerCore
import Foundation
import XCTest

@MainActor
internal class OfflineWorld {
    private(set) static var sharedWorld = OfflineWorld()

    private var _currentOfflineTest: OfflineTest?
    internal var currentOfflineTest: OfflineTest! {
        assertStartOfflineTest()

        return _currentOfflineTest
    }

    private init() {}

    internal func startOfflineTest(
        offlineConfig: OfflineConfig = OfflineConfig(),
        failOnError failOnErrorEnabled: Bool = true,
        waitForSuspendedDownloadsRestoring: Bool = true,
        file: StaticString = #file,
        line: UInt = #line,
        _ testBlock: OfflineTestBlock
    ) async throws {
        try await _currentOfflineTest?.tearDown()
        _currentOfflineTest = OfflineTest()

        try await currentOfflineTest?.startOfflineTest(
            offlineConfig: offlineConfig,
            failOnError: failOnErrorEnabled,
            waitForSuspendedDownloadsRestoring: waitForSuspendedDownloadsRestoring,
            file: file,
            line: line,
            testBlock
        )

        try await currentOfflineTest?.tearDown()
        _currentOfflineTest = nil
    }

    private func assertStartOfflineTest() {
        guard _currentOfflineTest != nil else {
            XCTFail(
                """
                `offlineTest` was not created! Did you forget to call `startOfflineTest`?
                """
            )
            return
        }
    }
}
#endif
