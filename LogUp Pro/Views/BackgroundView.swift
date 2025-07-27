import SwiftUI

struct GlassMorphicBackground: View {
    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.87, green: 0.8, blue: 0.95), // 淡紫色
                    Color(red: 0.95, green: 0.87, blue: 0.95), // 淡粉色
                    Color(red: 0.9, green: 0.85, blue: 1.0)    // 淡蓝紫色
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            
            // 添加柔和的光晕效果
            Circle()
                .fill(Color(red: 0.95, green: 0.9, blue: 1.0))
                .frame(width: 250, height: 250)
                .blur(radius: 50)
                .offset(x: -100, y: -100)
            
            Circle()
                .fill(Color(red: 0.9, green: 0.85, blue: 1.0))
                .frame(width: 250, height: 250)
                .blur(radius: 50)
                .offset(x: 100, y: 100)
        }
    }
}

struct GlassCard: View {
    var body: some View {
        RoundedRectangle(cornerRadius: 25)
            .fill(.ultraThinMaterial)
            .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 5)
    }
} 