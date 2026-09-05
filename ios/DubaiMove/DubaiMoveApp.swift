import SwiftUI
import MapKit
import UIKit
import UniformTypeIdentifiers

typealias MapScale = MapScaleView

@main
struct DubaiMoveApp: App {
    @UIApplicationDelegateAdaptor(DubaiMoveAppDelegate.self) private var appDelegate
    @StateObject private var appState = AppState()
    @StateObject private var session = SessionStore()
    @StateObject private var connectedData = ConnectedDataStore()

    var body: some Scene {
        WindowGroup {
            FunctionalProductionEntryView()
                .environmentObject(appState)
                .environmentObject(session)
                .environmentObject(connectedData)
        }
    }
}

final class AppState: ObservableObject {
    @Published var selectedTab: MainTab = .home
    @Published var readiness: Int = 64
    @Published var moveDate = Date().addingTimeInterval(60 * 60 * 24 * 23)
    @Published var currentProperty = Property(name: "Marina Gate Tower 2", area: "Dubai Marina", unit: "1804", coordinate: .init(latitude: 25.0865, longitude: 55.1468))
    @Published var newProperty = Property(name: "Collective 2.0", area: "Dubai Hills", unit: "1203", coordinate: .init(latitude: 25.1107, longitude: 55.2387))
    @Published var moveTasks: [MoveTask] = MoveTask.samples
    @Published var quotes: [ProviderQuote] = ProviderQuote.samples
    @Published var selectedService: ServiceCategory?
    @Published var generatedReports: [GeneratedReport] = [
        .init(title: "Landlord Handover Pack", subtitle: "Inspection, utilities, keys and deposit", systemImage: "doc.text.image"),
        .init(title: "Rental Increase Check", subtitle: "Official-reference summary", systemImage: "percent")
    ]
}

enum MainTab: String, CaseIterable {
    case home = "Home"
    case move = "My Move"
    case services = "Services"
    case documents = "Documents"
    case money = "Money"

    var icon: String {
        switch self {
        case .home: return "house.fill"
        case .move: return "checklist"
        case .services: return "square.grid.2x2.fill"
        case .documents: return "folder.fill"
        case .money: return "banknote.fill"
        }
    }
}

struct Property: Identifiable, Hashable {
    let id = UUID()
    var name: String
    var area: String
    var unit: String
    var coordinate: CLLocationCoordinate2D

    static func == (lhs: Property, rhs: Property) -> Bool { lhs.id == rhs.id }
    func hash(into hasher: inout Hasher) { hasher.combine(id) }
}

struct MoveTask: Identifiable, Hashable {
    enum Status: String { case completed = "Completed", inProgress = "In progress", blocked = "Blocked", pending = "Pending" }
    let id = UUID()
    var title: String
    var subtitle: String
    var status: Status
    var destination: AppRoute

    static let samples: [MoveTask] = [
        .init(title: "Tenancy Contract", subtitle: "Reviewed and confirmed", status: .completed, destination: .contract),
        .init(title: "New Ejari", subtitle: "Landlord approval may be required", status: .inProgress, destination: .ejari),
        .init(title: "DEWA Move-To", subtitle: "Unlocks after Ejari readiness", status: .blocked, destination: .dewa),
        .init(title: "Building Move Permit", subtitle: "Check management requirements", status: .inProgress, destination: .building),
        .init(title: "Lift Reservation", subtitle: "Reserve a move slot", status: .pending, destination: .buildingAccess),
        .init(title: "Moving Company", subtitle: "Compare verified provider quotes", status: .pending, destination: .providerMatching),
        .init(title: "Old-home Inspection", subtitle: "Capture move-out evidence", status: .pending, destination: .moveOutInspection),
        .init(title: "Landlord Handover", subtitle: "Generate final handover pack", status: .pending, destination: .handover)
    ]
}

struct ServiceCategory: Identifiable, Hashable {
    let id = UUID()
    let title: String
    let subtitle: String
    let icon: String
    let regulated: Bool

    static let all: [ServiceCategory] = [
        .init(title: "Moving", subtitle: "Packing, transport and unpacking", icon: "truck.box.fill", regulated: false),
        .init(title: "Cleaning", subtitle: "Move-in and move-out cleaning", icon: "sparkles", regulated: false),
        .init(title: "Painting", subtitle: "Apartment and villa painting", icon: "paintbrush.fill", regulated: false),
        .init(title: "Maintenance", subtitle: "Handyman, AC and repairs", icon: "wrench.and.screwdriver.fill", regulated: false),
        .init(title: "Storage", subtitle: "Short and long-term storage", icon: "archivebox.fill", regulated: false),
        .init(title: "Inspection", subtitle: "Condition inspection assistance", icon: "camera.viewfinder", regulated: false),
        .init(title: "Ejari Assistance", subtitle: "Verified guidance and assistance", icon: "doc.badge.gearshape", regulated: true),
        .init(title: "DEWA Assistance", subtitle: "Move-In, Move-To and Move-Out help", icon: "bolt.fill", regulated: true),
        .init(title: "Cooling Assistance", subtitle: "Empower / Emicool support", icon: "snowflake", regulated: true),
        .init(title: "Telecom Relocation", subtitle: "Transfer or cancel connectivity", icon: "wifi", regulated: false),
        .init(title: "Move Permit Help", subtitle: "Building permit and lift coordination", icon: "building.2.fill", regulated: false),
        .init(title: "Deposit Assistance", subtitle: "Evidence and recovery support", icon: "arrow.uturn.backward.circle.fill", regulated: false)
    ]
}

struct ProviderQuote: Identifiable, Hashable {
    let id = UUID()
    let provider: String
    let rating: Double
    let score: Int
    let price: Int
    let badge: String
    let availability: String
    let verified: Bool
    let hiddenCostRisk: String

    static let samples: [ProviderQuote] = [
        .init(provider: "MoveFast Dubai", rating: 4.8, score: 92, price: 2300, badge: "Best Value", availability: "08:00 available", verified: true, hiddenCostRisk: "Low"),
        .init(provider: "SwiftMove", rating: 4.6, score: 84, price: 2050, badge: "Lowest Price", availability: "09:30 available", verified: true, hiddenCostRisk: "Medium"),
        .init(provider: "Premium Relocations", rating: 4.9, score: 95, price: 2650, badge: "Highest Rated", availability: "08:00 available", verified: true, hiddenCostRisk: "Low")
    ]
}

struct GeneratedReport: Identifiable, Hashable {
    let id = UUID()
    let title: String
    let subtitle: String
    let systemImage: String
}

enum AppRoute: Hashable {
    case notifications, aiCopilot, map, contract, rentalIncrease, ejari, dewa, cooling, telecom, building, buildingAccess
    case serviceRequest(ServiceCategory), videoInventory, providerMatching, quoteComparison, providerProfile(ProviderQuote), chat(ProviderQuote), booking(ProviderQuote), moveDay
    case moveInInspection, moveOutInspection, conditionReport, handover, deposit, starterPack, leavingDubai, reschedule, calendar, statusShare, multiProperty
    case emergencyMove, concierge, corporateRelocation, family, privacy, offlineSync, quoteProtection, packingLabels, disputeEvidence, support
}

// MARK: - Functional customer entry

struct FunctionalProductionEntryView: View {
    @AppStorage("dubaimove.onboarding.completed") private var onboardingCompleted = false

    var body: some View {
        if APIConfiguration.isConnectedMode {
            ProductionEntryView()
        } else if onboardingCompleted {
            FunctionalRootTabView()
        } else {
            OnboardingView(completed: $onboardingCompleted)
        }
    }
}

struct FunctionalRootTabView: View {
    @EnvironmentObject private var state: AppState

    var body: some View {
        TabView(selection: $state.selectedTab) {
            NavigationStack { FunctionalHomeView() }
                .tag(MainTab.home)
                .tabItem { Label("Home", systemImage: MainTab.home.icon) }

            NavigationStack { FunctionalMoveCenterView() }
                .tag(MainTab.move)
                .tabItem { Label("My Move", systemImage: MainTab.move.icon) }

            NavigationStack { FunctionalServicesCenterView() }
                .tag(MainTab.services)
                .tabItem { Label("Services", systemImage: MainTab.services.icon) }

            NavigationStack { FunctionalDocumentsView() }
                .tag(MainTab.documents)
                .tabItem { Label("Documents", systemImage: MainTab.documents.icon) }

            NavigationStack { ConnectedMoneyView() }
                .tag(MainTab.money)
                .tabItem { Label("Money", systemImage: MainTab.money.icon) }
        }
        .tint(DMTheme.green)
    }
}

// MARK: - Verified official destinations

enum OfficialAction: String, CaseIterable, Identifiable {
    case rentalIndex
    case ejariRegister
    case ejariCancel
    case ejariCertificate
    case dewaMoveIn
    case dewaMoveTo
    case dewaMoveOut
    case duHomeMove
    case etisalatHomeMove
    case empowerMoveOut
    case emicoolCustomers
    case uaeResidenceCancellation

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
        case .etisalatHomeMove: return "e& Home Move"
        case .empowerMoveOut: return "Empower Final Bill / Move-Out"
        case .emicoolCustomers: return "Emicool Customer Services"
        case .uaeResidenceCancellation: return "UAE Residence Cancellation Guidance"
        }
    }

    var authority: String {
        switch self {
        case .rentalIndex, .ejariRegister, .ejariCancel, .ejariCertificate: return "Dubai Land Department"
        case .dewaMoveIn, .dewaMoveTo, .dewaMoveOut: return "DEWA"
        case .duHomeMove: return "du"
        case .etisalatHomeMove: return "e& UAE"
        case .empowerMoveOut: return "Empower"
        case .emicoolCustomers: return "Emicool"
        case .uaeResidenceCancellation: return "UAE Government"
        }
    }

    var url: URL {
        let raw: String
        switch self {
        case .rentalIndex:
            raw = "https://dubailand.gov.ae/en/eservices/rental-index/rental-index"
        case .ejariRegister:
            raw = "https://dubailand.gov.ae/en/eservices/register-renew-ejari-contract/"
        case .ejariCancel:
            raw = "https://dubailand.gov.ae/en/eservices/request-for-cancellation-of-ejari-contract/"
        case .ejariCertificate:
            raw = "https://dubailand.gov.ae/en/eservices/download-ejari-certificate/"
        case .dewaMoveIn:
            raw = "https://www.dewa.gov.ae/en/consumer/supply-management/pre-login-activation-of-electricity-water-move-in"
        case .dewaMoveTo:
            raw = "https://www.dewa.gov.ae/en/consumer/supply-management/transfer-of-electricity-water-move-to"
        case .dewaMoveOut:
            raw = "https://www.dewa.gov.ae/en/consumer/supply-management/deactivation-of-electricity-water-move-out"
        case .duHomeMove:
            raw = "https://www.du.ae/personal/at-home/moving-to-a-new-home"
        case .etisalatHomeMove:
            raw = "https://etisalat-ae.akamaized.net/en/c/home/home-moving.html"
        case .empowerMoveOut:
            raw = "https://empower.ae/media/rvqgimof/final-bill-request-form.pdf"
        case .emicoolCustomers:
            raw = "https://www.emicool.com/en/customers"
        case .uaeResidenceCancellation:
            raw = "https://u.ae/en/information-and-services/visa-and-emirates-id/Visa-information/general-provisions-for-the-residence-visa"
        }
        return URL(string: raw)!
    }

    var detail: String {
        switch self {
        case .rentalIndex: return "Official DLD calculator / reference. Dubai Move does not make a legal determination."
        case .ejariRegister: return "Official DLD service for registering or renewing a tenancy contract."
        case .ejariCancel: return "Official DLD tenancy-contract cancellation service."
        case .ejariCertificate: return "Official DLD certificate lookup / download service."
        case .dewaMoveIn: return "Official DEWA electricity and water activation service."
        case .dewaMoveTo: return "Official DEWA transfer from an old Dubai premise to a new one."
        case .dewaMoveOut: return "Official DEWA electricity and water deactivation / final-bill service."
        case .duHomeMove: return "Official du Home relocation page."
        case .etisalatHomeMove: return "Official e& Home Move guidance and application path."
        case .empowerMoveOut: return "Official Empower final bill / refund form used for tenant move-out."
        case .emicoolCustomers: return "Official Emicool customer portal and Move-Out / Move-In information."
        case .uaeResidenceCancellation: return "Official UAE Government guidance. Sponsor/employer rules may apply."
        }
    }
}

struct OfficialActionRow: View {
    let action: OfficialAction
    @Environment(\.openURL) private var openURL

    var body: some View {
        Button {
            openURL(action.url)
        } label: {
            HStack(spacing: 12) {
                Image(systemName: "arrow.up.right.square.fill")
                    .foregroundStyle(DMTheme.green)
                    .frame(width: 28)
                VStack(alignment: .leading, spacing: 3) {
                    Text(action.title).font(.headline).foregroundStyle(.primary)
                    Text(action.authority).font(.caption).foregroundStyle(.secondary)
                }
                Spacer()
                Image(systemName: "chevron.right").foregroundStyle(.secondary)
            }
        }
    }
}

struct OfficialActionDetailView: View {
    let action: OfficialAction
    @Environment(\.openURL) private var openURL

    var body: some View {
        Form {
            Section {
                Text(action.title).font(.title2.bold())
                Text(action.detail).foregroundStyle(.secondary)
                LabeledContent("Official provider", value: action.authority)
            }
            Section("What happens next") {
                Text("The action opens the authority/provider's HTTPS channel. Dubai Move does not mark the external transaction completed automatically in this TestFlight build.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
            Section {
                Button("Open official channel") { openURL(action.url) }
                    .buttonStyle(.borderedProminent)
                    .tint(DMTheme.green)
            }
        }
        .navigationTitle(action.title)
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Home

struct FunctionalHomeView: View {
    @EnvironmentObject private var state: AppState

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Your Dubai move").font(.largeTitle.bold())
                        Text("TestFlight · functional local mode").foregroundStyle(.secondary)
                    }
                    Spacer()
                    Image(systemName: "checkmark.shield.fill").font(.title2).foregroundStyle(DMTheme.green)
                }

                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        Text("MOVE READINESS").font(.caption.bold()).foregroundStyle(.secondary)
                        Spacer()
                        Text("\(state.readiness)%").font(.title.bold()).foregroundStyle(DMTheme.green)
                    }
                    ProgressView(value: Double(state.readiness), total: 100).tint(DMTheme.green)
                    NavigationLink("Open My Move", destination: FunctionalMoveCenterView())
                        .buttonStyle(.borderedProminent).tint(DMTheme.green)
                }.dmCard(background: DMTheme.mint)

                NavigationLink(destination: GovernmentUtilitiesHubView()) {
                    functionalRow("Government & utilities", "Ejari, DEWA, cooling and official services", "checkmark.shield.fill")
                }
                NavigationLink(destination: TelecomCenterView()) {
                    functionalRow("Internet & telecom", "du and e& relocation paths", "wifi")
                }
                NavigationLink(destination: FunctionalLeavingDubaiView()) {
                    functionalRow("Leaving Dubai", "Home exit + official departure guidance", "airplane.departure")
                }
                NavigationLink(destination: ConnectedInspectionHubView()) {
                    functionalRow("Inspection & handover", "User-confirmed condition records", "camera.viewfinder")
                }
                NavigationLink(destination: FunctionalServicesCenterView()) {
                    functionalRow("Home services", "Moving, cleaning, painting, maintenance and more", "square.grid.2x2.fill")
                }
                NavigationLink(destination: RentalIndexLocalView()) {
                    functionalRow("Rental Increase Check", "Calculate change and open official DLD index", "percent")
                }
                NavigationLink(destination: FunctionalBuildingCenterView()) {
                    functionalRow("Building access", "Management contact, permit and lift notes", "building.2.fill")
                }
            }
            .padding()
        }
        .background(Color(uiColor: .systemGroupedBackground))
    }

    private func functionalRow(_ title: String, _ subtitle: String, _ icon: String) -> some View {
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

// MARK: - Move center

struct FunctionalMoveCenterView: View {
    @EnvironmentObject private var state: AppState

    var body: some View {
        List {
            Section {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Dubai Marina → Dubai Hills").font(.title2.bold())
                    Text(state.moveDate.formatted(date: .abbreviated, time: .omitted)).foregroundStyle(.secondary)
                    ProgressView(value: Double(state.readiness), total: 100).tint(DMTheme.green)
                }
                .padding(.vertical, 4)
            }

            Section("Government & utility tasks") {
                NavigationLink("Ejari", destination: EjariCenterView())
                NavigationLink("DEWA", destination: DewaCenterView())
                NavigationLink("Cooling", destination: CoolingCenterView())
                NavigationLink("Internet / telecom", destination: TelecomCenterView())
            }

            Section("Home & provider tasks") {
                NavigationLink("Moving / cleaning / maintenance", destination: FunctionalServicesCenterView())
                NavigationLink("Building permit & lift", destination: FunctionalBuildingCenterView())
                NavigationLink("Move-out inspection", destination: ConnectedInspectionHubView())
                NavigationLink("Handover checklist", destination: FunctionalHandoverView())
            }

            Section("Exit") {
                NavigationLink("Leaving Dubai Center", destination: FunctionalLeavingDubaiView())
            }
        }
        .navigationTitle("My Move")
    }
}

// MARK: - Government and utilities

struct GovernmentUtilitiesHubView: View {
    var body: some View {
        List {
            Section("Property") {
                NavigationLink("Ejari", destination: EjariCenterView())
                NavigationLink("Rental Index", destination: RentalIndexLocalView())
            }
            Section("Utilities") {
                NavigationLink("DEWA", destination: DewaCenterView())
                NavigationLink("Cooling", destination: CoolingCenterView())
                NavigationLink("Internet & telecom", destination: TelecomCenterView())
            }
            Section {
                Text("Every external action in this hub opens a verified HTTPS authority/provider destination. External completion is never faked inside Dubai Move.")
                    .font(.footnote).foregroundStyle(.secondary)
            }
        }
        .navigationTitle("Government & Utilities")
    }
}

struct EjariCenterView: View {
    var body: some View {
        List {
            Section("Ejari journeys") {
                NavigationLink(destination: OfficialActionDetailView(action: .ejariRegister)) { OfficialActionRow(action: .ejariRegister) }
                NavigationLink(destination: OfficialActionDetailView(action: .ejariCancel)) { OfficialActionRow(action: .ejariCancel) }
                NavigationLink(destination: OfficialActionDetailView(action: .ejariCertificate)) { OfficialActionRow(action: .ejariCertificate) }
            }
            Section("Before you continue") {
                Text("Requirements can differ by contract status and applicant role. Review the official service requirements before submitting.")
                    .font(.footnote).foregroundStyle(.secondary)
            }
        }
        .navigationTitle("Ejari")
    }
}

struct DewaCenterView: View {
    var body: some View {
        List {
            Section("Choose the correct DEWA journey") {
                NavigationLink(destination: OfficialActionDetailView(action: .dewaMoveIn)) { OfficialActionRow(action: .dewaMoveIn) }
                NavigationLink(destination: OfficialActionDetailView(action: .dewaMoveTo)) { OfficialActionRow(action: .dewaMoveTo) }
                NavigationLink(destination: OfficialActionDetailView(action: .dewaMoveOut)) { OfficialActionRow(action: .dewaMoveOut) }
            }
            Section("Move-To readiness") {
                Label("Existing DEWA contract account", systemImage: "number")
                Label("Move-out date", systemImage: "calendar")
                Label("New premise number", systemImage: "building.2")
                Label("Valid Ejari for new premise", systemImage: "doc.text")
                Label("Move-in date", systemImage: "calendar.badge.plus")
            }
        }
        .navigationTitle("DEWA")
    }
}

struct TelecomCenterView: View {
    var body: some View {
        List {
            Section("Relocate existing home internet") {
                NavigationLink(destination: OfficialActionDetailView(action: .duHomeMove)) { OfficialActionRow(action: .duHomeMove) }
                NavigationLink(destination: OfficialActionDetailView(action: .etisalatHomeMove)) { OfficialActionRow(action: .etisalatHomeMove) }
            }
            Section("Other provider") {
                Text("If your provider is not listed, use its official app/account channel. Dubai Move will not send you to an unverified third-party seller.")
                    .font(.footnote).foregroundStyle(.secondary)
            }
        }
        .navigationTitle("Internet & Telecom")
    }
}

struct CoolingCenterView: View {
    @State private var provider = "Not sure"

    var body: some View {
        List {
            Section("Cooling provider") {
                Picker("Provider", selection: $provider) {
                    Text("Not sure").tag("Not sure")
                    Text("Empower").tag("Empower")
                    Text("Emicool").tag("Emicool")
                }
            }
            if provider == "Empower" {
                Section { NavigationLink(destination: OfficialActionDetailView(action: .empowerMoveOut)) { OfficialActionRow(action: .empowerMoveOut) } }
            } else if provider == "Emicool" {
                Section { NavigationLink(destination: OfficialActionDetailView(action: .emicoolCustomers)) { OfficialActionRow(action: .emicoolCustomers) } }
            } else {
                Section {
                    Text("Confirm the district-cooling provider from your building management or latest cooling bill before continuing.")
                        .font(.footnote).foregroundStyle(.secondary)
                }
            }
        }
        .navigationTitle("Cooling")
    }
}

struct RentalIndexLocalView: View {
    @State private var currentRent = ""
    @State private var proposedRent = ""

    private var change: Double? {
        guard let current = Double(currentRent), let proposed = Double(proposedRent), current > 0 else { return nil }
        return ((proposed - current) / current) * 100
    }

    var body: some View {
        Form {
            Section("Landlord proposal") {
                TextField("Current annual rent (AED)", text: $currentRent).keyboardType(.decimalPad)
                TextField("Proposed annual rent (AED)", text: $proposedRent).keyboardType(.decimalPad)
                if let change {
                    LabeledContent("Change", value: String(format: "%.1f%%", change))
                }
            }
            Section("Official reference") {
                NavigationLink(destination: OfficialActionDetailView(action: .rentalIndex)) { OfficialActionRow(action: .rentalIndex) }
            }
            Section {
                Text("The percentage above is arithmetic only. Use the official DLD Rental Index for the applicable official reference.")
                    .font(.footnote).foregroundStyle(.secondary)
            }
        }
        .navigationTitle("Rental Increase Check")
    }
}

// MARK: - Services

struct FunctionalServicesCenterView: View {
    var body: some View {
        List {
            Section("Home services") {
                ForEach(Array(ServiceCategory.all.prefix(6))) { service in
                    NavigationLink(destination: FunctionalServiceRequestView(service: service)) {
                        serviceRow(service)
                    }
                }
            }
            Section("Move administration") {
                NavigationLink("Ejari", destination: EjariCenterView())
                NavigationLink("DEWA", destination: DewaCenterView())
                NavigationLink("Cooling", destination: CoolingCenterView())
                NavigationLink("Telecom relocation", destination: TelecomCenterView())
                NavigationLink("Move permit help", destination: FunctionalBuildingCenterView())
                NavigationLink("Deposit assistance", destination: FunctionalHandoverView())
            }
        }
        .navigationTitle("Services")
    }

    private func serviceRow(_ service: ServiceCategory) -> some View {
        HStack(spacing: 12) {
            Image(systemName: service.icon).foregroundStyle(DMTheme.green).frame(width: 28)
            VStack(alignment: .leading) {
                Text(service.title).font(.headline)
                Text(service.subtitle).font(.caption).foregroundStyle(.secondary)
            }
        }
    }
}

struct LocalServiceRequest: Codable, Identifiable {
    var id = UUID()
    var service: String
    var note: String
    var requestedDate: Date
    var createdAt = Date()
}

@MainActor
final class LocalServiceRequestStore: ObservableObject {
    @Published var requests: [LocalServiceRequest] = [] { didSet { save() } }
    private let key = "dubaimove.functional.requests"

    init() {
        if let data = UserDefaults.standard.data(forKey: key),
           let decoded = try? JSONDecoder().decode([LocalServiceRequest].self, from: data) {
            requests = decoded
        }
    }

    func add(service: String, note: String, date: Date) {
        requests.insert(.init(service: service, note: note, requestedDate: date), at: 0)
    }

    private func save() {
        if let data = try? JSONEncoder().encode(requests) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }
}

struct FunctionalServiceRequestView: View {
    let service: ServiceCategory
    @StateObject private var store = LocalServiceRequestStore()
    @State private var note = ""
    @State private var date = Date().addingTimeInterval(86400 * 7)
    @State private var saved = false

    var body: some View {
        Form {
            Section {
                Label(service.title, systemImage: service.icon).font(.title2.bold())
                Text(service.subtitle).foregroundStyle(.secondary)
            }
            Section("Request") {
                DatePicker("Preferred date", selection: $date, displayedComponents: [.date, .hourAndMinute])
                TextField("Scope / notes", text: $note, axis: .vertical).lineLimit(3...7)
            }
            Section {
                Button(saved ? "Request saved" : "Save request") {
                    store.add(service: service.title, note: note, date: date)
                    saved = true
                }
                .disabled(saved)
            }
            Section {
                if APIConfiguration.isConnectedMode {
                    Text("Connected mode sends requests to eligible providers through the live backend.")
                } else {
                    Text("This TestFlight build stores the request safely on this iPhone. It does not invent live provider quotes while the public staging backend is not configured.")
                }
            }
            .font(.footnote)
            .foregroundStyle(.secondary)
        }
        .navigationTitle(service.title)
    }
}

// MARK: - Documents

struct LocalDocumentItem: Codable, Identifiable {
    var id = UUID()
    var name: String
    var type: String
    var addedAt = Date()
}

@MainActor
final class FunctionalDocumentStore: ObservableObject {
    @Published var items: [LocalDocumentItem] = [] { didSet { save() } }
    private let key = "dubaimove.functional.documents"

    init() {
        if let data = UserDefaults.standard.data(forKey: key),
           let decoded = try? JSONDecoder().decode([LocalDocumentItem].self, from: data) {
            items = decoded
        }
    }

    func add(name: String, type: String) {
        items.insert(.init(name: name, type: type), at: 0)
    }

    private func save() {
        if let data = try? JSONEncoder().encode(items) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }
}

struct FunctionalDocumentsView: View {
    @StateObject private var store = FunctionalDocumentStore()
    @State private var importing = false
    @State private var documentType = "Tenancy Contract"

    var body: some View {
        List {
            Section("Add document") {
                Picker("Type", selection: $documentType) {
                    ForEach(["Tenancy Contract", "Ejari", "DEWA", "Cooling", "Building Permit", "Provider", "Inspection", "Handover", "Receipt"], id: \.self) { Text($0) }
                }
                Button("Choose PDF / image") { importing = true }
            }

            Section("Document wallet") {
                if store.items.isEmpty {
                    Text("No local documents added yet").foregroundStyle(.secondary)
                }
                ForEach(store.items) { item in
                    VStack(alignment: .leading, spacing: 3) {
                        Text(item.type).font(.headline)
                        Text(item.name).font(.caption).foregroundStyle(.secondary)
                        Text(item.addedAt.formatted(date: .abbreviated, time: .shortened)).font(.caption2).foregroundStyle(.secondary)
                    }
                }
            }

            Section {
                Text("In this backend-free TestFlight mode, the wallet stores document references locally and never claims a private cloud upload occurred. Connected mode uses the secure upload/OCR flow.")
                    .font(.footnote).foregroundStyle(.secondary)
            }
        }
        .navigationTitle("Documents")
        .fileImporter(isPresented: $importing, allowedContentTypes: [.pdf, .image]) { result in
            if case .success(let url) = result {
                store.add(name: url.lastPathComponent, type: documentType)
            }
        }
    }
}

// MARK: - Building, handover and leaving Dubai

struct FunctionalBuildingCenterView: View {
    @AppStorage("dubaimove.building.contact.phone") private var phone = ""
    @AppStorage("dubaimove.building.contact.email") private var email = ""
    @AppStorage("dubaimove.building.permit.note") private var permitNote = ""
    @Environment(\.openURL) private var openURL

    var body: some View {
        Form {
            Section("Building management") {
                TextField("Management phone", text: $phone).keyboardType(.phonePad)
                TextField("Management email", text: $email).keyboardType(.emailAddress).textInputAutocapitalization(.never)
                Button("Call management") {
                    let cleaned = phone.filter { "+0123456789".contains($0) }
                    if let url = URL(string: "tel:\(cleaned)") { openURL(url) }
                }
                .disabled(phone.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)

                Button("Email management") {
                    if let url = URL(string: "mailto:\(email)") { openURL(url) }
                }
                .disabled(!email.contains("@"))
            }
            Section("Permit / lift notes") {
                TextField("Requirements, permit portal, lift slot, parking…", text: $permitNote, axis: .vertical).lineLimit(3...8)
            }
            Section {
                Text("Building rules vary by property. Dubai Move does not invent a management portal when one has not been verified for the selected building.")
                    .font(.footnote).foregroundStyle(.secondary)
            }
        }
        .navigationTitle("Building Access")
    }
}

struct FunctionalHandoverView: View {
    @AppStorage("dubaimove.handover.cleaning") private var cleaning = false
    @AppStorage("dubaimove.handover.inspection") private var inspection = false
    @AppStorage("dubaimove.handover.dewa") private var dewa = false
    @AppStorage("dubaimove.handover.cooling") private var cooling = false
    @AppStorage("dubaimove.handover.telecom") private var telecom = false
    @AppStorage("dubaimove.handover.keys") private var keys = false
    @AppStorage("dubaimove.handover.deposit") private var deposit = false

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
            Section("Go to action") {
                NavigationLink("Inspection", destination: ConnectedInspectionHubView())
                NavigationLink("DEWA Move-Out", destination: OfficialActionDetailView(action: .dewaMoveOut))
                NavigationLink("Cooling", destination: CoolingCenterView())
                NavigationLink("Internet / telecom", destination: TelecomCenterView())
            }
        }
        .navigationTitle("Handover")
    }
}

struct FunctionalLeavingDubaiView: View {
    var body: some View {
        List {
            Section {
                Text("Leaving Dubai").font(.largeTitle.bold())
                Text("Home exit and UAE departure are separate journeys. Each row below goes to the relevant action instead of a placeholder screen.")
                    .foregroundStyle(.secondary)
            }
            Section("Home exit") {
                NavigationLink("Ejari cancellation", destination: OfficialActionDetailView(action: .ejariCancel))
                NavigationLink("DEWA Move-Out", destination: OfficialActionDetailView(action: .dewaMoveOut))
                NavigationLink("Cooling Move-Out", destination: CoolingCenterView())
                NavigationLink("Telecom transfer / cancel", destination: TelecomCenterView())
                NavigationLink("Move-out inspection", destination: ConnectedInspectionHubView())
                NavigationLink("Cleaning", destination: FunctionalServiceRequestView(service: ServiceCategory.all[1]))
                NavigationLink("Keys & handover", destination: FunctionalHandoverView())
                NavigationLink("Deposit / refunds", destination: ConnectedMoneyView())
            }
            Section("UAE departure") {
                NavigationLink(destination: OfficialActionDetailView(action: .uaeResidenceCancellation)) {
                    OfficialActionRow(action: .uaeResidenceCancellation)
                }
            }
            Section {
                Text("Visa/work-permit cancellation depends on sponsorship and employment circumstances. Dubai Move provides official guidance links, not immigration or legal advice.")
                    .font(.footnote).foregroundStyle(.secondary)
            }
        }
        .navigationTitle("Leaving Dubai")
    }
}
