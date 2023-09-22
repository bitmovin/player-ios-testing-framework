//
// Bitmovin Player iOS SDK
// Copyright (C) 2020, Bitmovin GmbH, All Rights Reserved
//
// This source code and its use and distribution, is subject to the terms
// and conditions of the applicable license agreement.
//

import BitmovinPlayer
import Foundation

/// 'Abstract' class for expecting multiple events
public class MultipleEventsExpectation {
    let singleExpectations: [SingleExpectation]
    var expectedFulfillmentCount: Int {
        preconditionFailure("This must be overridden")
    }

    public init(_ singleExpectations: [SingleExpectation]) {
        self.singleExpectations = singleExpectations
    }

    public convenience init(_ singleExpectations: SingleExpectation...) {
        self.init(singleExpectations)
    }

    public convenience init(_ eventClasses: Event.Type...) {
        self.init(eventClasses)
    }

    public convenience init(_ eventClasses: [Event.Type]) {
        self.init(eventClasses.map(IsMemberExpectation.init))
    }

    public func isNextExpectationMet(receivedEvent: EventHolder<Event>) -> Bool {
        preconditionFailure("This method must be overridden")
    }
}

extension String.StringInterpolation {
    mutating func appendInterpolation(multipleExpectation: MultipleEventsExpectation) {
        appendInterpolation("\n\(multipleExpectation)\n")
    }
}

private class IsMemberExpectation: SingleExpectation {
    var isFulfilled = false

    let eventClass: Event.Type

    init(_ eventClass: Event.Type) {
        self.eventClass = eventClass
    }

    func maybeFulfillExpectation(receivedEvent: EventHolder<Event>) -> Bool {
        // In order to support protocols as event types we need to get the `Protocol` instance for the type
        // and use `.conforms(to: )` in order to verify event type
        if let eventProtocol = NSProtocolFromString(String(describing: eventClass)) {
            isFulfilled = receivedEvent.event.conforms(to: eventProtocol)
        } else {
            isFulfilled = receivedEvent.event.isMember(of: eventClass)
        }
        return isFulfilled
    }
}

extension IsMemberExpectation: CustomStringConvertible {
    var description: String {
        description { isFulfilled in
            isFulfilled ? .fulfilled : .unfulfilled
        }
    }
}
