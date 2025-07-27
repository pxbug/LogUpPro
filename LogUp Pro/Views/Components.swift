import SwiftUI

struct CustomTextEditor: View {
    @Binding var text: String
    
    var body: some View {
        Group {
            if #available(iOS 16.0, macOS 13.0, *) {
                TextEditor(text: $text)
                    .scrollContentBackground(.hidden)
                    .frame(height: 200)
                    .padding(15)
                    .background(
                        ZStack {
                            // 磨砂玻璃效果背景
                            RoundedRectangle(cornerRadius: 15)
                                .fill(.regularMaterial)
                                .opacity(0.7)
                            
                            // 渐变边框
                            RoundedRectangle(cornerRadius: 15)
                                .stroke(
                                    LinearGradient(
                                        colors: [
                                            .white.opacity(0.5),
                                            .white.opacity(0.2),
                                            .blue.opacity(0.2)
                                        ],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    lineWidth: 1.5
                                )
                        }
                    )
                    .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
            } else {
                // 旧版本的实现
                TextEditor(text: $text)
                    .frame(height: 200)
                    .padding(15)
                    .background(
                        ZStack {
                            // 磨砂玻璃效果背景
                            RoundedRectangle(cornerRadius: 15)
                                .fill(Color.white.opacity(0.1))
                                .background(.ultraThinMaterial)
                                .cornerRadius(15)
                            
                            // 渐变边框
                            RoundedRectangle(cornerRadius: 15)
                                .stroke(
                                    LinearGradient(
                                        colors: [
                                            .white.opacity(0.5),
                                            .white.opacity(0.2),
                                            .blue.opacity(0.2)
                                        ],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    lineWidth: 1.5
                                )
                        }
                    )
                    .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
            }
        }
    }
}

struct GradientButton: View {
    let icon: String
    let text: String
    let action: () -> Void
    let fullWidth: Bool
    
    init(icon: String, text: String, fullWidth: Bool = false, action: @escaping () -> Void) {
        self.icon = icon
        self.text = text
        self.fullWidth = fullWidth
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: icon)
                Text(text)
            }
            .frame(maxWidth: fullWidth ? .infinity : nil)
            .padding(.horizontal, fullWidth ? 20 : 15)
            .padding(.vertical, fullWidth ? 12 : 10)
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color.blue.opacity(0.8),
                        Color.purple.opacity(0.8)
                    ]),
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .cornerRadius(15)
            .shadow(color: .black.opacity(0.2), radius: 5, x: 0, y: 2)
            .foregroundColor(.white)
        }
    }
}

struct ErrorToast: View {
    let message: String
    
    var body: some View {
        Text(message)
            .foregroundColor(.white)
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.red.opacity(0.9))
            )
    }
}

struct AccountInfoGridItem: View {
    let icon: String
    let title: String
    let value: String
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.blue)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
            
            Text(value)
                .font(.body)
                .fontWeight(.medium)
                .foregroundColor(.primary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(.regularMaterial)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
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
}

struct AccountInfoGridView: View {
    let response: LoginResponse
    let onClose: () -> Void
    let onConfirm: () -> Void
    
    let columns = Array(repeating: GridItem(.flexible(), spacing: 12), count: 2)
    
    var body: some View {
        VStack(spacing: 20) {
            Text(response.msg ?? "账号信息")
                .font(.title2)
                .fontWeight(.bold)
                .padding(.top)

            ScrollView {
                LazyVGrid(columns: columns, spacing: 12) {
                    AccountInfoGridItem(
                        icon: "person.fill",
                        title: "角色名称",
                        value: response.charac_name
                    )
                    
                    AccountInfoGridItem(
                        icon: "number",
                        title: "玩家编号",
                        value: response.player_id
                    )
                    
                    AccountInfoGridItem(
                        icon: "star.fill",
                        title: "账号等级",
                        value: response.level
                    )
                    
                    AccountInfoGridItem(
                        icon: "dollarsign.circle.fill",
                        title: "科恩币",
                        value: response.coin
                    )
                    
                    AccountInfoGridItem(
                        icon: "bag.fill",
                        title: "实物商品",
                        value: response.recharge
                    )
                    
                    AccountInfoGridItem(
                        icon: "circle.fill",
                        title: "在线状态",
                        value: response.isroleonline
                    )
                    
                    AccountInfoGridItem(
                        icon: "shield.fill",
                        title: "账号状态",
                        value: response.account_status
                    )
                    
                    AccountInfoGridItem(
                        icon: "calendar",
                        title: "登录天数",
                        value: response.loginDays
                    )
                    
                    AccountInfoGridItem(
                        icon: "message.fill",
                        title: "聊天状态",
                        value: response.chat_banned
                    )
                    
                    AccountInfoGridItem(
                        icon: "person.2.fill",
                        title: "社交状态",
                        value: response.social_banned
                    )
                    
                    AccountInfoGridItem(
                        icon: "cart.fill",
                        title: "交易状态",
                        value: response.trade_banned
                    )
                    
                    AccountInfoGridItem(
                        icon: "clock.fill",
                        title: "最后登录",
                        value: response.lastlogintime
                    )
                    
                    AccountInfoGridItem(
                        icon: "clock.badge.checkmark",
                        title: "最后下线",
                        value: response.lastlogouttime
                    )
                }
                .padding()
            }
            

            HStack(spacing: 20) {
                Button(action: onClose) {
                    Text("关闭")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(10)
                }
                
                Button(action: onConfirm) {
                    Text("确认登录")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            LinearGradient(
                                colors: [.blue, .purple],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
            }
            .padding(.horizontal)
            .padding(.bottom)
        }
        .frame(maxWidth: 500)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(.regularMaterial)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20)
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
} 
