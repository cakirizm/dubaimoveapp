import SwiftUI
import MapKit

struct DMTheme {
    static let green = Color(red: 0.04, green: 0.42, blue: 0.32)
    static let mint = Color(red: 0.88, green: 0.96, blue: 0.93)
    static let sand = Color(red: 0.97, green: 0.95, blue: 0.90)
    static let ink = Color(red: 0.08, green: 0.11, blue: 0.10)
    static let card = Color(uiColor: .secondarySystemBackground)
}

struct RootTabView: View {
    @EnvironmentObject var state: AppState
    var body: some View {
        TabView(selection: $state.selectedTab) {
            NavigationStack { HomeView() }.tag(MainTab.home).tabItem { Label("Home", systemImage: MainTab.home.icon) }
            NavigationStack { MyMoveView() }.tag(MainTab.move).tabItem { Label("My Move", systemImage: MainTab.move.icon) }
            NavigationStack {
                if APIConfiguration.isConnectedMode { ConnectedServicesView() } else { ServicesView() }
            }.tag(MainTab.services).tabItem { Label("Services", systemImage: MainTab.services.icon) }
            NavigationStack {
                if APIConfiguration.isConnectedMode { ConnectedDocumentsTabView() } else { DocumentsView() }
            }.tag(MainTab.documents).tabItem { Label("Documents", systemImage: MainTab.documents.icon) }
            NavigationStack { MoneyView() }.tag(MainTab.money).tabItem { Label("Money", systemImage: MainTab.money.icon) }
        }.tint(DMTheme.green)
    }
}

struct HomeView: View {
    @EnvironmentObject var state: AppState
    var body: some View {
        ScrollView {
            VStack(spacing: 18) { header; routeCard; readinessCard; nextAction; importantDates; moneySnapshot; aiCard; quickTools }.padding()
        }
        .background(Color(uiColor: .systemGroupedBackground))
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItemGroup(placement: .topBarTrailing) {
                NavigationLink(destination: MoreView()) { Image(systemName: "square.grid.3x3.fill") }
                NavigationLink(value: AppRoute.notifications) { Image(systemName: "bell.fill") }
            }
        }
        .navigationDestination(for: AppRoute.self, destination: routeDestination)
    }

    private var header: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) { Text("Good morning").font(.subheadline).foregroundStyle(.secondary); Text("Your Dubai move").font(.largeTitle.bold()) }
            Spacer()
            NavigationLink(destination: OriginalScreenIndexView()) {
                Circle().fill(DMTheme.green).frame(width: 44, height: 44).overlay(Text("DM").foregroundStyle(.white).font(.caption.bold()))
            }.accessibilityLabel("Open full Dubai Move tools")
        }
    }

    private var routeCard: some View {
        NavigationLink(value: AppRoute.map) {
            VStack(alignment: .leading, spacing: 12) {
                Label("Move route", systemImage: "map.fill").font(.headline)
                HStack(alignment: .top, spacing: 14) {
                    VStack(spacing: 6) { Circle().fill(DMTheme.green).frame(width: 10, height: 10); Rectangle().fill(.secondary.opacity(0.35)).frame(width: 2, height: 24); Circle().stroke(DMTheme.green, lineWidth: 2).frame(width: 10, height: 10) }
                    VStack(alignment: .leading, spacing: 14) { Text("Dubai Marina · \(state.currentProperty.name)").font(.subheadline.bold()); Text("Dubai Hills · \(state.newProperty.name)").font(.subheadline.bold()) }
                    Spacer(); Image(systemName: "chevron.right").foregroundStyle(.secondary)
                }
            }.dmCard()
        }.buttonStyle(.plain)
    }

    private var readinessCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading) { Text("MOVE READINESS").font(.caption.bold()).foregroundStyle(.secondary); Text("\(state.readiness)% READY").font(.title2.bold()) }
                Spacer()
                ZStack { Circle().stroke(.gray.opacity(0.2), lineWidth: 8); Circle().trim(from: 0, to: Double(state.readiness) / 100).stroke(DMTheme.green, style: .init(lineWidth: 8, lineCap: .round)).rotationEffect(.degrees(-90)); Text("\(state.readiness)%").font(.caption.bold()) }.frame(width: 62, height: 62)
            }
            ProgressView(value: Double(state.readiness), total: 100).tint(DMTheme.green)
            Text("8 completed · 3 waiting · 2 blocked").font(.footnote).foregroundStyle(.secondary)
            NavigationLink(destination: OriginalAppCoverageView(screen: .readinessDetail)) { Label("Open readiness detail", systemImage: "arrow.right.circle.fill") }
        }.dmCard()
    }

    private var nextAction: some View {
        NavigationLink(value: AppRoute.ejari) {
            VStack(alignment: .leading, spacing: 10) { Text("NEXT ACTION").font(.caption.bold()).foregroundStyle(DMTheme.green); Text("Complete your new Ejari").font(.title3.bold()); Text("DEWA Move-To stays blocked until Ejari readiness is complete.").foregroundStyle(.secondary); Label("Continue Ejari", systemImage: "arrow.right.circle.fill").font(.headline).foregroundStyle(DMTheme.green) }.dmCard(background: DMTheme.mint)
        }.buttonStyle(.plain)
    }

    private var importantDates: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack { Text("Important dates").font(.title3.bold()); Spacer(); NavigationLink("Calendar", value: AppRoute.calendar).font(.subheadline.bold()) }
            dateRow("Ejari target", "18 Sep", "doc.text.fill"); dateRow("Move permit", "20 Sep", "building.2.fill"); dateRow("DEWA", "24 Sep", "bolt.fill"); dateRow("Move day", "28 Sep", "truck.box.fill")
        }.dmCard()
    }
    private func dateRow(_ title: String, _ date: String, _ icon: String) -> some View { HStack { Image(systemName: icon).frame(width: 24).foregroundStyle(DMTheme.green); Text(title); Spacer(); Text(date).foregroundStyle(.secondary) } }

    private var moneySnapshot: some View {
        NavigationLink(value: AppRoute.deposit) {
            HStack { VStack(alignment: .leading, spacing: 5) { Text("Money & refunds").font(.headline); Text("Estimated move cost · AED 4,850").font(.subheadline); Text("Expected refunds · AED 6,500").font(.subheadline).foregroundStyle(DMTheme.green) }; Spacer(); Image(systemName: "chevron.right") }.dmCard()
        }.buttonStyle(.plain)
    }

    private var aiCard: some View {
        NavigationLink(value: AppRoute.aiCopilot) {
            HStack(spacing: 14) { Image(systemName: "sparkles").font(.title2).foregroundStyle(DMTheme.green); VStack(alignment: .leading) { Text("Ask Dubai Move").font(.headline); Text("What should I do next? What is blocking my move?").font(.subheadline).foregroundStyle(.secondary) }; Spacer(); Image(systemName: "chevron.right") }.dmCard(background: DMTheme.sand)
        }.buttonStyle(.plain)
    }

    private var quickTools: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Quick tools").font(.title3.bold())
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                tool("Rental Increase", "percent", .rentalIncrease); tool("Inspect My Home", "camera.viewfinder", .moveOutInspection); tool("Leaving Dubai", "airplane.departure", .leavingDubai); tool("Building Rules", "building.2.fill", .building); tool("Compare Quotes", "arrow.left.arrow.right", .quoteComparison); tool("Emergency Move", "exclamationmark.bubble.fill", .emergencyMove)
            }
        }
    }
    private func tool(_ title: String, _ icon: String, _ route: AppRoute) -> some View { NavigationLink(value: route) { VStack(alignment: .leading, spacing: 12) { Image(systemName: icon).font(.title2).foregroundStyle(DMTheme.green); Text(title).font(.subheadline.bold()).foregroundStyle(DMTheme.ink) }.frame(maxWidth: .infinity, minHeight: 84, alignment: .leading).padding().background(DMTheme.card).clipShape(RoundedRectangle(cornerRadius: 18)) }.buttonStyle(.plain) }
    @ViewBuilder private func routeDestination(_ route: AppRoute) -> some View { FeatureRouter(route: route) }
}

struct MyMoveView: View {
    @EnvironmentObject var state: AppState
    var body: some View {
        List {
            Section { HStack { VStack(alignment: .leading) { Text("Dubai Marina → Dubai Hills").font(.headline); Text("28 September · 64% ready").foregroundStyle(.secondary) }; Spacer(); NavigationLink(value: AppRoute.reschedule) { Image(systemName: "calendar.badge.clock") } } }
            Section("Old home → Move → New home") { ForEach(state.moveTasks) { task in NavigationLink(value: task.destination) { HStack(spacing: 12) { Image(systemName: statusIcon(task.status)).foregroundStyle(statusColor(task.status)).frame(width: 28); VStack(alignment: .leading) { Text(task.title).font(.headline); Text(task.subtitle).font(.caption).foregroundStyle(.secondary) } }.padding(.vertical, 4) } } }
            if APIConfiguration.isConnectedMode { Section("Live setup") { NavigationLink("Search / confirm building", destination: ConnectedBuildingSearchView()); NavigationLink("Live requests & bookings", destination: ConnectedWorkspaceView()) } }
            Section("Original workflow") { NavigationLink("Full Checklist", destination: OriginalAppCoverageView(screen: .fullChecklist)); NavigationLink("Blocked Tasks", destination: OriginalAppCoverageView(screen: .blockedTask)); NavigationLink("Move Timeline", destination: OriginalAppCoverageView(screen: .timeline)); NavigationLink("Old Home Dashboard", destination: OriginalAppCoverageView(screen: .oldHomeDashboard)) }
            Section("Move tools") { NavigationLink("Move Day Live", value: AppRoute.moveDay); NavigationLink("Status Sharing", value: AppRoute.statusShare); NavigationLink("New-home Starter Pack", value: AppRoute.starterPack) }
        }.navigationTitle("My Move").navigationDestination(for: AppRoute.self) { FeatureRouter(route: $0) }
    }
    private func statusIcon(_ status: MoveTask.Status) -> String { switch status { case .completed: "checkmark.circle.fill"; case .inProgress: "clock.fill"; case .blocked: "lock.fill"; case .pending: "circle" } }
    private func statusColor(_ status: MoveTask.Status) -> Color { switch status { case .completed: DMTheme.green; case .inProgress: .orange; case .blocked: .red; case .pending: .secondary } }
}

struct DocumentsView: View {
    @EnvironmentObject var state: AppState
    let folders = ["Property", "Ejari", "DEWA", "Cooling", "Building", "Provider", "Inspection", "Handover", "Receipts"]
    var body: some View {
        List {
            Section("Document Wallet") { ForEach(folders, id: \.self) { folder in NavigationLink(destination: OriginalAppCoverageView(screen: .documentDetail)) { Label(folder, systemImage: "folder.fill") } }; NavigationLink("Upload Document", destination: OriginalAppCoverageView(screen: .uploadDocument)) }
            Section("Generated reports") { ForEach(state.generatedReports) { report in NavigationLink(value: report.title.contains("Landlord") ? AppRoute.handover : AppRoute.rentalIncrease) { Label { VStack(alignment: .leading) { Text(report.title); Text(report.subtitle).font(.caption).foregroundStyle(.secondary) } } icon: { Image(systemName: report.systemImage).foregroundStyle(DMTheme.green) } } } }
            Section("Evidence tools") { NavigationLink("Move-in Inspection", value: AppRoute.moveInInspection); NavigationLink("Move-out Inspection", value: AppRoute.moveOutInspection); NavigationLink("Condition Report", value: AppRoute.conditionReport); NavigationLink("Dispute Evidence", value: AppRoute.disputeEvidence); NavigationLink("Inspection Summary", destination: OriginalAppCoverageView(screen: .inspectionSummary)) }
        }.navigationTitle("Documents").navigationDestination(for: AppRoute.self) { FeatureRouter(route: $0) }
    }
}

struct MoneyView: View {
    var body: some View {
        List {
            Section { VStack(alignment: .leading, spacing: 8) { Text("Move budget").font(.headline); Text("AED 4,850").font(.largeTitle.bold()); Text("Expected refunds AED 6,500").foregroundStyle(DMTheme.green) }.padding(.vertical, 10) }
            Section("Costs") { NavigationLink(destination: OriginalAppCoverageView(screen: .expenseDetail)) { moneyRow("Moving", "AED 2,300") }; moneyRow("Cleaning", "AED 450"); moneyRow("Painting", "AED 750"); moneyRow("Building fees", "AED 300"); NavigationLink("Add Manual Expense", destination: OriginalAppCoverageView(screen: .addManualExpense)) }
            Section("Refunds & deposits") { NavigationLink("Security Deposit Tracker", value: AppRoute.deposit); NavigationLink("All Refunds", destination: OriginalAppCoverageView(screen: .refunds)); moneyRow("DEWA deposit", "Tracking"); moneyRow("Cooling deposit", "Tracking") }
            Section("Intelligence") { Label("Hidden Cost Predictor", systemImage: "sparkles"); Label("Fair Price Benchmarks", systemImage: "chart.bar.fill") }
            Section("All tools") { NavigationLink("More & Original App Coverage", destination: MoreView()) }
        }.navigationTitle("Money").navigationDestination(for: AppRoute.self) { FeatureRouter(route: $0) }
    }
    private func moneyRow(_ title: String, _ value: String) -> some View { HStack { Text(title); Spacer(); Text(value).foregroundStyle(.secondary) } }
}

extension View {
    func dmCard(background: Color = DMTheme.card) -> some View { self.padding(16).background(background).clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous)) }
}
