import BitmovinPlayerCore

extension Source {
    var readableReference: String {
        "Source - \(Unmanaged.passUnretained(self).toOpaque())"
    }
}
