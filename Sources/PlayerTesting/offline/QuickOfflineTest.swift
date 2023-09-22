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

open class QuickOfflineTest: QuickSpec {
    private var offlineTest: OfflineTest?

    override open func setUp() {
        super.setUp()
        continueAfterFailure = false
    }
}

extension QuickOfflineTest: OfflineTestLifecycleApi {
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

extension QuickOfflineTest: OfflineTestCallOfflineContentManagerAndExpectApi {
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

extension QuickOfflineTest: OfflineTestSingleEventExpectationApi {
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

extension QuickOfflineTest: OfflineTestMultipleEventsExpectationApi {
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

extension QuickOfflineTest: OfflineTestRejectEventApi {
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

extension QuickOfflineTest: OfflineTestRejectEventsApi {
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

extension QuickOfflineTest: OfflineTestConvenienceApi {
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
