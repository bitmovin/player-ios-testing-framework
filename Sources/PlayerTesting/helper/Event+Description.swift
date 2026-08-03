import BitmovinPlayerCore
import Foundation

internal extension Event {
    var eventDescription: String {
        switch self {
        case let errorEvent as PlayerErrorEvent:
            return """
                '\(String(describing: type(of: self)))' \
                errorCode: \(errorEvent.errorCode), \
                message: '\(errorEvent.message)'
                """
        case let errorEvent as SourceErrorEvent:
            return """
                '\(String(describing: type(of: self)))' \
                errorCode: \(errorEvent.errorCode), \
                message: '\(errorEvent.message)'
                """
#if os(iOS)
        case let errorEvent as OfflineErrorEvent:
            return """
                '\(String(describing: type(of: self)))' \
                errorCode: \(errorEvent.errorCode), \
                message: '\(errorEvent.message)'
                """
#endif
        default:
            return String(describing: type(of: self))
        }
    }
}
