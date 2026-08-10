import AVFoundation
import Foundation
import Observation

/// Plays one bundled ambient loop at a time.
///
/// Previously this type flipped a `Bool` and produced no sound at all; the
/// Sounds sheet has been a placebo since the first build. It now drives a real
/// `AVAudioPlayer` against the 60-second loops in `Resources/Audio/`.
///
/// The loops are generated (see `docs/AUDIO.md`) rather than licensed, so there
/// is no attribution to track and no licence that can be revoked.
@MainActor
@Observable
final class AudioPlayerService {
    static let shared = AudioPlayerService()

    private(set) var currentSound: SoundOption?
    private(set) var isPlaying = false

    /// User-facing level, 0...1. Persisted by the caller, not here.
    var volume: Float = 0.7 {
        didSet { applyVolume() }
    }

    private var player: AVAudioPlayer?
    private var isSessionActive = false

    private init() {
        observeInterruptions()
    }

    // MARK: - Playback

    func play(_ sound: SoundOption) {
        guard let url = Bundle.main.url(forResource: sound.resourceName, withExtension: "m4a") else {
            AppLogger.app.error("Missing bundled audio asset: \(sound.resourceName, privacy: .public).m4a")
            return
        }

        do {
            activateSessionIfNeeded()

            let newPlayer = try AVAudioPlayer(contentsOf: url)
            // -1 loops indefinitely, and because the files are generated as
            // exactly-periodic buffers the wrap is sample-continuous — no
            // click, no crossfade needed.
            newPlayer.numberOfLoops = -1
            newPlayer.volume = volume * sound.gainTrim
            newPlayer.prepareToPlay()
            newPlayer.play()

            player = newPlayer
            currentSound = sound
            isPlaying = true
        } catch {
            AppLogger.app.error("Could not start audio: \(error.localizedDescription, privacy: .public)")
            stop()
        }
    }

    func stop() {
        player?.stop()
        player = nil
        currentSound = nil
        isPlaying = false
        deactivateSession()
    }

    /// Play `sound`, or stop if it is already the one playing.
    func toggle(_ sound: SoundOption) {
        if isPlaying, currentSound == sound {
            stop()
        } else {
            play(sound)
        }
    }

    private func applyVolume() {
        guard let currentSound else { return }
        player?.volume = volume * currentSound.gainTrim
    }

    // MARK: - Audio session

    /// `.ambient` mixes with whatever the user already has playing (Spotify,
    /// a podcast) and honours the physical silent switch.
    ///
    /// The trade-off is that `.ambient` **stops when the app is backgrounded**,
    /// so ambient sound will not survive the screen locking during a session.
    /// Switching to `.playback` with `.mixWithOthers` fixes that, but then the
    /// silent switch is ignored — iOS ties the two behaviours together and
    /// there is no category that gives both. Changing this line and adding
    /// `UIBackgroundModes: audio` to Info.plist is the whole change if that
    /// trade is preferred. See `docs/AUDIO.md`.
    private func activateSessionIfNeeded() {
        guard !isSessionActive else { return }
        do {
            try AVAudioSession.sharedInstance().setCategory(.ambient, mode: .default, options: [.mixWithOthers])
            try AVAudioSession.sharedInstance().setActive(true)
            isSessionActive = true
        } catch {
            AppLogger.app.error("Could not activate audio session: \(error.localizedDescription, privacy: .public)")
        }
    }

    private func deactivateSession() {
        guard isSessionActive else { return }
        // Letting other apps resume matters when we were mixed over a podcast.
        try? AVAudioSession.sharedInstance().setActive(false, options: [.notifyOthersOnDeactivation])
        isSessionActive = false
    }

    // MARK: - Interruptions

    /// A phone call or a Siri request pauses us. iOS does not restart playback
    /// on its own, so without this the sound simply never comes back and the
    /// user assumes the feature is broken.
    private func observeInterruptions() {
        NotificationCenter.default.addObserver(
            forName: AVAudioSession.interruptionNotification,
            object: AVAudioSession.sharedInstance(),
            queue: .main
        ) { [weak self] notification in
            MainActor.assumeIsolated {
                self?.handleInterruption(notification)
            }
        }
    }

    private func handleInterruption(_ notification: Notification) {
        guard
            let info = notification.userInfo,
            let raw = info[AVAudioSessionInterruptionTypeKey] as? UInt,
            let type = AVAudioSession.InterruptionType(rawValue: raw)
        else { return }

        switch type {
        case .began:
            player?.pause()

        case .ended:
            guard
                let optionsRaw = info[AVAudioSessionInterruptionOptionKey] as? UInt,
                AVAudioSession.InterruptionOptions(rawValue: optionsRaw).contains(.shouldResume)
            else { return }
            try? AVAudioSession.sharedInstance().setActive(true)
            player?.play()

        @unknown default:
            break
        }
    }
}
