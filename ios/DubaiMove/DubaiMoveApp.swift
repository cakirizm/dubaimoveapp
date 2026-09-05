import SwiftUI
import MapKit

typealias MapScale = MapScaleView

extension Color {
    static var tertiary: Color { Color(uiColor: .tertiaryLabel) }
}

@main
struct DubaiMoveApp: App {
    @UIApplicationDelegateAdaptor(DubaiMoveAppDelegate.self) private var appDelegate
    @StateObject private var appState = AppState()
    @StateObject private var session = SessionStore()
    @StateObject private var connectedData = ConnectedDataStore()
    @StateObject private var localAccount = LocalAccountStore()

    var body: some Scene {
        WindowGroup {
            FunctionalProductionEntryView()
                .environmentObject(appState)
                .environmentObject(session)
                .environmentObject(connectedData)
                .environmentObject(localAccount)
        }
    }
}

struct FunctionalProductionEntryView: View {
    @EnvironmentObject private var appState: AppState
    @EnvironmentObject private var session: SessionStore
    @EnvironmentObject private var connectedData: ConnectedDataStore
    @EnvironmentObject private var localAccount: LocalAccountStore
    @AppStorage("dubaimove.onboarding.completed") private var onboardingCompleted = false
    @State private var launchFinished = false

    var body: some View {
        ZStack {
            if !launchFinished {
                BrandLaunchView()
                    .transition(.opacity)
            } else if APIConfiguration.isConnectedMode {
                connectedEntry
                    .transition(.opacity)
            } else {
                localEntry
                    .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.38), value: launchFinished)
        .task {
            guard !launchFinished else { return }
            try? await Task.sleep(for: .milliseconds(2350))
            launchFinished = true
        }
    }

    @ViewBuilder
    private var localEntry: some View {
        if !localAccount.isAuthenticated {
            BrandedEntryFlow(connected: false)
        } else if !onboardingCompleted {
            OnboardingView(completed: $onboardingCompleted)
        } else {
            FunctionalV2RootTabView()
        }
    }

    @ViewBuilder
    private var connectedEntry: some View {
        if !session.didAttemptRestore {
            VStack(spacing: 18) {
                Image("BrandLogo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 110, height: 110)
                ProgressView("Restoring your Dubai Move account…")
                    .tint(DMTheme.green)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(DMTheme.page.ignoresSafeArea())
            .task { await session.restore() }
        } else if !session.isAuthenticated {
            BrandedEntryFlow(connected: true)
        } else if !onboardingCompleted {
            OnboardingView(completed: $onboardingCompleted)
        } else {
            RootTabView()
                .task { await refreshConnectedData() }
        }
    }

    private func refreshConnectedData() async {
        await connectedData.refresh()
        if let readiness = connectedData.moves.first?.readiness {
            appState.readiness = readiness
        }
    }
}

final class AppState: ObservableObject {
    @Published var selectedTab: MainTab = .home
    @Published var readiness: Int = 0
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
