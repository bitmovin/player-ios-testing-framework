import BitmovinPlayerCore
import Foundation

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
@MainActor
public func startPlayerTest(
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
    try await PlayerWorld.sharedWorld.startPlayerTest(
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

/// Waits for a matching event and returns it.
///
/// If `whileListening` is provided, starts listening before running the closure and keeps any matching
/// events received while it runs. The timeout starts when the closure returns. If the closure is omitted
/// or `nil`, starts waiting immediately.
///
/// Rethrows errors from the closure and always removes the listeners before returning or throwing.
@MainActor
@discardableResult
public func expectEvent<T: PlayerEvent>(
    _ eventClass: T.Type,
    timeout: TimeInterval? = nil,
    file: StaticString = #file,
    line: UInt = #line,
    whileListening: TestContinuationBlock? = nil
) async throws -> T {
    try await PlayerWorld.sharedWorld.expectEvent(
        eventClass,
        timeout: timeout,
        file: file,
        line: line,
        whileListening: whileListening
    )
}

/// Waits for a matching event and returns it.
///
/// If `whileListening` is provided, starts listening before running the closure and keeps any matching
/// events received while it runs. The timeout starts when the closure returns. If the closure is omitted
/// or `nil`, starts waiting immediately.
///
/// Rethrows errors from the closure and always removes the listeners before returning or throwing.
@MainActor
@discardableResult
public func expectEvent<T: SourceEvent>(
    _ eventClass: T.Type,
    timeout: TimeInterval? = nil,
    file: StaticString = #file,
    line: UInt = #line,
    whileListening: TestContinuationBlock? = nil
) async throws -> T {
    try await PlayerWorld.sharedWorld.expectEvent(
        eventClass,
        timeout: timeout,
        file: file,
        line: line,
        whileListening: whileListening
    )
}

/// Waits for a matching event and returns it.
///
/// If `whileListening` is provided, starts listening before running the closure and keeps any matching
/// events received while it runs. The timeout starts when the closure returns. If the closure is omitted
/// or `nil`, starts waiting immediately.
///
/// Rethrows errors from the closure and always removes the listeners before returning or throwing.
@MainActor
@discardableResult
public func expectEvent<T: PlayerEvent>(
    _ eventExpectation: SingleEventExpectation<T>,
    timeout: TimeInterval? = nil,
    file: StaticString = #file,
    line: UInt = #line,
    whileListening: TestContinuationBlock? = nil
) async throws -> T {
    try await PlayerWorld.sharedWorld.expectEvent(
        eventExpectation,
        timeout: timeout,
        file: file,
        line: line,
        whileListening: whileListening
    )
}

/// Waits for a matching event and returns it.
///
/// If `whileListening` is provided, starts listening before running the closure and keeps any matching
/// events received while it runs. The timeout starts when the closure returns. If the closure is omitted
/// or `nil`, starts waiting immediately.
///
/// Rethrows errors from the closure and always removes the listeners before returning or throwing.
@MainActor
@discardableResult
public func expectEvent<T: SourceEvent>(
    _ eventExpectation: SingleEventExpectation<T>,
    timeout: TimeInterval? = nil,
    file: StaticString = #file,
    line: UInt = #line,
    whileListening: TestContinuationBlock? = nil
) async throws -> T {
    try await PlayerWorld.sharedWorld.expectEvent(
        eventExpectation,
        timeout: timeout,
        file: file,
        line: line,
        whileListening: whileListening
    )
}

/// Waits for the specified events in order and returns them.
///
/// If `whileListening` is provided, starts listening before running the closure and keeps any matching
/// events received while it runs. The timeout starts when the closure returns. If the closure is omitted
/// or `nil`, starts waiting immediately.
///
/// Rethrows errors from the closure and always removes the listeners before returning or throwing.
@MainActor
@discardableResult
public func expectEvents(
    _ eventClasses: Event.Type...,
    timeout: TimeInterval? = nil,
    file: StaticString = #file,
    line: UInt = #line,
    whileListening: TestContinuationBlock? = nil
) async throws -> [Event] {
    try await PlayerWorld.sharedWorld.expectEvents(
        eventClasses,
        timeout: timeout,
        file: file,
        line: line,
        whileListening: whileListening
    )
}

/// Waits for the specified events in order and returns them.
///
/// If `whileListening` is provided, starts listening before running the closure and keeps any matching
/// events received while it runs. The timeout starts when the closure returns. If the closure is omitted
/// or `nil`, starts waiting immediately.
///
/// Rethrows errors from the closure and always removes the listeners before returning or throwing.
@MainActor
@discardableResult
public func expectEvents(
    _ eventClasses: [Event.Type],
    timeout: TimeInterval? = nil,
    file: StaticString = #file,
    line: UInt = #line,
    whileListening: TestContinuationBlock? = nil
) async throws -> [Event] {
    try await PlayerWorld.sharedWorld.expectEvents(
        eventClasses,
        timeout: timeout,
        file: file,
        line: line,
        whileListening: whileListening
    )
}

/// Waits for the specified expectation and returns its matching events.
///
/// If `whileListening` is provided, starts listening before running the closure and keeps any matching
/// events received while it runs. The timeout starts when the closure returns. If the closure is omitted
/// or `nil`, starts waiting immediately.
///
/// Rethrows errors from the closure and always removes the listeners before returning or throwing.
@MainActor
@discardableResult
public func expectEvents(
    _ multipleEventExpectation: MultipleEventsExpectation,
    timeout: TimeInterval? = nil,
    file: StaticString = #file,
    line: UInt = #line,
    whileListening: TestContinuationBlock? = nil
) async throws -> [Event] {
    try await PlayerWorld.sharedWorld.expectEvents(
        multipleEventExpectation,
        timeout: timeout,
        file: file,
        line: line,
        whileListening: whileListening
    )
}

/// Listens for the specified BitmovinEvent while the test continues in the testContinuationBlock.
/// If the event is received during execution of the testContinuationBlock, the test fails.
@MainActor
public func rejectEvent<T: PlayerEvent>(
    file: StaticString = #file,
    line: UInt = #line,
    _ eventClass: T.Type,
    _ testContinuationBlock: TestContinuationBlock
) async throws {
    try await PlayerWorld.sharedWorld.rejectEvent(file: file, line: line, eventClass, testContinuationBlock)
}

/// Listens for the specified BitmovinEvent while the test continues in the testContinuationBlock.
/// If the event is received during execution of the testContinuationBlock, the test fails.
@MainActor
public func rejectEvent<T: SourceEvent>(
    file: StaticString = #file,
    line: UInt = #line,
    _ eventClass: T.Type,
    _ testContinuationBlock: TestContinuationBlock
) async throws {
    try await PlayerWorld.sharedWorld.rejectEvent(file: file, line: line, eventClass, testContinuationBlock)
}

/// Listens for the specified SingleEventExpectation while the test continues in the testContinuationBlock.
/// If the rejectedExpectation fulfills during the testContinuationBlock, the test fails.
@MainActor
public func rejectEvent<T: PlayerEvent>(
    file: StaticString = #file,
    line: UInt = #line,
    _ eventExpectation: SingleEventExpectation<T>,
    _ testContinuationBlock: TestContinuationBlock
) async throws {
    try await PlayerWorld.sharedWorld.rejectEvent(file: file, line: line, eventExpectation, testContinuationBlock)
}

/// Listens for the specified SingleEventExpectation while the test continues in the testContinuationBlock.
/// If the rejectedExpectation fulfills during the testContinuationBlock, the test fails.
@MainActor
public func rejectEvent<T: SourceEvent>(
    file: StaticString = #file,
    line: UInt = #line,
    _ eventExpectation: SingleEventExpectation<T>,
    _ testContinuationBlock: TestContinuationBlock
) async throws {
    try await PlayerWorld.sharedWorld.rejectEvent(file: file, line: line, eventExpectation, testContinuationBlock)
}

/// Listens for the specified BitmovinEvents while the test continues in the testContinuationBlock.
/// If the events are received during execution of the testContinuationBlock, the test fails.
@MainActor
public func rejectEvents(
    file: StaticString = #file,
    line: UInt = #line,
    _ eventClasses: Event.Type...,
    testContinuationBlock: TestContinuationBlock
) async throws {
    try await PlayerWorld.sharedWorld.rejectEvents(file: file, line: line, eventClasses, testContinuationBlock)
}

/// Listens for the specified BitmovinEvents while the test continues in the testContinuationBlock.
/// If the events are received during execution of the testContinuationBlock, the test fails.
@MainActor
public func rejectEvents(
    file: StaticString = #file,
    line: UInt = #line,
    _ eventClasses: [Event.Type],
    _ testContinuationBlock: TestContinuationBlock
) async throws {
    try await PlayerWorld.sharedWorld.rejectEvents(file: file, line: line, eventClasses, testContinuationBlock)
}

/// Listens for the specified MultipleEventsExpectation while the test continues in the testContinuationBlock.
/// If the rejectedExpectation fulfills during the testContinuationBlock, the test fails.
@MainActor
public func rejectEvents(
    file: StaticString = #file,
    line: UInt = #line,
    _ multipleEventExpectation: MultipleEventsExpectation,
    _ testContinuationBlock: TestContinuationBlock
) async throws {
    try await PlayerWorld.sharedWorld.rejectEvents(
        file: file,
        line: line,
        multipleEventExpectation,
        testContinuationBlock
    )
}

/// Waits for a matching event and returns it.
///
/// Starts listening before running `playerBlock` and keeps any matching events received while it runs.
/// Once the block returns, waits for any remaining events within the given timeout.
/// Rethrows errors from the block and always removes the listeners before returning or throwing.
@MainActor
@discardableResult
public func callPlayerAndExpectEvent<T: Event>(
    _ playerBlock: @escaping AsyncCallPlayerBlock,
    _ eventClass: T.Type,
    timeout: TimeInterval? = nil,
    file: StaticString = #file,
    line: UInt = #line
) async throws -> T {
    try await PlayerWorld.sharedWorld.callPlayerAndExpectEvent(
        playerBlock,
        eventClass,
        timeout: timeout,
        file: file,
        line: line
    )
}

/// Waits for a matching event and returns it.
///
/// Starts listening before running `playerBlock` and keeps any matching events received while it runs.
/// Once the block returns, waits for any remaining events within the given timeout.
/// Rethrows errors from the block and always removes the listeners before returning or throwing.
@MainActor
@discardableResult
public func callPlayerAndExpectEvent<T: Event>(
    _ playerBlock: @escaping AsyncCallPlayerBlock,
    _ eventExpectation: SingleEventExpectation<T>,
    timeout: TimeInterval? = nil,
    file: StaticString = #file,
    line: UInt = #line
) async throws -> T {
    try await PlayerWorld.sharedWorld.callPlayerAndExpectEvent(
        playerBlock,
        eventExpectation,
        timeout: timeout,
        file: file,
        line: line
    )
}

/// Waits for the specified events in order and returns them.
///
/// Starts listening before running `playerBlock` and keeps any matching events received while it runs.
/// Once the block returns, waits for any remaining events within the given timeout.
/// Rethrows errors from the block and always removes the listeners before returning or throwing.
@MainActor
@discardableResult
public func callPlayerAndExpectEvents(
    _ playerBlock: @escaping AsyncCallPlayerBlock,
    _ eventClasses: [Event.Type],
    timeout: TimeInterval? = nil,
    file: StaticString = #file,
    line: UInt = #line
) async throws -> [Event] {
    try await PlayerWorld.sharedWorld.callPlayerAndExpectEvents(
        playerBlock,
        eventClasses,
        timeout: timeout,
        file: file,
        line: line
    )
}

/// Waits for the specified events in order and returns them.
///
/// Starts listening before running `playerBlock` and keeps any matching events received while it runs.
/// Once the block returns, waits for any remaining events within the given timeout.
/// Rethrows errors from the block and always removes the listeners before returning or throwing.
@MainActor
@discardableResult
public func callPlayerAndExpectEvents(
    _ playerBlock: @escaping AsyncCallPlayerBlock,
    _ eventClasses: Event.Type...,
    timeout: TimeInterval? = nil,
    file: StaticString = #file,
    line: UInt = #line
) async throws -> [Event] {
    try await PlayerWorld.sharedWorld.callPlayerAndExpectEvents(
        playerBlock,
        eventClasses,
        timeout: timeout,
        file: file,
        line: line
    )
}

/// Waits for the specified expectation and returns its matching events.
///
/// Starts listening before running `playerBlock` and keeps any matching events received while it runs.
/// Once the block returns, waits for any remaining events within the given timeout.
/// Rethrows errors from the block and always removes the listeners before returning or throwing.
@MainActor
@discardableResult
public func callPlayerAndExpectEvents(
    _ playerBlock: @escaping AsyncCallPlayerBlock,
    _ multipleEventsExpectation: MultipleEventsExpectation,
    timeout: TimeInterval? = nil,
    file: StaticString = #file,
    line: UInt = #line
) async throws -> [Event] {
    try await PlayerWorld.sharedWorld.callPlayerAndExpectEvents(
        playerBlock,
        multipleEventsExpectation,
        timeout: timeout,
        file: file,
        line: line
    )
}

/// Executes the passed block with the BitmovinPlayer as argument.
/// Use this function to call Player API as part of the test.
@MainActor
public func callPlayer(_ playerBlock: @escaping CallPlayerBlock) {
    PlayerWorld.sharedWorld.callPlayer(playerBlock)
}

@MainActor
public func callPlayer(_ playerBlock: @escaping AsyncCallPlayerBlock) async throws {
    try await PlayerWorld.sharedWorld.callPlayer(playerBlock)
}

/// Executes the passed block with the BitmovinPlayer as argument.
/// Use this function to perform assertions in the scope of the Player.
@MainActor
public func verifyPlayer(_ playerBlock: @escaping CallPlayerBlock) {
    PlayerWorld.sharedWorld.verifyPlayer(playerBlock)
}

// Executes the passed block with the optional BitmovinPlayer as argument.
// Use this function to perform assertions in the scope of the Player.

@MainActor
public func safeVerifyPlayer(_ playerBlock: @escaping (Player?) -> Void) {
    PlayerWorld.sharedWorld.safeVerifyPlayer(playerBlock)
}

/// Creates a `Source` from the given `SourceConfig`.
@MainActor
public func createSource(sourceConfig: SourceConfig) -> Source {
    PlayerWorld.sharedWorld.createSource(sourceConfig: sourceConfig)
}

// There is a limitation in Swift where you can not use a top level function (despite having a different signature)
// from within a class that has a function with the same name in the instance or class level.
// Details can be found here: https://forums.swift.org/t/rationale-for-swifts-overload-resolution/10838/14
// As a workaround we have to rename the load and wait functions to not match `NSObject.load` and `XCTest.wait`
// functions.

/// Loads a `Source` into the Player and blocks the calling thread until the source is successfully
/// loaded or the timeout is reached.
@MainActor
public func loadSource(
    _ source: Source,
    preloadAllSources: Bool = false,
    replayMode: ReplayMode = .playlist,
    timeout: TimeInterval? = nil,
    file: StaticString = #file,
    line: UInt = #line
) async throws {
    try await PlayerWorld.sharedWorld.load(
        source,
        preloadAllSources: preloadAllSources,
        replayMode: replayMode,
        timeout: timeout,
        file: file,
        line: line
    )
}

/// Loads array of `Source` into the Player and blocks the calling thread until the source is successfully
/// loaded or the timeout is reached.
@MainActor
public func loadSources(
    _ sources: [Source],
    preloadAllSources: Bool = false,
    replayMode: ReplayMode = .playlist,
    timeout: TimeInterval? = nil,
    file: StaticString = #file,
    line: UInt = #line
) async throws {
    try await PlayerWorld.sharedWorld.load(
        sources,
        preloadAllSources: preloadAllSources,
        replayMode: replayMode,
        timeout: timeout,
        file: file,
        line: line
    )
}

/// Loads array of `Source` into the Player and blocks the calling thread until the source is successfully
/// loaded or the timeout is reached.
@MainActor
public func loadSources(
    _ sources: Source...,
    preloadAllSources: Bool = false,
    replayMode: ReplayMode = .playlist,
    timeout: TimeInterval? = nil,
    file: StaticString = #file,
    line: UInt = #line
) async throws {
    try await PlayerWorld.sharedWorld.load(
        sources,
        preloadAllSources: preloadAllSources,
        replayMode: replayMode,
        timeout: timeout,
        file: file,
        line: line
    )
}

/// Loads a `SourceConfig` into the Player and blocks the calling thread until the source is successfully
/// loaded or the timeout is reached.
@MainActor
public func loadSourceConfig(
    _ sourceConfig: SourceConfig,
    preloadAllSources: Bool = false,
    replayMode: ReplayMode = .playlist,
    timeout: TimeInterval? = nil,
    file: StaticString = #file,
    line: UInt = #line
) async throws {
    try await PlayerWorld.sharedWorld.load(
        sourceConfig,
        preloadAllSources: preloadAllSources,
        replayMode: replayMode,
        timeout: timeout,
        file: file,
        line: line
    )
}

/// Loads an array of `SourceConfig`s into the Player and blocks the calling thread until the source is successfully
/// loaded or the timeout is reached.
@MainActor
public func loadSourceConfigs(
    _ sourceConfigs: [SourceConfig],
    preloadAllSources: Bool = false,
    replayMode: ReplayMode = .playlist,
    timeout: TimeInterval? = nil,
    file: StaticString = #file,
    line: UInt = #line
) async throws {
    try await PlayerWorld.sharedWorld.load(
        sourceConfigs,
        preloadAllSources: preloadAllSources,
        replayMode: replayMode,
        timeout: timeout,
        file: file,
        line: line
    )
}

/// Loads an array of `SourceConfig`s into the Player and blocks the calling thread until the source is successfully
/// loaded or the timeout is reached.
@MainActor
public func loadSourceConfigs(
    _ sourceConfigs: SourceConfig...,
    preloadAllSources: Bool = false,
    replayMode: ReplayMode = .playlist,
    timeout: TimeInterval? = nil,
    file: StaticString = #file,
    line: UInt = #line
) async throws {
    try await PlayerWorld.sharedWorld.load(
        sourceConfigs,
        preloadAllSources: preloadAllSources,
        replayMode: replayMode,
        timeout: timeout,
        file: file,
        line: line
    )
}

/// Loads a `PlaylistConfig` into the Player and blocks the calling thread until the source is successfully
/// loaded or the timeout is reached.
@MainActor
public func loadPlaylistConfig(
    _ playlistConfig: PlaylistConfig,
    timeout: TimeInterval? = nil,
    file: StaticString = #file,
    line: UInt = #line
) async throws {
    try await PlayerWorld.sharedWorld.load(
        playlistConfig,
        timeout: timeout,
        file: file,
        line: line
    )
}

/// Waits until the Player has played back the specified amount of time or until the timeout is reached.
/// Blocks the calling thread for the duration.
@MainActor
public func play(
    for time: TimeInterval,
    timeout: TimeInterval? = nil,
    file: StaticString = #file,
    line: UInt = #line
) async throws {
    try await PlayerWorld.sharedWorld.play(for: time, timeout: timeout, file: file, line: line)
}

/// Waits until the Player has played back until the specified time or until the timeout is reached.
/// Blocks the calling thread for the duration.
@MainActor
public func play(
    until time: TimeInterval,
    timeout: TimeInterval? = nil,
    file: StaticString = #file,
    line: UInt = #line
) async throws {
    try await PlayerWorld.sharedWorld.play(until: time, timeout: timeout, file: file, line: line)
}

/// Waits for the specified amount of time by blocking the calling thread.
@MainActor
public func sleep(time: TimeInterval) async {
    await PlayerWorld.sharedWorld.wait(for: time)
}

/// Waits until the specified playerBlock returns true or until the timeout is reached.
/// Blocks the calling thread for the duration.
@MainActor
public func waitUntil(
    timeout: TimeInterval? = nil,
    file: StaticString = #file,
    line: UInt = #line,
    until playerBlock: @escaping (Player) -> Bool
) async {
    await PlayerWorld.sharedWorld.wait(timeout: timeout, file: file, line: line, until: playerBlock)
}

/// Sets the internal reference for the player instance to `nil`,
/// deallocating it when there are no external strong references
///
/// For verifying this, `safeVerifyPlayer` should be used,
/// calling any other method from PlayerTest APIs will cause a crash.
@MainActor
public func deallocPlayer() {
    PlayerWorld.sharedWorld.deallocPlayer()
}

/// This stubs all requests made via standard iOS network APIs (URLSession, URLConnection)
/// to return the standard "not connected to internet" error
@MainActor
public func stubNoInternet(_ testBlock: TestContinuationBlock) async throws {
    try await PlayerWorld.sharedWorld.stubNoInternet(testBlock)
}

/// Waits for the specified expectation and returns its matching events.
///
/// Starts listening before running `playerViewBlock` and keeps any matching events received while it runs.
/// Once the block returns, waits for any remaining events within the given timeout.
/// Always removes the listeners before returning or throwing.
@MainActor
@discardableResult
public func callPlayerViewAndExpectEvents(
    _ playerViewBlock: @escaping (PlayerView) -> Void,
    _ multipleEventsExpectation: MultipleEventsExpectation,
    timeout: TimeInterval? = nil,
    file: StaticString = #file,
    line: UInt = #line
) async throws -> [Event] {
    try await PlayerWorld.sharedWorld.callPlayerViewAndExpectEvents(
        playerViewBlock,
        multipleEventsExpectation,
        timeout: timeout,
        file: file,
        line: line
    )
}

/// Executes the passed block with the PlayerView as argument.
/// Use this function to call PlayerView API as part of the test.
@MainActor
public func callPlayerView(
    _ playerViewBlock: @escaping (PlayerView) -> Void,
    file: StaticString = #file,
    line: UInt = #line
) {
    PlayerWorld.sharedWorld.callPlayerView(
        playerViewBlock,
        file: file,
        line: line
    )
}

/// Executes the passed block with the PlayerView as argument.
/// Use this function to call PlayerView API as part of the test.
@MainActor
public func callPlayerView(
    _ playerViewBlock: @escaping (PlayerView) async throws -> Void,
    file: StaticString = #file,
    line: UInt = #line
) async throws {
    try await PlayerWorld.sharedWorld.callPlayerView(
        playerViewBlock,
        file: file,
        line: line
    )
}
