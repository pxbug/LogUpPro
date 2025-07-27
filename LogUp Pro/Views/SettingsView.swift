import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var showClearCacheAlert = false
    @State private var showResetAlert = false
    
    private var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "未知"
    }
    
    var body: some View {
        ZStack {
            GlassMorphicBackground()
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 20) {
                    VStack(spacing: 15) {
                        // About Section
                        VStack(spacing: 0) {
                            HStack {
                                Label("版本", systemImage: "info.circle")
                                Spacer()
                                Text(appVersion)
                                    .foregroundColor(.secondary)
                            }
                            .padding()
                            
                            Divider()
                            
                            HStack {
                                Label("开发者", systemImage: "person.fill")
                                Spacer()
                                Text("YunZhi Net Co.,Ltd")
                                    .foregroundColor(.secondary)
                            }
                            .padding()
                        }
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
                        
                        NavigationLink(destination: AccountManagementView()) {
                            HStack {
                                Label("账号管理", systemImage: "person.text.rectangle")
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .foregroundColor(.secondary)
                            }
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
                        
                        VStack(spacing: 0) {
                            Button(action: {
                                showClearCacheAlert = true
                            }) {
                                HStack {
                                    Label("清除缓存", systemImage: "trash.fill")
                                        .foregroundColor(.red)
                                    Spacer()
                                }
                                .padding()
                            }
                            
                            Divider()
                            
                            Button(action: {
                                showResetAlert = true
                            }) {
                                HStack {
                                    Label("重置所有设置", systemImage: "arrow.counterclockwise")
                                        .foregroundColor(.red)
                                    Spacer()
                                }
                                .padding()
                            }
                        }
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
                        
                        VStack(spacing: 0) {
                            Button(action: {
                                if let url = URL(string: "https://www.xn--fhq57lu5b.vip") {
                                    UIApplication.shared.open(url)
                                }
                            }) {
                                HStack {
                                    Label("官方网站", systemImage: "globe")
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                        .foregroundColor(.secondary)
                                }
                                .padding()
                            }
                            
                            Divider()
                            
                            Button(action: {
                                if let url = URL(string: "https://t.me/iTroll886") {
                                    UIApplication.shared.open(url)
                                }
                            }) {
                                HStack {
                                    Label("官方交流群", systemImage: "bubble.left.and.bubble.right")
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                        .foregroundColor(.secondary)
                                }
                                .padding()
                            }
                            
                            Divider()
                            
                            NavigationLink(destination: ContactView()) {
                                HStack {
                                    Label("联系我们", systemImage: "bubble.left.and.bubble.right.fill")
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                        .foregroundColor(.secondary)
                                }
                                .padding()
                            }
                            
                            Divider()
                            
                            NavigationLink(destination: FeedbackView()) {
                                HStack {
                                    Label("问题反馈", systemImage: "exclamationmark.bubble.fill")
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                        .foregroundColor(.secondary)
                                }
                                .padding()
                            }
                        }
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
                    .padding(.horizontal)
                }
                .padding(.vertical)
            }
        }
        .navigationTitle("设置")
        .navigationBarTitleDisplayMode(.inline)
        .alert("确认清除缓存", isPresented: $showClearCacheAlert) {
            Button("取消", role: .cancel) { }
            Button("确认", role: .destructive) {
                clearCache()
            }
        } message: {
            Text("确定要清除所有缓存数据吗？")
        }
        .alert("确认重置", isPresented: $showResetAlert) {
            Button("取消", role: .cancel) { }
            Button("确认", role: .destructive) {
                resetAllSettings()
            }
        } message: {
            Text("确定要重置所有设置吗？这将清除所有个人设置和数据。")
        }
    }
    
    private func clearCache() {
        // 清除所有缓存数据
        UserDefaults.standard.removeObject(forKey: "lastLoginData")
        UserDefaults.standard.removeObject(forKey: "recentLogins")
        UserDefaults.standard.removeObject(forKey: "loginHistory")
        
        // 清除文档目录中的缓存文件
        if let cacheURL = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first {
            do {
                let fileURLs = try FileManager.default.contentsOfDirectory(at: cacheURL, includingPropertiesForKeys: nil)
                for fileURL in fileURLs {
                    try FileManager.default.removeItem(at: fileURL)
                }
            } catch {
                print("清除缓存文件失败: \(error.localizedDescription)")
            }
        }
        
        // 清除临时文件
        if let tempURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            do {
                let fileURLs = try FileManager.default.contentsOfDirectory(at: tempURL, includingPropertiesForKeys: nil)
                for fileURL in fileURLs {
                    if fileURL.lastPathComponent.hasPrefix("temp") {
                        try FileManager.default.removeItem(at: fileURL)
                    }
                }
            } catch {
                print("清除临时文件失败: \(error.localizedDescription)")
            }
        }
        
        UserDefaults.standard.synchronize()
    }
    
    private func resetAllSettings() {
        // 清除所有用户数据
        let domain = Bundle.main.bundleIdentifier!
        UserDefaults.standard.removePersistentDomain(forName: domain)
        
        UserDefaults.standard.removeObject(forKey: "lastLoginData")
        UserDefaults.standard.removeObject(forKey: "recentLogins")
        UserDefaults.standard.removeObject(forKey: "loginHistory")
        UserDefaults.standard.removeObject(forKey: "savedAccounts")
        UserDefaults.standard.removeObject(forKey: "accountTokens")
        
        if let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            do {
                let fileURLs = try FileManager.default.contentsOfDirectory(at: documentsURL, includingPropertiesForKeys: nil)
                for fileURL in fileURLs {
                    try FileManager.default.removeItem(at: fileURL)
                }
            } catch {
                print("清除文档文件失败: \(error.localizedDescription)")
            }
        }
        
        clearCache()
        
        UserDefaults.standard.synchronize()
    }
}

#Preview {
    NavigationView {
        SettingsView()
    }
} 
