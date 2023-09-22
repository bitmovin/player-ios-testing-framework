//
// Bitmovin Player iOS SDK
// Copyright (C) 2020, Bitmovin GmbH, All Rights Reserved
//
// This source code and its use and distribution, is subject to the terms
// and conditions of the applicable license agreement.
//

import BitmovinPlayer
import Foundation
import Nimble
import Quick

open class QuickPlayerTest: QuickSpec {
    private var playerTest: PlayerTest?

    override open func setUp() {
        super.setUp()
        continueAfterFailure = false
    }
}

// swiftlint:disable:this function_default_parameter_at_end
extension QuickPlayerTest: PlayerTestApi {
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
