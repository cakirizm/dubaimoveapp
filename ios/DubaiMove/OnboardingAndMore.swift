import SwiftUI
import CryptoKit

// MARK: - Local account fallback for backend-free TestFlight

@MainActor
final class LocalAccountStore: ObservableObject {
    @Published private(set) var isAuthenticated: Bool
    @Published private(set) var displayName: String
    @Published var errorMessage: String?

    private let defaults = UserDefaults.standard
    private let authKey = "dubaimove.local.authenticated"
    private let nameKey = "dubaimove.local.account.name"
    private let emailKey = "dubaimove.local.account.email"
    private let phoneKey = "dubaimove.local.account.phone"
    private let passwordHashKey = "dubaimove.local.account.passwordHash"

    init() {
        isAuthenticated = defaults.bool(forKey: authKey)
        displayName = defaults.string(forKey: nameKey) ?? ""
    }

    var email: String { defaults.string(forKey: emailKey) ?? "" }
    var phone: String { defaults.string(forKey: phoneKey) ?? "" }
    var hasAccount: Bool { defaults.string(forKey: passwordHashKey) != nil }

    func register(name: String, email: String, phone: String, password: String) -> Bool {
        let cleanName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        let cleanEmail = email.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard cleanName.count >= 2 else { errorMessage = "Enter your full name."; return false }
        guard cleanEmail.contains("@"), cleanEmail.contains(".") else { errorMessage = "Enter a valid email address."; return false }
        guard password.count >= 6 else { errorMessage = "Password must contain at least 6 characters."; return false }

        defaults.set(cleanName, forKey: nameKey)
        defaults.set(cleanEmail, forKey: emailKey)
        defaults.set(phone.trimmingCharacters(in: .whitespacesAndNewlines), forKey: phoneKey)
        defaults.set(Self.hash(password), forKey: passwordHashKey)
        defaults.set(true, forKey: authKey)
        displayName = cleanName
        isAuthenticated = true
        errorMessage = nil
        return true
    }

    func login(identifier: String, password: String) -> Bool {
        guard hasAccount else { errorMessage = "No account exists on this TestFlight install yet. Create an account first."; return false }
        let clean = identifier.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        let storedEmail = email.lowercased()
        let storedPhone = phone.lowercased()
        guard clean == storedEmail || (!storedPhone.isEmpty && clean == storedPhone) else { errorMessage = "Email or mobile does not match this account."; return false }
        guard Self.hash(password) == defaults.string(forKey: passwordHashKey) else { errorMessage = "Incorrect password."; return false }
        defaults.set(true, forKey: authKey)
        displayName = defaults.string(forKey: nameKey) ?? ""
        isAuthenticated = true
        errorMessage = nil
        return true
    }

    func logout() {
        defaults.set(false, forKey: authKey)
        isAuthenticated = false
        errorMessage = nil
    }

    private static func hash(_ value: String) -> String {
        let digest = SHA256.hash(data: Data(value.utf8))
        return digest.map { String(format: "%02x", $0) }.joined()
    }
}

// MARK: - Animated launch

struct BrandLaunchView: View {
    @State private var reveal = false
    @State private var progress: CGFloat = 0.06

    var body: some View {
        ZStack {
            Image("BrandWelcome")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
                .scaleEffect(reveal ? 1.02 : 1.10)
                .animation(.easeOut(duration: 2.4), value: reveal)

            LinearGradient(
                colors: [.black.opacity(0.12), .clear, .black.opacity(0.72)],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer()
                Image("BrandLogo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 190, height: 190)
                    .scaleEffect(reveal ? 1 : 0.72)
                    .opacity(reveal ? 1 : 0)
                    .shadow(color: .black.opacity(0.28), radius: 24, y: 12)

                Text("Dubai Move")
                    .font(.system(size: 39, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                    .tracking(-1)
                    .opacity(reveal ? 1 : 0)
                    .offset(y: reveal ? 0 : 12)

                Text("Your move, organized.")
                    .font(.title3.weight(.semibold))
                    .foregroundStyle(Color(red: 0.93, green: 0.76, blue: 0.42))
                    .padding(.top, 5)
                    .opacity(reveal ? 1 : 0)

                Text("PLAN  ·  SETTLE  ·  LIVE BETTER")
                    .font(.caption2.bold())
                    .tracking(3.2)
                    .foregroundStyle(.white.opacity(0.72))
                    .padding(.top, 16)
                    .opacity(reveal ? 1 : 0)

                Spacer()

                VStack(spacing: 12) {
                    Text("A smoother new beginning in Dubai")
                        .font(.footnote.weight(.medium))
                        .foregroundStyle(.white.opacity(0.82))

                    GeometryReader { proxy in
                        ZStack(alignment: .leading) {
                            Capsule().fill(.white.opacity(0.20))
                            Capsule()
                                .fill(Color(red: 0.93, green: 0.76, blue: 0.42))
                                .frame(width: proxy.size.width * progress)
                        }
                    }
                    .frame(height: 4)
                    .frame(maxWidth: 220)
                }
                .padding(.bottom, 38)
            }
            .padding(.horizontal, 22)
        }
        .onAppear {
            withAnimation(.spring(response: 0.9, dampingFraction: 0.82).delay(0.15)) { reveal = true }
            withAnimation(.easeInOut(duration: 2.2)) { progress = 1 }
        }
    }
}

// MARK: - What are you doing?

struct BrandedEntryFlow: View {
    let connected: Bool
    @EnvironmentObject private var session: SessionStore
    @EnvironmentObject private var localAccount: LocalAccountStore
    @AppStorage("dubaimove.onboarding.completed") private var onboardingCompleted = false
    @AppStorage("dubaimove.v2.moveKind") private var moveKind = LocalMoveKind.withinDubai.rawValue
    @State private var stage: Stage = .intent

    enum Stage { case intent, auth }

    var body: some View {
        ZStack {
            DMTheme.page.ignoresSafeArea()
            switch stage {
            case .intent:
                JourneyIntentView(selection: $moveKind) {
                    withAnimation(.snappy) { stage = .auth }
                }
            case .auth:
                BrandedAuthView(connected: connected) {
                    onboardingCompleted = true
                } back: {
                    withAnimation(.snappy) { stage = .intent }
                }
                .environmentObject(session)
                .environmentObject(localAccount)
            }
        }
    }
}

struct JourneyIntentView: View {
    @Binding var selection: String
    let onContinue: () -> Void

    private let options: [(String, String, String, String)] = [
        (LocalMoveKind.withinDubai.rawValue, "Moving within Dubai", "Old home → move day → new home", "arrow.left.arrow.right.circle.fill"),
        (LocalMoveKind.toDubai.rawValue, "Moving to Dubai", "Set up your first home and essentials", "airplane.arrival"),
        (LocalMoveKind.leavingDubai.rawValue, "Leaving Dubai", "Close utilities, handover and refunds", "airplane.departure"),
        (LocalMoveKind.serviceOnly.rawValue, "I need a home service", "Moving, cleaning, painting or maintenance", "sparkles.rectangle.stack.fill")
    ]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                HStack {
                    Image("BrandLogo").resizable().scaledToFit().frame(width: 58, height: 58)
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Dubai Move").font(.title2.bold())
                        Text("Your move, organized.").font(.caption).foregroundStyle(.secondary)
                    }
                }
                .padding(.top, 16)

                VStack(alignment: .leading, spacing: 7) {
                    Text("What are you doing?")
                        .font(.system(size: 34, weight: .bold, design: .rounded))
                        .tracking(-0.8)
                    Text("We’ll build the right Dubai journey before you create or access your account.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                VStack(spacing: 12) {
                    ForEach(options, id: \.0) { option in
                        Button { selection = option.0 } label: {
                            HStack(spacing: 14) {
                                Image(systemName: option.3)
                                    .font(.title2.weight(.semibold))
                                    .foregroundStyle(selection == option.0 ? .white : DMTheme.green)
                                    .frame(width: 50, height: 50)
                                    .background(selection == option.0 ? DMTheme.green : DMTheme.mint)
                                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(option.1).font(.headline).foregroundStyle(DMTheme.ink)
                                    Text(option.2).font(.caption).foregroundStyle(.secondary)
                                }
                                Spacer()
                                Image(systemName: selection == option.0 ? "checkmark.circle.fill" : "circle")
                                    .foregroundStyle(selection == option.0 ? DMTheme.green : Color.secondary.opacity(0.45))
                                    .font(.title3)
                            }
                            .padding(15)
                            .background(DMTheme.card)
                            .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
                            .overlay(RoundedRectangle(cornerRadius: 22).stroke(selection == option.0 ? DMTheme.green.opacity(0.45) : DMTheme.border, lineWidth: selection == option.0 ? 1.5 : 1))
                            .shadow(color: DMTheme.shadow, radius: 12, y: 6)
                        }
                        .buttonStyle(.plain)
                    }
                }

                VStack(alignment: .leading, spacing: 8) {
                    Label("Official tasks open verified authority/provider channels", systemImage: "checkmark.shield.fill")
                    Label("Private move details stay scoped to your account and job", systemImage: "lock.fill")
                }
                .font(.caption)
                .foregroundStyle(.secondary)
                .padding(.vertical, 4)

                Button(action: onContinue) {
                    HStack {
                        Text("Continue")
                        Spacer()
                        Image(systemName: "arrow.right")
                    }
                    .font(.headline)
                    .foregroundStyle(.white)
                    .padding(.horizontal, 18)
                    .frame(height: 56)
                    .background(DMTheme.green)
                    .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                }
                .buttonStyle(.plain)
                .padding(.bottom, 22)
            }
            .padding(.horizontal, 18)
        }
    }
}

// MARK: - Branded login / registration

struct BrandedAuthView: View {
    let connected: Bool
    let onAuthenticated: () -> Void
    let back: () -> Void

    @EnvironmentObject private var session: SessionStore
    @EnvironmentObject private var localAccount: LocalAccountStore
    @State private var mode: Mode = .register
    @State private var name = ""
    @State private var email = ""
    @State private var phone = ""
    @State private var password = ""
    @State private var localBusy = false

    enum Mode: String, CaseIterable { case register = "Create Account", login = "Log In" }

    private var error: String? { connected ? session.errorMessage : localAccount.errorMessage }
    private var busy: Bool { connected ? session.isLoading : localBusy }

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                HStack {
                    Button(action: back) { Image(systemName: "chevron.left").font(.headline).frame(width: 44, height: 44).background(DMTheme.card).clipShape(Circle()) }
                    .buttonStyle(.plain)
                    Spacer()
                    Image("BrandLogo").resizable().scaledToFit().frame(width: 64, height: 64)
                    Spacer()
                    Color.clear.frame(width: 44, height: 44)
                }

                VStack(spacing: 6) {
                    Text(mode == .register ? "Create your Dubai Move account" : "Welcome back")
                        .font(.system(size: 29, weight: .bold, design: .rounded))
                        .multilineTextAlignment(.center)
                    Text(mode == .register ? "Save your journey and continue your move from one place." : "Continue exactly where you left your move.")
                        .font(.subheadline).foregroundStyle(.secondary).multilineTextAlignment(.center)
                }

                Picker("Account mode", selection: $mode) {
                    ForEach(Mode.allCases, id: \.self) { Text($0.rawValue).tag($0) }
                }
                .pickerStyle(.segmented)

                VStack(spacing: 12) {
                    if mode == .register {
                        field("Full name", icon: "person.fill", text: $name, contentType: .name)
                    }
                    field(mode == .login ? "Email or mobile" : "Email", icon: "envelope.fill", text: $email, contentType: .emailAddress)
                    if mode == .register {
                        field("UAE mobile (optional)", icon: "phone.fill", text: $phone, contentType: .telephoneNumber)
                    }
                    HStack(spacing: 12) {
                        Image(systemName: "lock.fill").foregroundStyle(DMTheme.green).frame(width: 22)
                        SecureField("Password", text: $password)
                            .textContentType(mode == .register ? .newPassword : .password)
                    }
                    .padding(.horizontal, 14)
                    .frame(height: 54)
                    .background(DMTheme.card)
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                    .overlay(RoundedRectangle(cornerRadius: 16).stroke(DMTheme.border, lineWidth: 1))
                }

                if let error, !error.isEmpty {
                    HStack(alignment: .top, spacing: 9) {
                        Image(systemName: "exclamationmark.triangle.fill")
                        Text(error)
                        Spacer()
                    }
                    .font(.footnote)
                    .foregroundStyle(.red)
                    .padding(12)
                    .background(Color.red.opacity(0.08))
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                }

                Button { Task { await submit() } } label: {
                    HStack {
                        if busy { ProgressView().tint(.white) }
                        Text(busy ? "Please wait…" : mode.rawValue)
                        Spacer()
                        if !busy { Image(systemName: "arrow.right") }
                    }
                    .font(.headline)
                    .foregroundStyle(.white)
                    .padding(.horizontal, 18)
                    .frame(height: 56)
                    .background(DMTheme.green)
                    .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                }
                .buttonStyle(.plain)
                .disabled(busy || email.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || password.isEmpty || (mode == .register && name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty))
                .opacity((busy || email.isEmpty || password.isEmpty || (mode == .register && name.isEmpty)) ? 0.58 : 1)

                VStack(spacing: 8) {
                    HStack(spacing: 6) {
                        Image(systemName: connected ? "network" : "iphone")
                        Text(connected ? "Connected account" : "TestFlight local account")
                    }
                    .font(.caption.bold())
                    .foregroundStyle(DMTheme.green)

                    Text(connected
                         ? "Account actions use the configured Dubai Move backend. Session tokens are handled by the secure connected session layer."
                         : "Until the public backend is connected, this TestFlight account stays on this iPhone. Your raw password is not stored; only a one-way hash is kept locally.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.horizontal, 8)

                Text("By continuing, you acknowledge Dubai Move is an operational guidance and services platform. Government or regulated transactions remain on official channels.")
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
                    .multilineTextAlignment(.center)
                    .padding(.bottom, 18)
            }
            .padding(.horizontal, 18)
            .padding(.top, 10)
        }
        .background(DMTheme.page.ignoresSafeArea())
        .onChange(of: mode) { _, _ in
            localAccount.errorMessage = nil
            password = ""
        }
    }

    @ViewBuilder
    private func field(_ placeholder: String, icon: String, text: Binding<String>, contentType: UITextContentType) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon).foregroundStyle(DMTheme.green).frame(width: 22)
            TextField(placeholder, text: text)
                .textContentType(contentType)
                .textInputAutocapitalization(contentType == .name ? .words : .never)
                .keyboardType(contentType == .telephoneNumber ? .phonePad : (contentType == .emailAddress ? .emailAddress : .default))
        }
        .padding(.horizontal, 14)
        .frame(height: 54)
        .background(DMTheme.card)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(DMTheme.border, lineWidth: 1))
    }

    private func submit() async {
        if connected {
            if mode == .login {
                await session.login(identifier: email.trimmingCharacters(in: .whitespacesAndNewlines), password: password)
            } else {
                await session.register(name: name.trimmingCharacters(in: .whitespacesAndNewlines), email: email.trimmingCharacters(in: .whitespacesAndNewlines), phone: phone.trimmingCharacters(in: .whitespacesAndNewlines), password: password)
            }
            if session.isAuthenticated { onAuthenticated() }
        } else {
            localBusy = true
            try? await Task.sleep(for: .milliseconds(320))
            let success: Bool
            if mode == .login {
                success = localAccount.login(identifier: email, password: password)
            } else {
                success = localAccount.register(name: name, email: email, phone: phone, password: password)
            }
            localBusy = false
            if success { onAuthenticated() }
        }
    }
}

// MARK: - Existing educational onboarding (kept for reset / legacy users)

struct OnboardingView: View {
    @Binding var completed: Bool
    @State private var step = 0
    @State private var situation = "Moving within Dubai"

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Spacer()
                Image("BrandLogo").resizable().scaledToFit().frame(width: 108, height: 108)
                VStack(spacing: 10) {
                    Text(stepTitle).font(.largeTitle.bold()).multilineTextAlignment(.center)
                    Text(stepBody).foregroundStyle(.secondary).multilineTextAlignment(.center)
                }.padding(.horizontal)
                if step == 2 {
                    Picker("Situation", selection: $situation) {
                        Text("Moving within Dubai").tag("Moving within Dubai")
                        Text("Moving to Dubai").tag("Moving to Dubai")
                        Text("Leaving Dubai").tag("Leaving Dubai")
                        Text("I only need a home service").tag("I only need a home service")
                        Text("Manage an existing property").tag("Manage an existing property")
                    }.pickerStyle(.menu).padding().background(DMTheme.card).clipShape(RoundedRectangle(cornerRadius: 16))
                }
                Spacer()
                HStack { ForEach(0..<4, id: \.self) { i in Capsule().fill(i == step ? DMTheme.green : .gray.opacity(0.25)).frame(width: i == step ? 28 : 8, height: 8) } }
                Button(step == 3 ? "Start Dubai Move" : "Continue") {
                    if step < 3 { step += 1 } else { completed = true }
                }.buttonStyle(.borderedProminent).tint(DMTheme.green).controlSize(.large)
            }.padding()
            .background(DMTheme.page.ignoresSafeArea())
        }
    }

    private var stepTitle: String { ["Move smarter in Dubai", "Know what to do next", "Tell us your situation", "Private by default"][step] }
    private var stepBody: String {
        [
            "One place for your move route, building requirements, utilities, providers, documents and money.",
            "Dubai Move builds a practical task order, shows blockers and sends you to official channels when an official action is required.",
            "Your plan changes depending on whether you are moving within Dubai, arriving, leaving, or only requesting a service.",
            "Home photos, documents and chats are not broadly shared. Provider access is scoped to the job and user-reviewed data."
        ][step]
    }
}

struct MoreView: View {
    @EnvironmentObject private var localAccount: LocalAccountStore

    var body: some View {
        List {
            if APIConfiguration.isConnectedMode {
                Section("Live backend") {
                    NavigationLink(destination: ConnectedWorkspaceView()) {
                        Label("Connected Workspace", systemImage: "network")
                    }
                    Text("Live moves, requests, quotes, bookings, messages and private documents from the configured backend.")
                        .font(.footnote).foregroundStyle(.secondary)
                }
            }
            Section("Account") {
                if !APIConfiguration.isConnectedMode {
                    if !localAccount.displayName.isEmpty { LabeledContent("Signed in", value: localAccount.displayName) }
                    if !localAccount.email.isEmpty { LabeledContent("Email", value: localAccount.email) }
                    Button("Log out", role: .destructive) { localAccount.logout() }
                }
            }
            Section("Complete app coverage") {
                NavigationLink(destination: OriginalScreenIndexView()) {
                    Label("Original U-001…U-094 Screens", systemImage: "rectangle.stack.fill")
                }
                Text("Screens restored from the first Dubai Move functional contract, including auth, properties, checklist, request lifecycle, booking, inventory, documents, money, profile and support.")
                    .font(.footnote).foregroundStyle(.secondary)
            }
            Section("Government & utilities") {
                link("Ejari", "doc.text.fill", .ejari); link("DEWA", "bolt.fill", .dewa); link("Cooling", "snowflake", .cooling); link("Telecom", "wifi", .telecom); link("Rental Increase Check", "percent", .rentalIncrease)
                NavigationLink("Utilities Hub", destination: OriginalAppCoverageView(screen: .utilitiesHub))
                NavigationLink("DEWA Status & Handoff", destination: OriginalAppCoverageView(screen: .dewaStatus))
            }
            Section("Building & move operations") {
                link("Building Intelligence", "building.2.fill", .building); link("Building Access Pack", "person.badge.key.fill", .buildingAccess); link("Move Map", "map.fill", .map); link("Move Day Live", "truck.box.fill", .moveDay); link("Smart Rescheduling", "calendar.badge.clock", .reschedule); link("Packing Labels", "tag.fill", .packingLabels)
                NavigationLink("Building Search", destination: OriginalAppCoverageView(screen: .buildingSearch))
                NavigationLink("Permit Requirements", destination: OriginalAppCoverageView(screen: .permitRequirements))
            }
            Section("Inspection, handover & money") {
                link("Move-in Inspection", "camera.fill", .moveInInspection); link("Move-out Inspection", "camera.viewfinder", .moveOutInspection); link("Condition Report", "doc.text.image", .conditionReport); link("Landlord Handover Pack", "doc.richtext.fill", .handover); link("Deposit Tracker", "banknote.fill", .deposit); link("Dispute Evidence", "doc.text.magnifyingglass", .disputeEvidence)
                NavigationLink("Old Home Dashboard", destination: OriginalAppCoverageView(screen: .oldHomeDashboard))
                NavigationLink("Refunds", destination: OriginalAppCoverageView(screen: .refunds))
            }
            Section("Relocation tools") {
                link("Leaving Dubai Center", "airplane.departure", .leavingDubai); link("New-home Starter Pack", "shippingbox.fill", .starterPack); link("Status Sharing", "link", .statusShare); link("Calendar Sync", "calendar", .calendar); link("Multi-property", "building.2.crop.circle", .multiProperty); link("Emergency Move", "exclamationmark.triangle.fill", .emergencyMove); link("Concierge", "person.crop.circle.badge.checkmark", .concierge); link("Corporate Relocation", "briefcase.fill", .corporateRelocation); link("Shared Move / Family", "person.2.fill", .family)
            }
            Section("Marketplace & protection") {
                link("Smart Provider Matching", "sparkles", .providerMatching); link("Quote Comparison", "arrow.left.arrow.right", .quoteComparison); link("Quote Protection", "shield.checkered", .quoteProtection); link("AI Video Inventory", "video.fill", .videoInventory)
                NavigationLink("Service Request Lifecycle", destination: OriginalAppCoverageView(screen: .requestDetail))
                NavigationLink("My Bookings", destination: OriginalAppCoverageView(screen: .bookings))
                NavigationLink("Review / Problem", destination: OriginalAppCoverageView(screen: .review))
            }
            Section("Account & safety") {
                link("AI Copilot", "sparkles", .aiCopilot); link("Notifications", "bell.fill", .notifications); link("Privacy & Security", "lock.shield.fill", .privacy); link("Offline & Sync", "arrow.triangle.2.circlepath", .offlineSync); link("Help & Support", "questionmark.circle.fill", .support)
                NavigationLink("Profile", destination: OriginalAppCoverageView(screen: .profile))
                NavigationLink("Notification Settings", destination: OriginalAppCoverageView(screen: .notificationSettings))
                NavigationLink("Support Ticket", destination: OriginalAppCoverageView(screen: .supportTicket))
            }
            Section { Text("Dubai Move provides practical assistance and official-source navigation. It does not give legal advice, decide legal responsibility, or impersonate government/regulatory services.").font(.footnote).foregroundStyle(.secondary) }
        }
        .navigationTitle("More & Move Tools")
        .navigationDestination(for: AppRoute.self) { FeatureRouter(route: $0) }
    }

    private func link(_ title: String, _ icon: String, _ route: AppRoute) -> some View { NavigationLink(value: route) { Label(title, systemImage: icon) } }
}
