#if os(iOS)
import BitmovinPlayerCore
import Foundation

/// Starts the OfflineTest by creating a `OfflineManager` instance and executes the `testBlock`
/// - Parameters:
///   - offlineConfig: offline config to use with the `OfflineManager`
///   - failOnError: defines if tests should fail when receiving an error event
///   - waitForSuspendedDownloadsRestoring: defines if `testBlock` should wait for
///   estoring offline downlaods to finish
///   - file: The file to use for the log
///   - line: The line use for the log
///   - testBlock: test block to be executed
@MainActor
public func startOfflineTest(
    offlineConfig: OfflineConfig = OfflineConfig(),
    failOnError failOnErrorEnabled: Bool = true,
    waitForSuspendedDownloadsRestoring: Bool = true,
    file: StaticString = #file,
    line: UInt = #line,
    _ testBlock: OfflineTestBlock
) async throws {
    try await OfflineWorld.sharedWorld.startOfflineTest(
        offlineConfig: offlineConfig,
        failOnError: failOnErrorEnabled,
        waitForSuspendedDownloadsRestoring: waitForSuspendedDownloadsRestoring,
        file: file,
        line: line,
        testBlock
    )
}

/// Starts listening for the specified Event before executing the passed `offlineContentManagerBlock`.
/// When the event is received, the `eventHandlerBlock` is called. This is the race-condition-safe
/// version of calling `callOfflineContentManager` and `expectEvent` after that.
/// Useful when events are directly tied to calls in the `offlineContentManagerBlock`.
@MainActor
@discardableResult
public func callOfflineContentManagerAndExpectEvent<T: OfflineEvent>(
    _ offlineContentManager: OfflineContentManager,
    _ offlineContentManagerBlock: @escaping OfflineContentManagerTestBlock,
    _ eventClass: T.Type,
    timeout: TimeInterval,
    file: StaticString = #file,
    line: UInt = #line
) async throws -> T {
    try await OfflineWorld.sharedWorld.callOfflineContentManagerAndExpectEvent(
        offlineContentManager,
        offlineContentManagerBlock,
        eventClass,
        timeout: timeout,
        file: file,
        line: line
    )
}

/// Starts listening for the specified `SingleEventExpectation` before executing the passed
/// `offlineContentManagerBlock`.
/// When the event is received, the `eventHandlerBlock` is called. This is the race-condition-safe
/// version of calling `callOfflineContentManager` and `expectEvent` after that.
/// Useful when events are directly tied to calls in the `offlineContentManagerBlock`.
@MainActor
@discardableResult
public func callOfflineContentManagerAndExpectEvent<T: OfflineEvent>(
    _ offlineContentManager: OfflineContentManager,
    _ offlineContentManagerBlock: @escaping OfflineContentManagerTestBlock,
    _ eventExpectation: SingleEventExpectation<T>,
    timeout: TimeInterval,
    file: StaticString = #file,
    line: UInt = #line
) async throws -> T {
    try await OfflineWorld.sharedWorld.callOfflineContentManagerAndExpectEvent(
        offlineContentManager,
        offlineContentManagerBlock,
        eventExpectation,
        timeout: timeout,
        file: file,
        line: line
    )
}

/// Starts listening for the specified `MultipleEventsExpectation` before executing the passed
/// `offlineContentManagerBlock`.
/// When the expectation is fulfilled in the specified order, the `eventsHandlerBlock` is called.
/// This is the race-condition-safe version of calling `callOfflineContentManager` and `expectEvent` after that.
/// Useful when events are directly tied to calls in the `offlineContentManagerBlock`.
@MainActor
@discardableResult
public func callOfflineContentManagerAndExpectEvents(
    _ offlineContentManager: OfflineContentManager,
    _ offlineContentManagerBlock: @escaping OfflineContentManagerTestBlock,
    _ multipleEventsExpectation: MultipleEventsExpectation,
    timeout: TimeInterval,
    file: StaticString = #file,
    line: UInt = #line
) async throws -> [OfflineEvent] {
    try await OfflineWorld.sharedWorld.callOfflineContentManagerAndExpectEvents(
        offlineContentManager,
        offlineContentManagerBlock,
        multipleEventsExpectation,
        timeout: timeout,
        file: file,
        line: line
    )
}

/// Listens for the specified Event to be emitted and blocks the calling thread until the event is
/// received or the timeout is reached. In the case where the event is received, the `eventHandlerBlock` is called.
@MainActor
@discardableResult
public func expectEvent<T: OfflineEvent>(
    _ offlineContentManager: OfflineContentManager,
    _ eventClass: T.Type,
    timeout: TimeInterval,
    file: StaticString = #file,
    line: UInt = #line
) async throws -> T {
    try await OfflineWorld.sharedWorld.expectEvent(
        offlineContentManager,
        eventClass,
        timeout: timeout,
        file: file,
        line: line
    )
}

/// Listens for the specified `SingleEventExpectation` to be emitted and blocks the calling thread until the event
/// is received or the timeout is reached. In the case where the event is received, the `eventHandlerBlock`
/// is called.
@MainActor
@discardableResult
public func expectEvent<T: OfflineEvent>(
    _ offlineContentManager: OfflineContentManager,
    _ eventExpectation: SingleEventExpectation<T>,
    timeout: TimeInterval,
    file: StaticString = #file,
    line: UInt = #line
) async throws -> T {
    try await OfflineWorld.sharedWorld.expectEvent(
        offlineContentManager,
        eventExpectation,
        timeout: timeout,
        file: file,
        line: line
    )
}

/// Listens for the specified `MultipleEventsExpectation` to be fulfilled and blocks the calling thread until
/// the expectation is fulfilled in the specified order or the timeout is reached.
/// In the case where the expectation is fulfilled, the `eventsHandlerBlock` is called with an ordered list of the
/// Events
@MainActor
@discardableResult
public func expectEvents(
    _ offlineContentManager: OfflineContentManager,
    _ multipleEventExpectation: MultipleEventsExpectation,
    timeout: TimeInterval,
    file: StaticString = #file,
    line: UInt = #line
) async throws -> [OfflineEvent] {
    try await OfflineWorld.sharedWorld.expectEvents(
        offlineContentManager,
        multipleEventExpectation,
        timeout: timeout,
        file: file,
        line: line
    )
}

/// Listens for the specified `OfflineEvent` while the test continues in the `testContinuationBlock`.
/// If the event is received during execution of the `testContinuationBlock`, the test fails.
@MainActor
public func rejectEvent<T: OfflineEvent>(
    _ offlineContentManager: OfflineContentManager,
    file: StaticString = #file,
    line: UInt = #line,
    _ eventClass: T.Type,
    _ testContinuationBlock: TestContinuationBlock
) async throws {
    try await OfflineWorld.sharedWorld.rejectEvent(
        offlineContentManager,
        file: file,
        line: line,
        eventClass,
        testContinuationBlock
    )
}

/// Listens for the specified `SingleEventExpectation` while the test continues in the `testContinuationBlock`.
/// If the `rejectedExpectation` fulfills during the `testContinuationBlock`, the test fails.
@MainActor
public func rejectEvent<T: OfflineEvent>(
    _ offlineContentManager: OfflineContentManager,
    file: StaticString = #file,
    line: UInt = #line,
    _ eventExpectation: SingleEventExpectation<T>,
    _ testContinuationBlock: TestContinuationBlock
) async throws {
    try await OfflineWorld.sharedWorld.rejectEvent(
        offlineContentManager,
        file: file,
        line: line,
        eventExpectation,
        testContinuationBlock
    )
}

/// Listens for the specified `MultipleEventsExpectation` while the test continues in the `testContinuationBlock`.
/// If the `rejectedExpectation` fulfills during the `testContinuationBlock`, the test fails.
@MainActor
public func rejectEvents(
    _ offlineContentManager: OfflineContentManager,
    file: StaticString = #file,
    line: UInt = #line,
    _ multipleEventExpectation: MultipleEventsExpectation,
    _ testContinuationBlock: TestContinuationBlock
) async throws {
    try await OfflineWorld.sharedWorld.rejectEvents(
        offlineContentManager,
        file: file,
        line: line,
        multipleEventExpectation,
        testContinuationBlock
    )
}

/// Get the `OfflineContentManager` for the provided `SourceConfig`
/// - Parameters:
///   - sourceConfig: the source config to get the `OfflineContentManager`
///   - id: unique identifier for the given `SourceConfig` which must not change once provided.
///   - clean: reset the `OfflineContentManager` instance before returning it by
///   canceling the download and delete the data.
@MainActor
public func getOfflineContentManager(
    sourceConfig: SourceConfig,
    id: String? = nil,
    clean: Bool = true
) async throws -> OfflineContentManager {
    try await OfflineWorld.sharedWorld.getOfflineContentManager(
        sourceConfig: sourceConfig,
        id: id,
        clean: clean
    )
}

/// Download content until progress
@MainActor
public func downloadUntilProgress(
    _ offlineContentManager: OfflineContentManager,
    progress: Double,
    timeout: TimeInterval,
    file: StaticString = #file,
    line: UInt = #line
) async throws {
    try await OfflineWorld.sharedWorld.downloadUntilProgress(
        offlineContentManager,
        progress: progress,
        timeout: timeout,
        file: file,
        line: line
    )
}

/// Wait until the download of tracks has finished
@MainActor
public func waitUntilDownloaded(
    _ offlineContentManager: OfflineContentManager,
    tracks: OfflineTrackSelection,
    config: DownloadConfig = DownloadConfig.lowestQuality,
    timeout: TimeInterval,
    file: StaticString = #file,
    line: UInt = #line
) async throws {
    try await OfflineWorld.sharedWorld.waitUntilDownloaded(
        offlineContentManager,
        tracks: tracks,
        config: config,
        timeout: timeout,
        file: file,
        line: line
    )
}

/// Wait until the download finished
@MainActor
public func waitUntilDownloaded(
    _ offlineContentManager: OfflineContentManager,
    config: DownloadConfig = DownloadConfig.lowestQuality,
    timeout: TimeInterval,
    file: StaticString = #file,
    line: UInt = #line
) async throws {
    try await OfflineWorld.sharedWorld.waitUntilDownloaded(
        offlineContentManager,
        config: config,
        timeout: timeout,
        file: file,
        line: line
    )
}
#endif
