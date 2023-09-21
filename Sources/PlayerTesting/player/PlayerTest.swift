//
// Bitmovin Player iOS SDK
// Copyright (C) 2020, Bitmovin GmbH, All Rights Reserved
//
// This source code and its use and distribution, is subject to the terms
// and conditions of the applicable license agreement.
//

import BitmovinPlayerCore
import Foundation
import XCTest

public typealias PlayerTestBlock = () -> Void

public let defaultGlobalTimeout: TimeInterval = 30_000
internal let defaultTimeout = 10.0

internal final class PlayerTest {
    var appBundleMock: Bundle?
    var player: Player!
    var playerView: PlayerView?
    private var globalTimeoutQueueItem: DispatchWorkItem!
    private var heartbeatWindowQueueItem: DispatchWorkItem?
    private var heartbeatWindowEventListenerProxy: EventListenerProxy?
    private var activeConditions: [Condition] = []

    func tearDown() {
        cleanupTestData()
    }

    func fail(
        with message: String,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        activeConditions.forEach { $0.cancel() }
        XCTFail(message, file: file, line: line)
        activeConditions.removeAll()
    }
}

// swiftlint:disable:this function_default_parameter_at_end
extension PlayerTest: PlayerTestLifecycleApi {
    func startPlayerTest(
        config: PlayerConfig = PlayerConfig(),
        buildViewHierarchyMode: ViewHierarchyBuildMode,
        globalTimeout: TimeInterval = defaultGlobalTimeout,
        heartbeatWindow: TimeInterval? = nil,
        failOnError failOnErrorEnabled: Bool = true,
        setLicenseKeyForTesting: Bool = true,
        file: StaticString = #file,
        line: UInt = #line,
        _ testBlock: PlayerTestBlock
    ) {
        if setLicenseKeyForTesting, config.key == nil {
            // Override the LicenseKey for testing
            config.key = playerLicenseKeyForTesting
        }

        player = PlayerFactory.create(playerConfig: config)
        playerView = buildPlayerView(mode: buildViewHierarchyMode)

        addGlobalTimeoutQueueItem(
            globalTimeout: globalTimeout,
            file: file,
            line: line
        )
        maybeAddHeartbeatWindowQueueItem(
            heartbeatWindow: heartbeatWindow,
            file: file,
            line: line
        )

        if failOnErrorEnabled {
            failOnErrorEvent(file: file, line: line, testBlock)
        } else {
            testBlock()
        }

        globalTimeoutQueueItem?.cancel()
        heartbeatWindowQueueItem?.cancel()
        if let heartbeatWindowEventListenerProxy {
            player.remove(listener: heartbeatWindowEventListenerProxy)
        }
        heartbeatWindowEventListenerProxy = nil
    }

    private func buildPlayerView(mode: ViewHierarchyBuildMode) -> PlayerView? {
        switch mode {
        case .viewOnly(let playerViewConfig):
            return PlayerView(
                player: player,
                frame: .zero,
                playerViewConfig: playerViewConfig
            )
        case .full(let playerViewConfig):
            let viewController = buildViewController()
            let playerView = PlayerView(
                player: player,
                frame: .zero,
                playerViewConfig: playerViewConfig
            )

            playerView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            viewController.view = playerView
            return playerView
        case .none:
            return nil
        }
    }

    private func addGlobalTimeoutQueueItem(
        globalTimeout: TimeInterval,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        globalTimeoutQueueItem = DispatchWorkItem { [weak self] in
            guard let globalTimeoutQueueItem = self?.globalTimeoutQueueItem,
                  !globalTimeoutQueueItem.isCancelled else {
                return
            }
            self?.fail(with: "Exceeds the global timeout \(globalTimeout)", file: file, line: line)
        }
        DispatchQueue.main.asyncAfter(
            deadline: .now() + globalTimeout,
            execute: globalTimeoutQueueItem
        )
    }

    private func maybeAddHeartbeatWindowQueueItem(
        heartbeatWindow: TimeInterval?,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        guard let heartbeatWindow else {
            return
        }

        let handleHeartbeat = { [weak self] in
            guard let self else { return }
            self.heartbeatWindowQueueItem?.cancel()
            self.heartbeatWindowQueueItem = nil

            self.heartbeatWindowQueueItem = DispatchWorkItem { [weak self] in
                guard let heartbeatWindowQueueItem = self?.heartbeatWindowQueueItem,
                      !heartbeatWindowQueueItem.isCancelled else {
                    return
                }
                self?.fail(
                    with: "Events exception within Heartbeat window \(heartbeatWindow) was not met",
                    file: file,
                    line: line
                )
            }

            DispatchQueue.main.asyncAfter(
                deadline: .now() + heartbeatWindow,
                execute: self.heartbeatWindowQueueItem!
            )
        }

        let heartbeatWindowEventListenerProxy = EventListenerProxy()
        self.heartbeatWindowEventListenerProxy = heartbeatWindowEventListenerProxy

        heartbeatWindowEventListenerProxy.setHeartbeatCallback {
            handleHeartbeat()
        }

        self.player.add(listener: heartbeatWindowEventListenerProxy)

        handleHeartbeat()
    }

    private func buildViewController() -> UIViewController {
        let viewController = UIViewController()

        let window = UIWindow()
        window.rootViewController = viewController
        window.isHidden = false

        return viewController
    }
}

// MARK: - Single event handling
extension PlayerTest: PlayerTestSingleEventExpectationApi {
    internal func expectEvent<T: Event>(
        _ eventExpectation: SingleEventExpectation<T>,
        timeout: TimeInterval? = nil,
        file: StaticString = #file,
        line: UInt = #line,
        eventHandlerBlock: ((T) -> Void)? = nil
    ) {
        expectEventBlocking(
            singleEventExpectation: eventExpectation,
            timeout: timeout ?? defaultTimeout,
            file: file,
            line: line,
            eventHandlerBlock: eventHandlerBlock
        )
    }

    internal func expectEvent<T: Event>(
        _ eventClass: T.Type,
        timeout: TimeInterval? = nil,
        file: StaticString = #file,
        line: UInt = #line,
        eventHandlerBlock: ((T) -> Void)? = nil
    ) {
        expectEvent(
            PlainEventExpectation(eventClass),
            timeout: timeout ?? defaultTimeout,
            file: file,
            line: line,
            eventHandlerBlock: eventHandlerBlock
        )
    }

    private func expectEventBlocking<T: Event>(
        singleEventExpectation: SingleEventExpectation<T>,
        timeout: TimeInterval,
        file: StaticString = #file,
        line: UInt = #line,
        eventHandlerBlock: ((T) -> Void)? = nil,
        onListenerAttachedBlock: (() -> Void)? = nil
    ) {
        let eventListenerProxy = EventListenerProxy()
        player.add(listener: eventListenerProxy)

        let condition = Condition(description: "\(singleExpectation: singleEventExpectation)")

        let eventExpectationBlock: (EventHolder<Event>) -> Void = { eventHolder in
            if singleEventExpectation.maybeFulfillExpectation(
                receivedEvent: eventHolder
            ) {
                eventHandlerBlock?(eventHolder.event as! T)
                condition.fulfill()
            }
            condition.description = eventHolder.event.eventDescription
        }

        let sourceEventListenerProxy = SourceEventListenerProxy()
        if let source = (singleEventExpectation as? SingleSourceEventExpectation)?.source {
            source.add(listener: sourceEventListenerProxy)
            try? sourceEventListenerProxy
                .registerEvent(singleEventExpectation.eventClass) { (event: SourceEvent, source: Source) in
                    eventExpectationBlock(EventHolder(source: source, event: event))
                }
        } else {
            try? eventListenerProxy.registerEvent(singleEventExpectation.eventClass) { event in
                eventExpectationBlock(EventHolder(event: event))
            }
        }

        onListenerAttachedBlock?()

        activeConditions.append(condition)
        condition.wait(timeout: timeout)
        activeConditions.removeAll { $0 === condition }

        if let source = (singleEventExpectation as? SingleSourceEventExpectation)?.source {
            sourceEventListenerProxy.unregisterEvent(singleEventExpectation.eventClass)
            source.remove(listener: sourceEventListenerProxy)
        } else {
            eventListenerProxy.unregisterEvent(singleEventExpectation.eventClass)
        }

        eventListenerProxy.unregisterEvent(singleEventExpectation.eventClass)
        player?.remove(listener: eventListenerProxy)

        if !condition.isFulfilled {
            XCTFail("Expectation was not met: \(condition.description)", file: file, line: line)
        }
    }
}

// MARK: - Multiple events handling
extension PlayerTest: PlayerTestMultipleEventsExpectationApi {
    internal func expectEvents(
        _ eventClasses: [Event.Type],
        timeout: TimeInterval? = nil,
        file: StaticString = #file,
        line: UInt = #line,
        eventHandlerBlock: (([Event]) -> Void)? = nil
    ) {
        expectEvents(
            EventSequenceExpectation(eventClasses),
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
        expectEventsBlocking(
            multipleEventsExpectation: multipleEventExpectation,
            timeout: timeout ?? defaultTimeout,
            file: file,
            line: line,
            eventHandlerBlock: eventHandlerBlock
        )
    }

    // This methods handles Player and Source event expectations
    private func expectEventsBlocking(
        multipleEventsExpectation: MultipleEventsExpectation,
        timeout: TimeInterval,
        file: StaticString = #file,
        line: UInt = #line,
        eventHandlerBlock: (([Event]) -> Void)? = nil,
        onListenerAttachedBlock: (() -> Void)? = nil
    ) {
        let eventListenerProxy = EventListenerProxy()
        player.add(listener: eventListenerProxy)

        var recordedEvents: [Event] = []
        let condition = Condition(description: "\(multipleExpectation: multipleEventsExpectation)")
        condition.expectedFulfillmentCount = multipleEventsExpectation.expectedFulfillmentCount

        let eventExpectationBlock: (EventHolder<Event>) -> Void = { eventHolder in
            if multipleEventsExpectation.isNextExpectationMet(
                receivedEvent: eventHolder
            ) {
                recordedEvents.append(eventHolder.event)
                condition.fulfill()
            }
            condition.description = "\(multipleExpectation: multipleEventsExpectation)"
        }

        let sourceEventListenerProxy = SourceEventListenerProxy()
        multipleEventsExpectation.singleExpectations.forEach { singleEventExpectation in
            if let source = (singleEventExpectation as? SingleSourceEventExpectation)?.source {
                source.add(listener: sourceEventListenerProxy)
                try? sourceEventListenerProxy
                    .registerEvent(singleEventExpectation.eventClass) { (event: SourceEvent, source: Source) in
                        eventExpectationBlock(EventHolder(source: source, event: event))
                    }
            } else {
                try? eventListenerProxy.registerEvent(singleEventExpectation.eventClass) { event in
                    eventExpectationBlock(EventHolder(event: event))
                }
            }
        }

        onListenerAttachedBlock?()

        activeConditions.append(condition)
        condition.wait(timeout: timeout)
        activeConditions.removeAll { $0 === condition }

        multipleEventsExpectation.singleExpectations.forEach { singleEventExpectation in
            if let source = (singleEventExpectation as? SingleSourceEventExpectation)?.source {
                sourceEventListenerProxy.unregisterEvent(singleEventExpectation.eventClass)
                source.remove(listener: sourceEventListenerProxy)
            } else {
                eventListenerProxy.unregisterEvent(singleEventExpectation.eventClass)
            }
        }

        player?.remove(listener: eventListenerProxy)

        if condition.isFulfilled {
            eventHandlerBlock?(recordedEvents)
        } else {
            XCTFail("Expectation was not met: \(condition.description)", file: file, line: line)
        }
    }
}

// MARK: - Reject event handling
extension PlayerTest: PlayerTestRejectEventApi {
    internal func rejectEvent<T: Event>(
        file: StaticString = #file,
        line: UInt = #line,
        _ eventClass: T.Type,
        _ testContinuationBlock: () -> Void
    ) {
        rejectEventBlocking(
            file: file,
            line: line,
            singleEventExpectation: PlainEventExpectation<T>(eventClass),
            testContinuationBlock: testContinuationBlock
        )
    }

    internal func rejectEvent<T: Event>(
        file: StaticString = #file,
        line: UInt = #line,
        _ eventExpectation: SingleEventExpectation<T>,
        _ testContinuationBlock: () -> Void
    ) {
        rejectEventBlocking(
            file: file,
            line: line,
            singleEventExpectation: eventExpectation,
            testContinuationBlock: testContinuationBlock
        )
    }

    private func rejectEventBlocking<T: Event>(
        file: StaticString,
        line: UInt,
        errorMessageFactory: @escaping SingleErrorMessageFactory = defaultSingleErrorMessageFactory,
        singleEventExpectation: SingleEventExpectation<T>,
        testContinuationBlock: () -> Void
    ) {
        let eventListenerProxy = EventListenerProxy()
        player.add(listener: eventListenerProxy)

        let eventClass = singleEventExpectation.eventClass
        let expectation = PlayerTestExpectation()

        try? eventListenerProxy.registerEvent(eventClass) { (event: T) in
            if singleEventExpectation.maybeFulfillExpectation(
                receivedEvent: EventHolder(event: event)
            ) {
                expectation.reject(
                    errorMessageFactory(event),
                    file: file,
                    line: line
                )
            }
        }

        testContinuationBlock()

        eventListenerProxy.unregisterEvent(eventClass)
        player?.remove(listener: eventListenerProxy)
    }
}

// MARK: - Reject events handling
extension PlayerTest: PlayerTestRejectEventsApi {
    internal func rejectEvents(
        file: StaticString = #file,
        line: UInt = #line,
        _ eventClasses: [Event.Type],
        _ testContinuationBlock: () -> Void
    ) {
        rejectEvents(
            file: file,
            line: line,
            EventSequenceExpectation(eventClasses),
            testContinuationBlock
        )
    }

    internal func rejectEvents(
        file: StaticString = #file,
        line: UInt = #line,
        _ multipleEventExpectation: MultipleEventsExpectation,
        _ testContinuationBlock: () -> Void
    ) {
        rejectEventsBlocking(
            file: file,
            line: line,
            multipleEventsExpectation: multipleEventExpectation,
            testContinuationBlock: testContinuationBlock
        )
    }

    private func rejectEventsBlocking(
        file: StaticString,
        line: UInt,
        errorMessageFactory: @escaping MultipleErrorMessageFactory = defaultMultipleErrorMessageFactory,
        multipleEventsExpectation: MultipleEventsExpectation,
        testContinuationBlock: () -> Void
    ) {
        let eventListenerProxy = EventListenerProxy()
        player.add(listener: eventListenerProxy)

        let expectation = PlayerTestExpectation()
        expectation.assertAtRejectCount = multipleEventsExpectation.singleExpectations.count

        multipleEventsExpectation.singleExpectations.forEach { singleEventExpectation in
            try? eventListenerProxy.registerEvent(singleEventExpectation.eventClass) { (event: Event) in
                if multipleEventsExpectation.isNextExpectationMet(
                    receivedEvent: EventHolder(event: event)
                ) {
                    expectation.reject(
                        errorMessageFactory(event, multipleEventsExpectation),
                        file: file,
                        line: line
                    )
                }
            }
        }

        testContinuationBlock()

        multipleEventsExpectation.singleExpectations.forEach { singleEventExpectation in
            eventListenerProxy.unregisterEvent(singleEventExpectation.eventClass)
        }
        player?.remove(listener: eventListenerProxy)
    }
}

// MARK: - Call player handling
extension PlayerTest: PlayerTestCallPlayerAndExpectApi {
    internal func callPlayerAndExpectEvent<T: Event>(
        _ playerBlock: @escaping (Player) -> Void,
        _ eventExpectation: SingleEventExpectation<T>,
        timeout: TimeInterval? = nil,
        file: StaticString = #file,
        line: UInt = #line,
        eventHandlerBlock: ((T) -> Void)? = nil
    ) {
        expectEventBlocking(
            singleEventExpectation: eventExpectation,
            timeout: timeout ?? defaultTimeout,
            file: file,
            line: line,
            eventHandlerBlock: eventHandlerBlock
        ) {
            self.callPlayer(playerBlock)
        }
    }

    internal func callPlayerAndExpectEvent<T: Event>(
        _ playerBlock: @escaping (Player) -> Void,
        _ eventClass: T.Type,
        timeout: TimeInterval? = nil,
        file: StaticString = #file,
        line: UInt = #line,
        eventHandlerBlock: ((T) -> Void)? = nil
    ) {
        callPlayerAndExpectEvent(
            playerBlock,
            PlainEventExpectation(eventClass),
            timeout: timeout,
            file: file,
            line: line
        ) { event in
            eventHandlerBlock?(event)
        }
    }

    internal func callPlayerAndExpectEvents(
        _ playerBlock: @escaping (Player) -> Void,
        _ eventClasses: [Event.Type],
        timeout: TimeInterval? = nil,
        file: StaticString = #file,
        line: UInt = #line,
        eventHandlerBlock: (([Event]) -> Void)? = nil
    ) {
        callPlayerAndExpectEvents(
            playerBlock,
            EventSequenceExpectation(eventClasses),
            timeout: timeout ?? defaultTimeout,
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
        expectEventsBlocking(
            multipleEventsExpectation: multipleEventsExpectation,
            timeout: timeout ?? defaultTimeout,
            file: file,
            line: line,
            eventHandlerBlock: eventHandlerBlock
        ) {
            self.callPlayer(playerBlock)
        }
    }
}

extension PlayerTest: PlayerTestCallPlayerApi {
    internal func callPlayer(_ playerBlock: @escaping (Player) -> Void) {
        playerBlock(player)
    }

    internal func verifyPlayer(_ playerBlock: @escaping (Player) -> Void) {
        playerBlock(player)
    }

    internal func safeVerifyPlayer(_ playerBlock: @escaping (Player?) -> Void) {
        playerBlock(player)
    }
}

// MARK: - Convenience helpers
extension PlayerTest: PlayerTestConvenienceApi {
    internal func createSource(sourceConfig: SourceConfig) -> Source {
        SourceFactory.create(from: sourceConfig)
    }

    internal func load(
        _ source: Source,
        preloadAllSources: Bool = false,
        replayMode: ReplayMode = .playlist,
        timeout: TimeInterval? = nil,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        load(
            [source],
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
        let options = PlaylistOptions(
            preloadAllSources: preloadAllSources,
            replayMode: replayMode
        )
        load(
            PlaylistConfig(sources: sources, options: options),
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
        load(
            [sourceConfig],
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
        load(
            sourceConfigs.map { createSource(sourceConfig: $0) },
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
        // swiftlint:disable:next multiline_arguments_brackets
        callPlayerAndExpectEvent({ player in
                player.load(playlistConfig: playlistConfig)
            },
            ReadyEvent.self,
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
        play(
            until: self.player.currentTime + time,
            timeout: timeout,
            file: file,
            line: line
        )
    }

    internal func play(
        until time: TimeInterval,
        timeout: TimeInterval? = nil,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        expectEventBlocking(
            singleEventExpectation: FilteredEventExpectation(TimeChangedEvent.self) { timeChangedEvent -> Bool in
                timeChangedEvent.currentTime >= time
            },
            timeout: timeout ?? defaultTimeout,
            file: file,
            line: line,
            eventHandlerBlock: nil
        ) {
            self.callPlayer { player in
                player.play()
            }
        }
    }

    internal func wait(for time: TimeInterval) {
        let condition = Condition(description: "wait for")

        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .milliseconds(Int(time * 1_000))) {
            condition.fulfill()
        }

        activeConditions.append(condition)
        condition.wait(timeout: time)
        activeConditions.removeAll { $0 === condition }
    }

    internal func wait(
        timeout: TimeInterval? = nil,
        file: StaticString = #file,
        line: UInt = #line,
        until playerBlock: @escaping (Player) -> Bool
    ) {
        let condition = Condition(description: "wait until")

        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { timer in
            if playerBlock(self.player) {
                timer.invalidate()
                condition.fulfill()
            }
        }
        .fire()

        activeConditions.append(condition)
        condition.wait(timeout: timeout ?? defaultTimeout)
        activeConditions.removeAll { $0 === condition }

        if !condition.isFulfilled {
            XCTFail("Expectation was not met: \(condition.description)", file: file, line: line)
        }
    }

    internal func deallocPlayer() {
        player = nil
    }
}

// MARK: - PlayerView Testing
extension PlayerTest: PlayerViewTest {
    func callPlayerViewAndExpectEvents(
        _ playerViewBlock: @escaping (PlayerView) -> Void,
        _ multipleEventsExpectation: MultipleEventsExpectation,
        timeout: TimeInterval? = nil,
        file: StaticString = #file,
        line: UInt = #line,
        eventHandlerBlock: (([Event]) -> Void)? = nil
    ) {
        expectPlayerViewEventsBlocking(
            multipleEventsExpectation: multipleEventsExpectation,
            timeout: timeout ?? defaultTimeout,
            file: file,
            line: line,
            eventHandlerBlock: eventHandlerBlock
        ) {
            self.callPlayerView(playerViewBlock)
        }
    }

    internal func callPlayerView(
        _ playerViewBlock: @escaping (PlayerView) -> Void,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        guard let playerView else {
            XCTFail("No `PlayerView` was created for this test case!", file: file, line: line)
            return
        }

        playerViewBlock(playerView)
    }

    private func expectPlayerViewEventsBlocking(
        multipleEventsExpectation: MultipleEventsExpectation,
        timeout: TimeInterval,
        file: StaticString = #file,
        line: UInt = #line,
        eventHandlerBlock: (([Event]) -> Void)? = nil,
        onListenerAttachedBlock: (() -> Void)? = nil
    ) {
        guard let playerView else {
            XCTFail("No `PlayerView` was created for this test case!", file: file, line: line)
            return
        }

        let eventListenerProxy = PlayerViewEventListenerProxy()
        playerView.add(listener: eventListenerProxy)

        var recordedEvents: [Event] = []
        let condition = Condition(description: "\(multipleExpectation: multipleEventsExpectation)")
        condition.expectedFulfillmentCount = multipleEventsExpectation.expectedFulfillmentCount

        let eventExpectationBlock: (EventHolder<Event>) -> Void = { eventHolder in
            if multipleEventsExpectation.isNextExpectationMet(
                receivedEvent: eventHolder
            ) {
                recordedEvents.append(eventHolder.event)
                condition.fulfill()
            }
            condition.description = "\(multipleExpectation: multipleEventsExpectation)"
        }

        multipleEventsExpectation.singleExpectations.forEach { singleEventExpectation in
            try? eventListenerProxy.registerEvent(singleEventExpectation.eventClass) { event in
                eventExpectationBlock(EventHolder(event: event))
            }
        }

        onListenerAttachedBlock?()

        activeConditions.append(condition)
        condition.wait(timeout: timeout)
        activeConditions.removeAll { $0 === condition }

        multipleEventsExpectation.singleExpectations.forEach { singleEventExpectation in
            eventListenerProxy.unregisterEvent(singleEventExpectation.eventClass)
        }

        playerView.remove(listener: eventListenerProxy)

        if condition.isFulfilled {
            eventHandlerBlock?(recordedEvents)
        } else {
            XCTFail("Expectation was not met: \(condition.description)", file: file, line: line)
        }
    }
}

// MARK: - Error Handling

extension PlayerTest {
    private func failOnErrorEvent(
        file: StaticString = #file,
        line: UInt = #line,
        _ testBlock: PlayerTestBlock
    ) {
        rejectEventsBlocking(
            file: file,
            line: line,
            errorMessageFactory: { event, _ in
                "Error event was received: \(event.eventDescription)"
            },
            multipleEventsExpectation: A(PlayerErrorEvent.self, SourceErrorEvent.self),
            testContinuationBlock: testBlock
        )
    }
}

// MARK: - Clean-up
private extension PlayerTest {
    private func cleanupTestData() {
        // This can happen from tests which are not using the PlayerTest features but extending it
        if player != nil {
            if let heartbeatWindowEventListenerProxy {
                player.remove(listener: heartbeatWindowEventListenerProxy)
            }
            player.destroy()
        }
        player = nil
        playerView = nil
        heartbeatWindowEventListenerProxy = nil
        globalTimeoutQueueItem?.cancel()
        globalTimeoutQueueItem = nil
        heartbeatWindowQueueItem?.cancel()
        heartbeatWindowQueueItem = nil
    }
}

private typealias SingleErrorMessageFactory = (_ event: Event) -> String

private let defaultSingleErrorMessageFactory: SingleErrorMessageFactory = {
    "Received rejected event: '\($0.eventDescription)'"
}

private typealias MultipleErrorMessageFactory = (
    _ event: Event,
    _ expectations: MultipleEventsExpectation
) -> String

private let defaultMultipleErrorMessageFactory: MultipleErrorMessageFactory = { _, expectations in
    "Received rejected event: '\(multipleExpectation: expectations)'"
}
