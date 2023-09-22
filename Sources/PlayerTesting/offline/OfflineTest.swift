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

internal final class OfflineTest: NSObject {
    private var offlineManager: OfflineManager!
    private var activeConditions: [Condition] = []
    private var failOnErrorEnabled = false
    private var failOnErrorFile: StaticString?
    private var failOnErrorLine: UInt?
    private var offlineContentManagers: [OfflineContentManager] = []

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

extension OfflineTest: OfflineContentManagerListener {
    func onOfflineError(_ event: OfflineErrorEvent, offlineContentManager: OfflineContentManager) {
        guard failOnErrorEnabled,
              let failOnErrorFile,
              let failOnErrorLine else { return }
        XCTFail(
            "Error event was received: \(event.eventDescription)",
            file: failOnErrorFile,
            line: failOnErrorLine
        )
    }
}

extension OfflineTest: OfflineTestLifecycleApi {
    func startOfflineTest(
        offlineConfig: OfflineConfig = OfflineConfig(),
        failOnError failOnErrorEnabled: Bool = true,
        waitForSuspendedDownloadsRestoring: Bool = true,
        file: StaticString = #file,
        line: UInt = #line,
        _ testBlock: OfflineTestBlock
    ) {
        self.failOnErrorEnabled = failOnErrorEnabled
        self.failOnErrorFile = file
        self.failOnErrorLine = line
        OfflineManager.initializeOfflineManager(offlineConfig: offlineConfig)
        offlineManager = OfflineManager.sharedInstance()
        if !offlineManager.areSuspendedDownloadsRestored, waitForSuspendedDownloadsRestoring {
            let offlineDelegate = OfflineManagerDelegateProxy()
            offlineManager.delegate = offlineDelegate

            let condition = Condition(
                description: "Waiting for offline Suspended Downloads restoring"
            )
            offlineDelegate.setSuspendedDownloadsRestoredCallback {
                condition.fulfill()
            }
            condition.wait(timeout: 100)
        }
        do {
            try testBlock()
        } catch {
            fail(
                with: "Test failed with error: \(error.localizedDescription)",
                file: file,
                line: line
            )
        }
    }
}

extension OfflineTest: OfflineTestCallOfflineContentManagerAndExpectApi {
    /// Starts listening for the specified Event before executing the passed offlineContentManagerBlock.
    /// When the event is received, the eventHandlerBlock is called. This is the race-condition-safe
    /// version of calling `callOfflineContentManager` and `expectEvent` after that.
    /// Useful when events are directly tied to calls in the offlineContentManagerBlock.
    internal func callOfflineContentManagerAndExpectEvent<T: OfflineEvent>(
        _ offlineContentManager: OfflineContentManager,
        _ offlineContentManagerBlock: @escaping OfflineContentManagerTestBlock,
        _ eventClass: T.Type,
        timeout: TimeInterval,
        file: StaticString = #file,
        line: UInt = #line,
        eventHandlerBlock: ((T) -> Void)? = nil
    ) {
        callOfflineContentManagerAndExpectEvent(
            offlineContentManager,
            offlineContentManagerBlock,
            PlainEventExpectation(eventClass),
            timeout: timeout,
            file: file,
            line: line
        ) { event in
            eventHandlerBlock?(event)
        }
    }

    /// Starts listening for the specified SingleEventExpectation before executing the passed
    /// offlineContentManagerBlock.
    /// When the event is received, the eventHandlerBlock is called. This is the race-condition-safe
    /// version of calling `callOfflineContentManager` and `expectEvent` after that.
    /// Useful when events are directly tied to calls in the offlineContentManagerBlock.
    internal func callOfflineContentManagerAndExpectEvent<T: OfflineEvent>(
        _ offlineContentManager: OfflineContentManager,
        _ offlineContentManagerBlock: @escaping OfflineContentManagerTestBlock,
        _ eventExpectation: SingleEventExpectation<T>,
        timeout: TimeInterval,
        file: StaticString = #file,
        line: UInt = #line,
        eventHandlerBlock: ((T) -> Void)? = nil
    ) {
        expectEventBlocking(
            offlineContentManager,
            singleEventExpectation: eventExpectation,
            timeout: timeout,
            file: file,
            line: line,
            eventHandlerBlock: eventHandlerBlock
        ) {
            offlineContentManagerBlock(offlineContentManager)
        }
    }

    /// Starts listening for the specified MultipleEventsExpectation before executing the passed
    /// offlineContentManagerBlock.
    /// When the expectation is fulfilled in the specified order, the eventsHandlerBlock is called.
    /// This is the race-condition-safe version of calling `callOfflineContentManager` and `expectEvent` after that.
    /// Useful when events are directly tied to calls in the offlineContentManagerBlock.
    internal func callOfflineContentManagerAndExpectEvents(
        _ offlineContentManager: OfflineContentManager,
        _ offlineContentManagerBlock: @escaping OfflineContentManagerTestBlock,
        _ multipleEventsExpectation: MultipleEventsExpectation,
        timeout: TimeInterval,
        file: StaticString = #file,
        line: UInt = #line,
        eventHandlerBlock: (([OfflineEvent]) -> Void)? = nil
    ) {
        expectEventsBlocking(
            offlineContentManager,
            multipleEventsExpectation: multipleEventsExpectation,
            timeout: timeout,
            file: file,
            line: line,
            eventHandlerBlock: eventHandlerBlock
        ) {
            offlineContentManagerBlock(offlineContentManager)
        }
    }
}

extension OfflineTest: OfflineTestSingleEventExpectationApi {
    /// Listens for the specified Event to be emitted and blocks the calling thread until the event is
    /// received or the timeout is reached. In the case where the event is received, the eventHandlerBlock is called.
    internal func expectEvent<T: OfflineEvent>(
        _ offlineContentManager: OfflineContentManager,
        _ eventClass: T.Type,
        timeout: TimeInterval,
        file: StaticString = #file,
        line: UInt = #line,
        eventHandlerBlock: ((T) -> Void)? = nil
    ) {
        expectEvent(
            offlineContentManager,
            PlainEventExpectation(eventClass),
            timeout: timeout,
            file: file,
            line: line,
            eventHandlerBlock: eventHandlerBlock
        )
    }

    /// Listens for the specified SingleEventExpectation to be emitted and blocks the calling thread until the event is
    /// received or the timeout is reached. In the case where the event is received, the eventHandlerBlock is called.
    internal func expectEvent<T: OfflineEvent>(
        _ offlineContentManager: OfflineContentManager,
        _ eventExpectation: SingleEventExpectation<T>,
        timeout: TimeInterval,
        file: StaticString = #file,
        line: UInt = #line,
        eventHandlerBlock: ((T) -> Void)? = nil
    ) {
        expectEventBlocking(
            offlineContentManager,
            singleEventExpectation: eventExpectation,
            timeout: timeout,
            file: file,
            line: line,
            eventHandlerBlock: eventHandlerBlock
        )
    }

    private func expectEventBlocking<T: OfflineEvent>(
        _ offlineContentManager: OfflineContentManager,
        singleEventExpectation: SingleEventExpectation<T>,
        timeout: TimeInterval,
        file: StaticString,
        line: UInt,
        eventHandlerBlock: ((T) -> Void)? = nil,
        onListenerAttachedBlock: (() -> Void)? = nil
    ) {
        let eventListenerProxy = OfflineContentManagerEventListenerProxy()
        offlineContentManager.add(listener: eventListenerProxy)

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

        try? eventListenerProxy.registerEvent(
            singleEventExpectation.eventClass
        ) { event, offlineContentManager in
            eventExpectationBlock(
                EventHolder(
                    offlineContentManager: offlineContentManager,
                    event: event
                )
            )
        }

        onListenerAttachedBlock?()

        activeConditions.append(condition)
        condition.wait(timeout: timeout)
        activeConditions.removeAll { $0 === condition }

        eventListenerProxy.unregisterEvent(singleEventExpectation.eventClass)
        offlineContentManager.remove(listener: eventListenerProxy)

        if !condition.isFulfilled {
            XCTFail("Expectation was not met: \(condition.description)", file: file, line: line)
        }
    }
}

extension OfflineTest: OfflineTestMultipleEventsExpectationApi {
    /// Listens for the specified MultipleEventsExpectation to be fulfilled and blocks the calling thread until
    /// the expectation is fulfilled in the specified order or the timeout is reached.
    /// In the case where the expectation is fulfilled, the eventsHandlerBlock is called with an ordered list of the
    /// Events
    internal func expectEvents(
        _ offlineContentManager: OfflineContentManager,
        _ multipleEventExpectation: MultipleEventsExpectation,
        timeout: TimeInterval,
        file: StaticString = #file,
        line: UInt = #line,
        eventHandlerBlock: (([OfflineEvent]) -> Void)? = nil
    ) {
        expectEventsBlocking(
            offlineContentManager,
            multipleEventsExpectation: multipleEventExpectation,
            timeout: timeout,
            file: file,
            line: line,
            eventHandlerBlock: eventHandlerBlock
        )
    }

    private func expectEventsBlocking(
        _ offlineContentManager: OfflineContentManager,
        multipleEventsExpectation: MultipleEventsExpectation,
        timeout: TimeInterval,
        file: StaticString = #file,
        line: UInt = #line,
        eventHandlerBlock: (([OfflineEvent]) -> Void)? = nil,
        onListenerAttachedBlock: (() -> Void)? = nil
    ) {
        let eventListenerProxy = OfflineContentManagerEventListenerProxy()
        offlineContentManager.add(listener: eventListenerProxy)

        var recordedEvents: [OfflineEvent] = []
        let condition = Condition(description: "\(multipleExpectation: multipleEventsExpectation)")
        condition.expectedFulfillmentCount = multipleEventsExpectation.expectedFulfillmentCount

        let eventExpectationBlock: (EventHolder<Event>) -> Void = { eventHolder in
            if multipleEventsExpectation.isNextExpectationMet(
                receivedEvent: eventHolder
            ) {
                recordedEvents.append(eventHolder.event as! OfflineEvent)
                condition.fulfill()
            }
            condition.description = "\(multipleExpectation: multipleEventsExpectation)"
        }

        multipleEventsExpectation.singleExpectations.forEach { singleEventExpectation in
            if let offlineContentManager = (singleEventExpectation as? SingleOfflineEventExpectation)?
                .offlineContentManager {
                offlineContentManager.add(listener: eventListenerProxy)
                try? eventListenerProxy
                    .registerEvent(singleEventExpectation.eventClass) { event, offlineContentManager in
                        eventExpectationBlock(EventHolder(offlineContentManager: offlineContentManager, event: event))
                    }
            } else {
                try? eventListenerProxy.registerEvent(
                    singleEventExpectation.eventClass
                ) { event, offlineContentManager in
                    eventExpectationBlock(EventHolder(offlineContentManager: offlineContentManager, event: event))
                }
            }
        }

        onListenerAttachedBlock?()

        activeConditions.append(condition)
        condition.wait(timeout: timeout)
        activeConditions.removeAll { $0 === condition }

        multipleEventsExpectation.singleExpectations.forEach { singleEventExpectation in
            eventListenerProxy.unregisterEvent(singleEventExpectation.eventClass)
            if let offlineContentManager = (singleEventExpectation as? SingleOfflineEventExpectation)?
                .offlineContentManager {
                offlineContentManager.remove(listener: eventListenerProxy)
            }
        }

        offlineContentManager.remove(listener: eventListenerProxy)

        if condition.isFulfilled {
            eventHandlerBlock?(recordedEvents)
        } else {
            XCTFail("Expectation was not met: \(condition.description)", file: file, line: line)
        }
    }
}

extension OfflineTest: OfflineTestRejectEventApi {
    /// Listens for the specified OfflineEvent while the test continues in the testContinuationBlock.
    /// If the event is received during execution of the testContinuationBlock, the test fails.
    internal func rejectEvent<T: OfflineEvent>(
        _ offlineContentManager: OfflineContentManager,
        file: StaticString = #file,
        line: UInt = #line,
        _ eventClass: T.Type,
        _ testContinuationBlock: () -> Void
    ) {
        rejectEvent(
            offlineContentManager,
            file: file,
            line: line,
            PlainEventExpectation<T>(eventClass),
            testContinuationBlock
        )
    }

    /// Listens for the specified SingleEventExpectation while the test continues in the testContinuationBlock.
    /// If the rejectedExpectation fulfills during the testContinuationBlock, the test fails.
    internal func rejectEvent<T: OfflineEvent>(
        _ offlineContentManager: OfflineContentManager,
        file: StaticString = #file,
        line: UInt = #line,
        _ eventExpectation: SingleEventExpectation<T>,
        _ testContinuationBlock: () -> Void
    ) {
        rejectEventBlocking(
            offlineContentManager,
            file: file,
            line: line,
            singleEventExpectation: eventExpectation,
            testContinuationBlock: testContinuationBlock
        )
    }

    private func rejectEventBlocking<T: OfflineEvent>(
        _ offlineContentManager: OfflineContentManager,
        file: StaticString,
        line: UInt,
        errorMessageFactory: @escaping SingleErrorMessageFactory = defaultSingleErrorMessageFactory,
        singleEventExpectation: SingleEventExpectation<T>,
        testContinuationBlock: () -> Void
    ) {
        let eventListenerProxy = OfflineContentManagerEventListenerProxy()
        offlineContentManager.add(listener: eventListenerProxy)

        let eventClass = singleEventExpectation.eventClass
        let expectation = PlayerTestExpectation()

        try? eventListenerProxy.registerEvent(eventClass) { (event: OfflineEvent, offlineContentManager) in
            if singleEventExpectation.maybeFulfillExpectation(
                receivedEvent: EventHolder(
                    offlineContentManager: offlineContentManager,
                    event: event
                )
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
        offlineContentManager.remove(listener: eventListenerProxy)
    }
}

extension OfflineTest: OfflineTestRejectEventsApi {
    /// Listens for the specified OfflineEvent while the test continues in the testContinuationBlock.
    /// If the events are received during execution of the testContinuationBlock, the test fails.
    internal func rejectEvents(
        _ offlineContentManager: OfflineContentManager,
        file: StaticString = #file,
        line: UInt = #line,
        _ eventClasses: [OfflineEvent.Type],
        _ testContinuationBlock: () -> Void
    ) {
        rejectEvents(
            offlineContentManager,
            file: file,
            line: line,
            EventSequenceExpectation(eventClasses),
            testContinuationBlock
        )
    }

    /// Listens for the specified MultipleEventsExpectation while the test continues in the testContinuationBlock.
    /// If the rejectedExpectation fulfills during the testContinuationBlock, the test fails.
    internal func rejectEvents(
        _ offlineContentManager: OfflineContentManager,
        file: StaticString = #file,
        line: UInt = #line,
        _ multipleEventExpectation: MultipleEventsExpectation,
        _ testContinuationBlock: () -> Void
    ) {
        rejectEventsBlocking(
            offlineContentManager,
            file: file,
            line: line,
            multipleEventsExpectation: multipleEventExpectation,
            testContinuationBlock: testContinuationBlock
        )
    }

    private func rejectEventsBlocking(
        _ offlineContentManager: OfflineContentManager,
        file: StaticString,
        line: UInt,
        errorMessageFactory: @escaping MultipleErrorMessageFactory = defaultMultipleErrorMessageFactory,
        multipleEventsExpectation: MultipleEventsExpectation,
        testContinuationBlock: () -> Void
    ) {
        let eventListenerProxy = OfflineContentManagerEventListenerProxy()
        offlineContentManager.add(listener: eventListenerProxy)

        let expectation = PlayerTestExpectation()
        expectation.assertAtRejectCount = multipleEventsExpectation.singleExpectations.count

        multipleEventsExpectation.singleExpectations.forEach { singleEventExpectation in
            try? eventListenerProxy.registerEvent(
                singleEventExpectation.eventClass
            ) { (event: OfflineEvent, offlineContentManager) in
                if multipleEventsExpectation.isNextExpectationMet(
                    receivedEvent: EventHolder(
                        offlineContentManager: offlineContentManager,
                        event: event
                    )
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
        offlineContentManager.remove(listener: eventListenerProxy)
    }
}

extension OfflineTest: OfflineTestConvenienceApi {
    internal func getOfflineContentManager(
        sourceConfig: SourceConfig,
        id: String? = nil,
        clean: Bool = true
    ) throws -> OfflineContentManager {
        let offlineContentManager: OfflineContentManager
        if let id {
            offlineContentManager = try offlineManager.offlineContentManager(
                for: sourceConfig,
                id: id
            )
        } else {
            offlineContentManager = try offlineManager.offlineContentManager(for: sourceConfig)
        }
        if clean {
            resetOfflineContentManager(offlineContentManager)
        }
        // This listener is used for the fail on error
        offlineContentManager.add(listener: self)
        offlineContentManagers.append(offlineContentManager)
        return offlineContentManager
    }

    internal func downloadUntilProgress(
        _ offlineContentManager: OfflineContentManager,
        progress: Double,
        timeout: TimeInterval,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        offlineContentManager.download()
        self.expectEvent(
            offlineContentManager,
            FilteredOfflineEventExpectation(
                offlineContentManager,
                ContentDownloadProgressChangedEvent.self
            ) { progressEvent -> Bool in
                progressEvent.progress >= progress
            },
            timeout: timeout,
            file: file,
            line: line
        )
    }

    internal func waitUntilDownloaded(
        _ offlineContentManager: OfflineContentManager,
        tracks: OfflineTrackSelection,
        config: DownloadConfig = DownloadConfig.lowestQuality,
        timeout: TimeInterval,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        expectEventBlocking(
            offlineContentManager,
            singleEventExpectation: PlainOfflineEventExpectation(
                offlineContentManager,
                ContentDownloadFinishedEvent.self
            ),
            timeout: timeout,
            file: file,
            line: line,
            eventHandlerBlock: nil
        ) {
            offlineContentManager.download(
                tracks: tracks,
                downloadConfig: config
            )
        }
    }

    internal func waitUntilDownloaded(
        _ offlineContentManager: OfflineContentManager,
        config: DownloadConfig = DownloadConfig.lowestQuality,
        timeout: TimeInterval,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        expectEventBlocking(
            offlineContentManager,
            singleEventExpectation: PlainOfflineEventExpectation(
                offlineContentManager,
                ContentDownloadFinishedEvent.self
            ),
            timeout: timeout,
            file: file,
            line: line,
            eventHandlerBlock: nil
        ) {
            offlineContentManager.download(
                downloadConfig: config
            )
        }
    }
}

private extension OfflineTest {
    private func cleanupTestData() {
        offlineContentManagers.forEach(resetOfflineContentManager)
        offlineContentManagers = []
        offlineManager = nil
    }

    private func resetOfflineContentManager(_ offlineContentManager: OfflineContentManager) {
        switch offlineContentManager.offlineState {
        case .downloading, .suspended:
            // swiftlint:disable opening_brace
            callOfflineContentManagerAndExpectEvent(
                offlineContentManager,
                { offlineContentManager in
                    offlineContentManager.cancelDownload()
                },
                ContentDownloadCanceledEvent.self,
                timeout: 10
            )
            // swiftlint:enable opening_brace
        case .downloaded:
            offlineContentManager.deleteOfflineData()
        default:
            break
        }
    }
}

private typealias SingleErrorMessageFactory = (_ event: Event) -> String

private let defaultSingleErrorMessageFactory: SingleErrorMessageFactory = {
    "Received rejected offline event: '\($0.eventDescription)'"
}

private typealias MultipleErrorMessageFactory = (
    _ event: Event,
    _ expectations: MultipleEventsExpectation
) -> String

private let defaultMultipleErrorMessageFactory: MultipleErrorMessageFactory = { _, expectations in
    "Received rejected offline event: '\(multipleExpectation: expectations)'"
}
#endif
