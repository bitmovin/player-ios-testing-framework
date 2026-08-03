import BitmovinPlayerCore
import Foundation
import XCTest

internal typealias PlayerTestApi =
    PlayerTestCallPlayerAndExpectApi &
    PlayerTestCallPlayerApi &
    PlayerTestConvenienceApi &
    PlayerTestLifecycleApi &
    PlayerTestMultipleEventsExpectationApi &
    PlayerTestRejectEventApi &
    PlayerTestRejectEventsApi &
    PlayerTestSingleEventExpectationApi

public enum ViewHierarchyBuildMode {
    public static let full = Self.full(PlayerViewConfig())
    public static let viewOnly = Self.viewOnly(PlayerViewConfig())

    case full(_ playerViewConfig: PlayerViewConfig)
    case viewOnly(_ playerViewConfig: PlayerViewConfig)
    case none
}

/// Provides all necessary API to conveniently write system tests.
@MainActor
internal protocol PlayerTestLifecycleApi {
    func startPlayerTest(
        config: PlayerConfig,
        buildViewHierarchyMode: ViewHierarchyBuildMode,
        globalTimeout: TimeInterval,
        heartbeatWindow: TimeInterval?,
        failOnError failOnErrorEnabled: Bool,
        setLicenseKeyForTesting: Bool,
        playerCreator: (_ config: PlayerConfig) -> Player,
        file: StaticString,
        line: UInt,
        _ testBlock: PlayerTestBlock
    ) async throws
}

@MainActor
internal protocol PlayerTestSingleEventExpectationApi {
    @discardableResult
    func expectEvent<T: PlayerEvent>(
        _ eventClass: T.Type,
        timeout: TimeInterval?,
        file: StaticString,
        line: UInt
    ) async throws -> T

    @discardableResult
    func expectEvent<T: SourceEvent>(
        _ eventClass: T.Type,
        timeout: TimeInterval?,
        file: StaticString,
        line: UInt
    ) async throws -> T

    @discardableResult
    func expectEvent<T: PlayerEvent>(
        _ eventExpectation: SingleEventExpectation<T>,
        timeout: TimeInterval?,
        file: StaticString,
        line: UInt
    ) async throws -> T

    @discardableResult
    func expectEvent<T: SourceEvent>(
        _ eventExpectation: SingleEventExpectation<T>,
        timeout: TimeInterval?,
        file: StaticString,
        line: UInt
    ) async throws -> T
}

@MainActor
internal protocol PlayerTestMultipleEventsExpectationApi {
    @discardableResult
    func expectEvents(
        _ eventClasses: [Event.Type],
        timeout: TimeInterval?,
        file: StaticString,
        line: UInt
    ) async throws -> [Event]

    @discardableResult
    func expectEvents(
        _ multipleEventExpectation: MultipleEventsExpectation,
        timeout: TimeInterval?,
        file: StaticString,
        line: UInt
    ) async throws -> [Event]
}

@MainActor
internal protocol PlayerTestRejectEventApi {
    func rejectEvent<T: PlayerEvent>(
        file: StaticString,
        line: UInt,
        _ eventClass: T.Type,
        _ testContinuationBlock: TestContinuationBlock
    ) async throws

    func rejectEvent<T: SourceEvent>(
        file: StaticString,
        line: UInt,
        _ eventClass: T.Type,
        _ testContinuationBlock: TestContinuationBlock
    ) async throws

    func rejectEvent<T: PlayerEvent>(
        file: StaticString,
        line: UInt,
        _ eventExpectation: SingleEventExpectation<T>,
        _ testContinuationBlock: TestContinuationBlock
    ) async throws

    func rejectEvent<T: SourceEvent>(
        file: StaticString,
        line: UInt,
        _ eventExpectation: SingleEventExpectation<T>,
        _ testContinuationBlock: TestContinuationBlock
    ) async throws
}

@MainActor
internal protocol PlayerTestRejectEventsApi {
    func rejectEvents(
        file: StaticString,
        line: UInt,
        _ eventClasses: [Event.Type],
        _ testContinuationBlock: TestContinuationBlock
    ) async throws

    func rejectEvents(
        file: StaticString,
        line: UInt,
        _ multipleEventExpectation: MultipleEventsExpectation,
        _ testContinuationBlock: TestContinuationBlock
    ) async throws
}

@MainActor
internal protocol PlayerTestCallPlayerAndExpectApi {
    @discardableResult
    func callPlayerAndExpectEvent<T: Event>(
        _ playerBlock: @escaping AsyncCallPlayerBlock,
        _ eventClass: T.Type,
        timeout: TimeInterval?,
        file: StaticString,
        line: UInt
    ) async throws -> T

    @discardableResult
    func callPlayerAndExpectEvent<T: Event>(
        _ playerBlock: @escaping AsyncCallPlayerBlock,
        _ eventExpectation: SingleEventExpectation<T>,
        timeout: TimeInterval?,
        file: StaticString,
        line: UInt
    ) async throws -> T

    @discardableResult
    func callPlayerAndExpectEvents(
        _ playerBlock: @escaping AsyncCallPlayerBlock,
        _ eventClasses: [Event.Type],
        timeout: TimeInterval?,
        file: StaticString,
        line: UInt
    ) async throws -> [Event]

    @discardableResult
    func callPlayerAndExpectEvents(
        _ playerBlock: @escaping AsyncCallPlayerBlock,
        _ multipleEventsExpectation: MultipleEventsExpectation,
        timeout: TimeInterval?,
        file: StaticString,
        line: UInt
    ) async throws -> [Event]
}

@MainActor
internal protocol PlayerTestCallPlayerApi {
    func callPlayer(_ playerBlock: @escaping CallPlayerBlock)

    func callPlayer(_ playerBlock: @escaping AsyncCallPlayerBlock) async throws

    func verifyPlayer(_ playerBlock: @escaping CallPlayerBlock)

    func safeVerifyPlayer(_ playerBlock: @escaping (Player?) -> Void)
}

@MainActor
internal protocol PlayerTestConvenienceApi {
    func createSource(sourceConfig: SourceConfig) -> Source

    func load(
        _ sourceConfig: SourceConfig,
        preloadAllSources: Bool,
        replayMode: ReplayMode,
        timeout: TimeInterval?,
        file: StaticString,
        line: UInt
    ) async throws

    func load(
        _ sourceConfigs: [SourceConfig],
        preloadAllSources: Bool,
        replayMode: ReplayMode,
        timeout: TimeInterval?,
        file: StaticString,
        line: UInt
    ) async throws

    func load(
        _ source: Source,
        preloadAllSources: Bool,
        replayMode: ReplayMode,
        timeout: TimeInterval?,
        file: StaticString,
        line: UInt
    ) async throws

    func load(
        _ sources: [Source],
        preloadAllSources: Bool,
        replayMode: ReplayMode,
        timeout: TimeInterval?,
        file: StaticString,
        line: UInt
    ) async throws

    func load(
        _ playlistConfig: PlaylistConfig,
        timeout: TimeInterval?,
        file: StaticString,
        line: UInt
    ) async throws

    func play(
        for time: TimeInterval,
        timeout: TimeInterval?,
        file: StaticString,
        line: UInt
    ) async throws

    func play(
        until time: TimeInterval,
        timeout: TimeInterval?,
        file: StaticString,
        line: UInt
    ) async throws

    func wait(for time: TimeInterval) async throws

    func wait(
        timeout: TimeInterval?,
        file: StaticString,
        line: UInt,
        until playerBlock: @escaping (Player) -> Bool
    ) async throws

    func deallocPlayer()
}

@MainActor
internal protocol PlayerViewTest {
    @discardableResult
    func callPlayerViewAndExpectEvents(
        _ playerViewBlock: @escaping (PlayerView) async throws -> Void,
        _ multipleEventsExpectation: MultipleEventsExpectation,
        timeout: TimeInterval?,
        file: StaticString,
        line: UInt
    ) async throws -> [Event]

    func callPlayerView(
        _ playerViewBlock: @escaping (PlayerView) -> Void,
        file: StaticString,
        line: UInt
    )

    func callPlayerView(
        _ playerViewBlock: @escaping (PlayerView) async throws -> Void,
        file: StaticString,
        line: UInt
    ) async throws
}
