import BitmovinPlayerCore
import Foundation

internal class PlayerTestLogger {
    private var currentPlayerTestFunctionNesting = 0

    func logFunctionStart(_ functionName: String = #function) {
        logWithPadding(
            .info(
                "┌ \(buildFunctionName(from: functionName))"
            ),
            count: currentPlayerTestFunctionNesting
        )
        currentPlayerTestFunctionNesting += 1
    }

    func logFunctionEnd(_ functionName: String = #function) {
        currentPlayerTestFunctionNesting -= 1
        logWithPadding(
            .info(
                "└ \(buildFunctionName(from: functionName))"
            ),
            count: currentPlayerTestFunctionNesting
        )
    }

    func log(event: Event, sender: String, functionName: String = #function) {
        var customEventDetails = ""
        switch event {
        case let event as TimeChangedEvent:
            customEventDetails = " - currentTime: \(event.currentTime)"
        case let event as AudioChangedEvent:
            customEventDetails = """
                                  - from: \(event.audioTrackOld?.language ?? "nil"), \
                                 to: \(event.audioTrackNew.language ?? "nil")
                                 """
        case let event as SubtitleChangedEvent:
            customEventDetails = """
                                  - from: \(event.subtitleTrackOld?.language ?? "nil"), \
                                 to: \(event.subtitleTrackNew?.language ?? "nil")
                                 """
        case let event as DurationChangedEvent:
            customEventDetails = " - duration: \(event.duration)"
#if !os(tvOS)
        case let event as ContentDownloadProgressChangedEvent:
            customEventDetails = " - downloadProgress: \(event.progress)"
#endif
        case let event as DownloadFinishedEvent:
            customEventDetails = " - url: \(event.url)"
        case let event as SourceRemovedEvent:
            customEventDetails = " - source: \(event.source.readableReference)"
        default:
            break
        }

        logWithPadding(
            .info(
                """
                ├ Received Event '\(String(describing: type(of: event)))' \
                from '\(sender)' \
                in '\(buildFunctionName(from: functionName))'\
                \(customEventDetails)
                """
            ),
            count: currentPlayerTestFunctionNesting
        )
    }

    func reset() {
        currentPlayerTestFunctionNesting = 0
    }
}

private func buildFunctionName(from functionName: String) -> String {
    guard let bracketIndex = functionName.firstIndex(of: "(") else {
        return functionName
    }

    return functionName[..<bracketIndex].trimmingCharacters(in: .whitespaces)
}

private func logWithPadding(_ logEntry: LogEntry, count: Int) {
    let padding = String(String(repeating: "│ ", count: count))

    let paddedLogEntry = LogEntry(
        message: "\(padding)\(logEntry.message)",
        level: logEntry.level,
        code: logEntry.code,
        sender: logEntry.sender,
        data: logEntry.data
    )

    PlayerTesting.log(paddedLogEntry)
}
