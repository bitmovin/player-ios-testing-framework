//
// Bitmovin Player iOS SDK
// Copyright (C) 2020, Bitmovin GmbH, All Rights Reserved
//
// This source code and its use and distribution, is subject to the terms
// and conditions of the applicable license agreement.
//

import BitmovinPlayer
import Foundation

/// 'Abstract' class for expecting one single event
public class SingleEventExpectation<T: Event>: SingleExpectation {
    public internal(set) var isFulfilled = false

    public let eventClass: Event.Type

    public init(_ eventClass: T.Type) {
        self.eventClass = T.self
    }

    public func maybeFulfillExpectation(receivedEvent: EventHolder<Event>) -> Bool {
        preconditionFailure("This method must be overridden")
    }

    internal func copy() -> SingleEventExpectation<T> {
        preconditionFailure("This method must be overridden")
    }
}

extension SingleEventExpectation: CustomStringConvertible {
    public var description: String {
        description { isFulfilled in
            isFulfilled ? .fulfilled : .unfulfilled
        }
    }
}

extension String.StringInterpolation {
    mutating func appendInterpolation(singleExpectation: SingleExpectation) {
        appendInterpolation("\(singleExpectation)")
    }
}
