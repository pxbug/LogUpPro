import SwiftUI

struct InfoRow: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Text(title)
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .foregroundColor(.primary)
        }
    }
}

struct AccountInfoView: View {
    let response: LoginResponse
    let onClose: () -> Void
    let onConfirm: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            Text(response.msg ?? "账号信息")
                .font(.title2)
                .fontWeight(.bold)
            
            ScrollView {
                VStack(alignment: .leading, spacing: 15) {
                    InfoRow(title: "角色名称", value: response.charac_name)
                    InfoRow(title: "等级", value: response.level)
                    InfoRow(title: "在线状态", value: response.isroleonline == "1" ? "在线" : "离线")
                    InfoRow(title: "账号状态", value: response.account_status == "1" ? "封禁" : "正常")
                    InfoRow(title: "最后登录", value: response.lastlogintime)
                    InfoRow(title: "最后登出", value: response.lastlogouttime)
                    InfoRow(title: "科恩币", value: response.coin)
                    InfoRow(title: "充值金额", value: response.recharge)
                    InfoRow(title: "登录天数", value: "\(response.loginDays)天")
                }
                .padding()
            }
            
            HStack(spacing: 20) {
                Button("取消") {
                    onClose()
                }
                .buttonStyle(.bordered)
                
                Button("登录") {
                    onConfirm()
                }
                .buttonStyle(.borderedProminent)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(.ultraThinMaterial)
        )
        .frame(maxWidth: 400)
    }
} 