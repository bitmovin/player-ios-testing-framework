<p align="center">
    <h1 align="center">Player iOS - Testing Framework 🤖</h1>
</p>
<br />

The `PlayerTesting` framework provides a easy and convenient way to test various streams and use-cases with the Bitmoivn iOS Player. It supports testing all main entities such as `Source`, `Player`, `PlayerView` and `OfflineContentManager`.

## Installation

### Swift Package Manager

[Swift Package Manager](https://swift.org/package-manager/) is a tool for managing the distribution of Swift frameworks. It integrates with the Swift build system to automate the process of downloading, compiling, and linking dependencies.

To integrate using Xcode, open your Project file and specify it in `Project > Package Dependencies` using the following URL:

```
https://github.com/bitmovin/player-ios.git
```

## Usage

### Simple Player Test
A simple use case for a first Player test is to interact with the `Player` and expect accorindg `Event`s afterwards. The following example shows how to test a simple playback scenario.

```swift
let sourceConfig = SourceConfig(
    url: URL(string: "")!,
    type: .hls
)

startPlayerTest {
    loadSourceConfig(sourceConfig)

    callPlayerAndExpectEvent({ player in
            player.play()
        },
        PlayingEvent.self
    )
}
```

### Advanced use cases
#### Running on a real device
If you want to run your Player test on a physical device, a license key is required same to the regular Player usage.
Your license key can be provided through the `PlayerTestingConfig`:

```swift
PlayerTestingConfig.playerLicenseKeyForTesting = "YOUR_LICENSE_KEY"
```

## Contribution
Currently, this repo is a hard fork of the `PlayerTesting` framework from our [player-ios](https://github.com/bitmovin-engineering/player-ios) SDK repo. To extend the PlayerTesting framework with feature, please implement them in the SDK repo first.
To sync the framework from the SDK repo to this repo, please copy over the whole `PlayerTesting` folder excluding the following files:
- `*.plist` (`Info.plist`)
- `*.h` (`PlayerTesting.h`)
