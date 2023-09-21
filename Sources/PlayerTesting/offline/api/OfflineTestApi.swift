//
// Bitmovin Player iOS SDK
// Copyright (C) 2021, Bitmovin GmbH, All Rights Reserved
//
// This source code and its use and distribution, is subject to the terms
// and conditions of the applicable license agreement.
//

import BitmovinPlayerCore
import Foundation
import XCTest

public typealias OfflineContentManagerTestBlock = (OfflineContentManager) -> Void
public typealias OfflineTestBlock = () throws -> Void

internal typealias OfflineTestApi =
    OfflineTestLifecycleApi &
    OfflineTestSingleEventExpectationApi &
    OfflineTestMultipleEventsExpectationApi &
    OfflineTestRejectEventApi &
    OfflineTestRejectEventsApi &
    OfflineTestConvenienceApi

/// Provides all necessary API to conveniently write system tests for the Offline feature
internal protocol OfflineTestLifecycleApi {
    func startOfflineTest(
        offlineConfig: OfflineConfig,
        failOnError failOnErrorEnabled: Bool,
        waitForSuspendedDownloadsRestoring: Bool,
        file: StaticString,
        line: UInt,
        _ testBlock: OfflineTestBlock
    )
}

internal protocol OfflineTestCallOfflineContentManagerAndExpectApi {
    func callOfflineContentManagerAndExpectEvent<T: OfflineEvent>(
        _ offlineContentManager: OfflineContentManager,
        _ offlineContentManagerBlock: @escaping OfflineContentManagerTestBlock,
        _ eventClass: T.Type,
        timeout: TimeInterval,
        file: StaticString,
        line: UInt,
        eventHandlerBlock: ((T) -> Void)?
    )

    func callOfflineContentManagerAndExpectEvent<T: OfflineEvent>(
        _ offlineContentManager: OfflineContentManager,
        _ offlineContentManagerBlock: @escaping OfflineContentManagerTestBlock,
        _ eventExpectation: SingleEventExpectation<T>,
        timeout: TimeInterval,
        file: StaticString,
        line: UInt,
        eventHandlerBlock: ((T) -> Void)?
    )

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

internal protocol OfflineTestSingleEventExpectationApi {
    func expectEvent<T: OfflineEvent>(
        _ offlineContentManager: OfflineContentManager,
        _ eventClass: T.Type,
        timeout: TimeInterval,
        file: StaticString,
        line: UInt,
        eventHandlerBlock: ((T) -> Void)?
    )

    func expectEvent<T: OfflineEvent>(
        _ offlineContentManager: OfflineContentManager,
        _ eventExpectation: SingleEventExpectation<T>,
        timeout: TimeInterval,
        file: StaticString,
        line: UInt,
        eventHandlerBlock: ((T) -> Void)?
    )
}

internal protocol OfflineTestMultipleEventsExpectationApi {
    func expectEvents(
        _ offlineContentManager: OfflineContentManager,
        _ multipleEventExpectation: MultipleEventsExpectation,
        timeout: TimeInterval,
        file: StaticString,
        line: UInt,
        eventHandlerBlock: (([OfflineEvent]) -> Void)?
    )
}

internal protocol OfflineTestRejectEventApi {
    func rejectEvent<T: OfflineEvent>(
        _ offlineContentManager: OfflineContentManager,
        file: StaticString,
        line: UInt,
        _ eventClass: T.Type,
        _ testContinuationBlock: () -> Void
    )

    func rejectEvent<T: OfflineEvent>(
        _ offlineContentManager: OfflineContentManager,
        file: StaticString,
        line: UInt,
        _ eventExpectation: SingleEventExpectation<T>,
        _ testContinuationBlock: () -> Void
    )
}

internal protocol OfflineTestRejectEventsApi {
    func rejectEvents(
        _ offlineContentManager: OfflineContentManager,
        file: StaticString,
        line: UInt,
        _ multipleEventExpectation: MultipleEventsExpectation,
        _ testContinuationBlock: () -> Void
    )
}

internal protocol OfflineTestConvenienceApi {
    func getOfflineContentManager(
        sourceConfig: SourceConfig,
        id: String?,
        clean: Bool
    ) throws -> OfflineContentManager

    func downloadUntilProgress(
        _ offlineContentManager: OfflineContentManager,
        progress: Double,
        timeout: TimeInterval,
        file: StaticString,
        line: UInt
    )

    func waitUntilDownloaded(
        _ offlineContentManager: OfflineContentManager,
        tracks: OfflineTrackSelection,
        config: DownloadConfig,
        timeout: TimeInterval,
        file: StaticString,
        line: UInt
    )

    func waitUntilDownloaded(
        _ offlineContentManager: OfflineContentManager,
        config: DownloadConfig,
        timeout: TimeInterval,
        file: StaticString,
        line: UInt
    )
}
