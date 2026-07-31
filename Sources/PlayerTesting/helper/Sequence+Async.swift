//
// Bitmovin Player iOS SDK
// Copyright (C) 2024, Bitmovin GmbH, All Rights Reserved
//
// This source code and its use and distribution, is subject to the terms
// and conditions of the applicable license agreement.
//

import Foundation

internal extension Sequence {
    func map<T>(
        _ transform: (Element) async throws -> T
    ) async rethrows -> [T] {
        var values: [T] = []

        for element in self {
            try await values.append(transform(element))
        }

        return values
    }

    func compactMap<T>(
        _ transform: (Element) async throws -> T?
    ) async rethrows -> [T] {
        var values: [T] = []

        for element in self {
            if let result = try await transform(element) {
                values.append(result)
            }
        }

        return values
    }

    func flatMap<T: Sequence>(
        _ transform: (Element) async throws -> T
    ) async rethrows -> [T.Element] {
        var values: [T.Element] = []

        for element in self {
            try await values.append(contentsOf: transform(element))
        }

        return values
    }

    func forEach(
        _ operation: (Element) async throws -> Void
    ) async rethrows {
        for element in self {
            try await operation(element)
        }
    }

    func reduce<T>(
        _ initialResult: T,
        _ nextPartialResult: (T, Element) async throws -> T
    ) async rethrows -> T {
        var result = initialResult
        for element in self {
            result = try await nextPartialResult(result, element)
        }
        return result
    }

    /// Taken from https://github.com/happn-app/CollectionConcurrencyKit/blob/903a94af1104ccf907982dd35f980b60d95025a3/Sources/CollectionConcurrencyKit.swift#L368
    /// Transform the sequence into an array of new values using
    /// an async closure that returns sequences. The returned sequences
    /// will be flattened into the array returned from this function.
    ///
    /// The closure calls will be performed concurrently, but the call
    /// to this function won't return until all of the closure calls
    /// have completed.
    ///
    /// - parameter priority: Any specific `TaskPriority` to assign to
    ///   the async tasks that will perform the closure calls. The
    ///   default is `nil` (meaning that the system picks a priority).
    /// - parameter transform: The transform to run on each element.
    /// - returns: The transformed values as an array. The order of
    ///   the transformed values will match the original sequence,
    ///   with the results of each closure call appearing in-order
    ///   within the returned array.
    func concurrentFlatMap<T: Sequence>(
        withPriority priority: TaskPriority? = nil,
        _ transform: @escaping (Element) async -> T
    ) async -> [T.Element] {
        await withTaskGroup(of: (offset: Int, value: T).self) { group in
            for (idx, element) in enumerated() {
                group.addTask(priority: priority) {
                    await (idx, transform(element))
                }
            }

            var res = [(offset: Int, value: T)]()
            while let next = await group.next() {
                res.append(next)
            }
            // swiftformat:disable:next preferKeyPath
            return res.sorted { $0.offset < $1.offset }.flatMap { $0.value }
        }
    }

    /// Transform the sequence into an array of new values using
    /// an async closure that returns sequences. The returned sequences
    /// will be flattened into the array returned from this function.
    ///
    /// The closure calls will be performed concurrently, but the call
    /// to this function won't return until all of the closure calls
    /// have completed. If any of the closure calls throw an error,
    /// then the first error will be rethrown once all closure calls have
    /// completed.
    ///
    /// - parameter priority: Any specific `TaskPriority` to assign to
    ///   the async tasks that will perform the closure calls. The
    ///   default is `nil` (meaning that the system picks a priority).
    /// - parameter transform: The transform to run on each element.
    /// - returns: The transformed values as an array. The order of
    ///   the transformed values will match the original sequence,
    ///   with the results of each closure call appearing in-order
    ///   within the returned array.
    /// - throws: Rethrows any error thrown by the passed closure.
    func concurrentFlatMap<T: Sequence>(
        withPriority priority: TaskPriority? = nil,
        _ transform: @escaping (Element) async throws -> T
    ) async throws -> [T.Element] {
        try await withThrowingTaskGroup(of: (offset: Int, value: T).self) { group in
            for (idx, element) in enumerated() {
                group.addTask(priority: priority) {
                    try await (idx, transform(element))
                }
            }

            var res = [(offset: Int, value: T)]()
            while let next = try await group.next() {
                res.append(next)
            }
            // swiftformat:disable:next preferKeyPath
            return res.sorted { $0.offset < $1.offset }.flatMap { $0.value }
        }
    }

    /// Run an async closure for each element within the sequence.
    ///
    /// The closure calls will be performed concurrently, but the call
    /// to this function won't return until all of the closure calls
    /// have completed. If any of the closure calls throw an error,
    /// then the first error will be rethrown once all closure calls have
    /// completed.
    ///
    /// - parameter priority: Any specific `TaskPriority` to assign to
    ///   the async tasks that will perform the closure calls. The
    ///   default is `nil` (meaning that the system picks a priority).
    /// - parameter operation: The closure to run for each element.
    /// - throws: Rethrows any error thrown by the passed closure.
    func concurrentForEach(
        withPriority priority: TaskPriority? = nil,
        _ operation: @escaping (Element) async throws -> Void
    ) async throws {
        try await withThrowingTaskGroup(of: Void.self) { group in
            for element in self {
                group.addTask(priority: priority) {
                    try await operation(element)
                }
            }

            for try await _ in group {}
        }
    }
}
