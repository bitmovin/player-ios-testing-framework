//
// Bitmovin Player iOS SDK
// Copyright (C) 2021, Bitmovin GmbH, All Rights Reserved
//
// This source code and its use and distribution, is subject to the terms
// and conditions of the applicable license agreement.
//

import BitmovinPlayer
import Nimble

public class StallingHistory {
    private var stallingTimes: [TimeInterval] = []
    private var lastStallStarted: StallStartedEvent?

    func trackStallStarted(event: StallStartedEvent) {
        lastStallStarted = event
    }

    func trackStallEnded(event: StallEndedEvent) {
        guard let lastStallStarted = lastStallStarted else {
            fail("There is an SDK issue as we didn't get a StallStarted event first")
            return
        }
        stallingTimes.append(event.timestamp - lastStallStarted.timestamp)
        self.lastStallStarted = nil
    }

    public func timeRespectingStalling(value: TimeInterval) -> TimeInterval {
        stallingTimes.reduce(0, +) + value
    }
}
