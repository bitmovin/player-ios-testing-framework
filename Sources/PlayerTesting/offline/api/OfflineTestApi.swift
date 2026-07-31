//
// Bitmovin Player iOS SDK
// Copyright (C) 2021, Bitmovin GmbH, All Rights Reserved
//
// This source code and its use and distribution, is subject to the terms
// and conditions of the applicable license agreement.
//

#if os(iOS)
import BitmovinPlayerCore
import Foundation
import XCTest

public typealias OfflineContentManagerTestBlock = (OfflineContentManager) -> Void
public typealias OfflineTestBlock = () async throws -> Void

internal typealias OfflineTestApi =
    OfflineTestConvenienceApi &
    OfflineTestLifecycleApi &
    OfflineTestMultipleEventsExpectationApi &
    OfflineTestRejectEventApi &
    OfflineTestRejectEventsApi &
    OfflineTestSingleEventExpectationApi

/// Provides all necessary API to conveniently write system tests for the Offline feature
internal protocol OfflineTestLifecycleApi {
    func startOfflineTest(
        offlineConfig: OfflineConfig,
        failOnError failOnErrorEnabled: Bool,
        waitForSuspendedDownloadsRestoring: Bool,
        file: StaticString,
        line: UInt,
        _ testBlock: OfflineTestBlock
    ) async throws
}

internal protocol OfflineTestCallOfflineContentManagerAndExpectApi {
    @discardableResult
    func callOfflineContentManagerAndExpectEvent<T: OfflineEvent>(
        _ offlineContentManager: OfflineContentManager,
        _ offlineContentManagerBlock: @escaping OfflineContentManagerTestBlock,
        _ eventClass: T.Type,
        timeout: TimeInterval,
        file: StaticString,
        line: UInt
    ) async throws -> T

    @discardableResult
    func callOfflineContentManagerAndExpectEvent<T: OfflineEvent>(
        _ offlineContentManager: OfflineContentManager,
        _ offlineContentManagerBlock: @escaping OfflineContentManagerTestBlock,
        _ eventExpectation: SingleEventExpectation<T>,
        timeout: TimeInterval,
        file: StaticString,
        line: UInt
    ) async throws -> T

    @discardableResult
    func callOfflineContentManagerAndExpectEvents(
        _ offlineContentManager: OfflineContentManager,
        _ offlineContentManagerBlock: @escaping OfflineContentManagerTestBlock,
        _ multipleEventsExpectation: MultipleEventsExpectation,
        timeout: TimeInterval,
        file: StaticString,
        line: UInt
    ) async throws -> [OfflineEvent]
}

internal protocol OfflineTestSingleEventExpectationApi {
    @discardableResult
    func expectEvent<T: OfflineEvent>(
        _ offlineContentManager: OfflineContentManager,
        _ eventClass: T.Type,
        timeout: TimeInterval,
        file: StaticString,
        line: UInt
    ) async throws -> T

    @discardableResult
    func expectEvent<T: OfflineEvent>(
        _ offlineContentManager: OfflineContentManager,
        _ eventExpectation: SingleEventExpectation<T>,
        timeout: TimeInterval,
        file: StaticString,
        line: UInt
    ) async throws -> T
}

internal protocol OfflineTestMultipleEventsExpectationApi {
    @discardableResult
    func expectEvents(
        _ offlineContentManager: OfflineContentManager,
        _ multipleEventExpectation: MultipleEventsExpectation,
        timeout: TimeInterval,
        file: StaticString,
        line: UInt
    ) async throws -> [OfflineEvent]
}

internal protocol OfflineTestRejectEventApi {
    func rejectEvent<T: OfflineEvent>(
        _ offlineContentManager: OfflineContentManager,
        file: StaticString,
        line: UInt,
        _ eventClass: T.Type,
        _ testContinuationBlock: TestContinuationBlock
    ) async throws

    func rejectEvent<T: OfflineEvent>(
        _ offlineContentManager: OfflineContentManager,
        file: StaticString,
        line: UInt,
        _ eventExpectation: SingleEventExpectation<T>,
        _ testContinuationBlock: TestContinuationBlock
    ) async throws
}

internal protocol OfflineTestRejectEventsApi {
    func rejectEvents(
        _ offlineContentManager: OfflineContentManager,
        file: StaticString,
        line: UInt,
        _ multipleEventExpectation: MultipleEventsExpectation,
        _ testContinuationBlock: TestContinuationBlock
    ) async throws
}

internal protocol OfflineTestConvenienceApi {
    func getOfflineContentManager(
        sourceConfig: SourceConfig,
        id: String?,
        clean: Bool
    ) async throws -> OfflineContentManager

    func downloadUntilProgress(
        _ offlineContentManager: OfflineContentManager,
        progress: Double,
        timeout: TimeInterval,
        file: StaticString,
        line: UInt
    ) async throws

    func waitUntilDownloaded(
        _ offlineContentManager: OfflineContentManager,
        tracks: OfflineTrackSelection,
        config: DownloadConfig,
        timeout: TimeInterval,
        file: StaticString,
        line: UInt
    ) async throws

    func waitUntilDownloaded(
        _ offlineContentManager: OfflineContentManager,
        config: DownloadConfig,
        timeout: TimeInterval,
        file: StaticString,
        line: UInt
    ) async throws
}
#endif
