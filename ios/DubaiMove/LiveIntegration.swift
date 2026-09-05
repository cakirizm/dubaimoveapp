import SwiftUI
import UIKit
import UserNotifications

struct ServiceRequestCreateResponse: Codable, Identifiable {
    let id: String
    let serviceType: String?
    let status: String?
    let moveId: String?
}

struct ProvisionalBuildingDTO: Codable, Identifiable {
    let id: String
    let name: String
    let community: String?
    let confidence: String?
}

struct WebSocketTicketDTO: Codable {
    let ticket: String
    let expiresAt: String?
    let url: String?
}

extension DubaiMoveAPI {
    static func createServiceRequest(moveId: String?, serviceType: String, preferredDate: Date, notes: String, origin: String?, destination: String?) async throws -> ServiceRequestDTO {
        struct Body: Encodable {
            let moveId: String?
            let serviceType: String
            let preferredDate: String
            let notes: String
            let origin: String?
            let destination: String?
        }
        let formatter = ISO8601DateFormatter()
        return try await APIClient.shared.request(
            "service-requests",
            method: "POST",
            body: Body(moveId: moveId, serviceType: serviceType, preferredDate: formatter.string(from: preferredDate), notes: notes, origin: origin, destination: destination)
        )
    }

    static func createProvisionalBuilding(name: String, community: String) async throws -> BuildingDTO {
        struct Body: Encodable { let name: String; let community: String }
        return try await APIClient.shared.request("buildings/provisional", method: "POST", body: Body(name: name, community: community))
    }

    static func websocketTicket(conversationId: String) async throws -> WebSocketTicketDTO {
        try await APIClient.shared.request("conversations/\(conversationId)/ws-ticket", method: "POST")
    }
}

@MainActor
final class RealtimeChatStore: ObservableObject {
    @Published var messages: [MessageDTO] = []
    @Published var connected = false
    @Published var errorMessage: String?

    private var task: URLSessionWebSocketTask?
    private var conversationId: String?

    func connect(conversation: ConversationDTO) async {
        disconnect()
        conversationId = conversation.id
        do {
            messages = try await DubaiMoveAPI.messages(conversationId: conversation.id)
            let ticket = try await DubaiMoveAPI.websocketTicket(conversationId: conversation.id)
            guard let wsURL = resolvedWebSocketURL(ticket: ticket, conversationId: conversation.id) else {
                throw APIError.invalidURL
            }
            let socket = URLSession.shared.webSocketTask(with: wsURL)
            task = socket
            socket.resume()
            connected = true
            receiveLoop()
        } catch {
            errorMessage = error.localizedDescription
            connected = false
        }
    }

    func disconnect() {
        task?.cancel(with: .goingAway, reason: nil)
        task = nil
        connected = false
    }

    func send(_ text: String) async {
        guard let conversationId else { return }
        do {
            let message = try await DubaiMoveAPI.sendMessage(conversationId: conversationId, body: text)
            if !messages.contains(where: { $0.id == message.id }) { messages.append(message) }
        } catch { errorMessage = error.localizedDescription }
    }

    private func receiveLoop() {
        task?.receive { [weak self] result in
            Task { @MainActor in
                guard let self else { return }
                switch result {
                case .failure(let error):
                    self.connected = false
                    self.errorMessage = error.localizedDescription
                case .success(let message):
                    let data: Data?
                    switch message {
                    case .string(let text): data = text.data(using: .utf8)
                    case .data(let raw): data = raw
                    @unknown default: data = nil
                    }
                    if let data, let event = try? JSONDecoder().decode(MessageDTO.self, from: data), !self.messages.contains(where: { $0.id == event.id }) {
                        self.messages.append(event)
                    }
                    self.receiveLoop()
                }
            }
        }
    }

    private func resolvedWebSocketURL(ticket: WebSocketTicketDTO, conversationId: String) -> URL? {
        if let raw = ticket.url, var components = URLComponents(string: raw) {
            var items = components.queryItems ?? []
            if !items.contains(where: { $0.name == "ticket" }) { items.append(.init(name: "ticket", value: ticket.ticket)) }
            components.queryItems = items
            return components.url
        }
        guard let base = APIConfiguration.baseURL, var components = URLComponents(url: base, resolvingAgainstBaseURL: false) else { return nil }
        components.scheme = base.scheme == "https" ? "wss" : "ws"
        let prefix = base.path.hasSuffix("/") ? String(base.path.dropLast()) : base.path
        components.path = "\(prefix)/conversations/\(conversationId)/ws"
        components.queryItems = [.init(name: "ticket", value: ticket.ticket)]
        return components.url
    }
}

final class DubaiMoveAppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        UNUserNotificationCenter.current().delegate = self
        return true
    }

    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let token = deviceToken.map { String(format: "%02x", $0) }.joined()
        Task {
            guard APIConfiguration.isConnectedMode else { return }
            try? await DubaiMoveAPI.registerPushToken(token)
        }
    }

    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Push registration failed: \(error.localizedDescription)")
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.banner, .sound, .badge])
    }
}

@MainActor
enum PushRegistration {
    static func request() async {
        do {
            let granted = try await UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound])
            if granted { UIApplication.shared.registerForRemoteNotifications() }
        } catch { }
    }
}

struct ConnectedServicesView: View {
    @EnvironmentObject private var live: ConnectedDataStore

    var body: some View {
        List {
            if APIConfiguration.isConnectedMode {
                Section("LIVE MARKETPLACE") {
                    NavigationLink("My live requests (\(live.requests.count))", destination: LiveRequestsView())
                    NavigationLink("My bookings (\(live.bookings.count))", destination: LiveBookingsView())
                    NavigationLink("Messages (\(live.conversations.count))", destination: LiveConversationsView())
                }
            }
            Section("HOME SERVICES") {
                ForEach(Array(ServiceCategory.all.prefix(6))) { service in serviceLink(service) }
            }
            Section("GOVERNMENT, UTILITY & MOVE ADMIN") {
                ForEach(Array(ServiceCategory.all.dropFirst(6))) { service in serviceLink(service) }
            }
            Section("LOCATION & BUILDING") {
                NavigationLink("Search / confirm building", destination: ConnectedBuildingSearchView())
            }
            Section {
                Text("For regulated assistance, provider capability must be verified for the specific service. Official/government fees remain separate from provider fees.")
                    .font(.footnote).foregroundStyle(.secondary)
            }
        }
        .navigationTitle("Services")
        .task { if APIConfiguration.isConnectedMode && live.lastRefresh == nil { await live.refresh() } }
    }

    private func serviceLink(_ service: ServiceCategory) -> some View {
        NavigationLink(destination: ConnectedServiceRequestView(service: service)) {
            Label {
                VStack(alignment: .leading, spacing: 2) {
                    HStack {
                        Text(service.title).font(.headline)
                        if service.regulated { Text("VERIFIED").font(.caption2.bold()).foregroundStyle(DMTheme.green) }
                    }
                    Text(service.subtitle).font(.caption).foregroundStyle(.secondary)
                }
            } icon: { Image(systemName: service.icon).foregroundStyle(DMTheme.green) }
        }
    }
}

struct ConnectedServiceRequestView: View {
    @EnvironmentObject private var state: AppState
    @EnvironmentObject private var live: ConnectedDataStore
    let service: ServiceCategory
    @State private var date = Date().addingTimeInterval(7 * 86_400)
    @State private var notes = ""
    @State private var submitting = false
    @State private var created: ServiceRequestDTO?
    @State private var errorMessage: String?

    var body: some View {
        Form {
            Section {
                Label(service.title, systemImage: service.icon).font(.title2.bold())
                Text(service.subtitle).foregroundStyle(.secondary)
                LabeledContent("Mode", value: APIConfiguration.isConnectedMode ? "Connected" : "Demo")
            }
            if service.title == "Moving" {
                Section("Route") {
                    LabeledContent("From", value: "\(state.currentProperty.area) · \(state.currentProperty.name)")
                    LabeledContent("To", value: "\(state.newProperty.area) · \(state.newProperty.name)")
                }
            }
            Section("Request details") {
                DatePicker("Preferred date", selection: $date)
                TextField("Requirements / notes", text: $notes, axis: .vertical).lineLimit(3...7)
            }
            if service.regulated {
                Section("Protection") {
                    Text("Only providers verified for this service capability should receive the request. Dubai Move does not pretend to execute a government transaction itself.")
                        .font(.footnote).foregroundStyle(.secondary)
                }
            }
            if let errorMessage { Section { Text(errorMessage).foregroundStyle(.red) } }
            if let created {
                Section("Request created") {
                    LabeledContent("ID", value: String(created.id.prefix(10)))
                    LabeledContent("Status", value: created.status ?? "Submitted")
                    NavigationLink("Open quotes", destination: LiveQuotesView(request: created))
                }
            } else {
                Section {
                    Button(submitting ? "Submitting…" : "Request Quotes") { Task { await submit() } }
                        .disabled(submitting)
                }
            }
        }
        .navigationTitle(service.title)
    }

    private func submit() async {
        guard APIConfiguration.isConnectedMode else {
            errorMessage = "Connect a backend test URL to submit a real request. Demo mode does not fake a production request."
            return
        }
        submitting = true; errorMessage = nil
        defer { submitting = false }
        do {
            let moveId = live.moves.first?.id
            let request = try await DubaiMoveAPI.createServiceRequest(
                moveId: moveId,
                serviceType: service.title,
                preferredDate: date,
                notes: notes,
                origin: service.title == "Moving" ? state.currentProperty.name : nil,
                destination: service.title == "Moving" ? state.newProperty.name : nil
            )
            created = request
            live.requests.insert(request, at: 0)
        } catch { errorMessage = error.localizedDescription }
    }
}

struct ConnectedBuildingSearchView: View {
    @State private var query = ""
    @State private var community = ""
    @State private var results: [BuildingDTO] = []
    @State private var selected: BuildingDTO?
    @State private var loading = false
    @State private var errorMessage: String?

    var body: some View {
        List {
            Section("Search Dubai building") {
                TextField("Building name", text: $query)
                TextField("Community / area", text: $community)
                Button(loading ? "Searching…" : "Search") { Task { await search() } }
                    .disabled(loading || query.trimmingCharacters(in: .whitespaces).count < 2)
            }
            if let errorMessage { Section { Text(errorMessage).foregroundStyle(.red) } }
            if let selected {
                Section("Selected") {
                    Text(selected.name).font(.headline)
                    Text(selected.community ?? "Community not confirmed").foregroundStyle(.secondary)
                    LabeledContent("Source confidence", value: selected.confidence ?? "Unknown")
                }
            }
            if !results.isEmpty {
                Section("Results") {
                    ForEach(results) { building in
                        Button {
                            selected = building
                        } label: {
                            VStack(alignment: .leading) {
                                Text(building.name).foregroundStyle(.primary)
                                Text(building.community ?? "Unknown community").font(.caption).foregroundStyle(.secondary)
                            }
                        }
                    }
                }
            }
            Section("Can't find your building?") {
                Text("Create a provisional record. Permit, lift and cooling rules start as unknown and do not hard-block your move until verified.")
                    .font(.footnote).foregroundStyle(.secondary)
                Button("Create provisional building") { Task { await createProvisional() } }
                    .disabled(query.trimmingCharacters(in: .whitespaces).isEmpty)
            }
        }
        .navigationTitle("Building Search")
    }

    private func search() async {
        guard APIConfiguration.isConnectedMode else { errorMessage = "Backend test URL is not configured."; return }
        loading = true; errorMessage = nil
        defer { loading = false }
        do { results = try await DubaiMoveAPI.buildings(query: query) }
        catch { errorMessage = error.localizedDescription }
    }

    private func createProvisional() async {
        guard APIConfiguration.isConnectedMode else { errorMessage = "Backend test URL is not configured."; return }
        loading = true; errorMessage = nil
        defer { loading = false }
        do { selected = try await DubaiMoveAPI.createProvisionalBuilding(name: query, community: community) }
        catch { errorMessage = error.localizedDescription }
    }
}

struct ConnectedDocumentsTabView: View {
    @EnvironmentObject private var live: ConnectedDataStore
    var body: some View {
        LiveDocumentsView()
            .task { if APIConfiguration.isConnectedMode && live.lastRefresh == nil { await live.refresh() } }
    }
}

struct RealtimeConversationView: View {
    let conversation: ConversationDTO
    @StateObject private var store = RealtimeChatStore()
    @State private var draft = ""

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Circle().fill(store.connected ? Color.green : Color.orange).frame(width: 8, height: 8)
                Text(store.connected ? "Realtime connected" : "Realtime fallback")
                    .font(.caption).foregroundStyle(.secondary)
                Spacer()
            }.padding(.horizontal).padding(.top, 8)
            List(store.messages) { message in Text(message.body ?? "") }
            if let error = store.errorMessage { Text(error).font(.caption).foregroundStyle(.red).padding(.horizontal) }
            HStack {
                TextField("Message", text: $draft).textFieldStyle(.roundedBorder)
                Button("Send") {
                    let text = draft.trimmingCharacters(in: .whitespacesAndNewlines)
                    guard !text.isEmpty else { return }
                    draft = ""
                    Task { await store.send(text) }
                }
            }.padding()
        }
        .navigationTitle("Provider Chat")
        .task { await store.connect(conversation: conversation) }
        .onDisappear { store.disconnect() }
    }
}
