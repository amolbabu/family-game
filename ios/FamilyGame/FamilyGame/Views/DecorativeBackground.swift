import SwiftUI

@available(macOS 10.15, *)
struct DecorativeBackground: View {
    @State private var animateGradient = false
    @State private var float1 = false
    @State private var float2 = false
    @State private var float3 = false
    var body: some View {
        ZStack {
            // Animated main gradient
            LinearGradient(
                gradient: Gradient(colors: [
                    .playfulBlue,
                    .sunnyYellow
                ]),
                startPoint: animateGradient ? .topLeading : .bottomTrailing,
                endPoint: animateGradient ? .bottomTrailing : .topLeading
            )
            .animation(Animation.linear(duration: 10).repeatForever(autoreverses: true), value: animateGradient)
            .ignoresSafeArea()
            // Floating decorative shapes
            Group {
                Circle()
                    .fill(Color.energeticPink.opacity(0.18))
                    .frame(width: 80, height: 80)
                    .offset(x: float1 ? -120 : -100, y: float1 ? -220 : -180)
                    .scaleEffect(float1 ? 1.08 : 0.95)
                    .animation(Animation.easeInOut(duration: 3.2).repeatForever(autoreverses: true), value: float1)
                RoundedRectangle(cornerRadius: 24)
                    .fill(Color.livelyGreen.opacity(0.13))
                    .frame(width: 60, height: 60)
                    .offset(x: float2 ? 120 : 100, y: float2 ? 200 : 180)
                    .scaleEffect(float2 ? 1.12 : 0.92)
                    .animation(Animation.easeInOut(duration: 2.7).repeatForever(autoreverses: true), value: float2)
                Circle()
                    .fill(Color.softPurple.opacity(0.15))
                    .frame(width: 50, height: 50)
                    .offset(x: float3 ? 80 : 60, y: float3 ? -160 : -120)
                    .scaleEffect(float3 ? 1.09 : 0.97)
                    .animation(Animation.easeInOut(duration: 3.8).repeatForever(autoreverses: true), value: float3)
            }
        }
        .onAppear {
            animateGradient = true
            float1 = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) { float2 = true }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) { float3 = true }
        }
    }
}
