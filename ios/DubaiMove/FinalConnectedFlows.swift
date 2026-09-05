import SwiftUI

struct ProductionEntryView: View {
    @EnvironmentObject private var session: SessionStore
    @EnvironmentObject private var live: ConnectedDataStore
    @EnvironmentObject private var appState: AppState
    @AppStorage("dubaimove.onboarding.completed") private var onboardingCompleted = false

    var body: some View {
        Group {
            if APIConfiguration.isConnectedMode {
                if !session.didAttemptRestore {
                    ProgressView("Restoring secure session…").task { await session.restore() }
                } else if !session.isAuthenticated {
                    ConnectedAuthView()
                } else if !onboardingCompleted {
                    OnboardingView(completed: $onboardingCompleted)
                } else {
                    ConnectedRootTabView().task { await refreshLiveData() }
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
        await PushRegistration.request()
    }
}

struct ConnectedRootTabView: View {
    @EnvironmentObject var state: AppState
    var body: some View {
        TabView(selection: $state.selectedTab) {
            NavigationStack { ConnectedHomeView() }.tag(MainTab.home).tabItem { Label("Home", systemImage: MainTab.home.icon) }
            NavigationStack { ConnectedMyMoveView() }.tag(MainTab.move).tabItem { Label("My Move", systemImage: MainTab.move.icon) }
            NavigationStack { ConnectedServicesView() }.tag(MainTab.services).tabItem { Label("Services", systemImage: MainTab.services.icon) }
            NavigationStack { ConnectedDocumentsTabView() }.tag(MainTab.documents).tabItem { Label("Documents", systemImage: MainTab.documents.icon) }
            NavigationStack { ConnectedMoneyView() }.tag(MainTab.money).tabItem { Label("Money", systemImage: MainTab.money.icon) }
        }.tint(DMTheme.green)
    }
}

struct ConnectedHomeView: View {
    @EnvironmentObject private var live: ConnectedDataStore
    @EnvironmentObject private var state: AppState

    private var move: MoveDTO? { live.moves.first }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Your Dubai move").font(.largeTitle.bold())
                        Text(APIConfiguration.isConnectedMode ? "Connected test environment" : "Demo mode").foregroundStyle(.secondary)
                    }
                    Spacer()
                    NavigationLink(destination: ConnectedMoreView()) { Image(systemName: "square.grid.3x3.fill").font(.title2) }
                }

                if let move {
                    VStack(alignment: .leading, spacing: 10) {
                        HStack { Text(move.type ?? "Active move").font(.title2.bold()); Spacer(); Text("\(move.readiness ?? state.readiness)%").font(.title.bold()).foregroundStyle(DMTheme.green) }
                        ProgressView(value: Double(move.readiness ?? state.readiness), total: 100).tint(DMTheme.green)
                        Text(move.status ?? "ACTIVE").font(.caption).foregroundStyle(.secondary)
                        NavigationLink("Open My Move", destination: ConnectedMyMoveView()).buttonStyle(.borderedProminent).tint(DMTheme.green)
                    }.dmCard(background: DMTheme.mint)
                } else {
                    ContentUnavailableView("No active move", systemImage: "figure.walk.motion", description: Text("The connected backend has not returned an active move yet."))
                        .dmCard()
                }

                Group {
                    NavigationLink(destination: ConnectedServicesView()) { homeRow("Services & quotes", "Create a request, compare quotes and book", "square.grid.2x2.fill") }
                    NavigationLink(destination: ConnectedDocumentsTabView()) { homeRow("Documents & contract", "Private upload, OCR and review", "folder.fill") }
                    NavigationLink(destination: ConnectedMoneyView()) { homeRow("Money & refunds", "Track local drafts until backend sync is available", "banknote.fill") }
                    NavigationLink(destination: ConnectedBuildingSearchView()) { homeRow("Building", "Search or create a provisional building", "building.2.fill") }
                    if let move { NavigationLink(destination: ConnectedOfficialServicesView(moveId: move.id, filter: "EJARI|DEWA|EMPOWER|EMICOOL")) { homeRow("Government & utilities", "Official handoff from backend registry", "checkmark.shield.fill") } }
                    NavigationLink(destination: ConnectedInspectionHubView()) { homeRow("Inspection & handover", "Capture user-confirmed condition records", "camera.viewfinder") }
                }.buttonStyle(.plain)

                if let error = live.errorMessage { Text(error).font(.footnote).foregroundStyle(.red).dmCard() }
            }.padding()
        }
        .background(Color(uiColor: .systemGroupedBackground))
        .refreshable { await live.refresh() }
        .task { if live.lastRefresh == nil { await live.refresh() }; if let r = move?.readiness { state.readiness = r } }
    }

    private func homeRow(_ title: String, _ subtitle: String, _ icon: String) -> some View {
        HStack(spacing: 14) {
            Image(systemName: icon).font(.title2).foregroundStyle(DMTheme.green).frame(width: 36)
            VStack(alignment: .leading, spacing: 3) { Text(title).font(.headline); Text(subtitle).font(.caption).foregroundStyle(.secondary) }
            Spacer(); Image(systemName: "chevron.right").foregroundStyle(.secondary)
        }.dmCard()
    }
}

struct LocalExpense: Codable, Identifiable {
    var id = UUID()
    var title: String
    var amount: Double
    var createdAt = Date()
}

@MainActor final class LocalMoneyStore: ObservableObject {
    @Published var expenses: [LocalExpense] = [] { didSet { save() } }
    @Published var refundNote: String = "" { didSet { UserDefaults.standard.set(refundNote, forKey: "dubaimove.refund.note") } }
    private let key = "dubaimove.money.expenses"
    init() {
        if let data = UserDefaults.standard.data(forKey: key), let decoded = try? JSONDecoder().decode([LocalExpense].self, from: data) { expenses = decoded }
        refundNote = UserDefaults.standard.string(forKey: "dubaimove.refund.note") ?? ""
    }
    func add(title: String, amount: Double) { expenses.insert(.init(title: title, amount: amount), at: 0) }
    func delete(at offsets: IndexSet) { expenses.remove(atOffsets: offsets) }
    private func save() { if let data = try? JSONEncoder().encode(expenses) { UserDefaults.standard.set(data, forKey: key) } }
}

struct ConnectedMoneyView: View {
    @StateObject private var store = LocalMoneyStore()
    @State private var showingAdd = false
    private var total: Double { store.expenses.reduce(0) { $0 + $1.amount } }

    var body: some View {
        List {
            Section {
                Text("AED \(total, specifier: "%.2f")").font(.largeTitle.bold())
                Label("Saved on this iPhone · pending backend sync", systemImage: "iphone.and.arrow.forward").font(.caption).foregroundStyle(.secondary)
            }
            Section("Expenses") {
                if store.expenses.isEmpty { Text("No expenses added yet").foregroundStyle(.secondary) }
                ForEach(store.expenses) { item in HStack { VStack(alignment: .leading) { Text(item.title); Text(item.createdAt.formatted(date: .abbreviated, time: .omitted)).font(.caption).foregroundStyle(.secondary) }; Spacer(); Text("AED \(item.amount, specifier: "%.2f")") } }
                    .onDelete(perform: store.delete)
                Button("Add expense") { showingAdd = true }
            }
            Section("Refund / deposit notes") {
                TextField("Deposit or refund follow-up", text: $store.refundNote, axis: .vertical).lineLimit(2...5)
                Text("This is a real local draft. Dubai Move does not claim server persistence until the exact backend sync contract is verified.").font(.footnote).foregroundStyle(.secondary)
            }
        }
        .navigationTitle("Money")
        .sheet(isPresented: $showingAdd) { AddExpenseSheet(store: store) }
    }
}

struct AddExpenseSheet: View {
    @ObservedObject var store: LocalMoneyStore
    @Environment(\.dismiss) private var dismiss
    @State private var title = ""
    @State private var amount = ""
    var body: some View {
        NavigationStack {
            Form { TextField("Expense", text: $title); TextField("Amount AED", text: $amount).keyboardType(.decimalPad) }
                .navigationTitle("Add Expense")
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } }
                    ToolbarItem(placement: .confirmationAction) { Button("Save") { if let value = Double(amount), value >= 0 { store.add(title: title, amount: value); dismiss() } }.disabled(title.trimmingCharacters(in: .whitespaces).isEmpty || Double(amount) == nil) }
                }
        }
    }
}

struct InspectionRecord: Codable, Identifiable {
    var id = UUID()
    var room: String
    var note: String
    var confirmed: Bool
    var createdAt = Date()
}

@MainActor final class InspectionDraftStore: ObservableObject {
    @Published var records: [InspectionRecord] = [] { didSet { save() } }
    private let key = "dubaimove.inspection.records"
    init() { if let data = UserDefaults.standard.data(forKey: key), let decoded = try? JSONDecoder().decode([InspectionRecord].self, from: data) { records = decoded } }
    func add(room: String, note: String, confirmed: Bool) { records.append(.init(room: room, note: note, confirmed: confirmed)) }
    private func save() { if let data = try? JSONEncoder().encode(records) { UserDefaults.standard.set(data, forKey: key) } }
}

struct ConnectedInspectionHubView: View {
    @StateObject private var store = InspectionDraftStore()
    @State private var room = "Living room"
    @State private var note = ""
    @State private var confirmed = false
    var body: some View {
        List {
            Section("Add condition record") {
                Picker("Room", selection: $room) { ForEach(["Living room","Kitchen","Bedroom","Bathroom","Balcony","Other"], id: \.self) { Text($0) } }
                TextField("Observation", text: $note, axis: .vertical).lineLimit(2...6)
                Toggle("I confirm this observation", isOn: $confirmed)
                Button("Save inspection record") { store.add(room: room, note: note, confirmed: confirmed); note = ""; confirmed = false }
                    .disabled(note.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
            Section("Condition summary") {
                if store.records.isEmpty { Text("No inspection records yet").foregroundStyle(.secondary) }
                ForEach(store.records) { record in VStack(alignment: .leading, spacing: 4) { HStack { Text(record.room).font(.headline); Spacer(); Image(systemName: record.confirmed ? "checkmark.seal.fill" : "sparkles").foregroundStyle(record.confirmed ? DMTheme.green : .orange) }; Text(record.note); Text(record.confirmed ? "User-confirmed" : "Draft / not confirmed").font(.caption).foregroundStyle(.secondary) }.padding(.vertical, 3) }
            }
            Section { Text("Only user-confirmed findings should be used as final condition evidence. AI suggestions are not treated as conclusive by themselves.").font(.footnote).foregroundStyle(.secondary) }
        }.navigationTitle("Inspection & Handover")
    }
}

struct ConnectedMoreView: View {
    @EnvironmentObject private var live: ConnectedDataStore
    @EnvironmentObject private var session: SessionStore
    var body: some View {
        List {
            Section("Live account") {
                NavigationLink("Requests", destination: LiveRequestsView())
                NavigationLink("Bookings", destination: LiveBookingsView())
                NavigationLink("Messages", destination: LiveConversationsView())
                NavigationLink("Documents", destination: LiveDocumentsView())
            }
            Section("Move tools") {
                NavigationLink("Building Search", destination: ConnectedBuildingSearchView())
                NavigationLink("Inspection & Handover", destination: ConnectedInspectionHubView())
                NavigationLink("Money", destination: ConnectedMoneyView())
            }
            Section("System") {
                NavigationLink("Connection status", destination: ConnectedWorkspaceView())
                NavigationLink("Privacy & sync behavior", destination: ConnectedSafetyView())
                Button("Enable notifications") { Task { await PushRegistration.request() } }
            }
            Section {
                Button("Refresh all live data") { Task { await live.refresh() } }
                Button("Log out", role: .destructive) { Task { await session.logout() } }
            }
        }.navigationTitle("More")
    }
}

struct ConnectedSafetyView: View {
    var body: some View {
        List {
            Section("Privacy") {
                Label("Private by default", systemImage: "lock.shield.fill")
                Text("Documents, photos and messages are not broadly shared. Provider access should stay scoped to the job.").font(.footnote)
            }
            Section("Offline / pending sync") {
                Text("When an exact backend contract is unavailable, Dubai Move keeps a local draft and labels it pending sync instead of pretending the server accepted it.").font(.footnote)
            }
            Section("Government boundary") {
                Text("Dubai Move prepares and tracks official handoffs but does not claim a government or utility transaction was completed unless a verified integration confirms it.").font(.footnote)
            }
        }.navigationTitle("Privacy & Sync")
    }
}
