import SwiftUI
import UIKit

struct MoveTaskDTO: Codable, Identifiable {
    let id: String
    let title: String?
    let description: String?
    let status: String?
    let category: String?
    let priority: String?
    let blockedByTaskId: String?
    let dueAt: String?
}

struct PropertyDTO: Codable, Identifiable {
    let id: String
    let role: String?
    let buildingId: String?
    let buildingName: String?
    let community: String?
    let unit: String?
    let premiseNumber: String?
}

struct OfficialServiceDTO: Codable, Identifiable {
    let id: String
    let code: String?
    let authority: String?
    let title: String
    let description: String?
    let executionMode: String?
    let sourceUpdatedAt: String?
}

struct OfficialHandoffDTO: Codable, Identifiable {
    let id: String
    let serviceId: String?
    let status: String?
    let officialURL: String?
    let sourceVersion: String?
}

extension DubaiMoveAPI {
    static func moveTasks(moveId: String) async throws -> [MoveTaskDTO] {
        try await APIClient.shared.request("moves/\(moveId)/tasks")
    }

    static func updateMoveTask(moveId: String, taskId: String, status: String) async throws -> MoveTaskDTO {
        struct Body: Encodable { let status: String }
        return try await APIClient.shared.request("moves/\(moveId)/tasks/\(taskId)", method: "PATCH", body: Body(status: status))
    }

    static func properties(moveId: String) async throws -> [PropertyDTO] {
        try await APIClient.shared.request("moves/\(moveId)/properties")
    }

    static func upsertProperty(moveId: String, role: String, buildingId: String?, buildingName: String, community: String, unit: String, premiseNumber: String?) async throws -> PropertyDTO {
        struct Body: Encodable {
            let buildingId: String?
            let buildingName: String
            let community: String
            let unit: String
            let premiseNumber: String?
        }
        return try await APIClient.shared.request(
            "moves/\(moveId)/properties/\(role)",
            method: "PUT",
            body: Body(buildingId: buildingId, buildingName: buildingName, community: community, unit: unit, premiseNumber: premiseNumber)
        )
    }

    static func officialServices() async throws -> [OfficialServiceDTO] {
        try await APIClient.shared.request("official-services")
    }

    static func createOfficialHandoff(moveId: String, serviceId: String) async throws -> OfficialHandoffDTO {
        struct Body: Encodable { let moveId: String; let serviceId: String }
        return try await APIClient.shared.request("official-handoffs", method: "POST", body: Body(moveId: moveId, serviceId: serviceId))
    }

    static func markOfficialHandoffOpened(_ handoffId: String) async throws -> OfficialHandoffDTO {
        try await APIClient.shared.request("official-handoffs/\(handoffId)/open", method: "POST")
    }
}

@MainActor
final class ConnectedMoveStore: ObservableObject {
    @Published var tasks: [MoveTaskDTO] = []
    @Published var properties: [PropertyDTO] = []
    @Published var officialServices: [OfficialServiceDTO] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    func refresh(moveId: String) async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        do {
            async let liveTasks = DubaiMoveAPI.moveTasks(moveId: moveId)
            async let liveProperties = DubaiMoveAPI.properties(moveId: moveId)
            async let services = DubaiMoveAPI.officialServices()
            (tasks, properties, officialServices) = try await (liveTasks, liveProperties, services)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    var completedCount: Int { tasks.filter { ($0.status ?? "").uppercased() == "COMPLETED" }.count }
    var blockedCount: Int { tasks.filter { ($0.status ?? "").uppercased() == "BLOCKED" }.count }
}

struct ConnectedMyMoveView: View {
    @EnvironmentObject private var live: ConnectedDataStore
    @EnvironmentObject private var appState: AppState
    @StateObject private var store = ConnectedMoveStore()

    private var move: MoveDTO? { live.moves.first }

    var body: some View {
        List {
            if let move {
                Section {
                    VStack(alignment: .leading, spacing: 10) {
                        HStack {
                            VStack(alignment: .leading, spacing: 3) {
                                Text(move.type ?? "Dubai Move").font(.title2.bold())
                                Text(move.status ?? "Active").foregroundStyle(.secondary)
                            }
                            Spacer()
                            Text("\(move.readiness ?? appState.readiness)%").font(.title.bold()).foregroundStyle(DMTheme.green)
                        }
                        ProgressView(value: Double(move.readiness ?? appState.readiness), total: 100).tint(DMTheme.green)
                        Text("\(store.completedCount) completed · \(store.blockedCount) blocked").font(.caption).foregroundStyle(.secondary)
                    }.padding(.vertical, 6)
                }

                Section("Homes") {
                    NavigationLink("Current home", destination: ConnectedPropertyEditor(moveId: move.id, role: "current", initial: property(role: "current")))
                    NavigationLink("New home", destination: ConnectedPropertyEditor(moveId: move.id, role: "new", initial: property(role: "new")))
                    NavigationLink("Search / verify building", destination: ConnectedBuildingSearchView())
                }

                Section("Move checklist") {
                    if store.isLoading && store.tasks.isEmpty { ProgressView() }
                    ForEach(store.tasks) { task in
                        ConnectedMoveTaskRow(moveId: move.id, task: task) { updated in
                            if let index = store.tasks.firstIndex(where: { $0.id == updated.id }) { store.tasks[index] = updated }
                        }
                    }
                }

                Section("Government & utilities") {
                    NavigationLink("Ejari", destination: ConnectedOfficialServicesView(moveId: move.id, filter: "EJARI"))
                    NavigationLink("DEWA", destination: ConnectedOfficialServicesView(moveId: move.id, filter: "DEWA"))
                    NavigationLink("Cooling", destination: ConnectedOfficialServicesView(moveId: move.id, filter: "EMPOWER|EMICOOL"))
                }
            } else {
                ContentUnavailableView("No active move", systemImage: "figure.walk.motion", description: Text("Create or restore a move from the connected backend."))
            }

            if let error = store.errorMessage { Section { Text(error).foregroundStyle(.red) } }
        }
        .navigationTitle("My Move")
        .refreshable { await reload() }
        .task { await reload() }
    }

    private func property(role: String) -> PropertyDTO? {
        store.properties.first { ($0.role ?? "").lowercased() == role.lowercased() }
    }

    private func reload() async {
        guard let move else { return }
        await store.refresh(moveId: move.id)
        if let readiness = move.readiness { appState.readiness = readiness }
    }
}

struct ConnectedMoveTaskRow: View {
    let moveId: String
    let task: MoveTaskDTO
    let onUpdated: (MoveTaskDTO) -> Void
    @State private var busy = false
    @State private var errorMessage: String?

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .top) {
                Image(systemName: icon).foregroundStyle(color)
                VStack(alignment: .leading, spacing: 3) {
                    Text(task.title ?? "Move task").font(.headline)
                    if let description = task.description { Text(description).font(.caption).foregroundStyle(.secondary) }
                    HStack {
                        Text(task.status ?? "PENDING").font(.caption.bold())
                        if let priority = task.priority { Text(priority).font(.caption).foregroundStyle(.secondary) }
                    }
                }
                Spacer()
            }
            if canComplete {
                Button(busy ? "Updating…" : "Mark completed") {
                    Task {
                        busy = true
                        defer { busy = false }
                        do { onUpdated(try await DubaiMoveAPI.updateMoveTask(moveId: moveId, taskId: task.id, status: "COMPLETED")) }
                        catch { errorMessage = error.localizedDescription }
                    }
                }.disabled(busy)
            }
            if let errorMessage { Text(errorMessage).font(.caption).foregroundStyle(.red) }
        }.padding(.vertical, 4)
    }

    private var normalized: String { (task.status ?? "PENDING").uppercased() }
    private var canComplete: Bool { normalized != "COMPLETED" && normalized != "BLOCKED" }
    private var icon: String { normalized == "COMPLETED" ? "checkmark.circle.fill" : normalized == "BLOCKED" ? "lock.fill" : "circle" }
    private var color: Color { normalized == "COMPLETED" ? DMTheme.green : normalized == "BLOCKED" ? .red : .secondary }
}

struct ConnectedPropertyEditor: View {
    let moveId: String
    let role: String
    let initial: PropertyDTO?
    @State private var buildingName: String
    @State private var community: String
    @State private var unit: String
    @State private var premiseNumber: String
    @State private var saved: PropertyDTO?
    @State private var busy = false
    @State private var errorMessage: String?

    init(moveId: String, role: String, initial: PropertyDTO?) {
        self.moveId = moveId
        self.role = role
        self.initial = initial
        _buildingName = State(initialValue: initial?.buildingName ?? "")
        _community = State(initialValue: initial?.community ?? "")
        _unit = State(initialValue: initial?.unit ?? "")
        _premiseNumber = State(initialValue: initial?.premiseNumber ?? "")
    }

    var body: some View {
        Form {
            Section(role == "current" ? "Current home" : "New home") {
                TextField("Building", text: $buildingName)
                TextField("Community / area", text: $community)
                TextField("Unit", text: $unit)
                if role == "new" { TextField("DEWA premise number (if known)", text: $premiseNumber).keyboardType(.numberPad) }
                NavigationLink("Find building", destination: ConnectedBuildingSearchView())
            }
            if let errorMessage { Section { Text(errorMessage).foregroundStyle(.red) } }
            if let saved { Section { Label("Saved to move", systemImage: "checkmark.circle.fill").foregroundStyle(DMTheme.green); Text(saved.buildingName ?? buildingName) } }
            Section {
                Button(busy ? "Saving…" : "Save home") { Task { await save() } }
                    .disabled(busy || buildingName.trimmingCharacters(in: .whitespaces).isEmpty)
            }
        }.navigationTitle(role == "current" ? "Current Home" : "New Home")
    }

    private func save() async {
        busy = true; errorMessage = nil
        defer { busy = false }
        do {
            saved = try await DubaiMoveAPI.upsertProperty(
                moveId: moveId,
                role: role,
                buildingId: initial?.buildingId,
                buildingName: buildingName,
                community: community,
                unit: unit,
                premiseNumber: premiseNumber.isEmpty ? nil : premiseNumber
            )
        } catch { errorMessage = error.localizedDescription }
    }
}

struct ConnectedOfficialServicesView: View {
    let moveId: String
    let filter: String
    @State private var services: [OfficialServiceDTO] = []
    @State private var errorMessage: String?

    var body: some View {
        List {
            Section {
                Text("Official actions remain on the authority's approved channel. Dubai Move prepares, tracks and opens only backend-allowlisted official URLs.")
                    .font(.footnote).foregroundStyle(.secondary)
            }
            ForEach(filteredServices) { service in
                NavigationLink(destination: ConnectedOfficialHandoffView(moveId: moveId, service: service)) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(service.title).font(.headline)
                        Text(service.authority ?? "Official service").font(.caption).foregroundStyle(.secondary)
                        if let mode = service.executionMode { Text(mode.replacingOccurrences(of: "_", with: " ")).font(.caption2).foregroundStyle(DMTheme.green) }
                    }
                }
            }
            if let errorMessage { Section { Text(errorMessage).foregroundStyle(.red) } }
        }
        .navigationTitle(filter.contains("EJARI") ? "Ejari" : filter.contains("DEWA") ? "DEWA" : "Utilities")
        .task { await load() }
    }

    private var filteredServices: [OfficialServiceDTO] {
        let keys = filter.split(separator: "|").map { String($0).uppercased() }
        return services.filter { service in
            let haystack = "\(service.code ?? "") \(service.title) \(service.authority ?? "")".uppercased()
            return keys.contains { haystack.contains($0) }
        }
    }

    private func load() async {
        do { services = try await DubaiMoveAPI.officialServices() }
        catch { errorMessage = error.localizedDescription }
    }
}

struct ConnectedOfficialHandoffView: View {
    let moveId: String
    let service: OfficialServiceDTO
    @State private var handoff: OfficialHandoffDTO?
    @State private var busy = false
    @State private var errorMessage: String?

    var body: some View {
        Form {
            Section {
                Text(service.title).font(.title2.bold())
                if let description = service.description { Text(description).foregroundStyle(.secondary) }
                LabeledContent("Authority", value: service.authority ?? "Official authority")
                if let source = service.sourceUpdatedAt { LabeledContent("Source updated", value: source) }
            }
            Section("Safety boundary") {
                Text("Dubai Move does not claim the authority completed the transaction. Completion/status is tracked separately unless a verified direct integration exists.")
                    .font(.footnote).foregroundStyle(.secondary)
            }
            if let handoff {
                LabeledContent("Handoff status", value: handoff.status ?? "CREATED")
                Button("Open official channel") { Task { await open(handoff) } }
                    .buttonStyle(.borderedProminent).tint(DMTheme.green)
            } else {
                Button(busy ? "Preparing…" : "Prepare official handoff") { Task { await prepare() } }.disabled(busy)
            }
            if let errorMessage { Section { Text(errorMessage).foregroundStyle(.red) } }
        }.navigationTitle(service.title)
    }

    private func prepare() async {
        busy = true; errorMessage = nil
        defer { busy = false }
        do { handoff = try await DubaiMoveAPI.createOfficialHandoff(moveId: moveId, serviceId: service.id) }
        catch { errorMessage = error.localizedDescription }
    }

    private func open(_ current: OfficialHandoffDTO) async {
        do {
            let opened = try await DubaiMoveAPI.markOfficialHandoffOpened(current.id)
            handoff = opened
            guard let raw = opened.officialURL ?? current.officialURL, let url = URL(string: raw), url.scheme == "https" else {
                throw APIError.invalidURL
            }
            await MainActor.run { UIApplication.shared.open(url) }
        } catch { errorMessage = error.localizedDescription }
    }
}
