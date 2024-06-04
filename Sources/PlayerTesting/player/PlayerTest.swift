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

public typealias PlayerTestBlock = @MainActor () async throws -> Void
public typealias TestContinuationBlock = @MainActor () async throws -> Void
public typealias CallPlayerBlock = (Player) -> Void
public typealias AsyncCallPlayerBlock = @MainActor (Player) async throws -> Void
internal typealias OnListenerAttachedBlock = @MainActor () async throws -> Void

public let defaultGlobalTimeout: TimeInterval = 30_000
internal let defaultTimeout = 10.0

public enum PlayerTestingError: Error {
    case expectationNotMet
}

@MainActor
internal final class PlayerTest {
    var appBundleMock: Bundle?
    var player: Player!
    var playerView: PlayerView?
    private var globalTimeoutQueueItem: DispatchWorkItem!
    private var heartbeatWindowQueueItem: DispatchWorkItem?
    private var heartbeatWindowEventListenerProxy: EventListenerProxy?
    private var activeConditions: [Condition] = []
    private var viewController: UIViewController?
    private var window: UIWindow?

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
        playerCreator: (_ config: PlayerConfig) -> Player = PlayerCoreFactory.createPlayer(playerConfig:),
        file: StaticString = #file,
        line: UInt = #line,
        _ testBlock: PlayerTestBlock
    ) async throws {
        if setLicenseKeyForTesting, config.key == nil {
            // Override the LicenseKey for testing
            config.key = PlayerTestingConfig.playerLicenseKeyForTesting
        }

        player = playerCreator(config)
        (playerView, viewController, window) = buildPlayerView(mode: buildViewHierarchyMode)

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
            try await failOnErrorEvent(file: file, line: line, testBlock)
        } else {
            try await testBlock()
        }

        globalTimeoutQueueItem?.cancel()
        heartbeatWindowQueueItem?.cancel()
        if let heartbeatWindowEventListenerProxy {
            player.remove(listener: heartbeatWindowEventListenerProxy)
        }
        heartbeatWindowEventListenerProxy = nil
    }

    private func buildPlayerView(mode: ViewHierarchyBuildMode) -> (
        playerView: PlayerView?,
        viewController: UIViewController?,
        window: UIWindow?
    ) {
        switch mode {
        case .viewOnly(let playerViewConfig):
            return (
                PlayerView(
                    player: player,
                    frame: .zero,
                    playerViewConfig: playerViewConfig
                ),
                nil,
                nil
            )
        case .full(let playerViewConfig):
            let (viewController, window) = buildViewController()
            let playerView = PlayerView(
                player: player,
                frame: .zero,
                playerViewConfig: playerViewConfig
            )

            playerView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            viewController.view = playerView
            return (playerView, viewController, window)
        case .none:
            return (nil, nil, nil)
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
        heartbeatWindowEventListenerProxy.onEventCallback = { event in
            log(.info("Received heartbeat event: '\(event.name)'"))
        }
        self.heartbeatWindowEventListenerProxy = heartbeatWindowEventListenerProxy

        heartbeatWindowEventListenerProxy.setHeartbeatCallback {
            handleHeartbeat()
        }

        self.player.add(listener: heartbeatWindowEventListenerProxy)

        handleHeartbeat()
    }

    private func buildViewController() -> (viewController: UIViewController, window: UIWindow) {
        let viewController = UIViewController()

        let window = UIWindow()
        window.rootViewController = viewController
        window.isHidden = false

        return (viewController, window)
    }
}

// MARK: - Single event handling
extension PlayerTest: PlayerTestSingleEventExpectationApi {
    internal func expectEvent<T: Event>(
        _ eventExpectation: SingleEventExpectation<T>,
        timeout: TimeInterval? = nil,
        file: StaticString = #file,
        line: UInt = #line
    ) async throws -> T {
        try await expectEventBlocking(
            singleEventExpectation: eventExpectation,
            timeout: timeout ?? defaultTimeout,
            file: file,
            line: line
        )
    }

    internal func expectEvent<T: Event>(
        _ eventClass: T.Type,
        timeout: TimeInterval? = nil,
        file: StaticString = #file,
        line: UInt = #line
    ) async throws -> T {
        try await expectEvent(
            PlainEventExpectation(eventClass),
            timeout: timeout ?? defaultTimeout,
            file: file,
            line: line
        )
    }

    @discardableResult
    private func expectEventBlocking<T: Event>(
        singleEventExpectation: SingleEventExpectation<T>,
        timeout: TimeInterval,
        file: StaticString = #file,
        line: UInt = #line,
        onListenerAttachedBlock: OnListenerAttachedBlock? = nil
    ) async throws -> T {
        let events = try await expectEventsBlocking(
            multipleEventsExpectation: EventSequenceExpectation([singleEventExpectation]),
            timeout: timeout,
            file: file,
            line: line,
            onListenerAttachedBlock: onListenerAttachedBlock
        )

        guard let event = events.first as? T else {
            throw PlayerTestingError.expectationNotMet
        }

        return event
    }
}

// MARK: - Multiple events handling
extension PlayerTest: PlayerTestMultipleEventsExpectationApi {
    internal func expectEvents(
        _ eventClasses: [Event.Type],
        timeout: TimeInterval? = nil,
        file: StaticString = #file,
        line: UInt = #line
    ) async throws -> [Event] {
        try await expectEvents(
            EventSequenceExpectation(eventClasses),
            timeout: timeout,
            file: file,
            line: line
        )
    }

    internal func expectEvents(
        _ multipleEventExpectation: MultipleEventsExpectation,
        timeout: TimeInterval? = nil,
        file: StaticString = #file,
        line: UInt = #line
    ) async throws -> [Event] {
        try await expectEventsBlocking(
            multipleEventsExpectation: multipleEventExpectation,
            timeout: timeout ?? defaultTimeout,
            file: file,
            line: line
        )
    }

    // This methods handles Player and Source event expectations
    private func expectEventsBlocking(
        multipleEventsExpectation: MultipleEventsExpectation,
        timeout: TimeInterval,
        file: StaticString = #file,
        line: UInt = #line,
        onListenerAttachedBlock: OnListenerAttachedBlock? = nil
    ) async throws -> [Event] {
        let eventListenerProxy = EventListenerProxy()
        eventListenerProxy.onEventCallback = { event in
            log(.info("Received `Event` inside `expectEvent`: '\(event.name)'"))
        }

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
        sourceEventListenerProxy.onEventCallback = { event in
            log(.info("Received `SourceEvent` inside `expectEvent`: '\(event.name)'"))
        }
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

        try await onListenerAttachedBlock?()

        activeConditions.append(condition)
        await condition.wait(timeout: timeout)
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

        guard condition.isFulfilled else {
            XCTFail("Expectation was not met: \(condition.description)", file: file, line: line)
            throw PlayerTestingError.expectationNotMet
        }

        return recordedEvents
    }
}

// MARK: - Reject event handling
extension PlayerTest: PlayerTestRejectEventApi {
    internal func rejectEvent<T: Event>(
        file: StaticString = #file,
        line: UInt = #line,
        _ eventClass: T.Type,
        _ testContinuationBlock: TestContinuationBlock
    ) async throws {
        try await rejectEventBlocking(
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
        _ testContinuationBlock: TestContinuationBlock
    ) async throws {
        try await rejectEventBlocking(
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
        testContinuationBlock: TestContinuationBlock
    ) async throws {
        try await rejectEventsBlocking(
            file: file,
            line: line,
            errorMessageFactory: { event, _ in
                errorMessageFactory(event)
            },
            multipleEventsExpectation: EventSequenceExpectation([singleEventExpectation]),
            testContinuationBlock: testContinuationBlock
        )
    }
}

// MARK: - Reject events handling
extension PlayerTest: PlayerTestRejectEventsApi {
    internal func rejectEvents(
        file: StaticString = #file,
        line: UInt = #line,
        _ eventClasses: [Event.Type],
        _ testContinuationBlock: TestContinuationBlock
    ) async throws {
        try await rejectEvents(
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
        _ testContinuationBlock: TestContinuationBlock
    ) async throws {
        try await rejectEventsBlocking(
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
        testContinuationBlock: TestContinuationBlock
    ) async throws {
        let eventListenerProxy = EventListenerProxy()
        eventListenerProxy.onEventCallback = { event in
            log(.info("Received `Event` inside `rejectEvents`: '\(event.name)'"))
        }

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

        try await testContinuationBlock()

        multipleEventsExpectation.singleExpectations.forEach { singleEventExpectation in
            eventListenerProxy.unregisterEvent(singleEventExpectation.eventClass)
        }
        player?.remove(listener: eventListenerProxy)
    }
}

// MARK: - Call player handling
extension PlayerTest: PlayerTestCallPlayerAndExpectApi {
    internal func callPlayerAndExpectEvent<T: Event>(
        _ playerBlock: @escaping AsyncCallPlayerBlock,
        _ eventExpectation: SingleEventExpectation<T>,
        timeout: TimeInterval? = nil,
        file: StaticString = #file,
        line: UInt = #line
    ) async throws -> T {
        try await expectEventBlocking(
            singleEventExpectation: eventExpectation,
            timeout: timeout ?? defaultTimeout,
            file: file,
            line: line
        ) {
            try await self.callPlayer(playerBlock)
        }
    }

    @discardableResult
    internal func callPlayerAndExpectEvent<T: Event>(
        _ playerBlock: @escaping AsyncCallPlayerBlock,
        _ eventClass: T.Type,
        timeout: TimeInterval? = nil,
        file: StaticString = #file,
        line: UInt = #line
    ) async throws -> T {
        try await callPlayerAndExpectEvent(
            playerBlock,
            PlainEventExpectation(eventClass),
            timeout: timeout,
            file: file,
            line: line
        )
    }

    internal func callPlayerAndExpectEvents(
        _ playerBlock: @escaping AsyncCallPlayerBlock,
        _ eventClasses: [Event.Type],
        timeout: TimeInterval? = nil,
        file: StaticString = #file,
        line: UInt = #line
    ) async throws -> [Event] {
        try await callPlayerAndExpectEvents(
            playerBlock,
            EventSequenceExpectation(eventClasses),
            timeout: timeout ?? defaultTimeout,
            file: file,
            line: line
        )
    }

    internal func callPlayerAndExpectEvents(
        _ playerBlock: @escaping AsyncCallPlayerBlock,
        _ multipleEventsExpectation: MultipleEventsExpectation,
        timeout: TimeInterval? = nil,
        file: StaticString = #file,
        line: UInt = #line
    ) async throws -> [Event] {
        try await expectEventsBlocking(
            multipleEventsExpectation: multipleEventsExpectation,
            timeout: timeout ?? defaultTimeout,
            file: file,
            line: line
        ) {
            try await self.callPlayer(playerBlock)
        }
    }
}

extension PlayerTest: PlayerTestCallPlayerApi {
    internal func callPlayer(_ playerBlock: @escaping CallPlayerBlock) {
        playerBlock(player)
    }

    internal func callPlayer(_ playerBlock: @escaping AsyncCallPlayerBlock) async throws {
        try await playerBlock(player)
    }

    internal func verifyPlayer(_ playerBlock: @escaping CallPlayerBlock) {
        playerBlock(player)
    }

    internal func safeVerifyPlayer(_ playerBlock: @escaping (Player?) -> Void) {
        playerBlock(player)
    }
}

// MARK: - Convenience helpers
extension PlayerTest: PlayerTestConvenienceApi {
    internal func createSource(sourceConfig: SourceConfig) -> Source {
        SourceFactory.createSource(from: sourceConfig)
    }

    internal func load(
        _ source: Source,
        preloadAllSources: Bool = false,
        replayMode: ReplayMode = .playlist,
        timeout: TimeInterval? = nil,
        file: StaticString = #file,
        line: UInt = #line
    ) async throws {
        try await load(
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
    ) async throws {
        let options = PlaylistOptions(
            preloadAllSources: preloadAllSources,
            replayMode: replayMode
        )
        try await load(
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
    ) async throws {
        try await load(
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
    ) async throws {
        try await load(
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
    ) async throws {
        // swiftlint:disable:next multiline_arguments_brackets
        try await callPlayerAndExpectEvents({ player in
                player.load(playlistConfig: playlistConfig)
            },
            B(ReadyEvent.self, SourceLoadedEvent.self),
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
    ) async throws {
        try await play(
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
    ) async throws {
        try await expectEventBlocking(
            singleEventExpectation: FilteredEventExpectation(TimeChangedEvent.self) { timeChangedEvent -> Bool in
                timeChangedEvent.currentTime >= time
            },
            timeout: timeout ?? defaultTimeout,
            file: file,
            line: line
        ) {
            self.callPlayer { player in
                player.play()
            }
        }
    }

    internal func wait(for time: TimeInterval) async {
        let condition = Condition(description: "wait for")

        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .milliseconds(Int(time * 1_000))) {
            condition.fulfill()
        }

        activeConditions.append(condition)
        await condition.wait(timeout: time)
        activeConditions.removeAll { $0 === condition }
    }

    internal func wait(
        timeout: TimeInterval? = nil,
        file: StaticString = #file,
        line: UInt = #line,
        until playerBlock: @escaping (Player) -> Bool
    ) async {
        let condition = Condition(description: "wait until")

        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak player] timer in
            guard let player else { return }

            if playerBlock(player) {
                timer.invalidate()
                condition.fulfill()
            }
        }
        .fire()

        activeConditions.append(condition)
        await condition.wait(timeout: timeout ?? defaultTimeout)
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
        _ playerViewBlock: @escaping (PlayerView) async throws -> Void,
        _ multipleEventsExpectation: MultipleEventsExpectation,
        timeout: TimeInterval? = nil,
        file: StaticString = #file,
        line: UInt = #line
    ) async throws -> [Event] {
        try await expectPlayerViewEventsBlocking(
            multipleEventsExpectation: multipleEventsExpectation,
            timeout: timeout ?? defaultTimeout,
            file: file,
            line: line
        ) {
            try await self.callPlayerView(playerViewBlock)
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

    internal func callPlayerView(
        _ playerViewBlock: @escaping (PlayerView) async throws -> Void,
        file: StaticString = #file,
        line: UInt = #line
    ) async throws {
        guard let playerView else {
            XCTFail("No `PlayerView` was created for this test case!", file: file, line: line)
            return
        }

        try await playerViewBlock(playerView)
    }

    private func expectPlayerViewEventsBlocking(
        multipleEventsExpectation: MultipleEventsExpectation,
        timeout: TimeInterval,
        file: StaticString = #file,
        line: UInt = #line,
        onListenerAttachedBlock: OnListenerAttachedBlock? = nil
    ) async throws -> [Event] {
        guard let playerView else {
            XCTFail("No `PlayerView` was created for this test case!", file: file, line: line)
            throw PlayerTestingError.expectationNotMet
        }

        let eventListenerProxy = PlayerViewEventListenerProxy()
        eventListenerProxy.onEventCallback = { event in
            log(.info("Received `PlayerViewEvent` inside `expectEvent`: '\(event.name)'"))
        }
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

        try await onListenerAttachedBlock?()

        activeConditions.append(condition)
        await condition.wait(timeout: timeout)
        activeConditions.removeAll { $0 === condition }

        multipleEventsExpectation.singleExpectations.forEach { singleEventExpectation in
            eventListenerProxy.unregisterEvent(singleEventExpectation.eventClass)
        }

        playerView.remove(listener: eventListenerProxy)

        guard condition.isFulfilled else {
            XCTFail("Expectation was not met: \(condition.description)", file: file, line: line)
            throw PlayerTestingError.expectationNotMet
        }

        return recordedEvents
    }
}

// MARK: - Error Handling

extension PlayerTest {
    private func failOnErrorEvent(
        file: StaticString = #file,
        line: UInt = #line,
        _ testBlock: PlayerTestBlock
    ) async throws {
        try await rejectEventsBlocking(
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
        viewController = nil
        window = nil
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
