import Foundation
import Security

struct APIConfiguration {
    static var baseURL: URL? {
        guard let raw = Bundle.main.object(forInfoDictionaryKey: "DUBAI_MOVE_API_BASE_URL") as? String,
              !raw.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
              let url = URL(string: raw) else { return nil }
        return url
    }

    static var isConnectedMode: Bool { baseURL != nil }
}

enum APIError: LocalizedError {
    case notConfigured
    case invalidURL
    case invalidResponse
    case unauthorized
    case server(status: Int, message: String?)
    case decoding(Error)
    case transport(Error)

    var errorDescription: String? {
        switch self {
        case .notConfigured: return "Backend URL is not configured."
        case .invalidURL: return "The API request URL is invalid."
        case .invalidResponse: return "Invalid server response."
        case .unauthorized: return "Your session has expired. Please sign in again."
        case .server(let status, let message): return message ?? "Server request failed (\(status))."
        case .decoding: return "The server response could not be read."
        case .transport(let error): return error.localizedDescription
        }
    }
}

struct EmptyResponse: Decodable {}

struct AuthTokens: Codable {
    let accessToken: String
    let refreshToken: String
}

struct UserDTO: Codable, Identifiable {
    let id: String
    let name: String?
    let email: String?
    let phone: String?
}

struct AuthResponse: Codable {
    let user: UserDTO
    let accessToken: String
    let refreshToken: String
}

struct MoveDTO: Codable, Identifiable {
    let id: String
    let type: String?
    let status: String?
    let readiness: Int?
    let moveDate: String?
}

struct BuildingDTO: Codable, Identifiable {
    let id: String
    let name: String
    let community: String?
    let confidence: String?
}

struct ServiceRequestDTO: Codable, Identifiable {
    let id: String
    let serviceType: String?
    let status: String?
    let moveId: String?
}

struct QuoteDTO: Codable, Identifiable {
    let id: String
    let requestId: String?
    let providerId: String?
    let providerName: String?
    let amount: Double?
    let currency: String?
    let status: String?
    let version: Int?
    let expiresAt: String?
}

struct BookingDTO: Codable, Identifiable {
    let id: String
    let requestId: String?
    let quoteId: String?
    let providerId: String?
    let status: String?
    let scheduledAt: String?
}

struct ConversationDTO: Codable, Identifiable {
    let id: String
    let requestId: String?
    let bookingId: String?
    let providerId: String?
}

struct MessageDTO: Codable, Identifiable {
    let id: String
    let conversationId: String?
    let senderId: String?
    let body: String?
    let createdAt: String?
}

struct DocumentUploadIntentDTO: Codable {
    let documentId: String
    let uploadURL: String
    let headers: [String: String]?
}

struct DocumentDTO: Codable, Identifiable {
    let id: String
    let type: String?
    let status: String?
    let extractionStatus: String?
}

actor TokenStore {
    static let shared = TokenStore()
    private let service = "com.dubaimove.app.auth"
    private let account = "tokens"

    func save(_ tokens: AuthTokens) throws {
        let data = try JSONEncoder().encode(tokens)
        let query: [String: Any] = [kSecClass as String: kSecClassGenericPassword,
                                    kSecAttrService as String: service,
                                    kSecAttrAccount as String: account]
        SecItemDelete(query as CFDictionary)
        var add = query
        add[kSecValueData as String] = data
        let status = SecItemAdd(add as CFDictionary, nil)
        guard status == errSecSuccess else { throw APIError.server(status: Int(status), message: "Unable to store secure session.") }
    }

    func load() -> AuthTokens? {
        let query: [String: Any] = [kSecClass as String: kSecClassGenericPassword,
                                    kSecAttrService as String: service,
                                    kSecAttrAccount as String: account,
                                    kSecReturnData as String: true,
                                    kSecMatchLimit as String: kSecMatchLimitOne]
        var result: AnyObject?
        guard SecItemCopyMatching(query as CFDictionary, &result) == errSecSuccess,
              let data = result as? Data else { return nil }
        return try? JSONDecoder().decode(AuthTokens.self, from: data)
    }

    func clear() {
        let query: [String: Any] = [kSecClass as String: kSecClassGenericPassword,
                                    kSecAttrService as String: service,
                                    kSecAttrAccount as String: account]
        SecItemDelete(query as CFDictionary)
    }
}

actor APIClient {
    static let shared = APIClient()
    private let session: URLSession
    private let decoder = JSONDecoder()
    private let encoder = JSONEncoder()
    private var refreshing = false

    init(session: URLSession = .shared) { self.session = session }

    func request<T: Decodable>(
        _ path: String,
        method: String = "GET",
        body: Encodable? = nil,
        authenticated: Bool = true,
        retryOn401: Bool = true
    ) async throws -> T {
        guard let base = APIConfiguration.baseURL else { throw APIError.notConfigured }
        guard let url = URL(string: path, relativeTo: base.appendingPathComponent("/"))?.absoluteURL else { throw APIError.invalidURL }
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        if authenticated, let access = await TokenStore.shared.load()?.accessToken {
            request.setValue("Bearer \(access)", forHTTPHeaderField: "Authorization")
        }
        if let body { request.httpBody = try encoder.encode(AnyEncodable(body)) }

        do {
            let (data, response) = try await session.data(for: request)
            guard let http = response as? HTTPURLResponse else { throw APIError.invalidResponse }
            if http.statusCode == 401, authenticated, retryOn401 {
                try await refreshSession()
                return try await self.request(path, method: method, body: body, authenticated: authenticated, retryOn401: false)
            }
            guard (200...299).contains(http.statusCode) else {
                let message = (try? JSONSerialization.jsonObject(with: data))
                    .flatMap { $0 as? [String: Any] }?["message"] as? String
                if http.statusCode == 401 { throw APIError.unauthorized }
                throw APIError.server(status: http.statusCode, message: message)
            }
            if T.self == EmptyResponse.self, data.isEmpty { return EmptyResponse() as! T }
            do { return try decoder.decode(T.self, from: data) }
            catch { throw APIError.decoding(error) }
        } catch let error as APIError { throw error }
        catch { throw APIError.transport(error) }
    }

    func upload(to signedURL: String, data: Data, mimeType: String, headers: [String: String] = [:]) async throws {
        guard let url = URL(string: signedURL) else { throw APIError.invalidURL }
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue(mimeType, forHTTPHeaderField: "Content-Type")
        headers.forEach { request.setValue($0.value, forHTTPHeaderField: $0.key) }
        let (_, response) = try await session.upload(for: request, from: data)
        guard let http = response as? HTTPURLResponse, (200...299).contains(http.statusCode) else { throw APIError.invalidResponse }
    }

    private func refreshSession() async throws {
        guard !refreshing else { throw APIError.unauthorized }
        guard let refresh = await TokenStore.shared.load()?.refreshToken else { throw APIError.unauthorized }
        refreshing = true
        defer { refreshing = false }
        struct RefreshBody: Encodable { let refreshToken: String }
        struct RefreshResponse: Decodable { let accessToken: String; let refreshToken: String }
        let result: RefreshResponse = try await request("auth/refresh", method: "POST", body: RefreshBody(refreshToken: refresh), authenticated: false, retryOn401: false)
        try await TokenStore.shared.save(.init(accessToken: result.accessToken, refreshToken: result.refreshToken))
    }
}

private struct AnyEncodable: Encodable {
    private let encodeClosure: (Encoder) throws -> Void
    init(_ wrapped: Encodable) { encodeClosure = wrapped.encode }
    func encode(to encoder: Encoder) throws { try encodeClosure(encoder) }
}

@MainActor
final class SessionStore: ObservableObject {
    @Published private(set) var user: UserDTO?
    @Published private(set) var isAuthenticated = false
    @Published private(set) var isLoading = false
    @Published private(set) var didAttemptRestore = false
    @Published var errorMessage: String?

    func restore() async {
        defer { didAttemptRestore = true }
        guard APIConfiguration.isConnectedMode else { return }
        guard await TokenStore.shared.load() != nil else { return }
        isLoading = true
        defer { isLoading = false }
        do {
            let me: UserDTO = try await APIClient.shared.request("auth/me")
            user = me
            isAuthenticated = true
        } catch {
            await TokenStore.shared.clear()
            isAuthenticated = false
        }
    }

    func login(identifier: String, password: String) async {
        struct Body: Encodable { let identifier: String; let password: String }
        isLoading = true; errorMessage = nil
        defer { isLoading = false }
        do {
            let response: AuthResponse = try await APIClient.shared.request("auth/login", method: "POST", body: Body(identifier: identifier, password: password), authenticated: false)
            try await TokenStore.shared.save(.init(accessToken: response.accessToken, refreshToken: response.refreshToken))
            user = response.user
            isAuthenticated = true
        } catch { errorMessage = error.localizedDescription }
    }

    func register(name: String, email: String, phone: String, password: String) async {
        struct Body: Encodable { let name: String; let email: String; let phone: String; let password: String }
        isLoading = true; errorMessage = nil
        defer { isLoading = false }
        do {
            let response: AuthResponse = try await APIClient.shared.request("auth/register", method: "POST", body: Body(name: name, email: email, phone: phone, password: password), authenticated: false)
            try await TokenStore.shared.save(.init(accessToken: response.accessToken, refreshToken: response.refreshToken))
            user = response.user
            isAuthenticated = true
        } catch { errorMessage = error.localizedDescription }
    }

    func logout() async {
        let _: EmptyResponse? = try? await APIClient.shared.request("auth/logout", method: "POST")
        await TokenStore.shared.clear()
        user = nil
        isAuthenticated = false
    }
}

@MainActor
final class ConnectedDataStore: ObservableObject {
    @Published var moves: [MoveDTO] = []
    @Published var requests: [ServiceRequestDTO] = []
    @Published var bookings: [BookingDTO] = []
    @Published var conversations: [ConversationDTO] = []
    @Published var documents: [DocumentDTO] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var lastRefresh: Date?

    func refresh() async {
        guard APIConfiguration.isConnectedMode else { return }
        isLoading = true; errorMessage = nil
        defer { isLoading = false }
        do {
            async let liveMoves = DubaiMoveAPI.moves()
            async let liveRequests = DubaiMoveAPI.serviceRequests()
            async let liveBookings = DubaiMoveAPI.bookings()
            async let liveConversations = DubaiMoveAPI.conversations()
            async let liveDocuments = DubaiMoveAPI.documents()
            (moves, requests, bookings, conversations, documents) = try await (liveMoves, liveRequests, liveBookings, liveConversations, liveDocuments)
            lastRefresh = Date()
        } catch { errorMessage = error.localizedDescription }
    }
}

enum DubaiMoveAPI {
    static func moves() async throws -> [MoveDTO] { try await APIClient.shared.request("moves") }
    static func buildings(query: String) async throws -> [BuildingDTO] {
        let escaped = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? query
        return try await APIClient.shared.request("buildings?query=\(escaped)")
    }
    static func serviceRequests() async throws -> [ServiceRequestDTO] { try await APIClient.shared.request("service-requests") }
    static func quotes(requestId: String) async throws -> [QuoteDTO] { try await APIClient.shared.request("service-requests/\(requestId)/quotes") }
    static func acceptQuote(_ quoteId: String) async throws -> BookingDTO { try await APIClient.shared.request("quotes/\(quoteId)/accept", method: "POST") }
    static func bookings() async throws -> [BookingDTO] { try await APIClient.shared.request("bookings") }
    static func conversations() async throws -> [ConversationDTO] { try await APIClient.shared.request("conversations") }
    static func messages(conversationId: String) async throws -> [MessageDTO] { try await APIClient.shared.request("conversations/\(conversationId)/messages") }
    static func sendMessage(conversationId: String, body: String) async throws -> MessageDTO {
        struct Body: Encodable { let body: String }
        return try await APIClient.shared.request("conversations/\(conversationId)/messages", method: "POST", body: Body(body: body))
    }
    static func documents() async throws -> [DocumentDTO] { try await APIClient.shared.request("documents") }
    static func createDocumentUpload(type: String, filename: String, mimeType: String) async throws -> DocumentUploadIntentDTO {
        struct Body: Encodable { let type: String; let filename: String; let mimeType: String }
        return try await APIClient.shared.request("documents/upload-intent", method: "POST", body: Body(type: type, filename: filename, mimeType: mimeType))
    }
    static func uploadDocument(data: Data, type: String, filename: String, mimeType: String) async throws -> DocumentDTO {
        let intent = try await createDocumentUpload(type: type, filename: filename, mimeType: mimeType)
        try await APIClient.shared.upload(to: intent.uploadURL, data: data, mimeType: mimeType, headers: intent.headers ?? [:])
        return try await confirmDocumentUpload(documentId: intent.documentId)
    }
    static func confirmDocumentUpload(documentId: String) async throws -> DocumentDTO { try await APIClient.shared.request("documents/\(documentId)/uploaded", method: "POST") }
    static func registerPushToken(_ token: String, platform: String = "ios") async throws {
        struct Body: Encodable { let token: String; let platform: String }
        let _: EmptyResponse = try await APIClient.shared.request("notifications/push-tokens", method: "POST", body: Body(token: token, platform: platform))
    }
}
