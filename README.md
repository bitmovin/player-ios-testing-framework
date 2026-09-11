<p align="center">
    <h1 align="center">Bitmovin Player iOS - Testing Framework 🤖</h1>
</p>
<br />

The `PlayerTesting` framework provides a easy and convenient way to test various streams and use-cases with the Bitmoivn iOS Player. It supports testing all main entities such as `Source`, `Player`, `PlayerView` and `OfflineContentManager`.

The framework supports:

- `Player`, `Source`, and `PlayerView` interactions
- Ordered, filtered, repeated, and rejected event expectations
- Automatic failure on unexpected playback errors and timeouts
- Configurable global timeouts and event heartbeat monitoring
- Offline playback tests on iOS

## Installation

### Swift Package Manager

In Xcode, select **File > Add Package Dependencies** and enter:

```text
https://github.com/bitmovin/player-ios-testing-framework.git
```

Select the `PlayerTesting` product and add it to your test target.

## Test Project and Target

`PlayerTesting` should be used from a unit testing target.

For an existing Xcode project:

1. Add a **Unit Testing Bundle** target for iOS or tvOS.
2. Add the `PlayerTesting` package product to that unit testing target only.
3. Add the unit testing target to the **Test** action of the scheme used to run the tests.
4. Set the test target and host application deployment targets to iOS 15.0 or tvOS 15.0 or later, and ensure they meet the requirements of the application under test.

### Running on a Simulator

The unit testing target can run without a dedicated host application when using a simulator. This is sufficient for tests that only need the test process and the view hierarchy created by `PlayerTesting`. Integrations that depend on application lifecycle behavior or a host-provided view hierarchy may still require a host application on the simulator.

### Running on a Physical Device

Tests running on a physical device need a host application. If the project already contains an app target, it can be used as the host. Frameworks or integrations without an app target should add a minimal application target for the same platform as the tests.

In the unit testing target's **General** settings, select the application under **Host Application**. Xcode then configures the test bundle to load into the application process. The host and test bundle must both be signed for the selected device.

The host application should remain minimal and must not create or start a Player on its own. `PlayerTesting` manages the Player lifecycle and creates the required view hierarchy for each test. Keep `PlayerTesting` linked to the unit testing target rather than the host application.

Physical-device tests also require a valid Bitmovin Player license key as described in [License Key](#license-key).

## Test Framework Compatibility

The public `PlayerTesting` API consists of top-level async functions and does not depend on a certain testing framework. It can be used from `XCTest`, `Swift Testing`, or [`Quick`](https://github.com/quick/quick) (our recommendation).

## Writing a Player Test

Import `PlayerTesting` and call `startPlayerTest` from an async method. The framework creates the `Player` in the test block and tears it down afterwards.

```swift
import Foundation
import PlayerTesting
import XCTest

final class PlaybackTests: XCTestCase {
    @MainActor
    func testPlaybackStarts() async throws {
        let sourceConfig = SourceConfig(
            url: URL(string: "https://example.com/stream.m3u8")!,
            type: .hls
        )

        try await startPlayerTest {
            try await loadSourceConfig(sourceConfig)

            try await callPlayerAndExpectEvent(
                { player in
                    player.play()
                },
                PlayingEvent.self
            )
        }
    }
}
```

Replace the example URL with the stream under test.

### Event Expectations

Use `expectEvent` or `expectEvents` when an event will be emitted independently of an immediate API call:

```swift
let playingEvent = try await expectEvent(PlayingEvent.self)

let events = try await expectEvents(
    SourceLoadedEvent.self,
    ReadyEvent.self
)
```

For events caused directly by a Player API call, prefer `callPlayerAndExpectEvent` or `callPlayerAndExpectEvents`. These helpers register the expectation before performing the action, avoiding races with events emitted synchronously or immediately afterwards.

```swift
let events = try await callPlayerAndExpectEvents({ player in
        player.play()
    },
    PlayingEvent.self,
    TimeChangedEvent.self
)
```

#### Single Event Expectations

`SingleEventExpectation` is the base type for matching one event. Use one of its concrete implementations to match by event type, event properties, or the object that emitted the event. Each implementation also has a short alias for composing expectations:

| Expectation | Alias | Matches |
| --- | --- | --- |
| `PlainEventExpectation` | `P` | The next event of the specified type. |
| `FilteredEventExpectation` | `F` | An event of the specified type for which the filter closure returns `true`. |
| `PlainSourceEventExpectation` | `PS` | An event of the specified type emitted by a particular `Source` instance. |
| `FilteredSourceEventExpectation` | `FS` | An event of the specified type emitted by a particular `Source` instance and accepted by the filter closure. |
| `PlainOfflineEventExpectation` | `PO` | An event of the specified type emitted by a particular `OfflineContentManager`. Available on iOS. |
| `FilteredOfflineEventExpectation` | `FO` | An event of the specified type emitted by a particular `OfflineContentManager` and accepted by the filter closure. Available on iOS. |

Passing an event type directly, such as `expectEvent(PlayingEvent.self)`, is the shorthand for a plain event expectation. Use the concrete expectation types when additional matching is needed:

```swift
let playing = P(PlayingEvent.self)
let playbackProgressed = F(TimeChangedEvent.self) { event in
    event.currentTime >= 5
}

let sourceLoaded = PS(source, SourceLoadedEvent.self)
let id3Metadata = FS(source, MetadataParsedEvent.self) { event in
    event.metadataType == .ID3
}

let downloadFinished = PO(
    offlineContentManager,
    ContentDownloadFinishedEvent.self
)
let downloadHalfwayFinished = FO(
    offlineContentManager,
    ContentDownloadProgressChangedEvent.self
) { event in
    event.progress >= 0.5
}
```

Player and source event expectations can be passed to `expectEvent`, `callPlayerAndExpectEvent`, and `rejectEvent`. Offline event expectations are used with the corresponding overloads that take an `OfflineContentManager`, including `expectEvent`, `callOfflineContentManagerAndExpectEvent`, and `rejectEvent`. All single event expectations can also be used as building blocks for multi event expectations.

#### Multi Event Expectations

`MultipleEventsExpectation` is the base type for combining single event expectations. Use one of the following implementations depending on the required ordering and fulfillment behavior:

| Expectation | Alias | Matches |
| --- | --- | --- |
| `EventSequenceExpectation` | `S` | All supplied expectations in the specified order. An event for a later expectation does not fulfill it before the preceding expectations have been met. |
| `EventBagExpectation` | `B` | All supplied expectations in any order. Each received event fulfills at most one still-unfulfilled expectation. |
| `AnyEventExpectation` | `A` | The first matching expectation out of the supplied alternatives. The expectation completes after one match. |
| `RepeatedEventExpectation` | `R` | The same event expectation a specified number of times. It accepts either an event type or any single event expectation. |

Passing multiple event types directly to `expectEvents` or `callPlayerAndExpectEvents` creates an `EventSequenceExpectation`. The explicit types allow more precise matching:

```swift
let playbackSequence = S(
    P(PlayingEvent.self),
    F(TimeChangedEvent.self) { $0.currentTime > 0 }
)

let eventsInAnyOrder = B(
    P(ReadyEvent.self),
    P(PlayingEvent.self)
)

let playingOrPaused = A(
    P(PlayingEvent.self),
    P(PausedEvent.self)
)

let threeTimeUpdates = R(
    F(TimeChangedEvent.self) { $0.currentTime > 0 },
    3
)
```

Multi event expectations can be passed to `expectEvents`, `callPlayerAndExpectEvents`, and `rejectEvents`. Offline tests provide corresponding overloads that take an `OfflineContentManager`, including `expectEvents`, `callOfflineContentManagerAndExpectEvents`, and `rejectEvents`:

```swift
try await callPlayerAndExpectEvents({ player in
        player.play()
    },
    playbackSequence
)
```

#### Rejecting unexpected Events

Use `rejectEvent` to fail when an event occurs during an operation:

```swift
try await rejectEvent(PausedEvent.self) {
    try await play(for: 5)
}
```

### Test Configuration

`startPlayerTest` accepts configuration for common system-test scenarios:

- `buildViewHierarchyMode`: Use `.full` when the Player requires a complete view hierarchy, `.viewOnly` for only a PlayerView, or `.none` for headless tests.
- `globalTimeout`: Fails the test when the complete test block exceeds the configured duration.
- `heartbeatWindow`: Fails when no Player events arrive within the configured interval.
- `failOnError`: Controls whether an `ErrorEvent` fails the test automatically. It is enabled by default.
- `playerCreator`: Supplies a custom Player factory for integrations or specialized Player setup.

### License Key

Tests use the same licensing requirements as the Bitmovin Player. Configure a testing license key when required, including when running on a physical device:

```swift
PlayerTestingConfig.playerLicenseKeyForTesting = "YOUR_LICENSE_KEY"
```

### Offline Testing

On iOS, `startOfflineTest` provides the corresponding lifecycle for `OfflineManager` and `OfflineContentManager` tests. The offline API includes helpers for observing and rejecting offline events, preparing an `OfflineContentManager`, monitoring download progress, and waiting for selected tracks to finish downloading.

```swift
let sourceConfig = SourceConfig(
    url: URL(string: "https://example.com/stream.m3u8")!,
    type: .hls
)

try await startOfflineTest {
    let offlineContentManager = try await getOfflineContentManager(
        sourceConfig: sourceConfig
    )

    try await waitUntilDownloaded(
        offlineContentManager,
        timeout: 120
    )
}
```
