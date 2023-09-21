//
// Bitmovin Player iOS SDK
// Copyright (C) 2020, Bitmovin GmbH, All Rights Reserved
//
// This source code and its use and distribution, is subject to the terms
// and conditions of the applicable license agreement.
//

import BitmovinPlayerCore
import Foundation

/// Class to expect a given eventType to happen multiple times
public class RepeatedEventExpectation<T: Event>: EventSequenceExpectation {
    public init(_ singleEventExpectation: SingleEventExpectation<T>, _ count: Int) {
        super.init(
            (0..<count).map { _ -> SingleExpectation in
                singleEventExpectation.copy()
            }
        )
    }

    public convenience init(_ eventClass: T.Type, _ count: Int) {
        self.init(PlainEventExpectation(T.self), count)
    }
}
