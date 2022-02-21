//
// Bitmovin Player iOS SDK
// Copyright (C) 2021, Bitmovin GmbH, All Rights Reserved
//
// This source code and its use and distribution, is subject to the terms
// and conditions of the applicable license agreement.
//

import BitmovinPlayer
import Foundation
import XCTest

public typealias OfflineContentManagerTestBlock = (OfflineContentManager) -> Void
public typealias OfflineTestBlock = () throws -> Void

typealias OfflineTestApi =
    OfflineTestLifecycleApi &
    OfflineTestSingleEventExpectationApi &
    OfflineTestMultipleEventsExpectationApi &
    OfflineTestRejectEventApi &
    OfflineTestRejectEventsApi &
    OfflineTestConvenienceApi

/// Provides all necessary API to conveniently write system tests for the Offline feature
protocol OfflineTestLifecycleApi {
    /// Starts the OfflineTest by creating a `OfflineManager` instance and executes the `testBlock`
    /// - Parameters:
    ///   - offlineConfig: offline config to use with the `OfflineManager`
    ///   - failOnError: defines if tests should fail when receiving an error event
    ///   - waitForSuspendedDownloadsRestoring: defines if `testBlock` should wait for
    ///   estoring offline downlaods to finish
    ///   - file: The file to use for the log
    ///   - line: The line use for the log
    ///   - testBlock: test block to be executed
    func startOfflineTest(
        offlineConfig: OfflineConfig,
        failOnError failOnErrorEnabled: Bool,
        waitForSuspendedDownloadsRestoring: Bool,
        file: StaticString,
        line: UInt,
        _ testBlock: OfflineTestBlock
    )
}

protocol OfflineTestCallOfflineContentManagerAndExpectApi {
    /// Starts listening for the specified offline Event before executing the passed `offlineContentManagerBlock`.
    /// When the event is received, the `eventHandlerBlock` is called. This is the race-condition-safe
    /// version of calling `callOfflineContentManager` and `expectEvent` after that.
    /// Useful when events are directly tied to calls in the `offlineContentManagerBlock`.
    func callOfflineContentManagerAndExpectEvent<T: OfflineEvent>(
        _ offlineContentManager: OfflineContentManager,
        _ offlineContentManagerBlock: @escaping OfflineContentManagerTestBlock,
        _ eventClass: T.Type,
        timeout: TimeInterval,
        file: StaticString,
        line: UInt,
        eventHandlerBlock: ((T) -> Void)?
    )

    /// Starts listening for the specified `SingleEventExpectation` before executing the passed
    /// `offlineContentManagerBlock`.
    /// When the event is received, the `eventHandlerBlock` is called. This is the race-condition-safe
    /// version of calling `callOfflineContentManager` and `expectEvent` after that.
    /// Useful when events are directly tied to calls in the `offlineContentManagerBlock`.
    func callOfflineContentManagerAndExpectEvent<T: OfflineEvent>(
        _ offlineContentManager: OfflineContentManager,
        _ offlineContentManagerBlock: @escaping OfflineContentManagerTestBlock,
        _ eventExpectation: SingleEventExpectation<T>,
        timeout: TimeInterval,
        file: StaticString,
        line: UInt,
        eventHandlerBlock: ((T) -> Void)?
    )

    /// Starts listening for the specified `MultipleEventsExpectation` before executing the passed
    /// `offlineContentManagerBlock`.
    /// When the expectation is fulfilled in the specified order, the `eventsHandlerBlock` is called.
    /// This is the race-condition-safe version of calling `callOfflineContentManager` and `expectEvent` after that.
    /// Useful when events are directly tied to calls in the `offlineContentManagerBlock`.
    func callOfflineContentManagerAndExpectEvents(
        _ offlineContentManager: OfflineContentManager,
        _ offlineContentManagerBlock: @escaping OfflineContentManagerTestBlock,
        _ multipleEventsExpectation: MultipleEventsExpectation,
        timeout: TimeInterval,
        file: StaticString,
        line: UInt,
        eventHandlerBlock: (([OfflineEvent]) -> Void)?
    )
}

protocol OfflineTestSingleEventExpectationApi {
    /// Listens for the specified Event to be emitted and blocks the calling thread until the event is
    /// received or the timeout is reached. In the case where the event is received, the `eventHandlerBlock` is called.
    func expectEvent<T: OfflineEvent>(
        _ offlineContentManager: OfflineContentManager,
        _ eventClass: T.Type,
        timeout: TimeInterval,
        file: StaticString,
        line: UInt,
        eventHandlerBlock: ((T) -> Void)?
    )

    /// Listens for the specified `SingleEventExpectation` to be emitted and blocks the calling thread until the event
    /// is received or the timeout is reached. In the case where the event is received, the `eventHandlerBlock`
    /// is called.
    func expectEvent<T: OfflineEvent>(
        _ offlineContentManager: OfflineContentManager,
        _ eventExpectation: SingleEventExpectation<T>,
        timeout: TimeInterval,
        file: StaticString,
        line: UInt,
        eventHandlerBlock: ((T) -> Void)?
    )
}

protocol OfflineTestMultipleEventsExpectationApi {
    /// Listens for the specified `MultipleEventsExpectation` to be fulfilled and blocks the calling thread until
    /// the expectation is fulfilled in the specified order or the timeout is reached.
    /// In the case where the expectation is fulfilled, the `eventsHandlerBlock` is called with an ordered list of the
    /// Events
    func expectEvents(
        _ offlineContentManager: OfflineContentManager,
        _ multipleEventExpectation: MultipleEventsExpectation,
        timeout: TimeInterval,
        file: StaticString,
        line: UInt,
        eventHandlerBlock: (([OfflineEvent]) -> Void)?
    )
}

protocol OfflineTestRejectEventApi {
    /// Listens for the specified `OfflineEvent` while the test continues in the `testContinuationBlock`.
    /// If the event is received during execution of the `testContinuationBlock`, the test fails.
    func rejectEvent<T: OfflineEvent>(
        _ offlineContentManager: OfflineContentManager,
        file: StaticString,
        line: UInt,
        _ eventClass: T.Type,
        _ testContinuationBlock: () -> Void
    )

    /// Listens for the specified `SingleEventExpectation` while the test continues in the `testContinuationBlock`.
    /// If the `rejectedExpectation` fulfills during the `testContinuationBlock`, the test fails.
    func rejectEvent<T: OfflineEvent>(
        _ offlineContentManager: OfflineContentManager,
        file: StaticString,
        line: UInt,
        _ eventExpectation: SingleEventExpectation<T>,
        _ testContinuationBlock: () -> Void
    )
}

protocol OfflineTestRejectEventsApi {
    /// Listens for the specified `MultipleEventsExpectation` while the test continues in the `testContinuationBlock`.
    /// If the `rejectedExpectation` fulfills during the `testContinuationBlock`, the test fails.
    func rejectEvents(
        _ offlineContentManager: OfflineContentManager,
        file: StaticString,
        line: UInt,
        _ multipleEventExpectation: MultipleEventsExpectation,
        _ testContinuationBlock: () -> Void
    )
}

protocol OfflineTestConvenienceApi {
    /// Get the `OfflineContentManager` for the provided `SourceConfig`
    /// - Parameters:
    ///   - sourceConfig: the source config to get the `OfflineContentManager`
    ///   - id: unique identifier for the given `SourceConfig` which must not change once provided.
    ///   - clean: reset the `OfflineContentManager` instance before returning it by
    ///   canceling the download and delete the data.
    func getOfflineContentManager(
        sourceConfig: SourceConfig,
        id: String?,
        clean: Bool
    ) throws -> OfflineContentManager

    /// Download content until progress
    func downloadUntilProgress(
        _ offlineContentManager: OfflineContentManager,
        progress: Double,
        timeout: TimeInterval,
        file: StaticString,
        line: UInt
    )

    /// Wait until the download of tracks has finished
    func waitUntilDownloaded(
        _ offlineContentManager: OfflineContentManager,
        tracks: OfflineTrackSelection,
        config: DownloadConfig,
        timeout: TimeInterval,
        file: StaticString,
        line: UInt
    )

    /// Wait until the download has finished
    func waitUntilDownloaded(
        _ offlineContentManager: OfflineContentManager,
        config: DownloadConfig,
        timeout: TimeInterval,
        file: StaticString,
        line: UInt
    )
}
