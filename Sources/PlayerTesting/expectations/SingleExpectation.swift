import BitmovinPlayerCore
import Foundation

// This interface is a workaround for the issue that covariance generics do not exist in swift yet.
//
// The problem is that we want to pass multiple `SingleEventExpectation`s into a `MultipleEventsExpectation`
// but the Swift compiler says that the type of e.g. `SingleEventExpectations<PlayEvent>` isn't compatible with
// e.g. SingleEventExpectations<TimeChangedEvent> even though both have the same super class. In Kotlin for example
// this is possible already.
//
// To workaround this problem we need this non-generic protocol which is implemented by `SingleEventExpectation`.
// This allows us to use this protocol when declaring the initializer for `MultiEventExpectation` and the compiler does
// no longer complain about type compatibility.
//
// TODO: There is a roadmap for swift to introduce better generic support so we should check new swift versions (> 5.1)
//       if we can get rid of this interface.
//
// More details about happened discussions:
// - https://stackoverflow.com/questions/35862869/swift-covariant-generics/35865954#35865954
//
// Resources:
// - https://github.com/apple/swift/blob/master/docs/GenericsManifesto.md
// - https://github.com/apple/swift-evolution/blob/master/proposals/0244-opaque-result-types.md
// - https://forums.swift.org/t/improving-the-ui-of-generics/22814#heading--reverse-generics
public protocol SingleExpectation: CustomStringConvertible {
    var isFulfilled: Bool { get }
    /// This non generic eventClass is needed to access the Event class from the expectation without any generics
    /// in case we got a `MultipleEventsExpectation`. For a `SingleEventExpectation` still the generic event
    /// class `genericEventClass` should and can be used.
    var eventClass: Event.Type { get }

    func maybeFulfillExpectation(receivedEvent: EventHolder<Event>) -> Bool
}

extension SingleExpectation {
    func description(statusClosure: (_ isFulfilled: Bool) -> EventExpectationReportStatus) -> String {
        "\(statusClosure(isFulfilled).rawValue) \(String(describing: eventClass))"
    }
}
