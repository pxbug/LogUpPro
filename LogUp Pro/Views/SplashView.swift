import SwiftUI

struct SplashView: View {
    @State private var isActive = false
    @State private var logoScale: CGFloat = 1.0
    @State private var logoOffset: CGFloat = 0
    @State private var glowOpacity: Double = 0.5
    @State private var titleOffset: CGFloat = -50
    @State private var titleOpacity: Double = 0
    
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var shouldShowUpdate = false
    @State private var updateUrl = ""
    @State private var trollStoreUrl = ""
    
    var body: some View {
        if isActive {
            ContentView()
        } else {
            ZStack {
                Image("xobxbj")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .ignoresSafeArea()
                
                VStack(spacing: 20) {
                    ZStack {
                        // 光晕
                        Image("xbox")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 140, height: 140)
                            .blur(radius: 20)
                            .opacity(glowOpacity)
                        
                        Image("xbox")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 120, height: 120)
                    }
                    .offset(y: logoOffset)
                    .scaleEffect(logoScale)
                    .onAppear {
                        withAnimation(.easeInOut(duration: 2).repeatForever(autoreverses: true)) {
                            logoOffset = -10
                        }
             withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                            logoScale = 1.1
                        }
                        withAnimation(.easeInOut(duration: 1.8).repeatForever(autoreverses: true)) {
                            glowOpacity = 0.8
                        }
                    }
                    
                    Text("LogUp Pro")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .offset(y: titleOffset)
                        .opacity(titleOpacity)
                        .onAppear {
                            withAnimation(.spring(response: 0.8, dampingFraction: 0.6, blendDuration: 0.6)) {
                                titleOffset = 0
                                titleOpacity = 1
                            }
                        }
                }
            }
            .onAppear {
                Task {
                    await checkAppStatus()
                }
            }
            //检测更新弹窗视图
            .alert("提示", isPresented: $showAlert) {
                if shouldShowUpdate {
                    Button("TrollStore") {
                        if let url = URL(string: trollStoreUrl) {
                            UIApplication.shared.open(url)
                        }
                    }
                    Button("下载IPA") {
                        if let url = URL(string: updateUrl) {
                            UIApplication.shared.open(url)
                        }
                    }
                    Button("取消", role: .cancel) {}
                } else {
                    Button("确定", role: .cancel) {}
                }
            } message: {
                Text(alertMessage)
            }
        }
    }
    
    private func checkAppStatus() async {
        do {
            let response = try await AppControl.shared.checkAppStatus()
            
            if let data = response.data {
                if !data.isEnabled {
                    alertMessage = data.message
                    showAlert = true
                    return
                }
                
                // 检查版本更新
                let currentVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0"
                if data.version != currentVersion && data.forceUpdate {
                    alertMessage = "发现新版本，请选择更新方式！"
                    updateUrl = data.updateUrl
                    trollStoreUrl = data.trollStoreUrl
                    shouldShowUpdate = true
                    showAlert = true
                    return
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {//正常则延迟进入
                    withAnimation {
                        self.isActive = true
                    }
                }
            }
        } catch {
            alertMessage = "无法连接到服务器，请检查网络连接"
            showAlert = true
        }
    }
}

#Preview {
    SplashView()
} 
