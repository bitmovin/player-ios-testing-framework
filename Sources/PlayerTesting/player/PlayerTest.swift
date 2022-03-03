//
// Bitmovin Player iOS SDK
// Copyright (C) 2020, Bitmovin GmbH, All Rights Reserved
//
// This source code and its use and distribution, is subject to the terms
// and conditions of the applicable license agreement.
//

import BitmovinPlayer
import Foundation
import XCTest

public typealias PlayerTestBlock = () -> Void

public let defaultGlobalTimeout: TimeInterval = 30_000
let defaultTimeout = 10.0

class PlayerTest {
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
#if targetEnvironment(simulator)
    func startPlayerTest(
        config: PlayerConfig = PlayerConfig(),
        buildViewHierarchyMode: ViewHierarchyBuildMode,
        globalTimeout: TimeInterval = defaultGlobalTimeout,
        heartbeatWindow: TimeInterval? = nil,
        failOnError failOnErrorEnabled: Bool = true,
        file: StaticString = #file,
        line: UInt = #line,
        _ testBlock: PlayerTestBlock
    ) {
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
        if let heartbeatWindowEventListenerProxy = heartbeatWindowEventListenerProxy {
            player.remove(listener: heartbeatWindowEventListenerProxy)
        }
        heartbeatWindowEventListenerProxy = nil
    }
#else
    func startPlayerTest(
        licenseKeyForTesting: String,
        config: PlayerConfig = PlayerConfig(),
        buildViewHierarchyMode: ViewHierarchyBuildMode,
        globalTimeout: TimeInterval = defaultGlobalTimeout,
        heartbeatWindow: TimeInterval? = nil,
        failOnError failOnErrorEnabled: Bool = true,
        file: StaticString = #file,
        line: UInt = #line,
        _ testBlock: PlayerTestBlock
    ) {
        config.key = licenseKeyForTesting

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
        if let heartbeatWindowEventListenerProxy = heartbeatWindowEventListenerProxy {
            player.remove(listener: heartbeatWindowEventListenerProxy)
        }
        heartbeatWindowEventListenerProxy = nil
    }
#endif

    private func buildPlayerView(mode: ViewHierarchyBuildMode) -> PlayerView? {
        switch mode {
        case .viewOnly:
            return PlayerView(
                player: player,
                frame: CGRect(origin: .zero, size: CGSize(width: 320, height: 480))
            )
        case .full:
            let viewController = buildViewController()
            let playerView = PlayerView(player: player, frame: viewController.view.frame)
            viewController.view.addSubview(playerView)
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
        guard let heartbeatWindow = heartbeatWindow else {
            return
        }

        let handleHeartbeat = { [weak self] in
            guard let self = self else { return }
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
    public func expectEvent<T: Event>(
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

    public func expectEvent<T: Event>(
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

    public func expectEvent<T: SourceEvent>(
        source: Source,
        _ eventExpectation: SingleEventExpectation<T>,
        timeout: TimeInterval? = nil,
        file: StaticString = #file,
        line: UInt = #line,
        eventHandlerBlock: ((T) -> Void)? = nil
    ) {
        expectSourceEventBlocking(
            source: source,
            singleEventExpectation: eventExpectation,
            timeout: timeout ?? defaultTimeout,
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
        expectSourceEventBlocking(
            source: source,
            singleEventExpectation: PlainEventExpectation(eventClass),
            timeout: timeout ?? defaultTimeout,
            file: file,
            line: line,
            eventHandlerBlock: eventHandlerBlock
        )
    }

    private func expectSourceEventBlocking<T: SourceEvent>(
        source: Source,
        singleEventExpectation: SingleEventExpectation<T>,
        timeout: TimeInterval,
        file: StaticString = #file,
        line: UInt = #line,
        eventHandlerBlock: ((T) -> Void)? = nil,
        onListenerAttachedBlock: (() -> Void)? = nil
    ) {
        let eventListenerProxy = SourceEventListenerProxy()
        source.add(listener: eventListenerProxy)

        let eventClass = singleEventExpectation.eventClass
        let condition = Condition(description: String(describing: eventClass))

        try? eventListenerProxy.registerEvent(T.self) { (event: T, source: Source) in
            if singleEventExpectation.maybeFulfillExpectation(
                receivedEvent: EventHolder(source: source, event: event)
            ) {
                eventHandlerBlock?(event)
                condition.fulfill()
            }
        }

        onListenerAttachedBlock?()

        activeConditions.append(condition)
        condition.wait(timeout: timeout)
        activeConditions.removeAll { $0 === condition }

        eventListenerProxy.unregisterEvent(eventClass)
        source.remove(listener: eventListenerProxy)

        if !condition.isFulfilled {
            XCTFail("Expectation was not met: \(condition.description)", file: file, line: line)
        }
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
    public func expectEvents(
        _ eventClasses: Event.Type...,
        timeout: TimeInterval? = nil,
        file: StaticString = #file,
        line: UInt = #line,
        eventHandlerBlock: (([Event]) -> Void)? = nil
    ) {
        expectEvents(
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
        expectEvents(
            EventSequenceExpectation(eventClasses),
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
        expectEventsBlocking(
            multipleEventsExpectation: multipleEventExpectation,
            timeout: timeout ?? defaultTimeout,
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
        expectEvents(
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
        expectEvents(
            source: source,
            EventSequenceExpectation(eventClasses),
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
        expectSourceEventsBlocking(
            source: source,
            multipleEventsExpectation: multipleEventExpectation,
            timeout: timeout ?? defaultTimeout,
            file: file,
            line: line,
            eventHandlerBlock: eventHandlerBlock
        )
    }

    private func expectSourceEventsBlocking(
        source: Source,
        multipleEventsExpectation: MultipleEventsExpectation,
        timeout: TimeInterval,
        file: StaticString = #file,
        line: UInt = #line,
        eventHandlerBlock: (([SourceEvent]) -> Void)? = nil,
        onListenerAttachedBlock: (() -> Void)? = nil
    ) {
        let eventListenerProxy = SourceEventListenerProxy()
        source.add(listener: eventListenerProxy)

        var recordedEvents: [SourceEvent] = []
        let condition = Condition(description: "\(multipleExpectation: multipleEventsExpectation)")
        condition.expectedFulfillmentCount = multipleEventsExpectation.singleExpectations.count

        multipleEventsExpectation.singleExpectations.forEach { singleEventExpectation in
            try? eventListenerProxy
                .registerEvent(singleEventExpectation.eventClass) { (event: SourceEvent, source: Source) in
                    if multipleEventsExpectation.isNextExpectationMet(
                        receivedEvent: EventHolder(source: source, event: event)
                    ) {
                        recordedEvents.append(event)
                        condition.fulfill()
                    }
                    condition.description = "\(multipleExpectation: multipleEventsExpectation)"
                }
        }

        onListenerAttachedBlock?()

        activeConditions.append(condition)
        condition.wait(timeout: timeout)
        activeConditions.removeAll { $0 === condition }

        multipleEventsExpectation.singleExpectations.forEach { singleEventExpectation in
            eventListenerProxy.unregisterEvent(singleEventExpectation.eventClass)
        }
        source.remove(listener: eventListenerProxy)

        if condition.isFulfilled {
            eventHandlerBlock?(recordedEvents)
        } else {
            XCTFail("Expectation was not met: \(condition.description)", file: file, line: line)
        }
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
    public func rejectEvent<T: Event>(
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

    public func rejectEvent<T: Event>(
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

    public func rejectEvent<T: SourceEvent>(
        source: Source,
        file: StaticString = #file,
        line: UInt = #line,
        _ eventClass: T.Type,
        _ testContinuationBlock: () -> Void
    ) {
        rejectEvent(
            source: source,
            file: file,
            line: line,
            PlainSourceEventExpectation(
                source,
                eventClass
            ),
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
        rejectSourceEventBlocking(
            source: source,
            file: file,
            line: line,
            singleEventExpectation: eventExpectation,
            testContinuationBlock: testContinuationBlock
        )
    }

    private func rejectSourceEventBlocking<T: SourceEvent>(
        source: Source,
        file: StaticString,
        line: UInt,
        singleEventExpectation: SingleEventExpectation<T>,
        testContinuationBlock: () -> Void
    ) {
        let eventListenerProxy = SourceEventListenerProxy()
        source.add(listener: eventListenerProxy)

        let eventClass = singleEventExpectation.eventClass
        let expectation = PlayerTestExpectation()

        try? eventListenerProxy.registerEvent(eventClass) { (event: T, source: Source) in
            if singleEventExpectation.maybeFulfillExpectation(
                receivedEvent: EventHolder(source: source, event: event)
            ) {
                expectation.reject(
                    "Received rejected event: '\(String(describing: eventClass))'",
                    file: file,
                    line: line
                )
            }
        }

        testContinuationBlock()

        eventListenerProxy.unregisterEvent(eventClass)
        source.remove(listener: eventListenerProxy)
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
    public func rejectEvents(
        file: StaticString = #file,
        line: UInt = #line,
        _ eventClasses: Event.Type...,
        testContinuationBlock: () -> Void
    ) {
        rejectEvents(
            file: file,
            line: line,
            eventClasses,
            testContinuationBlock
        )
    }

    public func rejectEvents(
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

    public func rejectEvents(
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

    public func rejectEvents(
        source: Source,
        file: StaticString = #file,
        line: UInt = #line,
        _ eventClasses: SourceEvent.Type...,
        testContinuationBlock: () -> Void
    ) {
        rejectEvents(
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
        rejectEvents(
            source: source,
            file: file,
            line: line,
            EventSequenceExpectation(eventClasses),
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
        rejectSourceEventsBlocking(
            source: source,
            file: file,
            line: line,
            multipleEventsExpectation: multipleEventExpectation,
            testContinuationBlock: testContinuationBlock
        )
    }

    private func rejectSourceEventsBlocking(
        source: Source,
        file: StaticString,
        line: UInt,
        multipleEventsExpectation: MultipleEventsExpectation,
        testContinuationBlock: () -> Void
    ) {
        let eventListenerProxy = SourceEventListenerProxy()
        source.add(listener: eventListenerProxy)

        let expectation = PlayerTestExpectation()
        expectation.assertAtRejectCount = multipleEventsExpectation.singleExpectations.count

        multipleEventsExpectation.singleExpectations.forEach { singleEventExpectation in
            try? eventListenerProxy
                .registerEvent(singleEventExpectation.eventClass) { (event: SourceEvent, source: Source) in
                    if multipleEventsExpectation.isNextExpectationMet(
                        receivedEvent: EventHolder(source: source, event: event)
                    ) {
                        expectation.reject(
                            "Received rejected source events: \(multipleExpectation: multipleEventsExpectation)",
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
        source.remove(listener: eventListenerProxy)
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
    public func callPlayerAndExpectEvent<T: Event>(
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

    public func callPlayerAndExpectEvent<T: Event>(
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

    public func callPlayerAndExpectEvent<T: SourceEvent>(
        source: Source,
        _ playerBlock: @escaping (Player) -> Void,
        _ eventExpectation: SingleEventExpectation<T>,
        timeout: TimeInterval? = nil,
        file: StaticString = #file,
        line: UInt = #line,
        eventHandlerBlock: ((T) -> Void)? = nil
    ) {
        expectSourceEventBlocking(
            source: source,
            singleEventExpectation: eventExpectation,
            timeout: timeout ?? defaultTimeout,
            file: file,
            line: line,
            eventHandlerBlock: eventHandlerBlock
        ) {
            self.callPlayer(playerBlock)
        }
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
        callPlayerAndExpectEvent(
            source: source,
            playerBlock,
            PlainSourceEventExpectation(source, eventClass),
            timeout: timeout,
            file: file,
            line: line
        ) { event in
            eventHandlerBlock?(event)
        }
    }

    public func callPlayerAndExpectEvents(
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

    public func callPlayerAndExpectEvents(
        _ playerBlock: @escaping (Player) -> Void,
        _ eventClasses: Event.Type...,
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

    public func callPlayerAndExpectEvents(
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

    public func callPlayerAndExpectEvents(
        source: Source,
        _ playerBlock: @escaping (Player) -> Void,
        _ eventClasses: [SourceEvent.Type],
        timeout: TimeInterval? = nil,
        file: StaticString = #file,
        line: UInt = #line,
        eventHandlerBlock: (([SourceEvent]) -> Void)? = nil
    ) {
        callPlayerAndExpectEvents(
            source: source,
            playerBlock,
            EventSequenceExpectation(eventClasses),
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
        callPlayerAndExpectEvents(
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
        expectSourceEventsBlocking(
            source: source,
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
    public func callPlayer(_ playerBlock: @escaping (Player) -> Void) {
        playerBlock(player)
    }

    public func verifyPlayer(_ playerBlock: @escaping (Player) -> Void) {
        playerBlock(player)
    }

    public func safeVerifyPlayer(_ playerBlock: @escaping (Player?) -> Void) {
        playerBlock(player)
    }
}

// MARK: - Convenience helpers
extension PlayerTest: PlayerTestConvenienceApi {
    public func createSource(sourceConfig: SourceConfig) -> Source {
        SourceFactory.create(from: sourceConfig)
    }

    public func load(
        _ source: Source,
        preloadAllSources: Bool = false,
        timeout: TimeInterval? = nil,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        load(
            [source],
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
        load(
            PlaylistConfig(sources: sources, options: PlaylistOptions(preloadAllSources: preloadAllSources)),
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
        load(
            [sourceConfig],
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
        load(
            sourceConfigs.map { createSource(sourceConfig: $0) },
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
        callPlayerAndExpectEvent({ player in
                player.load(playlistConfig: playlistConfig)
            },
            ReadyEvent.self,
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
        play(
            until: self.player.currentTime + time,
            timeout: timeout,
            file: file,
            line: line
        )
    }

    public func play(
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

    public func wait(for time: TimeInterval) {
        let condition = Condition(description: "wait for")

        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .milliseconds(Int(time * 1_000))) {
            condition.fulfill()
        }

        activeConditions.append(condition)
        condition.wait(timeout: time)
        activeConditions.removeAll { $0 === condition }
    }

    public func wait(
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

    public func deallocPlayer() {
        player = nil
    }

    public func trackStalling(_ trackingBlock: (StallingHistory) -> Void) {
        let eventListenerProxy = EventListenerProxy()
        player.add(listener: eventListenerProxy)

        let stallingHistory = StallingHistory()

        try? eventListenerProxy.registerEvent(StallStartedEvent.self) { event in
            stallingHistory.trackStallStarted(event: event)
        }

        try? eventListenerProxy.registerEvent(StallEndedEvent.self) { event in
            stallingHistory.trackStallEnded(event: event)
        }

        trackingBlock(stallingHistory)

        eventListenerProxy.unregisterEvent(StallStartedEvent.self)
        eventListenerProxy.unregisterEvent(StallEndedEvent.self)

        player?.remove(listener: eventListenerProxy)
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
            if let heartbeatWindowEventListenerProxy = heartbeatWindowEventListenerProxy {
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
