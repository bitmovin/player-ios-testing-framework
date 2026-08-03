import BitmovinPlayerCore
import Foundation

extension PlayerWorld {
    @discardableResult
    func expectEvent<T: PlayerEvent>(
        _ eventClass: T.Type,
        timeout: TimeInterval? = nil,
        file: StaticString = #file,
        line: UInt = #line
    ) async throws -> T {
        try await currentPlayerTest.expectEvent(
            eventClass,
            timeout: timeout,
            file: file,
            line: line
        )
    }

    @discardableResult
    func expectEvent<T: SourceEvent>(
        _ eventClass: T.Type,
        timeout: TimeInterval? = nil,
        file: StaticString = #file,
        line: UInt = #line
    ) async throws -> T {
        try await currentPlayerTest.expectEvent(
            eventClass,
            timeout: timeout,
            file: file,
            line: line
        )
    }

    @discardableResult
    func expectEvent<T: PlayerEvent>(
        _ eventExpectation: SingleEventExpectation<T>,
        timeout: TimeInterval? = nil,
        file: StaticString = #file,
        line: UInt = #line
    ) async throws -> T {
        try await currentPlayerTest.expectEvent(
            eventExpectation,
            timeout: timeout,
            file: file,
            line: line
        )
    }

    @discardableResult
    func expectEvent<T: SourceEvent>(
        _ eventExpectation: SingleEventExpectation<T>,
        timeout: TimeInterval? = nil,
        file: StaticString = #file,
        line: UInt = #line
    ) async throws -> T {
        try await currentPlayerTest.expectEvent(
            eventExpectation,
            timeout: timeout,
            file: file,
            line: line
        )
    }

    @discardableResult
    func expectEvents(
        _ eventClasses: [Event.Type],
        timeout: TimeInterval? = nil,
        file: StaticString = #file,
        line: UInt = #line
    ) async throws -> [Event] {
        try await currentPlayerTest.expectEvents(
            eventClasses,
            timeout: timeout,
            file: file,
            line: line
        )
    }

    @discardableResult
    func expectEvents(
        _ multipleEventExpectation: MultipleEventsExpectation,
        timeout: TimeInterval? = nil,
        file: StaticString = #file,
        line: UInt = #line
    ) async throws -> [Event] {
        try await currentPlayerTest.expectEvents(
            multipleEventExpectation,
            timeout: timeout,
            file: file,
            line: line
        )
    }

    func rejectEvent<T: PlayerEvent>(
        file: StaticString = #file,
        line: UInt = #line,
        _ eventClass: T.Type,
        _ testContinuationBlock: TestContinuationBlock
    ) async throws {
        try await currentPlayerTest.rejectEvent(file: file, line: line, eventClass, testContinuationBlock)
    }

    func rejectEvent<T: SourceEvent>(
        file: StaticString = #file,
        line: UInt = #line,
        _ eventClass: T.Type,
        _ testContinuationBlock: TestContinuationBlock
    ) async throws {
        try await currentPlayerTest.rejectEvent(file: file, line: line, eventClass, testContinuationBlock)
    }

    func rejectEvent<T: PlayerEvent>(
        file: StaticString = #file,
        line: UInt = #line,
        _ eventExpectation: SingleEventExpectation<T>,
        _ testContinuationBlock: TestContinuationBlock
    ) async throws {
        try await currentPlayerTest.rejectEvent(file: file, line: line, eventExpectation, testContinuationBlock)
    }

    func rejectEvent<T: SourceEvent>(
        file: StaticString = #file,
        line: UInt = #line,
        _ eventExpectation: SingleEventExpectation<T>,
        _ testContinuationBlock: TestContinuationBlock
    ) async throws {
        try await currentPlayerTest.rejectEvent(file: file, line: line, eventExpectation, testContinuationBlock)
    }

    func rejectEvents(
        file: StaticString = #file,
        line: UInt = #line,
        _ eventClasses: [Event.Type],
        _ testContinuationBlock: TestContinuationBlock
    ) async throws {
        try await currentPlayerTest.rejectEvents(file: file, line: line, eventClasses, testContinuationBlock)
    }

    func rejectEvents(
        file: StaticString = #file,
        line: UInt = #line,
        _ multipleEventExpectation: MultipleEventsExpectation,
        _ testContinuationBlock: TestContinuationBlock
    ) async throws {
        try await currentPlayerTest.rejectEvents(
            file: file,
            line: line,
            multipleEventExpectation,
            testContinuationBlock
        )
    }

    @discardableResult
    func callPlayerAndExpectEvent<T: Event>(
        _ playerBlock: @escaping AsyncCallPlayerBlock,
        _ eventClass: T.Type,
        timeout: TimeInterval? = nil,
        file: StaticString = #file,
        line: UInt = #line
    ) async throws -> T {
        try await currentPlayerTest.callPlayerAndExpectEvent(
            playerBlock,
            eventClass,
            timeout: timeout,
            file: file,
            line: line
        )
    }

    @discardableResult
    func callPlayerAndExpectEvent<T: Event>(
        _ playerBlock: @escaping AsyncCallPlayerBlock,
        _ eventExpectation: SingleEventExpectation<T>,
        timeout: TimeInterval? = nil,
        file: StaticString = #file,
        line: UInt = #line
    ) async throws -> T {
        try await currentPlayerTest.callPlayerAndExpectEvent(
            playerBlock,
            eventExpectation,
            timeout: timeout,
            file: file,
            line: line
        )
    }

    @discardableResult
    func callPlayerAndExpectEvents(
        _ playerBlock: @escaping AsyncCallPlayerBlock,
        _ eventClasses: [Event.Type],
        timeout: TimeInterval? = nil,
        file: StaticString = #file,
        line: UInt = #line
    ) async throws -> [Event] {
        try await currentPlayerTest.callPlayerAndExpectEvents(
            playerBlock,
            eventClasses,
            timeout: timeout,
            file: file,
            line: line
        )
    }

    @discardableResult
    func callPlayerAndExpectEvents(
        _ playerBlock: @escaping AsyncCallPlayerBlock,
        _ multipleEventsExpectation: MultipleEventsExpectation,
        timeout: TimeInterval? = nil,
        file: StaticString = #file,
        line: UInt = #line
    ) async throws -> [Event] {
        try await currentPlayerTest.callPlayerAndExpectEvents(
            playerBlock,
            multipleEventsExpectation,
            timeout: timeout,
            file: file,
            line: line
        )
    }

    func callPlayer(_ playerBlock: @escaping CallPlayerBlock) {
        currentPlayerTest.callPlayer(playerBlock)
    }

    func callPlayer(_ playerBlock: @escaping AsyncCallPlayerBlock) async throws {
        try await currentPlayerTest.callPlayer(playerBlock)
    }

    func verifyPlayer(_ playerBlock: @escaping CallPlayerBlock) {
        currentPlayerTest.verifyPlayer(playerBlock)
    }

    func safeVerifyPlayer(_ playerBlock: @escaping (Player?) -> Void) {
        currentPlayerTest.safeVerifyPlayer(playerBlock)
    }

    func createSource(sourceConfig: SourceConfig) -> Source {
        currentPlayerTest!.createSource(sourceConfig: sourceConfig)
    }

    func load(
        _ source: Source,
        preloadAllSources: Bool = false,
        replayMode: ReplayMode = .playlist,
        timeout: TimeInterval? = nil,
        file: StaticString = #file,
        line: UInt = #line
    ) async throws {
        try await currentPlayerTest.load(
            source,
            preloadAllSources: preloadAllSources,
            replayMode: replayMode,
            timeout: timeout,
            file: file,
            line: line
        )
    }

    func load(
        _ sources: [Source],
        preloadAllSources: Bool = false,
        replayMode: ReplayMode = .playlist,
        timeout: TimeInterval? = nil,
        file: StaticString = #file,
        line: UInt = #line
    ) async throws {
        try await currentPlayerTest.load(
            sources,
            preloadAllSources: preloadAllSources,
            replayMode: replayMode,
            timeout: timeout,
            file: file,
            line: line
        )
    }

    func load(
        _ sourceConfig: SourceConfig,
        preloadAllSources: Bool = false,
        replayMode: ReplayMode = .playlist,
        timeout: TimeInterval? = nil,
        file: StaticString = #file,
        line: UInt = #line
    ) async throws {
        try await currentPlayerTest.load(
            sourceConfig,
            preloadAllSources: preloadAllSources,
            replayMode: replayMode,
            timeout: timeout,
            file: file,
            line: line
        )
    }

    func load(
        _ sourceConfigs: [SourceConfig],
        preloadAllSources: Bool = false,
        replayMode: ReplayMode = .playlist,
        timeout: TimeInterval? = nil,
        file: StaticString = #file,
        line: UInt = #line
    ) async throws {
        try await currentPlayerTest.load(
            sourceConfigs,
            preloadAllSources: preloadAllSources,
            replayMode: replayMode,
            timeout: timeout,
            file: file,
            line: line
        )
    }

    func load(
        _ playlistConfig: PlaylistConfig,
        timeout: TimeInterval? = nil,
        file: StaticString = #file,
        line: UInt = #line
    ) async throws {
        try await currentPlayerTest.load(
            playlistConfig,
            timeout: timeout,
            file: file,
            line: line
        )
    }

    func play(
        for time: TimeInterval,
        timeout: TimeInterval? = nil,
        file: StaticString = #file,
        line: UInt = #line
    ) async throws {
        try await currentPlayerTest.play(for: time, timeout: timeout, file: file, line: line)
    }

    func play(
        until time: TimeInterval,
        timeout: TimeInterval? = nil,
        file: StaticString = #file,
        line: UInt = #line
    ) async throws {
        try await currentPlayerTest.play(until: time, timeout: timeout, file: file, line: line)
    }

    func wait(for time: TimeInterval) async {
        await currentPlayerTest.wait(for: time)
    }

    func wait(
        timeout: TimeInterval? = nil,
        file: StaticString = #file,
        line: UInt = #line,
        until playerBlock: @escaping (Player) -> Bool
    ) async {
        await currentPlayerTest.wait(timeout: timeout, file: file, line: line, until: playerBlock)
    }

    func deallocPlayer() {
        currentPlayerTest.deallocPlayer()
    }

    func callPlayerViewAndExpectEvents(
        _ playerViewBlock: @escaping (PlayerView) async throws -> Void,
        _ multipleEventsExpectation: MultipleEventsExpectation,
        timeout: TimeInterval? = nil,
        file: StaticString = #file,
        line: UInt = #line
    ) async throws -> [Event] {
        try await currentPlayerTest.callPlayerViewAndExpectEvents(
            playerViewBlock,
            multipleEventsExpectation,
            timeout: timeout,
            file: file,
            line: line
        )
    }

    func callPlayerView(
        _ playerViewBlock: @escaping (PlayerView) -> Void,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        currentPlayerTest.callPlayerView(
            playerViewBlock,
            file: file,
            line: line
        )
    }

    func callPlayerView(
        _ playerViewBlock: @escaping (PlayerView) async throws -> Void,
        file: StaticString = #file,
        line: UInt = #line
    ) async throws {
        try await currentPlayerTest.callPlayerView(
            playerViewBlock,
            file: file,
            line: line
        )
    }
}
