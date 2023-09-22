//
// Bitmovin Player iOS SDK
// Copyright (C) 2020, Bitmovin GmbH, All Rights Reserved
//
// This source code and its use and distribution, is subject to the terms
// and conditions of the applicable license agreement.
//

import BitmovinPlayerCore
import Foundation

// swiftlint:disable:this function_default_parameter_at_end
extension PlayerWorld {
    internal func expectEvent<T: PlayerEvent>(
        _ eventClass: T.Type,
        timeout: TimeInterval? = nil,
        file: StaticString = #file,
        line: UInt = #line,
        eventHandlerBlock: ((T) -> Void)? = nil
    ) {
        currentPlayerTest?.expectEvent(
            eventClass,
            timeout: timeout,
            file: file,
            line: line,
            eventHandlerBlock: eventHandlerBlock
        )
    }

    internal func expectEvent<T: SourceEvent>(
        _ eventClass: T.Type,
        timeout: TimeInterval? = nil,
        file: StaticString = #file,
        line: UInt = #line,
        eventHandlerBlock: ((T) -> Void)? = nil
    ) {
        currentPlayerTest?.expectEvent(
            eventClass,
            timeout: timeout,
            file: file,
            line: line,
            eventHandlerBlock: eventHandlerBlock
        )
    }

    internal func expectEvent<T: PlayerEvent>(
        _ eventExpectation: SingleEventExpectation<T>,
        timeout: TimeInterval? = nil,
        file: StaticString = #file,
        line: UInt = #line,
        eventHandlerBlock: ((T) -> Void)? = nil
    ) {
        currentPlayerTest?.expectEvent(
            eventExpectation,
            timeout: timeout,
            file: file,
            line: line,
            eventHandlerBlock: eventHandlerBlock
        )
    }

    internal func expectEvent<T: SourceEvent>(
        _ eventExpectation: SingleEventExpectation<T>,
        timeout: TimeInterval? = nil,
        file: StaticString = #file,
        line: UInt = #line,
        eventHandlerBlock: ((T) -> Void)? = nil
    ) {
        currentPlayerTest?.expectEvent(
            eventExpectation,
            timeout: timeout,
            file: file,
            line: line,
            eventHandlerBlock: eventHandlerBlock
        )
    }

    internal func expectEvents(
        _ eventClasses: [Event.Type],
        timeout: TimeInterval? = nil,
        file: StaticString = #file,
        line: UInt = #line,
        eventHandlerBlock: (([Event]) -> Void)? = nil
    ) {
        currentPlayerTest?.expectEvents(
            eventClasses,
            timeout: timeout,
            file: file,
            line: line,
            eventHandlerBlock: eventHandlerBlock
        )
    }

    internal func expectEvents(
        _ multipleEventExpectation: MultipleEventsExpectation,
        timeout: TimeInterval? = nil,
        file: StaticString = #file,
        line: UInt = #line,
        eventHandlerBlock: (([Event]) -> Void)? = nil
    ) {
        currentPlayerTest?.expectEvents(
            multipleEventExpectation,
            timeout: timeout,
            file: file,
            line: line,
            eventHandlerBlock: eventHandlerBlock
        )
    }

    internal func rejectEvent<T: PlayerEvent>(
        file: StaticString = #file,
        line: UInt = #line,
        _ eventClass: T.Type,
        _ testContinuationBlock: () -> Void
    ) {
        currentPlayerTest?.rejectEvent(file: file, line: line, eventClass, testContinuationBlock)
    }

    internal func rejectEvent<T: SourceEvent>(
        file: StaticString = #file,
        line: UInt = #line,
        _ eventClass: T.Type,
        _ testContinuationBlock: () -> Void
    ) {
        currentPlayerTest?.rejectEvent(file: file, line: line, eventClass, testContinuationBlock)
    }

    internal func rejectEvent<T: PlayerEvent>(
        file: StaticString = #file,
        line: UInt = #line,
        _ eventExpectation: SingleEventExpectation<T>,
        _ testContinuationBlock: () -> Void
    ) {
        currentPlayerTest?.rejectEvent(file: file, line: line, eventExpectation, testContinuationBlock)
    }

    internal func rejectEvent<T: SourceEvent>(
        file: StaticString = #file,
        line: UInt = #line,
        _ eventExpectation: SingleEventExpectation<T>,
        _ testContinuationBlock: () -> Void
    ) {
        currentPlayerTest?.rejectEvent(file: file, line: line, eventExpectation, testContinuationBlock)
    }

    internal func rejectEvents(
        file: StaticString = #file,
        line: UInt = #line,
        _ eventClasses: [Event.Type],
        _ testContinuationBlock: () -> Void
    ) {
        currentPlayerTest?.rejectEvents(file: file, line: line, eventClasses, testContinuationBlock)
    }

    internal func rejectEvents(
        file: StaticString = #file,
        line: UInt = #line,
        _ multipleEventExpectation: MultipleEventsExpectation,
        _ testContinuationBlock: () -> Void
    ) {
        currentPlayerTest?.rejectEvents(file: file, line: line, multipleEventExpectation, testContinuationBlock)
    }

    internal func callPlayerAndExpectEvent<T: Event>(
        _ playerBlock: @escaping (Player) -> Void,
        _ eventClass: T.Type,
        timeout: TimeInterval? = nil,
        file: StaticString = #file,
        line: UInt = #line,
        eventHandlerBlock: ((T) -> Void)? = nil
    ) {
        currentPlayerTest?.callPlayerAndExpectEvent(
            playerBlock,
            eventClass,
            timeout: timeout,
            file: file,
            line: line,
            eventHandlerBlock: eventHandlerBlock
        )
    }

    internal func callPlayerAndExpectEvent<T: Event>(
        _ playerBlock: @escaping (Player) -> Void,
        _ eventExpectation: SingleEventExpectation<T>,
        timeout: TimeInterval? = nil,
        file: StaticString = #file,
        line: UInt = #line,
        eventHandlerBlock: ((T) -> Void)? = nil
    ) {
        currentPlayerTest?.callPlayerAndExpectEvent(
            playerBlock,
            eventExpectation,
            timeout: timeout,
            file: file,
            line: line,
            eventHandlerBlock: eventHandlerBlock
        )
    }

    internal func callPlayerAndExpectEvents(
        _ playerBlock: @escaping (Player) -> Void,
        _ eventClasses: [Event.Type],
        timeout: TimeInterval? = nil,
        file: StaticString = #file,
        line: UInt = #line,
        eventHandlerBlock: (([Event]) -> Void)? = nil
    ) {
        currentPlayerTest?.callPlayerAndExpectEvents(
            playerBlock,
            eventClasses,
            timeout: timeout,
            file: file,
            line: line,
            eventHandlerBlock: eventHandlerBlock
        )
    }

    internal func callPlayerAndExpectEvents(
        _ playerBlock: @escaping (Player) -> Void,
        _ multipleEventsExpectation: MultipleEventsExpectation,
        timeout: TimeInterval? = nil,
        file: StaticString = #file,
        line: UInt = #line,
        eventHandlerBlock: (([Event]) -> Void)? = nil
    ) {
        currentPlayerTest?.callPlayerAndExpectEvents(
            playerBlock,
            multipleEventsExpectation,
            timeout: timeout,
            file: file,
            line: line,
            eventHandlerBlock: eventHandlerBlock
        )
    }

    internal func callPlayer(_ playerBlock: @escaping (Player) -> Void) {
        currentPlayerTest?.callPlayer(playerBlock)
    }

    internal func verifyPlayer(_ playerBlock: @escaping (Player) -> Void) {
        currentPlayerTest?.verifyPlayer(playerBlock)
    }

    internal func safeVerifyPlayer(_ playerBlock: @escaping (Player?) -> Void) {
        currentPlayerTest?.safeVerifyPlayer(playerBlock)
    }

    internal func createSource(sourceConfig: SourceConfig) -> Source {
        currentPlayerTest!.createSource(sourceConfig: sourceConfig)
    }

    internal func load(
        _ source: Source,
        preloadAllSources: Bool = false,
        replayMode: ReplayMode = .playlist,
        timeout: TimeInterval? = nil,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        currentPlayerTest?.load(
            source,
            preloadAllSources: preloadAllSources,
            replayMode: replayMode,
            timeout: timeout,
            file: file,
            line: line
        )
    }

    internal func load(
        _ sources: [Source],
        preloadAllSources: Bool = false,
        replayMode: ReplayMode = .playlist,
        timeout: TimeInterval? = nil,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        currentPlayerTest?.load(
            sources,
            preloadAllSources: preloadAllSources,
            replayMode: replayMode,
            timeout: timeout,
            file: file,
            line: line
        )
    }

    internal func load(
        _ sourceConfig: SourceConfig,
        preloadAllSources: Bool = false,
        replayMode: ReplayMode = .playlist,
        timeout: TimeInterval? = nil,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        currentPlayerTest?.load(
            sourceConfig,
            preloadAllSources: preloadAllSources,
            replayMode: replayMode,
            timeout: timeout,
            file: file,
            line: line
        )
    }

    internal func load(
        _ sourceConfigs: [SourceConfig],
        preloadAllSources: Bool = false,
        replayMode: ReplayMode = .playlist,
        timeout: TimeInterval? = nil,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        currentPlayerTest?.load(
            sourceConfigs,
            preloadAllSources: preloadAllSources,
            replayMode: replayMode,
            timeout: timeout,
            file: file,
            line: line
        )
    }

    internal func load(
        _ playlistConfig: PlaylistConfig,
        timeout: TimeInterval? = nil,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        currentPlayerTest?.load(
            playlistConfig,
            timeout: timeout,
            file: file,
            line: line
        )
    }

    internal func play(
        for time: TimeInterval,
        timeout: TimeInterval? = nil,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        currentPlayerTest?.play(for: time, timeout: timeout, file: file, line: line)
    }

    internal func play(
        until time: TimeInterval,
        timeout: TimeInterval? = nil,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        currentPlayerTest?.play(until: time, timeout: timeout, file: file, line: line)
    }

    internal func wait(for time: TimeInterval) {
        currentPlayerTest?.wait(for: time)
    }

    internal func wait(
        timeout: TimeInterval? = nil,
        file: StaticString = #file,
        line: UInt = #line,
        until playerBlock: @escaping (Player) -> Bool
    ) {
        currentPlayerTest?.wait(timeout: timeout, file: file, line: line, until: playerBlock)
    }

    internal func deallocPlayer() {
        currentPlayerTest?.deallocPlayer()
    }

    internal func callPlayerViewAndExpectEvents(
        _ playerViewBlock: @escaping (PlayerView) -> Void,
        _ multipleEventsExpectation: MultipleEventsExpectation,
        timeout: TimeInterval? = nil,
        file: StaticString = #file,
        line: UInt = #line,
        eventHandlerBlock: (([Event]) -> Void)? = nil
    ) {
        currentPlayerTest?.callPlayerViewAndExpectEvents(
            playerViewBlock,
            multipleEventsExpectation,
            timeout: timeout,
            file: file,
            line: line,
            eventHandlerBlock: eventHandlerBlock
        )
    }

    internal func callPlayerView(
        _ playerViewBlock: @escaping (PlayerView) -> Void,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        currentPlayerTest?.callPlayerView(
            playerViewBlock,
            file: file,
            line: line
        )
    }
}
