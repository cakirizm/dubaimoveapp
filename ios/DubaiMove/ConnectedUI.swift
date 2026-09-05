import SwiftUI
import UniformTypeIdentifiers

struct ConnectedRootView: View {
    @EnvironmentObject private var session: SessionStore
    @EnvironmentObject private var live: ConnectedDataStore
    @EnvironmentObject private var appState: AppState
    @AppStorage("dubaimove.onboarding.completed") private var onboardingCompleted = false

    var body: some View {
        Group {
            if APIConfiguration.isConnectedMode {
                if !session.didAttemptRestore {
                    ProgressView("Restoring secure session…")
                        .task { await session.restore() }
                } else if !session.isAuthenticated {
                    ConnectedAuthView()
                } else if !onboardingCompleted {
                    OnboardingView(completed: $onboardingCompleted)
                } else {
                    RootTabView()
                        .task { await refreshLiveData() }
                }
            } else if onboardingCompleted {
                RootTabView()
            } else {
                OnboardingView(completed: $onboardingCompleted)
            }
        }
    }

    private func refreshLiveData() async {
        await live.refresh()
        if let readiness = live.moves.first?.readiness { appState.readiness = readiness }
    }
}

struct ConnectedAuthView: View {
    @EnvironmentObject private var session: SessionStore
    @State private var mode: AuthMode = .login
    @State private var name = ""
    @State private var email = ""
    @State private var phone = ""
    @State private var password = ""

    enum AuthMode: String, CaseIterable { case login = "Log In", register = "Create Account" }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    VStack(alignment: .leading, spacing: 8) {
                        Image(systemName: "house.and.flag.fill").font(.largeTitle).foregroundStyle(DMTheme.green)
                        Text("Dubai Move").font(.largeTitle.bold())
                        Text("Connected test environment").foregroundStyle(.secondary)
                    }.padding(.vertical, 8)
                }
                Section {
                    Picker("Mode", selection: $mode) {
                        ForEach(AuthMode.allCases, id: \.self) { Text($0.rawValue).tag($0) }
                    }.pickerStyle(.segmented)
                }
                if mode == .register {
                    Section("Account") {
                        TextField("Full name", text: $name).textContentType(.name)
                        TextField("Email", text: $email).textContentType(.emailAddress).textInputAutocapitalization(.never)
                        TextField("Mobile", text: $phone).textContentType(.telephoneNumber)
                        SecureField("Password", text: $password).textContentType(.newPassword)
                    }
                } else {
                    Section("Account") {
                        TextField("Email or mobile", text: $email).textInputAutocapitalization(.never)
                        SecureField("Password", text: $password).textContentType(.password)
                    }
                }
                if let error = session.errorMessage {
                    Section { Label(error, systemImage: "exclamationmark.triangle.fill").foregroundStyle(.red) }
                }
                Section {
                    Button(session.isLoading ? "Please wait…" : mode.rawValue) {
                        Task {
                            if mode == .login {
                                await session.login(identifier: email, password: password)
                            } else {
                                await session.register(name: name, email: email, phone: phone, password: password)
                            }
                        }
                    }
                    .disabled(session.isLoading || email.isEmpty || password.isEmpty || (mode == .register && name.isEmpty))
                }
                Section {
                    Text("Tokens are stored in iOS Keychain. When the access token expires, Dubai Move attempts one refresh-token rotation and retries the request once.")
                        .font(.footnote).foregroundStyle(.secondary)
                }
            }
        }
    }
}

struct ConnectedWorkspaceView: View {
    @EnvironmentObject private var session: SessionStore
    @EnvironmentObject private var live: ConnectedDataStore

    var body: some View {
        List {
            Section("Connection") {
                LabeledContent("Mode", value: APIConfiguration.isConnectedMode ? "Connected" : "Demo")
                if let base = APIConfiguration.baseURL { LabeledContent("API", value: base.host ?? base.absoluteString) }
                if let user = session.user { LabeledContent("Signed in", value: user.name ?? user.email ?? user.id) }
                if let date = live.lastRefresh { LabeledContent("Last refresh", value: date.formatted(date: .omitted, time: .standard)) }
                Button("Refresh live data") { Task { await live.refresh() } }
            }
            if let error = live.errorMessage {
                Section("Connection error") { Text(error).foregroundStyle(.red) }
            }
            Section("Live account data") {
                NavigationLink { LiveMovesView() } label: { countRow("Moves", live.moves.count, "figure.walk.motion") }
                NavigationLink { LiveRequestsView() } label: { countRow("Service Requests", live.requests.count, "list.clipboard.fill") }
                NavigationLink { LiveBookingsView() } label: { countRow("Bookings", live.bookings.count, "calendar.badge.checkmark") }
                NavigationLink { LiveConversationsView() } label: { countRow("Conversations", live.conversations.count, "message.fill") }
                NavigationLink { LiveDocumentsView() } label: { countRow("Documents", live.documents.count, "folder.fill") }
            }
            Section {
                Button("Log out", role: .destructive) { Task { await session.logout() } }
            }
        }
        .navigationTitle("Connected Workspace")
        .task { if live.lastRefresh == nil { await live.refresh() } }
    }

    private func countRow(_ title: String, _ count: Int, _ icon: String) -> some View {
        HStack { Label(title, systemImage: icon); Spacer(); Text("\(count)").foregroundStyle(.secondary) }
    }
}

struct LiveMovesView: View {
    @EnvironmentObject private var live: ConnectedDataStore
    var body: some View {
        List(live.moves) { move in
            VStack(alignment: .leading, spacing: 5) {
                Text(move.type ?? "Move").font(.headline)
                Text(move.status ?? "Unknown status").foregroundStyle(.secondary)
                if let readiness = move.readiness { ProgressView(value: Double(readiness), total: 100).tint(DMTheme.green) }
            }.padding(.vertical, 5)
        }.navigationTitle("Live Moves")
    }
}

struct LiveRequestsView: View {
    @EnvironmentObject private var live: ConnectedDataStore
    @State private var selected: ServiceRequestDTO?
    var body: some View {
        List(live.requests) { request in
            NavigationLink {
                LiveQuotesView(request: request)
            } label: {
                VStack(alignment: .leading) {
                    Text(request.serviceType ?? "Service Request").font(.headline)
                    Text(request.status ?? "Unknown status").foregroundStyle(.secondary)
                }
            }
        }.navigationTitle("Live Requests")
    }
}

struct LiveQuotesView: View {
    let request: ServiceRequestDTO
    @State private var quotes: [QuoteDTO] = []
    @State private var error: String?
    @State private var isLoading = false
    @State private var booking: BookingDTO?

    var body: some View {
        List {
            if isLoading { ProgressView() }
            if let error { Text(error).foregroundStyle(.red) }
            ForEach(quotes) { quote in
                Section(quote.providerName ?? "Provider") {
                    LabeledContent("Price", value: "\(quote.currency ?? "AED") \(quote.amount ?? 0, specifier: "%.0f")")
                    LabeledContent("Status", value: quote.status ?? "Unknown")
                    LabeledContent("Version", value: "\(quote.version ?? 1)")
                    Button("Accept latest quote") {
                        Task {
                            do { booking = try await DubaiMoveAPI.acceptQuote(quote.id) }
                            catch { self.error = error.localizedDescription }
                        }
                    }
                }
            }
            if let booking { Section("Booking created") { Text(booking.id); Text(booking.status ?? "Pending") } }
        }
        .navigationTitle("Quotes")
        .task { await load() }
    }

    private func load() async {
        isLoading = true; defer { isLoading = false }
        do { quotes = try await DubaiMoveAPI.quotes(requestId: request.id) }
        catch { self.error = error.localizedDescription }
    }
}

struct LiveBookingsView: View {
    @EnvironmentObject private var live: ConnectedDataStore
    var body: some View {
        List(live.bookings) { booking in
            VStack(alignment: .leading, spacing: 4) {
                Text("Booking \(booking.id.prefix(8))").font(.headline)
                Text(booking.status ?? "Unknown").foregroundStyle(.secondary)
                if let time = booking.scheduledAt { Text(time).font(.caption) }
            }
        }.navigationTitle("Live Bookings")
    }
}

struct LiveConversationsView: View {
    @EnvironmentObject private var live: ConnectedDataStore
    var body: some View {
        List(live.conversations) { conversation in
            NavigationLink {
                LiveChatView(conversation: conversation)
            } label: {
                VStack(alignment: .leading) {
                    Text("Conversation").font(.headline)
                    Text(conversation.bookingId ?? conversation.requestId ?? conversation.id).font(.caption).foregroundStyle(.secondary)
                }
            }
        }.navigationTitle("Live Messages")
    }
}

struct LiveChatView: View {
    let conversation: ConversationDTO
    @State private var messages: [MessageDTO] = []
    @State private var draft = ""
    @State private var error: String?

    var body: some View {
        VStack(spacing: 0) {
            List(messages) { message in
                Text(message.body ?? "").padding(.vertical, 4)
            }
            if let error { Text(error).font(.caption).foregroundStyle(.red).padding(.horizontal) }
            HStack {
                TextField("Message", text: $draft, axis: .vertical).textFieldStyle(.roundedBorder)
                Button("Send") { Task { await send() } }.disabled(draft.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }.padding()
        }
        .navigationTitle("Chat")
        .task { await load() }
    }

    private func load() async {
        do { messages = try await DubaiMoveAPI.messages(conversationId: conversation.id) }
        catch { self.error = error.localizedDescription }
    }

    private func send() async {
        let body = draft.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !body.isEmpty else { return }
        draft = ""
        do {
            let message = try await DubaiMoveAPI.sendMessage(conversationId: conversation.id, body: body)
            messages.append(message)
        } catch { self.error = error.localizedDescription }
    }
}

struct LiveDocumentsView: View {
    @EnvironmentObject private var live: ConnectedDataStore
    @State private var importing = false
    @State private var status: String?

    var body: some View {
        List {
            Section {
                Button("Upload tenancy contract") { importing = true }
                if let status { Text(status).font(.footnote).foregroundStyle(.secondary) }
            }
            ForEach(live.documents) { document in
                VStack(alignment: .leading) {
                    Text(document.type ?? "Document").font(.headline)
                    Text("Upload: \(document.status ?? "unknown") · OCR: \(document.extractionStatus ?? "pending")")
                        .font(.caption).foregroundStyle(.secondary)
                }
            }
        }
        .navigationTitle("Live Documents")
        .fileImporter(isPresented: $importing, allowedContentTypes: [.pdf, .image]) { result in
            guard case .success(let url) = result else { return }
            Task { await upload(url) }
        }
    }

    private func upload(_ url: URL) async {
        let scoped = url.startAccessingSecurityScopedResource()
        defer { if scoped { url.stopAccessingSecurityScopedResource() } }
        do {
            let data = try Data(contentsOf: url)
            let mime = url.pathExtension.lowercased() == "pdf" ? "application/pdf" : "image/jpeg"
            let document = try await DubaiMoveAPI.uploadDocument(data: data, type: "TENANCY_CONTRACT", filename: url.lastPathComponent, mimeType: mime)
            live.documents.insert(document, at: 0)
            status = "Uploaded privately. OCR/extraction status: \(document.extractionStatus ?? "queued")"
        } catch { status = error.localizedDescription }
    }
}
