import SwiftUI
#if os(iOS)
import UIKit
#else
import AppKit
#endif

struct StatisticCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(color)
                Spacer()
            }
            
            HStack {
                Text(title)
                    .font(.caption)
                    .foregroundColor(.secondary)
                Spacer()
            }
            
            HStack {
                Text(value)
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                Spacer()
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 15)
                        .stroke(
                            LinearGradient(
                                colors: [color.opacity(0.5), color.opacity(0.2)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                )
        )
    }
}

struct SavedAccount: Identifiable, Codable {
    var id: UUID
    let originalInput: String
    let timestamp: Date
    
    init(id: UUID = UUID(), originalInput: String, timestamp: Date) {
        self.id = id
        self.originalInput = originalInput
        self.timestamp = timestamp
    }
}

struct AccountManagementView: View {
    @State private var savedAccounts: [SavedAccount] = []
    @State private var showDeleteAlert = false
    @State private var accountToDelete: SavedAccount?
    @State private var showCopyToast = false
    
    private var todayAccounts: Int {
        let calendar = Calendar.current
        return savedAccounts.filter { account in
            calendar.isDateInToday(account.timestamp)
        }.count
    }
    
    private var lastWeekAccounts: Int {
        let calendar = Calendar.current
        let oneWeekAgo = calendar.date(byAdding: .day, value: -7, to: Date())!
        return savedAccounts.filter { account in
            account.timestamp >= oneWeekAgo
        }.count
    }
    
    var body: some View {
        ZStack {
            // Background
            GlassMorphicBackground()
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 20) {
                    // Statistics Panel
                    VStack(spacing: 15) {
                        HStack(spacing: 15) {
                            StatisticCard(
                                title: "总账号数",
                                value: "\(savedAccounts.count)",
                                icon: "person.3.fill",
                                color: .blue
                            )
                            
                            StatisticCard(
                                title: "今日新增",
                                value: "\(todayAccounts)",
                                icon: "calendar",
                                color: .green
                            )
                        }
                        
                        HStack(spacing: 15) {
                            StatisticCard(
                                title: "最近一周",
                                value: "\(lastWeekAccounts)",
                                icon: "chart.line.uptrend.xyaxis",
                                color: .purple
                            )
                            
                            StatisticCard(
                                title: "最早记录",
                                value: savedAccounts.min { $0.timestamp < $1.timestamp }?.timestamp.formatted(.dateTime.month().day()) ?? "无",
                                icon: "clock.arrow.circlepath",
                                color: .orange
                            )
                        }
                    }
                    .padding(.horizontal)
                    
                    // Account List
                    VStack(spacing: 0) {
                        ForEach(savedAccounts.sorted(by: { $0.timestamp > $1.timestamp })) { account in
                            VStack(spacing: 0) {
                                HStack {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(account.originalInput)
                                            .font(.system(.body, design: .monospaced))
                                        Text(account.timestamp.formatted())
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                    
                                    Spacer()
                                    
                                    Button(action: {
                                        copyToClipboard(account.originalInput)
                                    }) {
                                        Image(systemName: "doc.on.doc")
                                            .foregroundColor(.blue)
                                            .padding(8)
                                            .background(
                                                Circle()
                                                    .fill(.ultraThinMaterial)
                                            )
                                    }
                                    .buttonStyle(.borderless)
                                }
                                .padding()
                                .background(.ultraThinMaterial)
                                
                                Divider()
                            }
                            .swipeActions(edge: .trailing) {
                                Button(role: .destructive) {
                                    accountToDelete = account
                                    showDeleteAlert = true
                                } label: {
                                    Label("删除", systemImage: "trash")
                                }
                            }
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
                    .padding(.horizontal)
                }
                .padding(.vertical)
            }
            
            // Copy Success Toast
            if showCopyToast {
                VStack {
                    Spacer()
                    Text("已复制到剪贴板")
                        .foregroundColor(.white)
                        .padding()
                        .background(
                            Capsule()
                                .fill(Color.black.opacity(0.75))
                        )
                        .transition(.move(edge: .bottom))
                        .animation(.spring(), value: showCopyToast)
                }
                .padding(.bottom, 20)
            }
        }
        .navigationTitle("账号管理")
        .navigationBarTitleDisplayMode(.inline)
        .alert("确认删除", isPresented: $showDeleteAlert) {
            Button("取消", role: .cancel) { }
            Button("删除", role: .destructive) {
                if let account = accountToDelete,
                   let index = savedAccounts.firstIndex(where: { $0.id == account.id }) {
                    savedAccounts.remove(at: index)
                    saveSavedAccounts()
                }
            }
        } message: {
            Text("确定要删除这个账号记录吗？")
        }
        .onAppear {
            loadSavedAccounts()
        }
    }
    
    private func copyToClipboard(_ text: String) {
        #if os(iOS)
        UIPasteboard.general.string = text
        #else
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(text, forType: .string)
        #endif
        
        showCopyToast = true
        // 2秒后隐藏提示
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            withAnimation {
                showCopyToast = false
            }
        }
    }
    
    private func loadSavedAccounts() {
        if let data = UserDefaults.standard.data(forKey: "savedOriginalAccounts"),
           let decoded = try? JSONDecoder().decode([SavedAccount].self, from: data) {
            savedAccounts = decoded
        }
    }
    
    private func saveSavedAccounts() {
        if let encoded = try? JSONEncoder().encode(savedAccounts) {
            UserDefaults.standard.set(encoded, forKey: "savedOriginalAccounts")
        }
    }
}

#Preview {
    NavigationView {
        AccountManagementView()
    }
} 