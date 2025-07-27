//
//  ContentView.swift
//  LogUp Pro
//
//  Created by YunZhi Net Co.,Ltd on 2025/6/11.
//

import SwiftUI
#if os(iOS)
import UIKit
#else
import AppKit
#endif

struct ContentView: View {
    @State private var inputText: String = ""
    @State private var isLoading = false
    @State private var errorMessage: String? = nil
    @State private var loginResponse: LoginResponse? = nil
    @State private var redirectURL: String? = nil
    @State private var showSettings = false
    @State private var glowOpacity: Double = 0.5
    @State private var logoScale: CGFloat = 1.0
    private let logger = Logger.shared
    
    func pasteFromClipboard() {
        #if os(iOS)
        if let string = UIPasteboard.general.string {
            inputText = string
            logger.info("已从iOS剪贴板粘贴文本")
        }
        #else
        if let string = NSPasteboard.general.string(forType: .string) {
            inputText = string
            logger.info("已从macOS剪贴板粘贴文本")
        }
        #endif
    }
    
    func showError(_ message: String) {
        logger.error(message)
        errorMessage = message
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            if errorMessage == message {
                errorMessage = nil
            }
        }
    }
    
    func handleLogin() {
        guard !inputText.isEmpty else {
            showError("请输入登录态token数据")
            return
        }
        
        // 保存原始输入数据到账号管理
        AccountManager.shared.saveOriginalInput(inputText)
        
        logger.info("开始登录流程")
        let accessToken = APIService.shared.extractAccessToken(from: inputText)
        guard !accessToken.isEmpty else {
            showError("无效的token格式")
            return
        }
        
        isLoading = true
        logger.info("正在发起API请求")
        
        Task {
            do {
                let gameInfo = try await APIService.shared.checkGameInfo(accessToken: accessToken)
                guard let gameID = GameID(rawValue: gameInfo.gameid) else {
                    throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "不支持的游戏ID"])
                }
                
                logger.info("已识别游戏: \(gameID.rawValue)")
                
                let response = try await APIService.shared.login(accessToken: accessToken, gameID: gameID)
                await MainActor.run {
                    loginResponse = response
                }
                
                let secondResponse = try await APIService.shared.executeSecondRequest(
                    accessToken: accessToken,
                    openid: gameInfo.op,
                    gameID: gameID
                )
                
                if let url = secondResponse.msg {
                    await MainActor.run {
                        redirectURL = url
                        logger.success("登录流程完成")
                    }
                }
                
            } catch {
                await MainActor.run {
                    showError(error.localizedDescription)
                }
            }
            
            await MainActor.run {
                isLoading = false
            }
        }
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                GlassMorphicBackground()
                    .ignoresSafeArea()
                
                VStack(spacing: 20) {
                    ZStack {
                        GlassCard()
                        
                        VStack(spacing: 25) {
                            ZStack {
                                Image("xbox")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 90, height: 90)
                                    .blur(radius: 20)
                                    .opacity(glowOpacity)
                                
                                Image("xbox")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 80, height: 80)
                                    .scaleEffect(logoScale)
                            }
                            .onAppear {
                                withAnimation(
                                    .easeInOut(duration: 1.8)
                                    .repeatForever(autoreverses: true)
                                ) {
                                    glowOpacity = 0.8
                                }
                                
                                withAnimation(
                                    .easeInOut(duration: 1.5)
                                    .repeatForever(autoreverses: true)
                                ) {
                                    logoScale = 1.1
                                }
                            }
                            
                            Text("上号器Pro")
                                .font(.title)
                                .fontWeight(.bold)
                                .foregroundColor(.primary)
                            
                            CustomTextEditor(text: $inputText)
                            
                            VStack(spacing: 15) {
                                HStack(spacing: 15) {
                                    GradientButton(
                                        icon: "doc.on.clipboard",
                                        text: "粘贴",
                                        fullWidth: true,
                                        action: pasteFromClipboard
                                    )
                                    .frame(maxWidth: .infinity)
                                    
                                    GradientButton(
                                        icon: "trash",
                                        text: "清空",
                                        fullWidth: true,
                                        action: {
                                            inputText = ""
                                            logger.info("已清空输入文本")
                                        }
                                    )
                                    .frame(maxWidth: .infinity)
                                }
                                
                                GradientButton(
                                    icon: "arrow.right.circle",
                                    text: "登录",
                                    fullWidth: true,
                                    action: handleLogin
                                )
                            }
                        }
                        .padding(30)
                        
                        VStack {
                            HStack {
                                Spacer()
                                NavigationLink(destination: SettingsView(), isActive: $showSettings) {
                                    Image(systemName: "gearshape.fill")
                                        .font(.title2)
                                        .foregroundColor(.red)
                                        .padding(8)
                                        .background(
                                            Circle()
                                                .fill(.ultraThinMaterial)
                                                .overlay(
                                                    Circle()
                                                        .stroke(
                                                            LinearGradient(
                                                                colors: [.white.opacity(0.5), .white.opacity(0.2)],
                                                                startPoint: .topLeading,
                                                                endPoint: .bottomTrailing
                                                            ),
                                                            lineWidth: 1
                                                        )
                                                )
                                        )
                                }
                                .padding(.trailing, 20)
                                .padding(.top, 20)
                            }
                            Spacer()
                        }
                    }
                    .frame(maxWidth: 500)
                }
                .padding()
                
                // Loading View
                if isLoading {
                    LoadingView()
                }
                
                // Error Toast
                if let error = errorMessage {
                    VStack {
                        Spacer()
                        ErrorToast(message: error)
                            .transition(.move(edge: .bottom))
                            .animation(.spring(), value: errorMessage)
                    }
                    .padding(.bottom, 20)
                }
                
                if loginResponse != nil {
                    Color.black.opacity(0.4)
                        .edgesIgnoringSafeArea(.all)
                        .overlay(
                            AccountInfoGridView(
                                response: loginResponse!,
                                onClose: {
                                    loginResponse = nil
                                    redirectURL = nil
                                    logger.info("已关闭账号信息窗口")
                                },
                                onConfirm: {
                                    if let url = redirectURL, let nsurl = URL(string: url) {
                                        #if os(iOS)
                                        UIApplication.shared.open(nsurl)
                                        #else
                                        NSWorkspace.shared.open(nsurl)
                                        #endif
                                        logger.success("正在跳转到游戏")
                                    }
                                    loginResponse = nil
                                    redirectURL = nil
                                }
                            )
                        )
                }
            }
            .navigationBarHidden(true)
        }
        .navigationViewStyle(.stack)
        .onAppear {
            logger.info("主界面已加载")
        }
    }
}

#Preview {
    ContentView()
}
