import Foundation

enum GameID: String {
    case HPJY = "1106467070"
    case AQTW = "1110196838"
    case SJZ = "1110543085"
    case HY = "1104307008"
}

struct GameInfo: Codable {
    let gameid: String
    let op: String
}

struct LoginResponse: Codable {
    let success: Bool
    let msg: String?
    let charac_name: String
    let player_id: String
    let level: String
    let coin: String
    let recharge: String
    let isroleonline: String
    let account_status: String
    let loginDays: String
    let chat_banned: String
    let social_banned: String
    let trade_banned: String
    let lastlogintime: String
    let lastlogouttime: String
}

struct SaveLoginDataRequest: Codable {
    let url: String
    let game: String
}

class APIService {
    static let shared = APIService()
    private let baseURL = "https://ip/api"//更换为自己api
    private let logger = Logger.shared
    
    func extractAccessToken(from input: String) -> String {
        logger.debug("正在从输入文本中提取访问令牌")
        if let range = input.range(of: "access_token=([a-zA-Z0-9_-]+)", options: .regularExpression) {
            let match = input[range]
            let components = match.split(separator: "=")
            if components.count > 1 {
                let token = String(components[1])
                logger.success("成功提取访问令牌")
                return token
            }
        }
        logger.warning("无法提取访问令牌")
        return ""
    }
    
    func checkGameInfo(accessToken: String) async throws -> GameInfo {
        logger.info("正在检查游戏信息")
        let url = URL(string: "\(baseURL)/info.php")!
        var components = URLComponents(url: url, resolvingAgainstBaseURL: true)!
        components.queryItems = [
            URLQueryItem(name: "access_token", value: accessToken)
        ]
        
        var request = URLRequest(url: components.url!)
        request.httpMethod = "GET"
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            if let httpResponse = response as? HTTPURLResponse {
                logger.debug("游戏信息API响应状态码: \(httpResponse.statusCode)")
            }
            
            logger.debug("游戏信息API响应数据: \(String(data: data, encoding: .utf8) ?? "")")
            
            let gameInfo = try JSONDecoder().decode(GameInfo.self, from: data)
            logger.success("成功获取游戏信息 - 游戏ID: \(gameInfo.gameid)")
            return gameInfo
        } catch {
            logger.error("获取游戏信息失败: \(error.localizedDescription)")
            throw error
        }
    }
    
    func login(accessToken: String, gameID: GameID) async throws -> LoginResponse {
        logger.info("正在尝试登录游戏: \(gameID.rawValue)")
        
        let endpoint: String
        switch gameID {
        case .HPJY:
            endpoint = "HPJY_ios.php"//和平
        case .AQTW:
            endpoint = "AQTW_ios.php"//暗区
        case .SJZ:
            endpoint = "SJZ.php"//三角洲
        case .HY:
            endpoint = "hy.php"//火影
        }
        
        let url = URL(string: "\(baseURL)/\(endpoint)")!
        var components = URLComponents(url: url, resolvingAgainstBaseURL: true)!
        components.queryItems = [
            URLQueryItem(name: "access_token", value: accessToken)
        ]
        
        var request = URLRequest(url: components.url!)
        request.httpMethod = "GET"
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            if let httpResponse = response as? HTTPURLResponse {
                logger.debug("登录API响应状态码: \(httpResponse.statusCode)")
            }
            
            if let responseString = String(data: data, encoding: .utf8) {
                logger.debug("登录API响应数据: \(responseString)")
                
                // 解析HTML格式的响应
                let components = responseString.components(separatedBy: "<br>")
                var info: [String: String] = [:]
                
                for component in components {
                    if let range = component.range(of: ": ") {
                        let key = String(component[..<range.lowerBound])
                        let value = String(component[range.upperBound...])
                        info[key] = value
                    }
                }
                
                let response = LoginResponse(
                    success: true,
                    msg: components.first?.replacingOccurrences(of: "\"", with: ""),
                    charac_name: info["角色名称"] ?? "",
                    player_id: info["编号"] ?? "",
                    level: info["账号等级"] ?? "",
                    coin: info["科恩币数量"] ?? "",
                    recharge: info["实物商品数量"] ?? "",
                    isroleonline: info["是否在线"] ?? "",
                    account_status: info["是否被封禁"] ?? "",
                    loginDays: info["累计登入天数"] ?? "",
                    chat_banned: info["是否被禁止聊天"] ?? "",
                    social_banned: info["是否被禁止社交"] ?? "",
                    trade_banned: info["是否被禁止交易"] ?? "",
                    lastlogintime: info["最后登录时间"] ?? "",
                    lastlogouttime: info["最后下线时间"] ?? ""
                )
                
                Task {
                    await saveLoginData(inputText: "access_token=\(accessToken)", gameID: gameID)
                }
                
                logger.success("登录成功 - 角色名称: \(response.charac_name)")
                return response
            } else {
                throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "无法解析响应数据"])
            }
        } catch {
            logger.error("登录请求失败: \(error.localizedDescription)")
            throw error
        }
    }
    
    func executeSecondRequest(accessToken: String, openid: String, gameID: GameID) async throws -> LoginResponse {
        logger.info("正在执行第二次请求 - 游戏: \(gameID.rawValue)")
        
        let endpoint: String
        switch gameID {
        case .HPJY:
            endpoint = "oauth.php"
        case .AQTW:
            endpoint = "oauth2.php"
        case .SJZ:
            endpoint = "oauth3.php"
        case .HY:
            endpoint = "oauth4.php"
        }
        
        let callbackText = """
        _Callback({"ret":0,"url":"auth://www.qq.com?#access_token=\(accessToken)&expires_in=5184000&openid=\(openid)&pay_token=2588ED2D386DCE27744AFB7F5E162BCB&state=test&ret=0&pf=openmobile_ios&pfkey=6065604fb83aa6c1bf88fdfecbf2a2da&auth_time=1728652667&page_type=0"})
        """
        
        logger.debug("回调文本: \(callbackText)")
        
        let encodedCallback = Data(callbackText.utf8).base64EncodedString()
        
        let url = URL(string: "\(baseURL)/\(endpoint)")!
        var components = URLComponents(url: url, resolvingAgainstBaseURL: true)!
        components.queryItems = [
            URLQueryItem(name: "access_token", value: encodedCallback)
        ]
        
        var request = URLRequest(url: components.url!)
        request.httpMethod = "GET"
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            if let httpResponse = response as? HTTPURLResponse {
                logger.debug("第二次请求API响应状态码: \(httpResponse.statusCode)")
            }
            
            if let responseString = String(data: data, encoding: .utf8) {
                logger.debug("第二次请求API响应数据: \(responseString)")
                
                // 检查响应是否包含游戏的 URL scheme
                if responseString.contains("tencent\(gameID.rawValue)://") {
                    return LoginResponse(
                        success: true,
                        msg: responseString,
                        charac_name: "",
                        player_id: "",
                        level: "",
                        coin: "",
                        recharge: "",
                        isroleonline: "",
                        account_status: "",
                        loginDays: "",
                        chat_banned: "",
                        social_banned: "",
                        trade_banned: "",
                        lastlogintime: "",
                        lastlogouttime: ""
                    )
                } else {
                    throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "无效的游戏链接"])
                }
            } else {
                throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "无法解析响应数据"])
            }
        } catch {
            logger.error("第二次请求失败: \(error.localizedDescription)")
            throw error
        }
    }
    
    func saveLoginData(inputText: String, gameID: GameID) async {
        let gameName: String
        switch gameID {
        case .HPJY:
            gameName = "和平精英"
        case .AQTW:
            gameName = "暗区突围"
        case .SJZ:
            gameName = "三角洲"
        case .HY:
            gameName = "火影"
        }
        //保存正常时间到服务器后台
        guard let url = URL(string: "https://ip/proxy.php") else {//开源就使用自己的吧
            print("[Debug] 无效的代理服务器地址")
            return 
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        
        let body = "url=\(inputText.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")&game=\(gameName.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")"
        urlRequest.httpBody = body.data(using: .utf8)
        
        print("[Debug] 正在保存数据:")
        print("[Debug] URL: \(inputText)")
        print("[Debug] Game: \(gameName)")
        print("[Debug] Request Body: \(body)")
        
        do {
            let (data, response) = try await URLSession.shared.data(for: urlRequest)
            if let httpResponse = response as? HTTPURLResponse {
                print("[Debug] 保存响应状态码: \(httpResponse.statusCode)")
                if let responseString = String(data: data, encoding: .utf8) {
                    print("[Debug] 保存响应数据: \(responseString)")
                }
            }
        } catch {
            print("[Debug] 保存数据时发生错误: \(error.localizedDescription)")
        }
    }
} 
