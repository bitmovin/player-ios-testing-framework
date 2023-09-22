//
// Bitmovin Player iOS SDK
// Copyright (C) 2020, Bitmovin GmbH, All Rights Reserved
//
// This source code and its use and distribution, is subject to the terms
// and conditions of the applicable license agreement.
//

import BitmovinPlayer
import Foundation
import XCTest

typealias PlayerTestApi =
    PlayerTestLifecycleApi &
    PlayerTestSingleEventExpectationApi &
    PlayerTestMultipleEventsExpectationApi &
    PlayerTestRejectEventApi &
    PlayerTestRejectEventsApi &
    PlayerTestCallPlayerAndExpectApi &
    PlayerTestCallPlayerApi &
    PlayerTestConvenienceApi

public enum ViewHierarchyBuildMode {
    case full, viewOnly, none
}

/// Provides all necessary API to conveniently write system tests.
protocol PlayerTestLifecycleApi {
    /// Starts the playerTest by creating a player instance with the given config and executes the testBlock
    /// - Parameters:
    ///   - config: the config the player will be set up with
    ///   - buildViewHierarchyMode: defines how the player should be setup with a view hierarchy.
    ///                             .full is needed e.g. for the IMA SDK to work properly.
    ///   - globalTimeout: global timeout for the test, which will fail the test if exceeds this time.
    ///   - heartbeatWindow: heartbeat window where test will fail if no events received within the window.
    ///   - failOnError: defines if tests should fail when receiving an error event
    ///   - setLicenseKeyForTesting: defines if a license key will be ensured if non is set in player config
    ///   - testBlock: test block to be executed
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

protocol PlayerTestSingleEventExpectationApi {
    /// Listens for the specified Event to be emitted and blocks the calling thread until the event is
    /// received or the timeout is reached. In the case where the event is received, the eventHandlerBlock is called.
    func expectEvent<T: PlayerEvent>(
        _ eventClass: T.Type,
        timeout: TimeInterval?,
        file: StaticString,
        line: UInt,
        eventHandlerBlock: ((T) -> Void)?
    )

    /// Listens for the specified Event to be emitted and blocks the calling thread until the event is
    /// received or the timeout is reached. In the case where the event is received, the eventHandlerBlock is called.
    func expectEvent<T: SourceEvent>(
        _ eventClass: T.Type,
        timeout: TimeInterval?,
        file: StaticString,
        line: UInt,
        eventHandlerBlock: ((T) -> Void)?
    )

    /// Listens for the specified SingleEventExpectation to be emitted and blocks the calling thread until the event is
    /// received or the timeout is reached. In the case where the event is received, the eventHandlerBlock is called.
    func expectEvent<T: PlayerEvent>(
        _ eventExpectation: SingleEventExpectation<T>,
        timeout: TimeInterval?,
        file: StaticString,
        line: UInt,
        eventHandlerBlock: ((T) -> Void)?
    )

    /// Listens for the specified SingleEventExpectation to be emitted and blocks the calling thread until the event is
    /// received or the timeout is reached. In the case where the event is received, the eventHandlerBlock is called.
    func expectEvent<T: SourceEvent>(
        _ eventExpectation: SingleEventExpectation<T>,
        timeout: TimeInterval?,
        file: StaticString,
        line: UInt,
        eventHandlerBlock: ((T) -> Void)?
    )

    /// Listens for the specified `SourceEvent` to be emitted from the specified `Source`
    /// and blocks the calling thread until the event is received or the timeout is reached.
    /// In the case where the event is received, the `eventHandlerBlock` is called.
    func expectEvent<T: SourceEvent>(
        source: Source,
        _ eventClass: T.Type,
        timeout: TimeInterval?,
        file: StaticString,
        line: UInt,
        eventHandlerBlock: ((T) -> Void)?
    )

    /// Listens for the specified SingleEventExpectation to be emitted from the specified `Source`
    /// and blocks the calling thread until the event is received or the timeout is reached.
    /// In the case where the event is received, the `eventHandlerBlock` is called.
    func expectEvent<T: SourceEvent>(
        source: Source,
        _ eventExpectation: SingleEventExpectation<T>,
        timeout: TimeInterval?,
        file: StaticString,
        line: UInt,
        eventHandlerBlock: ((T) -> Void)?
    )
}

protocol PlayerTestMultipleEventsExpectationApi {
    /// Listens for the specified Events to be fulfilled and blocks the calling thread until
    /// the expectation is fulfilled in the specified order or the timeout is reached.
    /// In the case where the expectation is fulfilled, the eventsHandlerBlock is called with an ordered list of the
    /// Events
    func expectEvents(
        _ eventClasses: Event.Type...,
        timeout: TimeInterval?,
        file: StaticString,
        line: UInt,
        eventHandlerBlock: (([Event]) -> Void)?
    )

    /// Listens for the specified Events to be fulfilled and blocks the calling thread until
    /// the expectation is fulfilled in the specified order or the timeout is reached.
    /// In the case where the expectation is fulfilled, the eventsHandlerBlock is called with an ordered list of the
    /// Events
    func expectEvents(
        _ eventClasses: [Event.Type],
        timeout: TimeInterval?,
        file: StaticString,
        line: UInt,
        eventHandlerBlock: (([Event]) -> Void)?
    )

    /// Listens for the specified MultipleEventsExpectation to be fulfilled and blocks the calling thread until
    /// the expectation is fulfilled in the specified order or the timeout is reached.
    /// In the case where the expectation is fulfilled, the eventsHandlerBlock is called with an ordered list of the
    /// Events
    func expectEvents(
        _ multipleEventExpectation: MultipleEventsExpectation,
        timeout: TimeInterval?,
        file: StaticString,
        line: UInt,
        eventHandlerBlock: (([Event]) -> Void)?
    )

    /// Listens for the specified `SourceEvent`s to be emitted from the specified `Source`
    /// and blocks the calling thread until the expectation is fulfilled in the specified order or
    /// the timeout is reached. In the case where the expectation is fulfilled, the `eventsHandlerBlock`
    /// is called with an ordered list of the `SourceEvent`s
    func expectEvents(
        source: Source,
        _ eventClasses: [SourceEvent.Type],
        timeout: TimeInterval?,
        file: StaticString,
        line: UInt,
        eventHandlerBlock: (([SourceEvent]) -> Void)?
    )

    /// Listens for the specified `SourceEvent`s to be emitted from the specified `Source`
    /// and blocks the calling thread until the expectation is fulfilled in the specified order or
    /// the timeout is reached. In the case where the expectation is fulfilled, the `eventsHandlerBlock`
    /// is called with an ordered list of the `SourceEvent`s
    func expectEvents(
        source: Source,
        _ eventClasses: SourceEvent.Type...,
        timeout: TimeInterval?,
        file: StaticString,
        line: UInt,
        eventHandlerBlock: (([SourceEvent]) -> Void)?
    )

    /// Listens for the specified MultipleEventsExpectations to be emitted from the specified `Source`
    /// and blocks the calling thread until the expectation is fulfilled in the specified order or
    /// the timeout is reached. In the case where the expectation is fulfilled, the `eventsHandlerBlock`
    /// is called with an ordered list of the `SourceEvent`s
    func expectEvents(
        source: Source,
        _ multipleEventExpectation: MultipleEventsExpectation,
        timeout: TimeInterval?,
        file: StaticString,
        line: UInt,
        eventHandlerBlock: (([SourceEvent]) -> Void)?
    )
}

protocol PlayerTestRejectEventApi {
    /// Listens for the specified BitmovinEvent while the test continues in the testContinuationBlock.
    /// If the event is received during execution of the testContinuationBlock, the test fails.
    func rejectEvent<T: PlayerEvent>(
        file: StaticString,
        line: UInt,
        _ eventClass: T.Type,
        _ testContinuationBlock: () -> Void
    )

    /// Listens for the specified BitmovinEvent while the test continues in the testContinuationBlock.
    /// If the event is received during execution of the testContinuationBlock, the test fails.
    func rejectEvent<T: SourceEvent>(
        file: StaticString,
        line: UInt,
        _ eventClass: T.Type,
        _ testContinuationBlock: () -> Void
    )

    /// Listens for the specified SingleEventExpectation while the test continues in the testContinuationBlock.
    /// If the rejectedExpectation fulfills during the testContinuationBlock, the test fails.
    func rejectEvent<T: PlayerEvent>(
        file: StaticString,
        line: UInt,
        _ eventExpectation: SingleEventExpectation<T>,
        _ testContinuationBlock: () -> Void
    )

    /// Listens for the specified SingleEventExpectation while the test continues in the testContinuationBlock.
    /// If the rejectedExpectation fulfills during the testContinuationBlock, the test fails.
    func rejectEvent<T: SourceEvent>(
        file: StaticString,
        line: UInt,
        _ eventExpectation: SingleEventExpectation<T>,
        _ testContinuationBlock: () -> Void
    )

    /// Listens for the specified `SourceEvent` and the specified `Source`
    /// while the test continues in the `testContinuationBlock`.
    /// If the event is received during execution of the `testContinuationBlock`, the test fails.
    func rejectEvent<T: SourceEvent>(
        source: Source,
        file: StaticString,
        line: UInt,
        _ eventClass: T.Type,
        _ testContinuationBlock: () -> Void
    )

    /// Listens for the specified SingleEventExpectation and the specified `Source`
    /// while the test continues in the `testContinuationBlock`.
    /// If the event is received during execution of the `testContinuationBlock`, the test fails.
    func rejectEvent<T: SourceEvent>(
        source: Source,
        file: StaticString,
        line: UInt,
        _ eventExpectation: SingleEventExpectation<T>,
        _ testContinuationBlock: () -> Void
    )
}

protocol PlayerTestRejectEventsApi {
    /// Listens for the specified BitmovinEvents while the test continues in the testContinuationBlock.
    /// If the events are received during execution of the testContinuationBlock, the test fails.
    func rejectEvents(
        file: StaticString,
        line: UInt,
        _ eventClasses: Event.Type...,
        testContinuationBlock: () -> Void
    )

    /// Listens for the specified BitmovinEvents while the test continues in the testContinuationBlock.
    /// If the events are received during execution of the testContinuationBlock, the test fails.
    func rejectEvents(
        file: StaticString,
        line: UInt,
        _ eventClasses: [Event.Type],
        _ testContinuationBlock: () -> Void
    )

    /// Listens for the specified MultipleEventsExpectation while the test continues in the testContinuationBlock.
    /// If the rejectedExpectation fulfills during the testContinuationBlock, the test fails.
    func rejectEvents(
        file: StaticString,
        line: UInt,
        _ multipleEventExpectation: MultipleEventsExpectation,
        _ testContinuationBlock: () -> Void
    )

    /// Listens for the specified `SourceEvent`s and the specified `Source`
    /// while the test continues in the testContinuationBlock.
    /// If the events are received during execution of the testContinuationBlock, the test fails.
    func rejectEvents(
        source: Source,
        file: StaticString,
        line: UInt,
        _ eventClasses: [SourceEvent.Type],
        _ testContinuationBlock: () -> Void
    )

    /// Listens for the specified `SourceEvent`s and the specified `Source`
    /// while the test continues in the testContinuationBlock.
    /// If the events are received during execution of the testContinuationBlock, the test fails.
    func rejectEvents(
        source: Source,
        file: StaticString,
        line: UInt,
        _ eventClasses: SourceEvent.Type...,
        testContinuationBlock: () -> Void
    )

    /// Listens for the specified MultipleEventsExpectations and the specified `Source`
    /// while the test continues in the testContinuationBlock.
    /// If the events are received during execution of the testContinuationBlock, the test fails.
    func rejectEvents(
        source: Source,
        file: StaticString,
        line: UInt,
        _ multipleEventExpectation: MultipleEventsExpectation,
        _ testContinuationBlock: () -> Void
    )
}

protocol PlayerTestCallPlayerAndExpectApi {
    /// Starts listening for the specified Event before executing the passed playerBlock.
    /// When the event is received, the eventHandlerBlock is called. This is the race-condition-safe
    /// version of calling callPlayer and expectEvent after that.
    /// Useful when events are directly tied to calls in the playerBlock.
    func callPlayerAndExpectEvent<T: Event>(
        _ playerBlock: @escaping (Player) -> Void,
        _ eventClass: T.Type,
        timeout: TimeInterval?,
        file: StaticString,
        line: UInt,
        eventHandlerBlock: ((T) -> Void)?
    )

    /// Starts listening for the specified SingleEventExpectation before executing the passed playerBlock.
    /// When the event is received, the eventHandlerBlock is called. This is the race-condition-safe
    /// version of calling callPlayer and expectEvent after that.
    /// Useful when events are directly tied to calls in the playerBlock.
    func callPlayerAndExpectEvent<T: Event>(
        _ playerBlock: @escaping (Player) -> Void,
        _ eventExpectation: SingleEventExpectation<T>,
        timeout: TimeInterval?,
        file: StaticString,
        line: UInt,
        eventHandlerBlock: ((T) -> Void)?
    )

    /// Starts listening for the specified `SourceEvent` before executing the passed playerBlock.
    /// When the event is received from the specified `Source`, the `eventHandlerBlock` is called.
    /// This is the race-condition-safe
    /// version of calling callPlayer and expectEvent after that.
    /// Useful when events are directly tied to calls in the playerBlock.
    func callPlayerAndExpectEvent<T: SourceEvent>(
        source: Source,
        _ playerBlock: @escaping (Player) -> Void,
        _ eventClass: T.Type,
        timeout: TimeInterval?,
        file: StaticString,
        line: UInt,
        eventHandlerBlock: ((T) -> Void)?
    )

    /// Starts listening for the specified SingleEventExpectation before executing the passed playerBlock.
    /// When the event is received from the specified `Source`, the `eventHandlerBlock` is called.
    /// This is the race-condition-safe
    /// version of calling callPlayer and expectEvent after that.
    /// Useful when events are directly tied to calls in the playerBlock.
    func callPlayerAndExpectEvent<T: SourceEvent>(
        source: Source,
        _ playerBlock: @escaping (Player) -> Void,
        _ eventExpectation: SingleEventExpectation<T>,
        timeout: TimeInterval?,
        file: StaticString,
        line: UInt,
        eventHandlerBlock: ((T) -> Void)?
    )

    /// Starts listening for the specified Events before executing the passed playerBlock.
    /// When the events are received in the specified order, the eventsHandlerBlock is called.
    /// This is the race-condition-safe version of calling callPlayer and expectEvents after that.
    /// Useful when events are directly tied to calls in the playerBlock.
    func callPlayerAndExpectEvents(
        _ playerBlock: @escaping (Player) -> Void,
        _ eventClasses: [Event.Type],
        timeout: TimeInterval?,
        file: StaticString,
        line: UInt,
        eventHandlerBlock: (([Event]) -> Void)?
    )

    /// Starts listening for the specified Events before executing the passed playerBlock.
    /// When the events are received in the specified order, the eventsHandlerBlock is called.
    /// This is the race-condition-safe version of calling callPlayer and expectEvents after that.
    /// Useful when events are directly tied to calls in the playerBlock.
    func callPlayerAndExpectEvents(
        _ playerBlock: @escaping (Player) -> Void,
        _ eventClasses: Event.Type...,
        timeout: TimeInterval?,
        file: StaticString,
        line: UInt,
        eventHandlerBlock: (([Event]) -> Void)?
    )

    /// Starts listening for the specified MultipleEventsExpectation before executing the passed playerBlock.
    /// When the expectation is fulfilled in the specified order, the eventsHandlerBlock is called.
    /// This is the race-condition-safe version of calling callPlayer and expectEvents after that.
    /// Useful when events are directly tied to calls in the playerApiBlock.
    func callPlayerAndExpectEvents(
        _ playerBlock: @escaping (Player) -> Void,
        _ multipleEventsExpectation: MultipleEventsExpectation,
        timeout: TimeInterval?,
        file: StaticString,
        line: UInt,
        eventHandlerBlock: (([Event]) -> Void)?
    )

    /// Starts listening for the specified `SourceEvent`s before executing the passed `playerBlock`.
    /// When the events are received from the specified `Source` in the specified order,
    /// the `eventsHandlerBlock` is called.
    /// This is the race-condition-safe version of calling callPlayer and expectEvents after that.
    /// Useful when events are directly tied to calls in the playerBlock.
    func callPlayerAndExpectEvents(
        source: Source,
        _ playerBlock: @escaping (Player) -> Void,
        _ eventClasses: [SourceEvent.Type],
        timeout: TimeInterval?,
        file: StaticString,
        line: UInt,
        eventHandlerBlock: (([SourceEvent]) -> Void)?
    )

    /// Starts listening for the specified `SourceEvent`s before executing the passed `playerBlock`.
    /// When the events are received from the specified `Source` in the specified order,
    /// the `eventsHandlerBlock` is called.
    /// This is the race-condition-safe version of calling callPlayer and expectEvents after that.
    /// Useful when events are directly tied to calls in the playerBlock.
    func callPlayerAndExpectEvents(
        source: Source,
        _ playerBlock: @escaping (Player) -> Void,
        _ eventClasses: SourceEvent.Type...,
        timeout: TimeInterval?,
        file: StaticString,
        line: UInt,
        eventHandlerBlock: (([SourceEvent]) -> Void)?
    )

    /// Starts listening for the specified MultipleEventsExpectation before executing the passed `playerBlock`.
    /// When the events are received from the specified `Source` in the specified order,
    /// the `eventsHandlerBlock` is called.
    /// This is the race-condition-safe version of calling callPlayer and expectEvents after that.
    /// Useful when events are directly tied to calls in the playerBlock.
    func callPlayerAndExpectEvents(
        source: Source,
        _ playerBlock: @escaping (Player) -> Void,
        _ multipleEventsExpectation: MultipleEventsExpectation,
        timeout: TimeInterval?,
        file: StaticString,
        line: UInt,
        eventHandlerBlock: (([SourceEvent]) -> Void)?
    )
}

protocol PlayerTestCallPlayerApi {
    /// Executes the passed block with the BitmovinPlayer as argument.
    /// Use this function to call Player API as part of the test.
    func callPlayer(_ playerBlock: @escaping (Player) -> Void)

    /// Executes the passed block with the BitmovinPlayer as argument.
    /// Use this function to perform assertions in the scope of the Player.
    func verifyPlayer(_ playerBlock: @escaping (Player) -> Void)

    /// Executes the passed block with the optional BitmovinPlayer as argument.
    /// Use this function to perform assertions in the scope of the Player.
    func safeVerifyPlayer(_ playerBlock: @escaping (Player?) -> Void)
}

protocol PlayerTestConvenienceApi {
    /// Creates a `Source` from the given `SourceConfig`.
    func createSource(sourceConfig: SourceConfig) -> Source

    /// Loads a `SourceConfig` into the Player and blocks the calling thread until the source is successfully
    /// loaded or the timeout is reached.
    func load(
        _ sourceConfig: SourceConfig,
        preloadAllSources: Bool,
        timeout: TimeInterval?,
        file: StaticString,
        line: UInt
    )

    /// Loads an array of `SourceConfig`s into the Player and blocks the calling thread until the source is successfully
    /// loaded or the timeout is reached.
    func load(
        _ sourceConfigs: [SourceConfig],
        preloadAllSources: Bool,
        timeout: TimeInterval?,
        file: StaticString,
        line: UInt
    )

    /// Loads a `Source` into the Player and blocks the calling thread until the source is successfully
    /// loaded or the timeout is reached.
    func load(
        _ source: Source,
        preloadAllSources: Bool,
        timeout: TimeInterval?,
        file: StaticString,
        line: UInt
    )

    /// Loads array of `Source` into the Player and blocks the calling thread until the source is successfully
    /// loaded or the timeout is reached.
    func load(
        _ sources: [Source],
        preloadAllSources: Bool,
        timeout: TimeInterval?,
        file: StaticString,
        line: UInt
    )

    /// Loads a `PlaylistConfig` into the Player and blocks the calling thread until the source is successfully
    /// loaded or the timeout is reached.
    func load(
        _ playlistConfig: PlaylistConfig,
        timeout: TimeInterval?,
        file: StaticString,
        line: UInt
    )

    /// Waits until the Player has played back the specified amount of time or until the timeout is reached.
    /// Blocks the calling thread for the duration.
    func play(for time: TimeInterval, timeout: TimeInterval?, file: StaticString, line: UInt)

    /// Waits until the Player has played back until the specified time or until the timeout is reached.
    /// Blocks the calling thread for the duration.
    func play(until time: TimeInterval, timeout: TimeInterval?, file: StaticString, line: UInt)

    /// Waits for the specified amount of time by blocking the calling thread.
    func wait(for time: TimeInterval)

    /// Waits until the specified playerBlock returns true or until the timeout is reached.
    /// Blocks the calling thread for the duration.
    func wait(
        timeout: TimeInterval?,
        file: StaticString,
        line: UInt,
        until playerBlock: @escaping (Player) -> Bool
    )

    /// Sets the internal reference for the player instance to `nil`,
    /// deallocating it when there are no external strong references
    ///
    /// For verifying this, `safeVerifyPlayer` should be used,
    /// calling any other method from PlayerTest APIs will cause a crash.
    func deallocPlayer()

    /// Track stalling and use StallingHistory in the code block which contains stalling history
    func trackStalling(_ trackingBlock: (StallingHistory) -> Void)
}
