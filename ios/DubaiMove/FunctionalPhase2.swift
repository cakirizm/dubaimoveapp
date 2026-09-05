import SwiftUI
import UIKit
import UniformTypeIdentifiers
import QuickLook

// MARK: - Functional V2 root

struct FunctionalV2RootTabView: View {
    @EnvironmentObject private var state: AppState

    var body: some View {
        TabView(selection: $state.selectedTab) {
            NavigationStack { FunctionalV2HomeView() }
                .tag(MainTab.home)
                .tabItem { Label("Home", systemImage: MainTab.home.icon) }

            NavigationStack { FunctionalV2MoveCenterView() }
                .tag(MainTab.move)
                .tabItem { Label("My Move", systemImage: MainTab.move.icon) }

            NavigationStack { FunctionalV2ServicesView() }
                .tag(MainTab.services)
                .tabItem { Label("Services", systemImage: MainTab.services.icon) }

            NavigationStack { FunctionalV2DocumentsView() }
                .tag(MainTab.documents)
                .tabItem { Label("Documents", systemImage: MainTab.documents.icon) }

            NavigationStack { ConnectedMoneyView() }
                .tag(MainTab.money)
                .tabItem { Label("Money", systemImage: MainTab.money.icon) }
        }
        .tint(DMTheme.green)
    }
}

// MARK: - Local move profile and readiness

enum LocalMoveKind: String, CaseIterable, Identifiable {
    case withinDubai = "Within Dubai"
    case toDubai = "Moving to Dubai"
    case leavingDubai = "Leaving Dubai"
    case serviceOnly = "Service only"

    var id: String { rawValue }
}

struct FunctionalV2HomeView: View {
    @EnvironmentObject private var state: AppState
    @AppStorage("dubaimove.v2.currentBuilding") private var currentBuilding = ""
    @AppStorage("dubaimove.v2.newBuilding") private var newBuilding = ""
    @AppStorage("dubaimove.v2.moveKind") private var moveKind = LocalMoveKind.withinDubai.rawValue

    private var checklist: LocalChecklistSnapshot { LocalChecklistSnapshot.current }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Your Dubai move").font(.largeTitle.bold())
                        Text(moveKind).foregroundStyle(.secondary)
                    }
                    Spacer()
                    NavigationLink(destination: FunctionalV2MoreView()) {
                        Image(systemName: "square.grid.3x3.fill").font(.title2)
                    }
                    .accessibilityLabel("More")
                }

                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        Text("MOVE READINESS").font(.caption.bold()).foregroundStyle(.secondary)
                        Spacer()
                        Text("\(checklist.readiness)%").font(.title.bold()).foregroundStyle(DMTheme.green)
                    }
                    ProgressView(value: Double(checklist.readiness), total: 100).tint(DMTheme.green)
                    Text("\(checklist.completed) of \(checklist.total) core tasks completed")
                        .font(.caption).foregroundStyle(.secondary)
                    NavigationLink("Open checklist", destination: FunctionalV2MoveCenterView())
                        .buttonStyle(.borderedProminent).tint(DMTheme.green)
                }
                .dmCard(background: DMTheme.mint)
                .task { state.readiness = checklist.readiness }

                if currentBuilding.isEmpty || (moveKind == LocalMoveKind.withinDubai.rawValue && newBuilding.isEmpty) {
                    NavigationLink(destination: FunctionalV2MoveSetupView()) {
                        actionCard("Finish move setup", "Add homes and move date so tasks can be tailored", "house.badge.plus")
                    }
                    .buttonStyle(.plain)
                } else {
                    NavigationLink(destination: FunctionalV2MoveSetupView()) {
                        actionCard("\(currentBuilding) → \(newBuilding.isEmpty ? "Destination" : newBuilding)", "Review addresses and move date", "arrow.left.arrow.right")
                    }
                    .buttonStyle(.plain)
                }

                Text("Next actions").font(.title3.bold())
                NavigationLink(destination: EjariV2View()) {
                    actionCard("Ejari", "Register, renew, cancel or check using official DLD channels", "doc.text.fill")
                }.buttonStyle(.plain)
                NavigationLink(destination: DewaV2View()) {
                    actionCard("DEWA", "Move-In, Move-To and Move-Out are separate official journeys", "bolt.fill")
                }.buttonStyle(.plain)
                NavigationLink(destination: TelecomV2View()) {
                    actionCard("Internet & telecom", "du, e& and Virgin Mobile official routes", "wifi")
                }.buttonStyle(.plain)
                NavigationLink(destination: FunctionalV2LeavingDubaiView()) {
                    actionCard("Leaving Dubai", "Home exit, utilities, handover and official departure guidance", "airplane.departure")
                }.buttonStyle(.plain)

                Text("Move tools").font(.title3.bold())
                NavigationLink(destination: FunctionalV2ServicesView()) {
                    actionCard("Home services", "Create real local requests without fake provider quotes", "square.grid.2x2.fill")
                }.buttonStyle(.plain)
                NavigationLink(destination: ConnectedInspectionHubView()) {
                    actionCard("Inspection", "Record and confirm condition observations", "camera.viewfinder")
                }.buttonStyle(.plain)
                NavigationLink(destination: FunctionalV2HandoverView()) {
                    actionCard("Handover", "Track keys, final bills, cleaning and deposit", "key.fill")
                }.buttonStyle(.plain)
            }
            .padding()
        }
        .background(Color(uiColor: .systemGroupedBackground))
        .navigationTitle("Dubai Move")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func actionCard(_ title: String, _ subtitle: String, _ icon: String) -> some View {
        HStack(spacing: 14) {
            Image(systemName: icon).font(.title2).foregroundStyle(DMTheme.green).frame(width: 36)
            VStack(alignment: .leading, spacing: 3) {
                Text(title).font(.headline).foregroundStyle(.primary)
                Text(subtitle).font(.caption).foregroundStyle(.secondary)
            }
            Spacer()
            Image(systemName: "chevron.right").foregroundStyle(.secondary)
        }
        .dmCard()
    }
}

struct FunctionalV2MoveSetupView: View {
    @AppStorage("dubaimove.v2.moveKind") private var moveKind = LocalMoveKind.withinDubai.rawValue
    @AppStorage("dubaimove.v2.currentBuilding") private var currentBuilding = ""
    @AppStorage("dubaimove.v2.currentArea") private var currentArea = ""
    @AppStorage("dubaimove.v2.currentUnit") private var currentUnit = ""
    @AppStorage("dubaimove.v2.newBuilding") private var newBuilding = ""
    @AppStorage("dubaimove.v2.newArea") private var newArea = ""
    @AppStorage("dubaimove.v2.newUnit") private var newUnit = ""
    @AppStorage("dubaimove.v2.propertyType") private var propertyType = "Apartment"
    @AppStorage("dubaimove.v2.bedrooms") private var bedrooms = 1
    @AppStorage("dubaimove.v2.moveDate") private var moveDateEpoch = Date().addingTimeInterval(86400 * 21).timeIntervalSince1970

    private var moveDate: Binding<Date> {
        Binding(get: { Date(timeIntervalSince1970: moveDateEpoch) }, set: { moveDateEpoch = $0.timeIntervalSince1970 })
    }

    var body: some View {
        Form {
            Section("Journey") {
                Picker("What are you doing?", selection: $moveKind) {
                    ForEach(LocalMoveKind.allCases) { Text($0.rawValue).tag($0.rawValue) }
                }
                DatePicker("Target date", selection: moveDate, displayedComponents: [.date])
                Picker("Property", selection: $propertyType) {
                    ForEach(["Apartment", "Villa", "Townhouse", "Other"], id: \.self) { Text($0) }
                }
                Stepper("Bedrooms: \(bedrooms)", value: $bedrooms, in: 0...10)
            }

            if moveKind != LocalMoveKind.toDubai.rawValue && moveKind != LocalMoveKind.serviceOnly.rawValue {
                Section("Current home") {
                    TextField("Building / villa", text: $currentBuilding)
                    TextField("Area / community", text: $currentArea)
                    TextField("Unit", text: $currentUnit)
                }
            }

            if moveKind == LocalMoveKind.withinDubai.rawValue || moveKind == LocalMoveKind.toDubai.rawValue {
                Section("New home") {
                    TextField("Building / villa", text: $newBuilding)
                    TextField("Area / community", text: $newArea)
                    TextField("Unit", text: $newUnit)
                }
            }

            Section {
                Text("Changes are saved on this iPhone immediately. A connected backend can later sync this same move profile.")
                    .font(.footnote).foregroundStyle(.secondary)
            }
        }
        .navigationTitle("Move Setup")
    }
}

struct LocalChecklistSnapshot {
    let completed: Int
    let total: Int
    var readiness: Int { total == 0 ? 0 : Int((Double(completed) / Double(total) * 100).rounded()) }

    static var current: LocalChecklistSnapshot {
        let defaults = UserDefaults.standard
        let keys = LocalChecklistTask.allCases.map(\.storageKey)
        return .init(completed: keys.filter { defaults.bool(forKey: $0) }.count, total: keys.count)
    }
}

enum LocalChecklistTask: String, CaseIterable, Identifiable {
    case contract = "Tenancy contract"
    case ejari = "Ejari"
    case dewa = "DEWA"
    case internet = "Internet / telecom"
    case building = "Building permit / lift"
    case mover = "Moving service"
    case inspection = "Move-out inspection"
    case handover = "Keys & handover"

    var id: String { rawValue }
    var storageKey: String { "dubaimove.v2.task.\(String(describing: self))" }
}

struct FunctionalV2MoveCenterView: View {
    @EnvironmentObject private var state: AppState
    @AppStorage("dubaimove.v2.moveDate") private var moveDateEpoch = Date().addingTimeInterval(86400 * 21).timeIntervalSince1970
    @AppStorage("dubaimove.v2.task.contract") private var contractDone = false
    @AppStorage("dubaimove.v2.task.ejari") private var ejariDone = false
    @AppStorage("dubaimove.v2.task.dewa") private var dewaDone = false
    @AppStorage("dubaimove.v2.task.internet") private var internetDone = false
    @AppStorage("dubaimove.v2.task.building") private var buildingDone = false
    @AppStorage("dubaimove.v2.task.mover") private var moverDone = false
    @AppStorage("dubaimove.v2.task.inspection") private var inspectionDone = false
    @AppStorage("dubaimove.v2.task.handover") private var handoverDone = false

    private var completedCount: Int {
        [contractDone, ejariDone, dewaDone, internetDone, buildingDone, moverDone, inspectionDone, handoverDone].filter { $0 }.count
    }
    private var readiness: Int { Int((Double(completedCount) / 8.0 * 100).rounded()) }

    var body: some View {
        List {
            Section {
                VStack(alignment: .leading, spacing: 8) {
                    HStack { Text("Readiness").font(.headline); Spacer(); Text("\(readiness)%").font(.title2.bold()).foregroundStyle(DMTheme.green) }
                    ProgressView(value: Double(readiness), total: 100).tint(DMTheme.green)
                    Text("Target: \(Date(timeIntervalSince1970: moveDateEpoch).formatted(date: .abbreviated, time: .omitted))")
                        .font(.caption).foregroundStyle(.secondary)
                }.padding(.vertical, 4)
            }

            Section("Core checklist") {
                checklistRow("Tenancy contract", isOn: $contractDone, destination: AnyView(FunctionalV2DocumentsView()))
                checklistRow("Ejari", isOn: $ejariDone, destination: AnyView(EjariV2View()))
                checklistRow("DEWA", isOn: $dewaDone, destination: AnyView(DewaV2View()))
                checklistRow("Internet / telecom", isOn: $internetDone, destination: AnyView(TelecomV2View()))
                checklistRow("Building permit / lift", isOn: $buildingDone, destination: AnyView(FunctionalV2BuildingView()))
                checklistRow("Moving service", isOn: $moverDone, destination: AnyView(FunctionalV2ServicesView()))
                checklistRow("Move-out inspection", isOn: $inspectionDone, destination: AnyView(ConnectedInspectionHubView()))
                checklistRow("Keys & handover", isOn: $handoverDone, destination: AnyView(FunctionalV2HandoverView()))
            }

            Section("Planning") {
                NavigationLink("Edit move setup", destination: FunctionalV2MoveSetupView())
                NavigationLink("Reschedule move", destination: FunctionalV2RescheduleView())
                NavigationLink("Leaving Dubai Center", destination: FunctionalV2LeavingDubaiView())
            }
        }
        .navigationTitle("My Move")
        .onAppear { state.readiness = readiness }
        .onChange(of: completedCount) { _, _ in state.readiness = readiness }
    }

    private func checklistRow(_ title: String, isOn: Binding<Bool>, destination: AnyView) -> some View {
        HStack(spacing: 12) {
            Button {
                isOn.wrappedValue.toggle()
            } label: {
                Image(systemName: isOn.wrappedValue ? "checkmark.circle.fill" : "circle")
                    .foregroundStyle(isOn.wrappedValue ? DMTheme.green : .secondary)
                    .font(.title3)
            }
            .buttonStyle(.plain)
            NavigationLink(destination: destination) {
                Text(title).foregroundStyle(.primary)
            }
        }
    }
}

// MARK: - Verified official routing

enum OfficialV2Action: String, CaseIterable, Identifiable {
    case rentalIndex, ejariRegister, ejariCancel, ejariCertificate
    case dewaMoveIn, dewaMoveTo, dewaMoveOut
    case duHomeMove, etisalatSupport, virginMobile
    case empower, emicool
    case uaeResidence

    var id: String { rawValue }

    var title: String {
        switch self {
        case .rentalIndex: return "Dubai Rental Index"
        case .ejariRegister: return "Register / Renew Ejari"
        case .ejariCancel: return "Cancel Ejari"
        case .ejariCertificate: return "Download / Check Ejari"
        case .dewaMoveIn: return "DEWA Move-In"
        case .dewaMoveTo: return "DEWA Move-To"
        case .dewaMoveOut: return "DEWA Move-Out"
        case .duHomeMove: return "du Home Relocation"
        case .etisalatSupport: return "e& Home Move"
        case .virginMobile: return "Virgin Mobile UAE"
        case .empower: return "Empower Customer Services"
        case .emicool: return "Emicool Customer Services"
        case .uaeResidence: return "UAE Residence Cancellation Guidance"
        }
    }

    var authority: String {
        switch self {
        case .rentalIndex, .ejariRegister, .ejariCancel, .ejariCertificate: return "Dubai Land Department"
        case .dewaMoveIn, .dewaMoveTo, .dewaMoveOut: return "DEWA"
        case .duHomeMove: return "du"
        case .etisalatSupport: return "e& UAE"
        case .virginMobile: return "Virgin Mobile UAE"
        case .empower: return "Empower"
        case .emicool: return "Emicool"
        case .uaeResidence: return "UAE Government"
        }
    }

    var url: URL {
        let raw: String
        switch self {
        case .rentalIndex: raw = "https://dubailand.gov.ae/en/eservices/rental-index/rental-index"
        case .ejariRegister: raw = "https://dubailand.gov.ae/en/eservices/register-renew-ejari-contract/"
        case .ejariCancel: raw = "https://dubailand.gov.ae/en/eservices/request-for-cancellation-of-ejari-contract/"
        case .ejariCertificate: raw = "https://dubailand.gov.ae/en/eservices/download-ejari-certificate/"
        case .dewaMoveIn: raw = "https://www.dewa.gov.ae/en/consumer/supply-management/pre-login-activation-of-electricity-water-move-in"
        case .dewaMoveTo: raw = "https://www.dewa.gov.ae/en/consumer/supply-management/transfer-of-electricity-water-move-to"
        case .dewaMoveOut: raw = "https://www.dewa.gov.ae/en/consumer/supply-management/deactivation-of-electricity-water-move-out"
        case .duHomeMove: raw = "https://www.du.ae/personal/at-home/moving-to-a-new-home"
        case .etisalatSupport: raw = "https://www.etisalat.ae/en/c/support/home.html"
        case .virginMobile: raw = "https://www.virginmobile.ae/"
        case .empower: raw = "https://www.empower.ae/"
        case .emicool: raw = "https://www.emicool.com/en/customers"
        case .uaeResidence: raw = "https://u.ae/en/information-and-services/visa-and-emirates-id/Visa-information/general-provisions-for-the-residence-visa"
        }
        return URL(string: raw)!
    }

    var detail: String {
        switch self {
        case .rentalIndex: return "Official DLD reference. Dubai Move does not make a legal determination."
        case .ejariRegister: return "Official DLD Ejari registration / renewal service."
        case .ejariCancel: return "Official DLD Ejari cancellation service."
        case .ejariCertificate: return "Official DLD Ejari certificate route."
        case .dewaMoveIn: return "Activate electricity and water at the new premise."
        case .dewaMoveTo: return "Transfer your DEWA lifecycle from one Dubai premise to another."
        case .dewaMoveOut: return "Deactivate electricity and water, receive final bill and manage refund method."
        case .duHomeMove: return "Official du Home relocation service."
        case .etisalatSupport: return "e& Home support includes Home Move; the e& UAE app can submit a Home Move request."
        case .virginMobile: return "Virgin Mobile UAE is a mobile-service provider. Manage mobile service through its official app/account rather than treating it as fixed-home fibre."
        case .empower: return "Open Empower's official customer channel and choose the move/final-bill service applicable to your account."
        case .emicool: return "Open Emicool's official customer channel for the applicable move-in/move-out service."
        case .uaeResidence: return "Official UAE Government information; sponsorship/employment rules may apply."
        }
    }
}

struct OfficialV2ActionView: View {
    let action: OfficialV2Action
    @Environment(\.openURL) private var openURL

    var body: some View {
        Form {
            Section {
                Text(action.title).font(.title2.bold())
                Text(action.detail).foregroundStyle(.secondary)
                LabeledContent("Official provider", value: action.authority)
            }
            Section("External action") {
                Button("Open official channel") { openURL(action.url) }
                    .buttonStyle(.borderedProminent).tint(DMTheme.green)
                Text("Dubai Move opens the provider/authority channel but does not claim the external transaction is completed.")
                    .font(.footnote).foregroundStyle(.secondary)
            }
        }
        .navigationTitle(action.title)
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct EjariV2View: View {
    var body: some View {
        List {
            Section("Choose journey") {
                NavigationLink("Register / Renew", destination: OfficialV2ActionView(action: .ejariRegister))
                NavigationLink("Cancel", destination: OfficialV2ActionView(action: .ejariCancel))
                NavigationLink("Download / Check certificate", destination: OfficialV2ActionView(action: .ejariCertificate))
            }
            Section {
                Text("Requirements can differ by contract state and applicant role. Always review the official DLD requirements before submission.")
                    .font(.footnote).foregroundStyle(.secondary)
            }
        }
        .navigationTitle("Ejari")
    }
}

struct DewaV2View: View {
    var body: some View {
        List {
            Section("Choose journey") {
                NavigationLink("Move-In", destination: OfficialV2ActionView(action: .dewaMoveIn))
                NavigationLink("Move-To", destination: OfficialV2ActionView(action: .dewaMoveTo))
                NavigationLink("Move-Out", destination: OfficialV2ActionView(action: .dewaMoveOut))
            }
            Section("Move-To preparation") {
                Label("Existing contract account", systemImage: "number")
                Label("New Ejari", systemImage: "doc.text")
                Label("New 9-digit premise number", systemImage: "building.2")
                Label("Move-out and move-in dates", systemImage: "calendar")
            }
        }
        .navigationTitle("DEWA")
    }
}

struct TelecomV2View: View {
    var body: some View {
        List {
            Section("Home internet") {
                NavigationLink("du Home relocation", destination: OfficialV2ActionView(action: .duHomeMove))
                NavigationLink("e& Home Move", destination: OfficialV2ActionView(action: .etisalatSupport))
            }
            Section("Mobile service") {
                NavigationLink("Virgin Mobile UAE", destination: OfficialV2ActionView(action: .virginMobile))
            }
            Section {
                Text("Virgin Mobile is shown under mobile service, not as a fixed-fibre provider. Dubai Move does not invent availability for an address.")
                    .font(.footnote).foregroundStyle(.secondary)
            }
        }
        .navigationTitle("Internet & Telecom")
    }
}

struct CoolingV2View: View {
    @State private var provider = "Not sure"
    var body: some View {
        List {
            Section("Provider") {
                Picker("District cooling", selection: $provider) {
                    Text("Not sure").tag("Not sure")
                    Text("Empower").tag("Empower")
                    Text("Emicool").tag("Emicool")
                }
            }
            if provider == "Empower" {
                Section { NavigationLink("Open Empower", destination: OfficialV2ActionView(action: .empower)) }
            } else if provider == "Emicool" {
                Section { NavigationLink("Open Emicool", destination: OfficialV2ActionView(action: .emicool)) }
            } else {
                Section { Text("Confirm the district-cooling provider from the building management or latest bill before continuing.").font(.footnote).foregroundStyle(.secondary) }
            }
        }
        .navigationTitle("Cooling")
    }
}

// MARK: - Real local service request queue

struct LocalV2ServiceRequest: Codable, Identifiable {
    var id = UUID()
    var service: String
    var note: String
    var requestedDate: Date
    var createdAt = Date()
}

@MainActor
final class LocalV2ServiceStore: ObservableObject {
    @Published var requests: [LocalV2ServiceRequest] = [] { didSet { save() } }
    private let key = "dubaimove.v2.requests"

    init() {
        if let data = UserDefaults.standard.data(forKey: key), let saved = try? JSONDecoder().decode([LocalV2ServiceRequest].self, from: data) { requests = saved }
    }

    func add(service: String, note: String, date: Date) { requests.insert(.init(service: service, note: note, requestedDate: date), at: 0) }
    func delete(at offsets: IndexSet) { requests.remove(atOffsets: offsets) }
    private func save() { if let data = try? JSONEncoder().encode(requests) { UserDefaults.standard.set(data, forKey: key) } }
}

struct FunctionalV2ServicesView: View {
    @StateObject private var store = LocalV2ServiceStore()

    var body: some View {
        List {
            Section("Home services") {
                ForEach(Array(ServiceCategory.all.prefix(6))) { service in
                    NavigationLink(destination: FunctionalV2ServiceRequestForm(service: service, store: store)) {
                        Label {
                            VStack(alignment: .leading) {
                                Text(service.title).font(.headline)
                                Text(service.subtitle).font(.caption).foregroundStyle(.secondary)
                            }
                        } icon: { Image(systemName: service.icon).foregroundStyle(DMTheme.green) }
                    }
                }
            }
            Section("Move administration") {
                NavigationLink("Ejari", destination: EjariV2View())
                NavigationLink("DEWA", destination: DewaV2View())
                NavigationLink("Cooling", destination: CoolingV2View())
                NavigationLink("Internet / telecom", destination: TelecomV2View())
                NavigationLink("Building permit / lift", destination: FunctionalV2BuildingView())
            }
            Section("Saved requests") {
                if store.requests.isEmpty { Text("No local requests yet").foregroundStyle(.secondary) }
                ForEach(store.requests) { request in
                    VStack(alignment: .leading, spacing: 3) {
                        Text(request.service).font(.headline)
                        Text(request.requestedDate.formatted(date: .abbreviated, time: .shortened)).font(.caption)
                        if !request.note.isEmpty { Text(request.note).font(.caption).foregroundStyle(.secondary) }
                    }
                }
                .onDelete(perform: store.delete)
            }
            Section {
                Text("Until a public backend is configured, requests stay on this iPhone. Dubai Move does not fabricate live quotes or provider acceptance.")
                    .font(.footnote).foregroundStyle(.secondary)
            }
        }
        .navigationTitle("Services")
    }
}

struct FunctionalV2ServiceRequestForm: View {
    let service: ServiceCategory
    @ObservedObject var store: LocalV2ServiceStore
    @Environment(\.dismiss) private var dismiss
    @State private var note = ""
    @State private var date = Date().addingTimeInterval(86400 * 7)

    var body: some View {
        Form {
            Section { Label(service.title, systemImage: service.icon).font(.title2.bold()); Text(service.subtitle).foregroundStyle(.secondary) }
            Section("Request") {
                DatePicker("Preferred date", selection: $date, displayedComponents: [.date, .hourAndMinute])
                TextField("Scope / notes", text: $note, axis: .vertical).lineLimit(3...7)
            }
            Section {
                Button("Save request") { store.add(service: service.title, note: note, date: date); dismiss() }
                    .buttonStyle(.borderedProminent).tint(DMTheme.green)
            }
        }
        .navigationTitle(service.title)
    }
}

// MARK: - Real local document wallet

struct LocalV2Document: Codable, Identifiable {
    var id = UUID()
    var type: String
    var originalName: String
    var storedPath: String
    var addedAt = Date()
}

@MainActor
final class LocalV2DocumentStore: ObservableObject {
    @Published var items: [LocalV2Document] = [] { didSet { saveIndex() } }
    private let key = "dubaimove.v2.documents.index"

    init() {
        if let data = UserDefaults.standard.data(forKey: key), let saved = try? JSONDecoder().decode([LocalV2Document].self, from: data) { items = saved }
    }

    func importFile(from source: URL, type: String) throws {
        let scoped = source.startAccessingSecurityScopedResource()
        defer { if scoped { source.stopAccessingSecurityScopedResource() } }
        let folder = try documentFolder()
        let ext = source.pathExtension.isEmpty ? "dat" : source.pathExtension
        let destination = folder.appendingPathComponent("\(UUID().uuidString).\(ext)")
        try FileManager.default.copyItem(at: source, to: destination)
        items.insert(.init(type: type, originalName: source.lastPathComponent, storedPath: destination.path), at: 0)
    }

    func delete(at offsets: IndexSet) {
        for index in offsets { try? FileManager.default.removeItem(atPath: items[index].storedPath) }
        items.remove(atOffsets: offsets)
    }

    private func documentFolder() throws -> URL {
        let base = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
        let folder = base.appendingPathComponent("DubaiMoveDocuments", isDirectory: true)
        try FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
        return folder
    }

    private func saveIndex() { if let data = try? JSONEncoder().encode(items) { UserDefaults.standard.set(data, forKey: key) } }
}

struct FunctionalV2DocumentsView: View {
    @StateObject private var store = LocalV2DocumentStore()
    @State private var importing = false
    @State private var type = "Tenancy Contract"
    @State private var previewURL: URL?
    @State private var errorMessage: String?

    var body: some View {
        List {
            Section("Add document") {
                Picker("Type", selection: $type) {
                    ForEach(["Tenancy Contract", "Ejari", "DEWA", "Cooling", "Building Permit", "Provider", "Inspection", "Handover", "Receipt"], id: \.self) { Text($0) }
                }
                Button("Choose PDF / image") { importing = true }
            }
            Section("Private local wallet") {
                if store.items.isEmpty { Text("No documents saved yet").foregroundStyle(.secondary) }
                ForEach(store.items) { item in
                    Button {
                        let url = URL(fileURLWithPath: item.storedPath)
                        if FileManager.default.fileExists(atPath: url.path) { previewURL = url }
                    } label: {
                        HStack {
                            Image(systemName: "doc.fill").foregroundStyle(DMTheme.green)
                            VStack(alignment: .leading) {
                                Text(item.type).font(.headline).foregroundStyle(.primary)
                                Text(item.originalName).font(.caption).foregroundStyle(.secondary)
                            }
                            Spacer(); Image(systemName: "eye").foregroundStyle(.secondary)
                        }
                    }
                }
                .onDelete(perform: store.delete)
            }
            if let errorMessage { Section { Text(errorMessage).foregroundStyle(.red) } }
            Section { Text("Files are copied into Dubai Move's private app container on this iPhone. No cloud upload is claimed in backend-free TestFlight mode.").font(.footnote).foregroundStyle(.secondary) }
        }
        .navigationTitle("Documents")
        .fileImporter(isPresented: $importing, allowedContentTypes: [.pdf, .image]) { result in
            do {
                let url = try result.get()
                try store.importFile(from: url, type: type)
                errorMessage = nil
            } catch { errorMessage = error.localizedDescription }
        }
        .sheet(isPresented: Binding(get: { previewURL != nil }, set: { if !$0 { previewURL = nil } })) {
            if let previewURL { QuickLookPreview(url: previewURL) }
        }
    }
}

struct QuickLookPreview: UIViewControllerRepresentable {
    let url: URL
    func makeCoordinator() -> Coordinator { Coordinator(url: url) }
    func makeUIViewController(context: Context) -> QLPreviewController {
        let controller = QLPreviewController(); controller.dataSource = context.coordinator; return controller
    }
    func updateUIViewController(_ uiViewController: QLPreviewController, context: Context) {}
    final class Coordinator: NSObject, QLPreviewControllerDataSource {
        let url: URL
        init(url: URL) { self.url = url }
        func numberOfPreviewItems(in controller: QLPreviewController) -> Int { 1 }
        func previewController(_ controller: QLPreviewController, previewItemAt index: Int) -> QLPreviewItem { url as NSURL }
    }
}

// MARK: - Building, handover, leaving Dubai

struct FunctionalV2BuildingView: View {
    @AppStorage("dubaimove.v2.buildingPhone") private var phone = ""
    @AppStorage("dubaimove.v2.buildingEmail") private var email = ""
    @AppStorage("dubaimove.v2.buildingPortal") private var portal = ""
    @AppStorage("dubaimove.v2.buildingNotes") private var notes = ""
    @Environment(\.openURL) private var openURL

    var body: some View {
        Form {
            Section("Building management") {
                TextField("Phone", text: $phone).keyboardType(.phonePad)
                TextField("Email", text: $email).keyboardType(.emailAddress).textInputAutocapitalization(.never)
                TextField("Verified portal URL (optional)", text: $portal).textInputAutocapitalization(.never)
                Button("Call") { if let url = URL(string: "tel:\(phone.filter { "+0123456789".contains($0) })") { openURL(url) } }.disabled(phone.isEmpty)
                Button("Email") { if let url = URL(string: "mailto:\(email)") { openURL(url) } }.disabled(!email.contains("@"))
                Button("Open saved portal") {
                    guard let url = URL(string: portal), url.scheme == "https" else { return }
                    openURL(url)
                }
                .disabled(!(URL(string: portal)?.scheme == "https"))
            }
            Section("Permit / lift / loading") { TextField("Requirements and notes", text: $notes, axis: .vertical).lineLimit(4...10) }
            Section { Text("Dubai Move only opens a building portal after you or a verified backend has supplied an HTTPS address; it does not guess management portals.").font(.footnote).foregroundStyle(.secondary) }
        }
        .navigationTitle("Building Access")
    }
}

struct FunctionalV2HandoverView: View {
    @AppStorage("dubaimove.v2.handover.cleaning") private var cleaning = false
    @AppStorage("dubaimove.v2.handover.inspection") private var inspection = false
    @AppStorage("dubaimove.v2.handover.dewa") private var dewa = false
    @AppStorage("dubaimove.v2.handover.cooling") private var cooling = false
    @AppStorage("dubaimove.v2.handover.telecom") private var telecom = false
    @AppStorage("dubaimove.v2.handover.keys") private var keys = false
    @AppStorage("dubaimove.v2.handover.deposit") private var deposit = false
    @State private var pdfURL: URL?

    var body: some View {
        List {
            Section("Handover checklist") {
                Toggle("Final cleaning", isOn: $cleaning)
                Toggle("Move-out inspection", isOn: $inspection)
                Toggle("DEWA final bill / clearance", isOn: $dewa)
                Toggle("Cooling move-out", isOn: $cooling)
                Toggle("Telecom transfer / cancellation", isOn: $telecom)
                Toggle("Keys & access returned", isOn: $keys)
                Toggle("Deposit follow-up started", isOn: $deposit)
            }
            Section("Actions") {
                NavigationLink("Move-out inspection", destination: ConnectedInspectionHubView())
                NavigationLink("DEWA Move-Out", destination: OfficialV2ActionView(action: .dewaMoveOut))
                NavigationLink("Cooling", destination: CoolingV2View())
                NavigationLink("Internet / telecom", destination: TelecomV2View())
            }
            Section("Handover pack") {
                Button("Generate local PDF summary") { pdfURL = generatePDF() }
                if let pdfURL { ShareLink(item: pdfURL) { Label("Share PDF", systemImage: "square.and.arrow.up") } }
            }
        }
        .navigationTitle("Handover")
    }

    private func generatePDF() -> URL? {
        let url = FileManager.default.temporaryDirectory.appendingPathComponent("DubaiMove-Handover-\(UUID().uuidString).pdf")
        let renderer = UIGraphicsPDFRenderer(bounds: CGRect(x: 0, y: 0, width: 595, height: 842))
        do {
            try renderer.writePDF(to: url) { context in
                context.beginPage()
                let title = "Dubai Move – Handover Summary"
                title.draw(at: CGPoint(x: 48, y: 48), withAttributes: [.font: UIFont.boldSystemFont(ofSize: 22)])
                let rows = [
                    ("Final cleaning", cleaning), ("Move-out inspection", inspection), ("DEWA final bill / clearance", dewa),
                    ("Cooling move-out", cooling), ("Telecom transfer / cancellation", telecom), ("Keys & access returned", keys), ("Deposit follow-up", deposit)
                ]
                var y: CGFloat = 100
                for row in rows {
                    let text = "\(row.1 ? "✓" : "○")  \(row.0)"
                    text.draw(at: CGPoint(x: 48, y: y), withAttributes: [.font: UIFont.systemFont(ofSize: 15)])
                    y += 28
                }
                "Generated locally by Dubai Move. External utility/government completion is not inferred.".draw(in: CGRect(x: 48, y: y + 20, width: 500, height: 100), withAttributes: [.font: UIFont.systemFont(ofSize: 11), .foregroundColor: UIColor.secondaryLabel])
            }
            return url
        } catch { return nil }
    }
}

struct FunctionalV2LeavingDubaiView: View {
    var body: some View {
        List {
            Section { Text("Leaving Dubai").font(.largeTitle.bold()); Text("Home exit and UAE departure are handled as separate journeys.").foregroundStyle(.secondary) }
            Section("Home exit") {
                NavigationLink("Ejari cancellation", destination: OfficialV2ActionView(action: .ejariCancel))
                NavigationLink("DEWA Move-Out", destination: OfficialV2ActionView(action: .dewaMoveOut))
                NavigationLink("Cooling Move-Out", destination: CoolingV2View())
                NavigationLink("Internet / telecom", destination: TelecomV2View())
                NavigationLink("Move-out inspection", destination: ConnectedInspectionHubView())
                NavigationLink("Cleaning", destination: FunctionalV2ServicesView())
                NavigationLink("Keys & handover", destination: FunctionalV2HandoverView())
                NavigationLink("Deposit / refunds", destination: ConnectedMoneyView())
            }
            Section("UAE departure") {
                NavigationLink("Residence cancellation guidance", destination: OfficialV2ActionView(action: .uaeResidence))
                NavigationLink("Mobile service", destination: OfficialV2ActionView(action: .virginMobile))
            }
            Section { Text("Visa and work-permit cancellation can depend on sponsorship/employment circumstances. Dubai Move provides official guidance, not immigration or legal advice.").font(.footnote).foregroundStyle(.secondary) }
        }
        .navigationTitle("Leaving Dubai")
    }
}

// MARK: - Reschedule, support, privacy and more

struct FunctionalV2RescheduleView: View {
    @AppStorage("dubaimove.v2.moveDate") private var moveDateEpoch = Date().addingTimeInterval(86400 * 21).timeIntervalSince1970
    private var dateBinding: Binding<Date> { Binding(get: { Date(timeIntervalSince1970: moveDateEpoch) }, set: { moveDateEpoch = $0.timeIntervalSince1970 }) }

    var body: some View {
        Form {
            Section("New move date") { DatePicker("Move date", selection: dateBinding, displayedComponents: .date) }
            Section("Review affected items") {
                NavigationLink("Mover / home services", destination: FunctionalV2ServicesView())
                NavigationLink("Building permit / lift", destination: FunctionalV2BuildingView())
                NavigationLink("DEWA", destination: DewaV2View())
                NavigationLink("Internet", destination: TelecomV2View())
                NavigationLink("Cleaning", destination: FunctionalV2ServicesView())
            }
            Section { Text("Changing the date here never silently changes an external booking or government/utility request. Each external item must be reviewed separately.").font(.footnote).foregroundStyle(.secondary) }
        }
        .navigationTitle("Reschedule")
    }
}

struct LocalSupportTicket: Codable, Identifiable {
    var id = UUID(); var category: String; var message: String; var createdAt = Date()
}

@MainActor final class LocalSupportStore: ObservableObject {
    @Published var tickets: [LocalSupportTicket] = [] { didSet { save() } }
    private let key = "dubaimove.v2.support"
    init() { if let data = UserDefaults.standard.data(forKey: key), let saved = try? JSONDecoder().decode([LocalSupportTicket].self, from: data) { tickets = saved } }
    func add(category: String, message: String) { tickets.insert(.init(category: category, message: message), at: 0) }
    private func save() { if let data = try? JSONEncoder().encode(tickets) { UserDefaults.standard.set(data, forKey: key) } }
}

struct FunctionalV2SupportView: View {
    @StateObject private var store = LocalSupportStore()
    @State private var category = "App issue"
    @State private var message = ""
    @State private var saved = false

    var body: some View {
        Form {
            Section("New ticket") {
                Picker("Category", selection: $category) { ForEach(["App issue", "Service request", "Government link", "Building info", "Other"], id: \.self) { Text($0) } }
                TextField("Describe the issue", text: $message, axis: .vertical).lineLimit(4...10)
                Button(saved ? "Saved" : "Save support ticket") { store.add(category: category, message: message); saved = true; message = "" }.disabled(message.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
            Section("Saved tickets") {
                if store.tickets.isEmpty { Text("No tickets yet").foregroundStyle(.secondary) }
                ForEach(store.tickets) { ticket in VStack(alignment: .leading) { Text(ticket.category).font(.headline); Text(ticket.message); Text(ticket.createdAt.formatted()).font(.caption).foregroundStyle(.secondary) } }
            }
            Section { Text("In backend-free TestFlight mode this is a local support draft. It is not presented as submitted to a server.").font(.footnote).foregroundStyle(.secondary) }
        }
        .navigationTitle("Support")
    }
}

struct FunctionalV2StatusShareView: View {
    @AppStorage("dubaimove.v2.currentBuilding") private var currentBuilding = ""
    @AppStorage("dubaimove.v2.newBuilding") private var newBuilding = ""
    @AppStorage("dubaimove.v2.moveDate") private var moveDateEpoch = Date().timeIntervalSince1970

    private var summary: String {
        let readiness = LocalChecklistSnapshot.current.readiness
        return "Dubai Move status\nRoute: \(currentBuilding.isEmpty ? "Current home" : currentBuilding) → \(newBuilding.isEmpty ? "Destination" : newBuilding)\nMove date: \(Date(timeIntervalSince1970: moveDateEpoch).formatted(date: .abbreviated, time: .omitted))\nReadiness: \(readiness)%\n\nShared manually by the user. Documents, photos, chats and phone number are not included."
    }

    var body: some View {
        Form {
            Section("Included") { Label("Route", systemImage: "checkmark.circle.fill"); Label("Move date", systemImage: "checkmark.circle.fill"); Label("Readiness percentage", systemImage: "checkmark.circle.fill") }
            Section("Excluded") { Label("Documents", systemImage: "xmark.circle"); Label("Photos", systemImage: "xmark.circle"); Label("Chats", systemImage: "xmark.circle"); Label("Phone number", systemImage: "xmark.circle") }
            Section { ShareLink(item: summary) { Label("Share status summary", systemImage: "square.and.arrow.up") } }
            Section { Text("A public revocable status URL requires the connected backend. This TestFlight mode shares only the text you explicitly choose to share.").font(.footnote).foregroundStyle(.secondary) }
        }
        .navigationTitle("Status Sharing")
    }
}

struct FunctionalV2PrivacyView: View {
    var body: some View {
        List {
            Section("Local TestFlight mode") {
                Label("Move profile and drafts stay on this iPhone", systemImage: "iphone")
                Label("Document files are copied into the private app container", systemImage: "lock.doc.fill")
                Label("No fake cloud sync or provider acceptance", systemImage: "checkmark.shield.fill")
            }
            Section("Connected mode") { Text("When a staging/production backend is configured, secure session, scoped document upload, provider requests and official handoff registry are used.").font(.footnote) }
            Section("Government boundary") { Text("Dubai Move never claims a government/utility transaction is complete simply because an external page was opened.").font(.footnote) }
        }
        .navigationTitle("Privacy & Data")
    }
}

struct FunctionalV2MoreView: View {
    @AppStorage("dubaimove.onboarding.completed") private var onboardingCompleted = true

    var body: some View {
        List {
            Section("Move") {
                NavigationLink("Move setup", destination: FunctionalV2MoveSetupView())
                NavigationLink("Reschedule", destination: FunctionalV2RescheduleView())
                NavigationLink("Status sharing", destination: FunctionalV2StatusShareView())
                NavigationLink("Leaving Dubai", destination: FunctionalV2LeavingDubaiView())
            }
            Section("Account & device") {
                Button("Enable notifications") { Task { await PushRegistration.request() } }
                NavigationLink("Privacy & data", destination: FunctionalV2PrivacyView())
                NavigationLink("Support", destination: FunctionalV2SupportView())
            }
            Section("Environment") {
                LabeledContent("Mode", value: APIConfiguration.isConnectedMode ? "Connected" : "Local TestFlight")
                Text("Provider marketplace, server messaging and secure cloud OCR activate only when the public backend is configured.").font(.footnote).foregroundStyle(.secondary)
            }
            Section {
                Button("Run onboarding again") { onboardingCompleted = false }
            }
        }
        .navigationTitle("More")
    }
}
