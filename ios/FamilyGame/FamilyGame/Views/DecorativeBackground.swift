import SwiftUI

@available(iOS 14.0, macOS 11.0, *)
struct DecorativeBackground: View {
    @State private var animateGradient = false
    @State private var float1 = false
    @State private var float2 = false
    @State private var float3 = false
    @State private var float4 = false
    @State private var float5 = false
    @State private var float6 = false
    @available(iOS 14.0, macOS 11.0, *)
    var body: some View {
        ZStack {
            // Warm radial gradient background
            RadialGradient(
                gradient: Gradient(colors: [
                    .sunnyYellow,
                    .warmOrange,
                    .energeticPink
                ]),
                center: animateGradient ? .topLeading : .bottomTrailing,
                startRadius: 50,
                endRadius: 600
            )
            .animation(Animation.linear(duration: 12).repeatForever(autoreverses: true), value: animateGradient)
            .ignoresSafeArea()
            
            // Subtle overlay for depth
            LinearGradient(
                gradient: Gradient(colors: [
                    .white.opacity(0.05),
                    .clear
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            // Floating decorative shapes (6 total)
            Group {
                // Shape 1: Warm orange circle
                Circle()
                    .fill(Color.warmOrange.opacity(0.2))
                    .frame(width: 90, height: 90)
                    .offset(x: float1 ? -130 : -110, y: float1 ? -240 : -200)
                    .scaleEffect(float1 ? 1.1 : 0.95)
                    .animation(Animation.easeInOut(duration: 3.5).repeatForever(autoreverses: true), value: float1)
                
                // Shape 2: Energetic pink rounded rect
                RoundedRectangle(cornerRadius: 28)
                    .fill(Color.energeticPink.opacity(0.16))
                    .frame(width: 70, height: 70)
                    .offset(x: float2 ? 130 : 110, y: float2 ? 220 : 190)
                    .scaleEffect(float2 ? 1.15 : 0.9)
                    .animation(Animation.easeInOut(duration: 2.9).repeatForever(autoreverses: true), value: float2)
                
                // Shape 3: Soft purple circle
                Circle()
                    .fill(Color.softPurple.opacity(0.18))
                    .frame(width: 60, height: 60)
                    .offset(x: float3 ? 90 : 70, y: float3 ? -180 : -140)
                    .scaleEffect(float3 ? 1.12 : 0.96)
                    .animation(Animation.easeInOut(duration: 4.0).repeatForever(autoreverses: true), value: float3)
                
                // Shape 4: Sunny yellow star (rotated square)
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.sunnyYellow.opacity(0.22))
                    .frame(width: 50, height: 50)
                    .rotationEffect(.degrees(45))
                    .offset(x: float4 ? -90 : -70, y: float4 ? 180 : 150)
                    .scaleEffect(float4 ? 1.08 : 0.94)
                    .animation(Animation.easeInOut(duration: 3.3).repeatForever(autoreverses: true), value: float4)
                
                // Shape 5: Lively green circle
                Circle()
                    .fill(Color.livelyGreen.opacity(0.14))
                    .frame(width: 55, height: 55)
                    .offset(x: float5 ? -140 : -120, y: float5 ? 60 : 40)
                    .scaleEffect(float5 ? 1.1 : 0.92)
                    .animation(Animation.easeInOut(duration: 3.7).repeatForever(autoreverses: true), value: float5)
                
                // Shape 6: Warm orange capsule/diamond
                Capsule()
                    .fill(Color.warmOrange.opacity(0.15))
                    .frame(width: 40, height: 80)
                    .rotationEffect(.degrees(30))
                    .offset(x: float6 ? 100 : 80, y: float6 ? -60 : -40)
                    .scaleEffect(float6 ? 1.06 : 0.98)
                    .animation(Animation.easeInOut(duration: 4.2).repeatForever(autoreverses: true), value: float6)
            }
        }
        .onAppear {
            animateGradient = true
            float1 = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { float2 = true }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.9) { float3 = true }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) { float4 = true }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.6) { float5 = true }
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { float6 = true }
        }
    }
}
