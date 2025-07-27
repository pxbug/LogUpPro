import SwiftUI

struct CustomTextArea: View {
    let title: String
    @Binding var text: String
    let placeholder: String
    let height: CGFloat
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)
                .foregroundColor(.primary)
            
            if #available(iOS 16.0, *) {
                TextEditor(text: $text)
                    .frame(height: height)
                    .scrollContentBackground(.hidden)
                    .padding(15)
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
                    .overlay(
                        Group {
                            if text.isEmpty {
                                Text(placeholder)
                                    .foregroundColor(.secondary)
                                    .padding(.horizontal, 20)
                                    .padding(.vertical, 12)
                            }
                        }
                    )
            } else {
                TextEditor(text: $text)
                    .frame(height: height)
                    .padding(15)
                    .background(
                        ZStack {
                            RoundedRectangle(cornerRadius: 15)
                                .fill(.ultraThinMaterial)
                            
                            RoundedRectangle(cornerRadius: 15)
                                .stroke(
                                    LinearGradient(
                                        colors: [.white.opacity(0.5), .white.opacity(0.2)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    lineWidth: 1
                                )
                        }
                    )
                    .overlay(
                        Group {
                            if text.isEmpty {
                                Text(placeholder)
                                    .foregroundColor(.secondary)
                                    .padding(.horizontal, 20)
                                    .padding(.vertical, 12)
                            }
                        }
                    )
            }
        }
    }
}

struct FeedbackView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var feedbackText = ""
    @State private var contactInfo = ""
    @State private var isSubmitting = false
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var isSuccess = false
    
    var body: some View {
        ZStack {
            // Background
            GlassMorphicBackground()
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 25) {
                    // Header Card
                    VStack(spacing: 10) {
                        Image(systemName: "exclamationmark.bubble.fill")
                            .font(.largeTitle)
                            .foregroundColor(.blue)
                        
                        Text("问题反馈")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Text("您的反馈对我们很重要")
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
                    
                    // Feedback Form
                    VStack(spacing: 20) {
                        CustomTextArea(
                            title: "问题描述",
                            text: $feedbackText,
                            placeholder: "请详细描述您遇到的问题...",
                            height: 150
                        )
                        
                        CustomTextArea(
                            title: "联系方式",
                            text: $contactInfo,
                            placeholder: "请留下您的QQ/邮箱/电话，方便我们联系您",
                            height: 80
                        )
                        
                        // Submit Button
                        Button(action: submitFeedback) {
                            HStack {
                                if isSubmitting {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                } else {
                                    Text("提交反馈")
                                        .fontWeight(.semibold)
                                }
                            }
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
                            .cornerRadius(15)
                        }
                        .disabled(feedbackText.isEmpty || isSubmitting)
                        .opacity(feedbackText.isEmpty ? 0.6 : 1)
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
                .padding()
            }
        }
        .navigationTitle("问题反馈")
        .navigationBarTitleDisplayMode(.inline)
        .alert(isSuccess ? "提交成功" : "提交失败", isPresented: $showAlert) {
            Button("确定") {
                if isSuccess {
                    dismiss()
                }
            }
        } message: {
            Text(alertMessage)
        }
    }
    
    private func submitFeedback() {
        guard !feedbackText.isEmpty else { return }
        isSubmitting = true
        
        let parameters = [
            "content": feedbackText,
            "contact": contactInfo
        ]
        
        guard let url = URL(string: "https://www.xn--fhq57lu5b.vip/api/feedback.php") else {//反馈后台api
            handleError("无效的URL")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: parameters)
        } catch {
            handleError("数据编码失败")
            return
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                isSubmitting = false
                
                if let error = error {
                    handleError("网络错误: \(error.localizedDescription)")
                    return
                }
                
                guard let httpResponse = response as? HTTPURLResponse else {
                    handleError("无效的响应")
                    return
                }
                
                if httpResponse.statusCode == 200 {
                    isSuccess = true
                    alertMessage = "感谢您的反馈，我们会尽快处理！"
                    showAlert = true
                } else {
                    handleError("服务器错误: \(httpResponse.statusCode)")
                }
            }
        }.resume()
    }
    
    private func handleError(_ message: String) {
        isSubmitting = false
        isSuccess = false
        alertMessage = message
        showAlert = true
    }
}

#Preview {
    NavigationView {
        FeedbackView()
    }
} 
