import AVFoundation

@available(iOS 17.0, *)
class LaunchSoundManager {
    private var audioEngine: AVAudioEngine?
    private var playerNode: AVAudioPlayerNode?
    
    static let shared = LaunchSoundManager()
    
    private init() {}
    
    func playWelcomeChime() {
        Task { @MainActor in
            do {
                // Setup audio session
                try setupAudioSession()
                
                // Generate and play the 4-note arpeggio: C5-E5-G5-C6
                let notes: [(frequency: Float, duration: Float)] = [
                    (523.25, 0.2),  // C5
                    (659.25, 0.2),  // E5
                    (783.99, 0.2),  // G5
                    (1046.50, 0.25) // C6 (slightly longer for finale)
                ]
                
                let engine = AVAudioEngine()
                let player = AVAudioPlayerNode()
                
                let monoFormat = AVAudioFormat(standardFormatWithSampleRate: 44100, channels: 1)
                engine.attach(player)
                engine.connect(player, to: engine.mainMixerNode, format: monoFormat)
                
                try engine.start()
                self.audioEngine = engine
                self.playerNode = player
                
                player.play()
                
                var currentTime: AVAudioTime = AVAudioTime(sampleTime: 0, atRate: 44100)
                
                for (frequency, duration) in notes {
                    if let buffer = generateTone(frequency: frequency, duration: duration) {
                        player.scheduleBuffer(buffer, at: currentTime, options: []) { }
                        currentTime = AVAudioTime(
                            sampleTime: currentTime.sampleTime + AVAudioFramePosition(duration * 44100),
                            atRate: 44100
                        )
                        
                        // Add gap between notes
                        let gapTime = AVAudioTime(
                            sampleTime: currentTime.sampleTime + AVAudioFramePosition(0.08 * 44100),
                            atRate: 44100
                        )
                        currentTime = gapTime
                    }
                }
                
                // Cleanup after all notes finish
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { [weak self] in
                    self?.cleanup()
                }
                
            } catch {
                cleanup()
            }
        }
    }
    
    private func setupAudioSession() throws {
        let audioSession = AVAudioSession.sharedInstance()
        try audioSession.setCategory(.playback, options: .mixWithOthers)
        try audioSession.setActive(true)
    }
    
    private func generateTone(frequency: Float, duration: Float, sampleRate: Double = 44100) -> AVAudioPCMBuffer? {
        let frameCount = AVAudioFrameCount(duration * Float(sampleRate))
        
        guard let format = AVAudioFormat(standardFormatWithSampleRate: sampleRate, channels: 1),
              let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: frameCount) else {
            return nil
        }
        
        buffer.frameLength = frameCount
        
        guard let channelData = buffer.floatChannelData else {
            return nil
        }
        
        let omega = 2.0 * Float.pi * frequency / Float(sampleRate)
        let attackFrames = Int(0.01 * Float(sampleRate))  // 10ms attack
        let releaseFrames = Int(0.05 * Float(sampleRate)) // 50ms release
        
        for frame in 0..<Int(frameCount) {
            var amplitude: Float = 0.3
            
            // Attack envelope
            if frame < attackFrames {
                amplitude *= Float(frame) / Float(attackFrames)
            }
            // Release envelope
            else if frame > Int(frameCount) - releaseFrames {
                let releasePosition = Float(Int(frameCount) - frame) / Float(releaseFrames)
                amplitude *= releasePosition
            }
            
            let sample = sin(omega * Float(frame)) * amplitude
            channelData[0][frame] = sample
        }
        
        return buffer
    }
    
    private func cleanup() {
        playerNode?.stop()
        audioEngine?.stop()
        audioEngine = nil
        playerNode = nil
    }
}
