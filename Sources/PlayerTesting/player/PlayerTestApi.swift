//
// Bitmovin Player iOS SDK
// Copyright (C) 2020, Bitmovin GmbH, All Rights Reserved
//
// This source code and its use and distribution, is subject to the terms
// and conditions of the applicable license agreement.
//

import BitmovinPlayerCore
import Foundation
import XCTest

internal typealias PlayerTestApi =
    PlayerTestLifecycleApi &
    PlayerTestSingleEventExpectationApi &
    PlayerTestMultipleEventsExpectationApi &
    PlayerTestRejectEventApi &
    PlayerTestRejectEventsApi &
    PlayerTestCallPlayerAndExpectApi &
    PlayerTestCallPlayerApi &
    PlayerTestConvenienceApi

public enum ViewHierarchyBuildMode {
    public static let full = Self.full(PlayerViewConfig())
    public static let viewOnly = Self.viewOnly(PlayerViewConfig())

    case full(_ playerViewConfig: PlayerViewConfig)
    case viewOnly(_ playerViewConfig: PlayerViewConfig)
    case none
}

/// Provides all necessary API to conveniently write system tests.
internal protocol PlayerTestLifecycleApi {
    func startPlayerTest(
        config: PlayerConfig,
        buildViewHierarchyMode: ViewHierarchyBuildMode,
        globalTimeout: TimeInterval,
        heartbeatWindow: TimeInterval?,
        failOnError failOnErrorEnabled: Bool,
        setLicenseKeyForTesting: Bool,
        file: StaticString,
        line: UInt,
        _ testBlock: PlayerTestBlock
    )
}

internal protocol PlayerTestSingleEventExpectationApi {
    func expectEvent<T: PlayerEvent>(
        _ eventClass: T.Type,
        timeout: TimeInterval?,
        file: StaticString,
        line: UInt,
        eventHandlerBlock: ((T) -> Void)?
    )

    func expectEvent<T: SourceEvent>(
        _ eventClass: T.Type,
        timeout: TimeInterval?,
        file: StaticString,
        line: UInt,
        eventHandlerBlock: ((T) -> Void)?
    )

    func expectEvent<T: PlayerEvent>(
        _ eventExpectation: SingleEventExpectation<T>,
        timeout: TimeInterval?,
        file: StaticString,
        line: UInt,
        eventHandlerBlock: ((T) -> Void)?
    )

    func expectEvent<T: SourceEvent>(
        _ eventExpectation: SingleEventExpectation<T>,
        timeout: TimeInterval?,
        file: StaticString,
        line: UInt,
        eventHandlerBlock: ((T) -> Void)?
    )
}

internal protocol PlayerTestMultipleEventsExpectationApi {
    func expectEvents(
        _ eventClasses: [Event.Type],
        timeout: TimeInterval?,
        file: StaticString,
        line: UInt,
        eventHandlerBlock: (([Event]) -> Void)?
    )

    func expectEvents(
        _ multipleEventExpectation: MultipleEventsExpectation,
        timeout: TimeInterval?,
        file: StaticString,
        line: UInt,
        eventHandlerBlock: (([Event]) -> Void)?
    )
}

internal protocol PlayerTestRejectEventApi {
    func rejectEvent<T: PlayerEvent>(
        file: StaticString,
        line: UInt,
        _ eventClass: T.Type,
        _ testContinuationBlock: () -> Void
    )

    func rejectEvent<T: SourceEvent>(
        file: StaticString,
        line: UInt,
        _ eventClass: T.Type,
        _ testContinuationBlock: () -> Void
    )

    func rejectEvent<T: PlayerEvent>(
        file: StaticString,
        line: UInt,
        _ eventExpectation: SingleEventExpectation<T>,
        _ testContinuationBlock: () -> Void
    )

    func rejectEvent<T: SourceEvent>(
        file: StaticString,
        line: UInt,
        _ eventExpectation: SingleEventExpectation<T>,
        _ testContinuationBlock: () -> Void
    )
}

internal protocol PlayerTestRejectEventsApi {
    func rejectEvents(
        file: StaticString,
        line: UInt,
        _ eventClasses: [Event.Type],
        _ testContinuationBlock: () -> Void
    )

    func rejectEvents(
        file: StaticString,
        line: UInt,
        _ multipleEventExpectation: MultipleEventsExpectation,
        _ testContinuationBlock: () -> Void
    )
}

internal protocol PlayerTestCallPlayerAndExpectApi {
    func callPlayerAndExpectEvent<T: Event>(
        _ playerBlock: @escaping (Player) -> Void,
        _ eventClass: T.Type,
        timeout: TimeInterval?,
        file: StaticString,
        line: UInt,
        eventHandlerBlock: ((T) -> Void)?
    )

    func callPlayerAndExpectEvent<T: Event>(
        _ playerBlock: @escaping (Player) -> Void,
        _ eventExpectation: SingleEventExpectation<T>,
        timeout: TimeInterval?,
        file: StaticString,
        line: UInt,
        eventHandlerBlock: ((T) -> Void)?
    )

    func callPlayerAndExpectEvents(
        _ playerBlock: @escaping (Player) -> Void,
        _ eventClasses: [Event.Type],
        timeout: TimeInterval?,
        file: StaticString,
        line: UInt,
        eventHandlerBlock: (([Event]) -> Void)?
    )

    func callPlayerAndExpectEvents(
        _ playerBlock: @escaping (Player) -> Void,
        _ multipleEventsExpectation: MultipleEventsExpectation,
        timeout: TimeInterval?,
        file: StaticString,
        line: UInt,
        eventHandlerBlock: (([Event]) -> Void)?
    )
}

internal protocol PlayerTestCallPlayerApi {
    func callPlayer(_ playerBlock: @escaping (Player) -> Void)

    func verifyPlayer(_ playerBlock: @escaping (Player) -> Void)

    func safeVerifyPlayer(_ playerBlock: @escaping (Player?) -> Void)
}

internal protocol PlayerTestConvenienceApi {
    func createSource(sourceConfig: SourceConfig) -> Source

    func load(
        _ sourceConfig: SourceConfig,
        preloadAllSources: Bool,
        replayMode: ReplayMode,
        timeout: TimeInterval?,
        file: StaticString,
        line: UInt
    )

    func load(
        _ sourceConfigs: [SourceConfig],
        preloadAllSources: Bool,
        replayMode: ReplayMode,
        timeout: TimeInterval?,
        file: StaticString,
        line: UInt
    )

    func load(
        _ source: Source,
        preloadAllSources: Bool,
        replayMode: ReplayMode,
        timeout: TimeInterval?,
        file: StaticString,
        line: UInt
    )

    func load(
        _ sources: [Source],
        preloadAllSources: Bool,
        replayMode: ReplayMode,
        timeout: TimeInterval?,
        file: StaticString,
        line: UInt
    )

    func load(
        _ playlistConfig: PlaylistConfig,
        timeout: TimeInterval?,
        file: StaticString,
        line: UInt
    )

    func play(for time: TimeInterval, timeout: TimeInterval?, file: StaticString, line: UInt)

    func play(until time: TimeInterval, timeout: TimeInterval?, file: StaticString, line: UInt)

    func wait(for time: TimeInterval)

    func wait(
        timeout: TimeInterval?,
        file: StaticString,
        line: UInt,
        until playerBlock: @escaping (Player) -> Bool
    )

    func deallocPlayer()
}

internal protocol PlayerViewTest {
    func callPlayerViewAndExpectEvents(
        _ playerViewBlock: @escaping (PlayerView) -> Void,
        _ multipleEventsExpectation: MultipleEventsExpectation,
        timeout: TimeInterval?,
        file: StaticString,
        line: UInt,
        eventHandlerBlock: (([Event]) -> Void)?
    )

    func callPlayerView(
        _ playerViewBlock: @escaping (PlayerView) -> Void,
        file: StaticString,
        line: UInt
    )
}
