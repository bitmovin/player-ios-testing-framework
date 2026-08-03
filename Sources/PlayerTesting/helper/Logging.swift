import BitmovinPlayerCore
import Foundation

private let senderTag = "PlayerTesting"

internal func log(_ logEntry: LogEntry) {
    DebugConfig.logging.logger?.log(logEntry)
}

internal extension LogEntry {
    static func info(_ message: String) -> LogEntry {
        LogEntry(
            message: message,
            level: .info,
            code: nil,
            sender: senderTag,
            data: nil
        )
    }

    static func warning(_ message: String) -> LogEntry {
        LogEntry(
            message: message,
            level: .warning,
            code: nil,
            sender: senderTag,
            data: nil
        )
    }

    static func error(_ message: String) -> LogEntry {
        LogEntry(
            message: message,
            level: .error,
            code: nil,
            sender: senderTag,
            data: nil
        )
    }
}
