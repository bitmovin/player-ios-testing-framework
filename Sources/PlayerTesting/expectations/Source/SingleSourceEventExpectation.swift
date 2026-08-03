import BitmovinPlayerCore
import Foundation

/// Represents an expectation for a specific scenario involving one [SourceEvent]
public protocol SingleSourceEventExpectation {
    var source: Source { get }
}
