import SwiftUI

@available(iOS 17.0, macOS 14.0, *)
struct WelcomeScreenView: View {
    @available(iOS 17.0, macOS 14.0, *)
    @Environment(AppState.self) var appState
    
    @State private var emojiFloat1 = false
    @State private var emojiFloat2 = false
    @State private var emojiFloat3 = false
    @State private var emojiFloat4 = false
    @State private var emojiFloat5 = false
    @State private var emojiFloat6 = false
    @State private var titleAppear = false
    @State private var subtitleAppear = false
    @State private var iconAppear = false
    @State private var buttonAppear = false
    @State private var badgeAppear = false
    @State private var iconPulse = false
    
    @available(iOS 17.0, macOS 14.0, *)
    var body: some View {
        ZStack {
            // Floating emoji decorations
            FloatingEmojiLayer(
                emojiFloat1: $emojiFloat1,
                emojiFloat2: $emojiFloat2,
                emojiFloat3: $emojiFloat3,
                emojiFloat4: $emojiFloat4,
                emojiFloat5: $emojiFloat5,
                emojiFloat6: $emojiFloat6
            )
            
            VStack {
                Spacer(minLength: 40)
                
                // Family Edition badge
                Text("👑 Family Edition")
                    .font(.custom("Baloo2-Medium", size: 16))
                    .foregroundColor(.deepNavy)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 6)
                    .background(
                        Capsule()
                            .fill(Color.sunnyYellow.opacity(0.85))
                    )
                    .opacity(badgeAppear ? 1 : 0)
                    .scaleEffect(badgeAppear ? 1 : 0.8)
                    .padding(.top, 20)
                
                // Title at top third
                AnimatedTitle()
                    .padding(.top, 12)
                    .opacity(titleAppear ? 1 : 0)
                    .offset(y: titleAppear ? 0 : -20)
                
                // Enhanced subtitle
                Text("Fun for the whole family! 🎉")
                    .font(.custom("Baloo2-Medium", size: 26).weight(.medium))
                    .kerning(1)
                    .foregroundColor(.deepNavy.opacity(0.85))
                    .opacity(subtitleAppear ? 1 : 0)
                    .offset(y: subtitleAppear ? 0 : 10)
                    .padding(.top, 20)
                
                // Enhanced family icon with gradient circle
                ZStack {
                    // Outer glow ring
                    Circle()
                        .fill(
                            RadialGradient(
                                gradient: Gradient(colors: [
                                    Color.warmOrange.opacity(0.3),
                                    Color.clear
                                ]),
                                center: .center,
                                startRadius: 60,
                                endRadius: 90
                            )
                        )
                        .frame(width: 180, height: 180)
                        .blur(radius: 8)
                    
                    // Main gradient circle
                    Circle()
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    .warmOrange,
                                    .sunnyYellow
                                ]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 140, height: 140)
                        .shadow(color: .warmOrange.opacity(0.4), radius: 12, x: 0, y: 6)
                    
                    // Family emoji
                    Text("👨‍👩‍👧‍👦")
                        .font(.system(size: 64))
                    
                    // Small decorative emojis around the circle
                    Text("👑")
                        .font(.system(size: 28))
                        .offset(x: -70, y: -50)
                        .opacity(0.9)
                    
                    Text("⭐")
                        .font(.system(size: 24))
                        .offset(x: 70, y: -40)
                        .opacity(0.85)
                    
                    Text("🎮")
                        .font(.system(size: 26))
                        .offset(x: 0, y: 80)
                        .opacity(0.9)
                }
                .scaleEffect(iconPulse ? 1.04 : 1.0)
                .animation(Animation.easeInOut(duration: 2.0).repeatForever(autoreverses: true), value: iconPulse)
                .accessibilityLabel("Family players icon with crown, star and game controller decorations")
                .opacity(iconAppear ? 1 : 0)
                .scaleEffect(iconAppear ? 1 : 0.7)
                .padding(.top, 32)
                
                // CTA Button with glow
                ZStack {
                    // Pulsing glow behind button
                    Capsule()
                        .fill(
                            RadialGradient(
                                gradient: Gradient(colors: [
                                    Color.energeticPink.opacity(0.4),
                                    Color.clear
                                ]),
                                center: .center,
                                startRadius: 0,
                                endRadius: 80
                            )
                        )
                        .frame(width: 220, height: 80)
                        .blur(radius: 15)
                        .scaleEffect(iconPulse ? 1.1 : 1.0)
                    
                    VibrantButton(title: "Start Game") {
                        appState.goToSetup()
                    }
                    .accessibilityHint("Tap to proceed to the player setup screen")
                }
                .opacity(buttonAppear ? 1 : 0)
                .scaleEffect(buttonAppear ? 1 : 0.85)
                .padding(.top, 36)
                
                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding(.horizontal, 24)
        }
        .background {
            DecorativeBackground()
                .ignoresSafeArea()
        }
        .onAppear {
            // Staggered entrance sequence
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.0) {
                withAnimation(.easeOut(duration: 0.4)) {
                    badgeAppear = true
                }
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                withAnimation(.interpolatingSpring(stiffness: 180, damping: 14)) {
                    titleAppear = true
                }
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                withAnimation(.easeOut(duration: 0.5)) {
                    subtitleAppear = true
                }
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                withAnimation(.interpolatingSpring(stiffness: 150, damping: 12)) {
                    iconAppear = true
                }
                iconPulse = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.9) {
                withAnimation(.interpolatingSpring(stiffness: 160, damping: 13)) {
                    buttonAppear = true
                }
            }
            
            // Start emoji animations
            emojiFloat1 = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { emojiFloat2 = true }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { emojiFloat3 = true }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) { emojiFloat4 = true }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.9) { emojiFloat5 = true }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.1) { emojiFloat6 = true }
            
            // Play welcome chime after UI appears
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                LaunchSoundManager.shared.playWelcomeChime()
            }
        }
    }
}

@available(iOS 17.0, macOS 14.0, *)
struct FloatingEmojiLayer: View {
    @Binding var emojiFloat1: Bool
    @Binding var emojiFloat2: Bool
    @Binding var emojiFloat3: Bool
    @Binding var emojiFloat4: Bool
    @Binding var emojiFloat5: Bool
    @Binding var emojiFloat6: Bool
    
    var body: some View {
        ZStack {
            // Emoji 1: Star (top-left)
            Text("🌟")
                .font(.system(size: 40))
                .opacity(0.8)
                .offset(
                    x: -140,
                    y: emojiFloat1 ? -280 : -300
                )
                .rotationEffect(.degrees(emojiFloat1 ? 10 : -10))
                .animation(Animation.easeInOut(duration: 3.5).repeatForever(autoreverses: true), value: emojiFloat1)
                .accessibilityHidden(true)
            
            // Emoji 2: Star (top-right)
            Text("⭐")
                .font(.system(size: 36))
                .opacity(0.75)
                .offset(
                    x: 130,
                    y: emojiFloat2 ? -260 : -280
                )
                .rotationEffect(.degrees(emojiFloat2 ? -15 : 15))
                .animation(Animation.easeInOut(duration: 2.8).repeatForever(autoreverses: true), value: emojiFloat2)
                .accessibilityHidden(true)
            
            // Emoji 3: House (left-middle)
            Text("🏠")
                .font(.system(size: 38))
                .opacity(0.7)
                .offset(
                    x: -150,
                    y: emojiFloat3 ? -50 : -70
                )
                .rotationEffect(.degrees(emojiFloat3 ? 8 : -8))
                .animation(Animation.easeInOut(duration: 4.2).repeatForever(autoreverses: true), value: emojiFloat3)
                .accessibilityHidden(true)
            
            // Emoji 4: Party (right-middle)
            Text("🎉")
                .font(.system(size: 42))
                .opacity(0.85)
                .offset(
                    x: 140,
                    y: emojiFloat4 ? 50 : 30
                )
                .rotationEffect(.degrees(emojiFloat4 ? -12 : 12))
                .animation(Animation.easeInOut(duration: 3.0).repeatForever(autoreverses: true), value: emojiFloat4)
                .accessibilityHidden(true)
            
            // Emoji 5: Balloon (bottom-left)
            Text("🎈")
                .font(.system(size: 44))
                .opacity(0.75)
                .offset(
                    x: -120,
                    y: emojiFloat5 ? 280 : 300
                )
                .rotationEffect(.degrees(emojiFloat5 ? 15 : -15))
                .animation(Animation.easeInOut(duration: 3.8).repeatForever(autoreverses: true), value: emojiFloat5)
                .accessibilityHidden(true)
            
            // Emoji 6: Heart (bottom-right)
            Text("❤️")
                .font(.system(size: 38))
                .opacity(0.8)
                .offset(
                    x: 135,
                    y: emojiFloat6 ? 260 : 280
                )
                .rotationEffect(.degrees(emojiFloat6 ? -10 : 10))
                .animation(Animation.easeInOut(duration: 3.3).repeatForever(autoreverses: true), value: emojiFloat6)
                .accessibilityHidden(true)
        }
    }
}

@available(iOS 17.0, macOS 14.0, *)
#Preview {
    @Previewable @State var appState = AppState()
    WelcomeScreenView()
        .environment(appState)
}
