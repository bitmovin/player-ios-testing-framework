//
// Bitmovin Player iOS SDK
// Copyright (C) 2021, Bitmovin GmbH, All Rights Reserved
//
// This source code and its use and distribution, is subject to the terms
// and conditions of the applicable license agreement.
//

import BitmovinPlayer
import Foundation
import Nimble
import Quick

open class QuickPlayerOfflineTest: QuickSpec {
    private var playerTest: PlayerTest?
    private var offlineTest: OfflineTest?

    override open func setUp() {
        super.setUp()
        continueAfterFailure = false
    }
}

extension QuickPlayerOfflineTest: OfflineTestLifecycleApi {
    public func startOfflineTest(
        offlineConfig: OfflineConfig = OfflineConfig(),
        failOnError failOnErrorEnabled: Bool = true,
        waitForSuspendedDownloadsRestoring: Bool = true,
        file: StaticString = #file,
        line: UInt = #line,
        _ testBlock: OfflineTestBlock
    ) {
        offlineTest?.tearDown()
        offlineTest = OfflineTest()

        offlineTest?.startOfflineTest(
            offlineConfig: offlineConfig,
            failOnError: failOnErrorEnabled,
            waitForSuspendedDownloadsRestoring: waitForSuspendedDownloadsRestoring,
            file: file,
            line: line,
            testBlock
        )

        offlineTest?.tearDown()
        offlineTest = nil
    }
}

extension QuickPlayerOfflineTest: OfflineTestCallOfflineContentManagerAndExpectApi {
    /// Starts listening for the specified Event before executing the passed `offlineContentManagerBlock`.
    /// When the event is received, the `eventHandlerBlock` is called. This is the race-condition-safe
    /// version of calling `callOfflineContentManager` and `expectEvent` after that.
    /// Useful when events are directly tied to calls in the `offlineContentManagerBlock`.
    public func callOfflineContentManagerAndExpectEvent<T: OfflineEvent>(
        _ offlineContentManager: OfflineContentManager,
        _ offlineContentManagerBlock: @escaping OfflineContentManagerTestBlock,
        _ eventClass: T.Type,
        timeout: TimeInterval,
        file: StaticString = #file,
        line: UInt = #line,
        eventHandlerBlock: ((T) -> Void)? = nil
    ) {
        offlineTest?.callOfflineContentManagerAndExpectEvent(
            offlineContentManager,
            offlineContentManagerBlock,
            eventClass,
            timeout: timeout,
            file: file,
            line: line,
            eventHandlerBlock: eventHandlerBlock
        )
    }

    /// Starts listening for the specified `SingleEventExpectation` before executing the passed
    /// `offlineContentManagerBlock`.
    /// When the event is received, the `eventHandlerBlock` is called. This is the race-condition-safe
    /// version of calling `callOfflineContentManager` and `expectEvent` after that.
    /// Useful when events are directly tied to calls in the `offlineContentManagerBlock`.
    public func callOfflineContentManagerAndExpectEvent<T: OfflineEvent>(
        _ offlineContentManager: OfflineContentManager,
        _ offlineContentManagerBlock: @escaping OfflineContentManagerTestBlock,
        _ eventExpectation: SingleEventExpectation<T>,
        timeout: TimeInterval,
        file: StaticString = #file,
        line: UInt = #line,
        eventHandlerBlock: ((T) -> Void)? = nil
    ) {
        offlineTest?.callOfflineContentManagerAndExpectEvent(
            offlineContentManager,
            offlineContentManagerBlock,
            eventExpectation,
            timeout: timeout,
            file: file,
            line: line,
            eventHandlerBlock: eventHandlerBlock
        )
    }

    /// Starts listening for the specified `MultipleEventsExpectation` before executing the passed
    /// `offlineContentManagerBlock`.
    /// When the expectation is fulfilled in the specified order, the `eventsHandlerBlock` is called.
    /// This is the race-condition-safe version of calling `callOfflineContentManager` and `expectEvent` after that.
    /// Useful when events are directly tied to calls in the `offlineContentManagerBlock`.
    public func callOfflineContentManagerAndExpectEvents(
        _ offlineContentManager: OfflineContentManager,
        _ offlineContentManagerBlock: @escaping OfflineContentManagerTestBlock,
        _ multipleEventsExpectation: MultipleEventsExpectation,
        timeout: TimeInterval,
        file: StaticString = #file,
        line: UInt = #line,
        eventHandlerBlock: (([OfflineEvent]) -> Void)? = nil
    ) {
        offlineTest?.callOfflineContentManagerAndExpectEvents(
            offlineContentManager,
            offlineContentManagerBlock,
            multipleEventsExpectation,
            timeout: timeout,
            file: file,
            line: line,
            eventHandlerBlock: eventHandlerBlock
        )
    }
}

extension QuickPlayerOfflineTest: OfflineTestSingleEventExpectationApi {
    /// Listens for the specified Event to be emitted and blocks the calling thread until the event is
    /// received or the timeout is reached. In the case where the event is received, the `eventHandlerBlock` is called.
    public func expectEvent<T: OfflineEvent>(
        _ offlineContentManager: OfflineContentManager,
        _ eventClass: T.Type,
        timeout: TimeInterval,
        file: StaticString = #file,
        line: UInt = #line,
        eventHandlerBlock: ((T) -> Void)? = nil
    ) {
        offlineTest?.expectEvent(
            offlineContentManager,
            eventClass,
            timeout: timeout,
            file: file,
            line: line,
            eventHandlerBlock: eventHandlerBlock
        )
    }

    /// Listens for the specified `SingleEventExpectation` to be emitted and blocks the calling thread until the event
    /// is received or the timeout is reached. In the case where the event is received, the `eventHandlerBlock`
    /// is called.
    public func expectEvent<T: OfflineEvent>(
        _ offlineContentManager: OfflineContentManager,
        _ eventExpectation: SingleEventExpectation<T>,
        timeout: TimeInterval,
        file: StaticString = #file,
        line: UInt = #line,
        eventHandlerBlock: ((T) -> Void)? = nil
    ) {
        offlineTest?.expectEvent(
            offlineContentManager,
            eventExpectation,
            timeout: timeout,
            file: file,
            line: line,
            eventHandlerBlock: eventHandlerBlock
        )
    }
}

extension QuickPlayerOfflineTest: OfflineTestMultipleEventsExpectationApi {
    /// Listens for the specified `MultipleEventsExpectation` to be fulfilled and blocks the calling thread until
    /// the expectation is fulfilled in the specified order or the timeout is reached.
    /// In the case where the expectation is fulfilled, the `eventsHandlerBlock` is called with an ordered list of the
    /// Events
    public func expectEvents(
        _ offlineContentManager: OfflineContentManager,
        _ multipleEventExpectation: MultipleEventsExpectation,
        timeout: TimeInterval,
        file: StaticString = #file,
        line: UInt = #line,
        eventHandlerBlock: (([OfflineEvent]) -> Void)? = nil
    ) {
        offlineTest?.expectEvents(
            offlineContentManager,
            multipleEventExpectation,
            timeout: timeout,
            file: file,
            line: line,
            eventHandlerBlock: eventHandlerBlock
        )
    }
}

extension QuickPlayerOfflineTest: OfflineTestRejectEventApi {
    /// Listens for the specified `OfflineEvent` while the test continues in the `testContinuationBlock`.
    /// If the event is received during execution of the `testContinuationBlock`, the test fails.
    public func rejectEvent<T: OfflineEvent>(
        _ offlineContentManager: OfflineContentManager,
        file: StaticString = #file,
        line: UInt = #line,
        _ eventClass: T.Type,
        _ testContinuationBlock: () -> Void
    ) {
        offlineTest?.rejectEvent(
            offlineContentManager,
            file: file,
            line: line,
            eventClass,
            testContinuationBlock
        )
    }

    /// Listens for the specified `SingleEventExpectation` while the test continues in the `testContinuationBlock`.
    /// If the `rejectedExpectation` fulfills during the `testContinuationBlock`, the test fails.
    public func rejectEvent<T: OfflineEvent>(
        _ offlineContentManager: OfflineContentManager,
        file: StaticString = #file,
        line: UInt = #line,
        _ eventExpectation: SingleEventExpectation<T>,
        _ testContinuationBlock: () -> Void
    ) {
        offlineTest?.rejectEvent(
            offlineContentManager,
            file: file,
            line: line,
            eventExpectation,
            testContinuationBlock
        )
    }
}

extension QuickPlayerOfflineTest: OfflineTestRejectEventsApi {
    /// Listens for the specified `MultipleEventsExpectation` while the test continues in the `testContinuationBlock`.
    /// If the `rejectedExpectation` fulfills during the `testContinuationBlock`, the test fails.
    public func rejectEvents(
        _ offlineContentManager: OfflineContentManager,
        file: StaticString = #file,
        line: UInt = #line,
        _ multipleEventExpectation: MultipleEventsExpectation,
        _ testContinuationBlock: () -> Void
    ) {
        offlineTest?.rejectEvents(
            offlineContentManager,
            file: file,
            line: line,
            multipleEventExpectation,
            testContinuationBlock
        )
    }
}

extension QuickPlayerOfflineTest: OfflineTestConvenienceApi {
    /// Get the `OfflineContentManager` for the provided `SourceConfig`
    /// - Parameters:
    ///   - sourceConfig: the source config to get the `OfflineContentManager`
    ///   - id: unique identifier for the given `SourceConfig` which must not change once provided.
    ///   - clean: reset the `OfflineContentManager` instance before returning it by
    ///   canceling the download and delete the data.
    public func getOfflineContentManager(
        sourceConfig: SourceConfig,
        id: String? = nil,
        clean: Bool = true
    ) throws -> OfflineContentManager {
        guard let offlineTest = offlineTest else {
            fatalError("Offline test cannot be nil")
        }
        return try offlineTest.getOfflineContentManager(
            sourceConfig: sourceConfig,
            id: id,
            clean: clean
        )
    }

    /// Download content until progress
    public func downloadUntilProgress(
        _ offlineContentManager: OfflineContentManager,
        progress: Double,
        timeout: TimeInterval,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        offlineTest?.downloadUntilProgress(
            offlineContentManager,
            progress: progress,
            timeout: timeout,
            file: file,
            line: line
        )
    }

    /// Wait until the download of tracks has finished
    public func waitUntilDownloaded(
        _ offlineContentManager: OfflineContentManager,
        tracks: OfflineTrackSelection,
        config: DownloadConfig = DownloadConfig(),
        timeout: TimeInterval,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        offlineTest?.waitUntilDownloaded(
            offlineContentManager,
            tracks: tracks,
            config: config,
            timeout: timeout,
            file: file,
            line: line
        )
    }

    /// Wait until the download finished
    public func waitUntilDownloaded(
        _ offlineContentManager: OfflineContentManager,
        config: DownloadConfig = DownloadConfig(),
        timeout: TimeInterval,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        offlineTest?.waitUntilDownloaded(
            offlineContentManager,
            config: config,
            timeout: timeout,
            file: file,
            line: line
        )
    }
}

// swiftlint:disable:this function_default_parameter_at_end
extension QuickPlayerOfflineTest: PlayerTestApi {
    public func startPlayerTest(
        config: PlayerConfig = PlayerConfig(),
        buildViewHierarchyMode: ViewHierarchyBuildMode = .none,
        globalTimeout: TimeInterval = defaultGlobalTimeout,
        heartbeatWindow: TimeInterval? = nil,
        failOnError failOnErrorEnabled: Bool = true,
        setLicenseKeyForTesting: Bool = true,
        file: StaticString = #file,
        line: UInt = #line,
        _ testBlock: PlayerTestBlock
    ) {
        // In case the previous test failed, we need to do the tear down here
        playerTest?.tearDown()

        playerTest = PlayerTest()

        playerTest?.startPlayerTest(
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

        playerTest?.tearDown()
        playerTest = nil
    }

    public func expectEvent<T: PlayerEvent>(
        _ eventClass: T.Type,
        timeout: TimeInterval? = nil,
        file: StaticString = #file,
        line: UInt = #line,
        eventHandlerBlock: ((T) -> Void)? = nil
    ) {
        playerTest?.expectEvent(
            eventClass,
            timeout: timeout,
            file: file,
            line: line,
            eventHandlerBlock: eventHandlerBlock
        )
    }

    public func expectEvent<T: SourceEvent>(
        _ eventClass: T.Type,
        timeout: TimeInterval? = nil,
        file: StaticString = #file,
        line: UInt = #line,
        eventHandlerBlock: ((T) -> Void)? = nil
    ) {
        playerTest?.expectEvent(
            eventClass,
            timeout: timeout,
            file: file,
            line: line,
            eventHandlerBlock: eventHandlerBlock
        )
    }

    public func expectEvent<T: PlayerEvent>(
        _ eventExpectation: SingleEventExpectation<T>,
        timeout: TimeInterval? = nil,
        file: StaticString = #file,
        line: UInt = #line,
        eventHandlerBlock: ((T) -> Void)? = nil
    ) {
        playerTest?.expectEvent(
            eventExpectation,
            timeout: timeout,
            file: file,
            line: line,
            eventHandlerBlock: eventHandlerBlock
        )
    }

    public func expectEvent<T: SourceEvent>(
        _ eventExpectation: SingleEventExpectation<T>,
        timeout: TimeInterval? = nil,
        file: StaticString = #file,
        line: UInt = #line,
        eventHandlerBlock: ((T) -> Void)? = nil
    ) {
        playerTest?.expectEvent(
            eventExpectation,
            timeout: timeout,
            file: file,
            line: line,
            eventHandlerBlock: eventHandlerBlock
        )
    }

    public func expectEvent<T: SourceEvent>(
        source: Source,
        _ eventClass: T.Type,
        timeout: TimeInterval? = nil,
        file: StaticString = #file,
        line: UInt = #line,
        eventHandlerBlock: ((T) -> Void)? = nil
    ) {
        playerTest?.expectEvent(
            source: source,
            eventClass,
            timeout: timeout,
            file: file,
            line: line,
            eventHandlerBlock: eventHandlerBlock
        )
    }

    public func expectEvent<T: SourceEvent>(
        source: Source,
        _ eventExpectation: SingleEventExpectation<T>,
        timeout: TimeInterval? = nil,
        file: StaticString = #file,
        line: UInt = #line,
        eventHandlerBlock: ((T) -> Void)? = nil
    ) {
        playerTest?.expectEvent(
            source: source,
            eventExpectation,
            timeout: timeout,
            file: file,
            line: line,
            eventHandlerBlock: eventHandlerBlock
        )
    }

    public func expectEvents(
        _ eventClasses: Event.Type...,
        timeout: TimeInterval? = nil,
        file: StaticString = #file,
        line: UInt = #line,
        eventHandlerBlock: (([Event]) -> Void)? = nil
    ) {
        playerTest?.expectEvents(
            eventClasses,
            timeout: timeout,
            file: file,
            line: line,
            eventHandlerBlock: eventHandlerBlock
        )
    }

    public func expectEvents(
        _ eventClasses: [Event.Type],
        timeout: TimeInterval? = nil,
        file: StaticString = #file,
        line: UInt = #line,
        eventHandlerBlock: (([Event]) -> Void)? = nil
    ) {
        playerTest?.expectEvents(
            eventClasses,
            timeout: timeout,
            file: file,
            line: line,
            eventHandlerBlock: eventHandlerBlock
        )
    }

    public func expectEvents(
        _ multipleEventExpectation: MultipleEventsExpectation,
        timeout: TimeInterval? = nil,
        file: StaticString = #file,
        line: UInt = #line,
        eventHandlerBlock: (([Event]) -> Void)? = nil
    ) {
        playerTest?.expectEvents(
            multipleEventExpectation,
            timeout: timeout,
            file: file,
            line: line,
            eventHandlerBlock: eventHandlerBlock
        )
    }

    public func expectEvents(
        source: Source,
        _ eventClasses: SourceEvent.Type...,
        timeout: TimeInterval? = nil,
        file: StaticString = #file,
        line: UInt = #line,
        eventHandlerBlock: (([SourceEvent]) -> Void)? = nil
    ) {
        playerTest?.expectEvents(
            source: source,
            eventClasses,
            timeout: timeout,
            file: file,
            line: line,
            eventHandlerBlock: eventHandlerBlock
        )
    }

    public func expectEvents(
        source: Source,
        _ eventClasses: [SourceEvent.Type],
        timeout: TimeInterval? = nil,
        file: StaticString = #file,
        line: UInt = #line,
        eventHandlerBlock: (([SourceEvent]) -> Void)? = nil
    ) {
        playerTest?.expectEvents(
            source: source,
            eventClasses,
            timeout: timeout,
            file: file,
            line: line,
            eventHandlerBlock: eventHandlerBlock
        )
    }

    public func expectEvents(
        source: Source,
        _ multipleEventExpectation: MultipleEventsExpectation,
        timeout: TimeInterval? = nil,
        file: StaticString = #file,
        line: UInt = #line,
        eventHandlerBlock: (([SourceEvent]) -> Void)? = nil
    ) {
        playerTest?.expectEvents(
            source: source,
            multipleEventExpectation,
            timeout: timeout,
            file: file,
            line: line,
            eventHandlerBlock: eventHandlerBlock
        )
    }

    public func rejectEvent<T: PlayerEvent>(
        file: StaticString = #file,
        line: UInt = #line,
        _ eventClass: T.Type,
        _ testContinuationBlock: () -> Void
    ) {
        playerTest?.rejectEvent(file: file, line: line, eventClass, testContinuationBlock)
    }

    public func rejectEvent<T: SourceEvent>(
        file: StaticString = #file,
        line: UInt = #line,
        _ eventClass: T.Type,
        _ testContinuationBlock: () -> Void
    ) {
        playerTest?.rejectEvent(file: file, line: line, eventClass, testContinuationBlock)
    }

    public func rejectEvent<T: PlayerEvent>(
        file: StaticString = #file,
        line: UInt = #line,
        _ eventExpectation: SingleEventExpectation<T>,
        _ testContinuationBlock: () -> Void
    ) {
        playerTest?.rejectEvent(file: file, line: line, eventExpectation, testContinuationBlock)
    }

    public func rejectEvent<T: SourceEvent>(
        file: StaticString = #file,
        line: UInt = #line,
        _ eventExpectation: SingleEventExpectation<T>,
        _ testContinuationBlock: () -> Void
    ) {
        playerTest?.rejectEvent(file: file, line: line, eventExpectation, testContinuationBlock)
    }

    public func rejectEvent<T: SourceEvent>(
        source: Source,
        file: StaticString = #file,
        line: UInt = #line,
        _ eventClass: T.Type,
        _ testContinuationBlock: () -> Void
    ) {
        playerTest?.rejectEvent(
            source: source,
            file: file,
            line: line,
            eventClass,
            testContinuationBlock
        )
    }

    public func rejectEvent<T: SourceEvent>(
        source: Source,
        file: StaticString = #file,
        line: UInt = #line,
        _ eventExpectation: SingleEventExpectation<T>,
        _ testContinuationBlock: () -> Void
    ) {
        playerTest?.rejectEvent(
            source: source,
            file: file,
            line: line,
            eventExpectation,
            testContinuationBlock
        )
    }

    public func rejectEvents(
        file: StaticString = #file,
        line: UInt = #line,
        _ eventClasses: Event.Type...,
        testContinuationBlock: () -> Void
    ) {
        playerTest?.rejectEvents(file: file, line: line, eventClasses, testContinuationBlock)
    }

    public func rejectEvents(
        file: StaticString = #file,
        line: UInt = #line,
        _ eventClasses: [Event.Type],
        _ testContinuationBlock: () -> Void
    ) {
        playerTest?.rejectEvents(file: file, line: line, eventClasses, testContinuationBlock)
    }

    public func rejectEvents(
        file: StaticString = #file,
        line: UInt = #line,
        _ multipleEventExpectation: MultipleEventsExpectation,
        _ testContinuationBlock: () -> Void
    ) {
        playerTest?.rejectEvents(file: file, line: line, multipleEventExpectation, testContinuationBlock)
    }

    public func rejectEvents(
        source: Source,
        file: StaticString = #file,
        line: UInt = #line,
        _ eventClasses: SourceEvent.Type...,
        testContinuationBlock: () -> Void
    ) {
        playerTest?.rejectEvents(
            source: source,
            file: file,
            line: line,
            eventClasses,
            testContinuationBlock
        )
    }

    public func rejectEvents(
        source: Source,
        file: StaticString = #file,
        line: UInt = #line,
        _ eventClasses: [SourceEvent.Type],
        _ testContinuationBlock: () -> Void
    ) {
        playerTest?.rejectEvents(
            source: source,
            file: file,
            line: line,
            eventClasses,
            testContinuationBlock
        )
    }

    public func rejectEvents(
        source: Source,
        file: StaticString = #file,
        line: UInt = #line,
        _ multipleEventExpectation: MultipleEventsExpectation,
        _ testContinuationBlock: () -> Void
    ) {
        playerTest?.rejectEvents(
            source: source,
            file: file,
            line: line,
            multipleEventExpectation,
            testContinuationBlock
        )
    }

    public func callPlayerAndExpectEvent<T: Event>(
        _ playerBlock: @escaping (Player) -> Void,
        _ eventClass: T.Type,
        timeout: TimeInterval? = nil,
        file: StaticString = #file,
        line: UInt = #line,
        eventHandlerBlock: ((T) -> Void)? = nil
    ) {
        playerTest?.callPlayerAndExpectEvent(
            playerBlock,
            eventClass,
            timeout: timeout,
            file: file,
            line: line,
            eventHandlerBlock: eventHandlerBlock
        )
    }

    public func callPlayerAndExpectEvent<T: Event>(
        _ playerBlock: @escaping (Player) -> Void,
        _ eventExpectation: SingleEventExpectation<T>,
        timeout: TimeInterval? = nil,
        file: StaticString = #file,
        line: UInt = #line,
        eventHandlerBlock: ((T) -> Void)? = nil
    ) {
        playerTest?.callPlayerAndExpectEvent(
            playerBlock,
            eventExpectation,
            timeout: timeout,
            file: file,
            line: line,
            eventHandlerBlock: eventHandlerBlock
        )
    }

    public func callPlayerAndExpectEvent<T: SourceEvent>(
        source: Source,
        _ playerBlock: @escaping (Player) -> Void,
        _ eventClass: T.Type,
        timeout: TimeInterval? = nil,
        file: StaticString = #file,
        line: UInt = #line,
        eventHandlerBlock: ((T) -> Void)? = nil
    ) {
        playerTest?.callPlayerAndExpectEvent(
            source: source,
            playerBlock,
            eventClass,
            timeout: timeout,
            file: file,
            line: line,
            eventHandlerBlock: eventHandlerBlock
        )
    }

    public func callPlayerAndExpectEvent<T: SourceEvent>(
        source: Source,
        _ playerBlock: @escaping (Player) -> Void,
        _ eventExpectation: SingleEventExpectation<T>,
        timeout: TimeInterval? = nil,
        file: StaticString = #file,
        line: UInt = #line,
        eventHandlerBlock: ((T) -> Void)? = nil
    ) {
        playerTest?.callPlayerAndExpectEvent(
            source: source,
            playerBlock,
            eventExpectation,
            timeout: timeout,
            file: file,
            line: line,
            eventHandlerBlock: eventHandlerBlock
        )
    }

    public func callPlayerAndExpectEvents(
        _ playerBlock: @escaping (Player) -> Void,
        _ eventClasses: [Event.Type],
        timeout: TimeInterval? = nil,
        file: StaticString = #file,
        line: UInt = #line,
        eventHandlerBlock: (([Event]) -> Void)? = nil
    ) {
        playerTest?.callPlayerAndExpectEvents(
            playerBlock,
            eventClasses,
            timeout: timeout,
            file: file,
            line: line,
            eventHandlerBlock: eventHandlerBlock
        )
    }

    public func callPlayerAndExpectEvents(
        _ playerBlock: @escaping (Player) -> Void,
        _ eventClasses: Event.Type...,
        timeout: TimeInterval? = nil,
        file: StaticString = #file,
        line: UInt = #line,
        eventHandlerBlock: (([Event]) -> Void)? = nil
    ) {
        playerTest?.callPlayerAndExpectEvents(
            playerBlock,
            eventClasses,
            timeout: timeout,
            file: file,
            line: line,
            eventHandlerBlock: eventHandlerBlock
        )
    }

    public func callPlayerAndExpectEvents(
        _ playerBlock: @escaping (Player) -> Void,
        _ multipleEventsExpectation: MultipleEventsExpectation,
        timeout: TimeInterval? = nil,
        file: StaticString = #file,
        line: UInt = #line,
        eventHandlerBlock: (([Event]) -> Void)? = nil
    ) {
        playerTest?.callPlayerAndExpectEvents(
            playerBlock,
            multipleEventsExpectation,
            timeout: timeout,
            file: file,
            line: line,
            eventHandlerBlock: eventHandlerBlock
        )
    }

    public func callPlayerAndExpectEvents(
        source: Source,
        _ playerBlock: @escaping (Player) -> Void,
        _ eventClasses: [SourceEvent.Type],
        timeout: TimeInterval? = nil,
        file: StaticString = #file,
        line: UInt = #line,
        eventHandlerBlock: (([SourceEvent]) -> Void)? = nil
    ) {
        playerTest?.callPlayerAndExpectEvents(
            source: source,
            playerBlock,
            eventClasses,
            timeout: timeout,
            file: file,
            line: line,
            eventHandlerBlock: eventHandlerBlock
        )
    }

    public func callPlayerAndExpectEvents(
        source: Source,
        _ playerBlock: @escaping (Player) -> Void,
        _ eventClasses: SourceEvent.Type...,
        timeout: TimeInterval? = nil,
        file: StaticString = #file,
        line: UInt = #line,
        eventHandlerBlock: (([SourceEvent]) -> Void)? = nil
    ) {
        playerTest?.callPlayerAndExpectEvents(
            source: source,
            playerBlock,
            eventClasses,
            timeout: timeout,
            file: file,
            line: line,
            eventHandlerBlock: eventHandlerBlock
        )
    }

    public func callPlayerAndExpectEvents(
        source: Source,
        _ playerBlock: @escaping (Player) -> Void,
        _ multipleEventsExpectation: MultipleEventsExpectation,
        timeout: TimeInterval? = nil,
        file: StaticString = #file,
        line: UInt = #line,
        eventHandlerBlock: (([SourceEvent]) -> Void)? = nil
    ) {
        playerTest?.callPlayerAndExpectEvents(
            source: source,
            playerBlock,
            multipleEventsExpectation,
            timeout: timeout,
            file: file,
            line: line,
            eventHandlerBlock: eventHandlerBlock
        )
    }

    public func callPlayer(_ playerBlock: @escaping (Player) -> Void) {
        playerTest?.callPlayer(playerBlock)
    }

    public func verifyPlayer(_ playerBlock: @escaping (Player) -> Void) {
        playerTest?.verifyPlayer(playerBlock)
    }

    public func safeVerifyPlayer(_ playerBlock: @escaping (Player?) -> Void) {
        playerTest?.safeVerifyPlayer(playerBlock)
    }

    public func createSource(sourceConfig: SourceConfig) -> Source {
        playerTest!.createSource(sourceConfig: sourceConfig)
    }

    public func load(
        _ source: Source,
        preloadAllSources: Bool = false,
        timeout: TimeInterval? = nil,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        playerTest?.load(
            source,
            preloadAllSources: preloadAllSources,
            timeout: timeout,
            file: file,
            line: line
        )
    }

    public func load(
        _ sources: [Source],
        preloadAllSources: Bool = false,
        timeout: TimeInterval? = nil,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        playerTest?.load(
            sources,
            preloadAllSources: preloadAllSources,
            timeout: timeout,
            file: file,
            line: line
        )
    }

    public func load(
        _ sources: Source...,
        preloadAllSources: Bool = false,
        timeout: TimeInterval? = nil,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        playerTest?.load(
            sources,
            preloadAllSources: preloadAllSources,
            timeout: timeout,
            file: file,
            line: line
        )
    }

    public func load(
        _ sourceConfig: SourceConfig,
        preloadAllSources: Bool = false,
        timeout: TimeInterval? = nil,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        playerTest?.load(
            sourceConfig,
            preloadAllSources: preloadAllSources,
            timeout: timeout,
            file: file,
            line: line
        )
    }

    public func load(
        _ sourceConfigs: [SourceConfig],
        preloadAllSources: Bool = false,
        timeout: TimeInterval? = nil,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        playerTest?.load(
            sourceConfigs,
            preloadAllSources: preloadAllSources,
            timeout: timeout,
            file: file,
            line: line
        )
    }

    public func load(
        _ sourceConfigs: SourceConfig...,
        preloadAllSources: Bool = false,
        timeout: TimeInterval? = nil,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        playerTest?.load(
            sourceConfigs,
            preloadAllSources: preloadAllSources,
            timeout: timeout,
            file: file,
            line: line
        )
    }

    public func load(
        _ playlistConfig: PlaylistConfig,
        timeout: TimeInterval? = nil,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        playerTest?.load(
            playlistConfig,
            timeout: timeout,
            file: file,
            line: line
        )
    }

    public func play(
        for time: TimeInterval,
        timeout: TimeInterval? = nil,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        playerTest?.play(for: time, timeout: timeout, file: file, line: line)
    }

    public func play(
        until time: TimeInterval,
        timeout: TimeInterval? = nil,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        playerTest?.play(until: time, timeout: timeout, file: file, line: line)
    }

    public func wait(for time: TimeInterval) {
        playerTest?.wait(for: time)
    }

    public func wait(
        timeout: TimeInterval? = nil,
        file: StaticString = #file,
        line: UInt = #line,
        until playerBlock: @escaping (Player) -> Bool
    ) {
        playerTest?.wait(timeout: timeout, file: file, line: line, until: playerBlock)
    }

    public func deallocPlayer() {
        playerTest?.deallocPlayer()
    }

    public func trackStalling(_ trackingBlock: (StallingHistory) -> Void) {
        playerTest?.trackStalling(trackingBlock)
    }

    public func stubNoInternet(_ testBlock: () -> Void) {
        playerTest?.stubNoInternet(testBlock)
    }
}
