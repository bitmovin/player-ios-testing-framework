//
// Bitmovin Player iOS SDK
// Copyright (C) 2021, Bitmovin GmbH, All Rights Reserved
//
// This source code and its use and distribution, is subject to the terms
// and conditions of the applicable license agreement.
//

import BitmovinPlayerCore
import Foundation

internal extension Event {
    var eventDescription: String {
        switch self {
        case let errorEvent as PlayerErrorEvent:
            return """
                '\(String(describing: type(of: self)))' \
                code: \(errorEvent.code.rawValue), \
                message: '\(errorEvent.message)'
                """
        case let errorEvent as SourceErrorEvent:
            return """
                '\(String(describing: type(of: self)))' \
                code: \(errorEvent.code.rawValue), \
                message: '\(errorEvent.message)'
                """
#if os(iOS)
        case let errorEvent as OfflineErrorEvent:
            return """
                '\(String(describing: type(of: self)))' \
                code: \(errorEvent.code.rawValue), \
                message: '\(errorEvent.message)'
                """
#endif
        default:
            return String(describing: type(of: self))
        }
    }
}
