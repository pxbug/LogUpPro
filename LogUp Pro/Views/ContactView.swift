import SwiftUI

struct ContactCard: View {
    let title: String
    let value: String
    let icon: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.title)
                    .foregroundColor(.blue)
                
                Text(title)
                    .font(.headline)
                
                Text(value)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 15)
                    .fill(.ultraThinMaterial)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 15)
                    .stroke(
                        LinearGradient(
                            colors: [.white.opacity(0.5), .white.opacity(0.2)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct ContactView: View {
    var body: some View {
        ZStack {
            // Background
            GlassMorphicBackground()
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 20) {
                    // Header Card
                    VStack(spacing: 10) {
                        Image(systemName: "bubble.left.and.bubble.right.fill")
                            .font(.largeTitle)
                            .foregroundColor(.blue)
                        
                        Text("联系我们")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Text("选择以下方式联系我们")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 15)
                            .fill(.ultraThinMaterial)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 15)
                            .stroke(
                                LinearGradient(
                                    colors: [.white.opacity(0.5), .white.opacity(0.2)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1
                            )
                    )
                    
                    // 
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 15) {
                        ContactCard(
                            title: "电报群",
                            value: "@iTroll886",
                            icon: "paperplane.fill"
                        ) {
                            if let url = URL(string: "https://t.me/iTroll886") {
                                UIApplication.shared.open(url)
                            }
                        }
                        
                        ContactCard(
                            title: "官方网站",
                            value: "www.上号器.vip",
                            icon: "globe"
                        ) {
                            if let url = URL(string: "https://www.xn--fhq57lu5b.vip/index.php") {
                                UIApplication.shared.open(url)
                            }
                        }
                        
                        ContactCard(
                            title: "客服QQ",
                            value: "2172679131",
                            icon: "message.fill"
                        ) {
                            if let url = URL(string: "https://qm.qq.com/q/2pIrazE1P6") {
                                UIApplication.shared.open(url)
                            }
                        }
                        
                        ContactCard(
                            title: "商务合作",
                            value: "iTroll@qq.com",
                            icon: "envelope.fill"
                        ) {
                            if let url = URL(string: "mailto:iTroll@qq.com") {
                                UIApplication.shared.open(url)
                            }
                        }
                    }
                }
                .padding()
            }
        }
        .navigationTitle("联系我们")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationView {
        ContactView()
    }
} 
