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

    private init() {}

    internal func startPlayerTest(
        config: PlayerConfig = PlayerConfig(),
        buildViewHierarchyMode: ViewHierarchyBuildMode = .full,
        globalTimeout: TimeInterval = defaultGlobalTimeout,
        heartbeatWindow: TimeInterval? = nil,
        failOnError failOnErrorEnabled: Bool = true,
        setLicenseKeyForTesting: Bool = true,
        playerCreator: (_ config: PlayerConfig) -> Player = PlayerCoreFactory.createPlayer(playerConfig:),
        file: StaticString = #file,
        line: UInt = #line,
        _ testBlock: PlayerTestBlock
    ) async throws {
        let playerTest = PlayerTest()
        _currentPlayerTest = playerTest

        defer {
            playerTest.tearDown()
            if _currentPlayerTest === playerTest {
                _currentPlayerTest = nil
            }
        }

        try await playerTest.startPlayerTest(
            config: config,
            buildViewHierarchyMode: buildViewHierarchyMode,
            globalTimeout: globalTimeout,
            heartbeatWindow: heartbeatWindow,
            failOnError: failOnErrorEnabled,
            setLicenseKeyForTesting: setLicenseKeyForTesting,
            playerCreator: playerCreator,
            file: file,
            line: line,
            testBlock
        )
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
