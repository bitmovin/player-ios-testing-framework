//
// Bitmovin Player iOS SDK
// Copyright (C) 2023, Bitmovin GmbH, All Rights Reserved
//
// This source code and its use and distribution, is subject to the terms
// and conditions of the applicable license agreement.
//

import BitmovinPlayerCore
import Foundation
import XCTest

@MainActor
internal class PlayerWorld {
    private(set) static var sharedWorld = PlayerWorld()

    private var _currentPlayerTest: PlayerTest?
    internal var currentPlayerTest: PlayerTest! {
        assertStartPlayerTest()

        return _currentPlayerTest
    }

    private init() { }

    internal func startPlayerTest(
        config: PlayerConfig = PlayerConfig(),
        buildViewHierarchyMode: ViewHierarchyBuildMode = .full,
        globalTimeout: TimeInterval = defaultGlobalTimeout,
        heartbeatWindow: TimeInterval? = nil,
        failOnError failOnErrorEnabled: Bool = true,
        setLicenseKeyForTesting: Bool = true,
        file: StaticString = #file,
        line: UInt = #line,
        _ testBlock: PlayerTestBlock
    ) {
        // In case the previous test failed, we need to do the tear down here
        _currentPlayerTest?.tearDown()

        _currentPlayerTest = PlayerTest()

        currentPlayerTest?.startPlayerTest(
            config: config,
            buildViewHierarchyMode: buildViewHierarchyMode,
            globalTimeout: globalTimeout,
            heartbeatWindow: heartbeatWindow,
            failOnError: failOnErrorEnabled,
            setLicenseKeyForTesting: setLicenseKeyForTesting,
            file: file,
            line: line,
            testBlock
        )

        currentPlayerTest?.tearDown()
        _currentPlayerTest = nil
    }

    private func assertStartPlayerTest() {
        guard _currentPlayerTest != nil else {
            XCTFail(
                """
                `playerTest` was not created! Did you forget to call `startPlayerTest`?
                """
            )
            return
        }
    }
}
