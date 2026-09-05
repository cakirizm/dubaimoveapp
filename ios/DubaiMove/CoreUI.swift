import SwiftUI
import MapKit
import UIKit

struct DMTheme {
    private static let appearanceBootstrap: Void = { DMPremiumAppearance.apply() }()

    static let green: Color = {
        _ = appearanceBootstrap
        return Color(red: 0.025, green: 0.355, blue: 0.265)
    }()
    static let greenBright = Color(red: 0.055, green: 0.515, blue: 0.385)
    static let greenDeep = Color(red: 0.018, green: 0.205, blue: 0.155)
    static let mint = Color(red: 0.905, green: 0.965, blue: 0.938)
    static let mintStrong = Color(red: 0.815, green: 0.925, blue: 0.865)
    static let sand = Color(red: 0.975, green: 0.955, blue: 0.905)
    static let gold = Color(red: 0.72, green: 0.55, blue: 0.22)
    static let ink = Color(uiColor: UIColor { traits in
        traits.userInterfaceStyle == .dark
        ? UIColor(red: 0.93, green: 0.95, blue: 0.94, alpha: 1)
        : UIColor(red: 0.065, green: 0.095, blue: 0.085, alpha: 1)
    })
    static let secondaryInk = Color(uiColor: .secondaryLabel)
    static let page = Color(uiColor: UIColor { traits in
        traits.userInterfaceStyle == .dark
        ? UIColor(red: 0.055, green: 0.065, blue: 0.06, alpha: 1)
        : UIColor(red: 0.965, green: 0.972, blue: 0.968, alpha: 1)
    })
    static let card = Color(uiColor: UIColor { traits in
        traits.userInterfaceStyle == .dark
        ? UIColor(red: 0.09, green: 0.105, blue: 0.098, alpha: 1)
        : UIColor.white
    })
    static let cardMuted = Color(uiColor: UIColor { traits in
        traits.userInterfaceStyle == .dark
        ? UIColor(red: 0.11, green: 0.125, blue: 0.118, alpha: 1)
        : UIColor(red: 0.985, green: 0.988, blue: 0.986, alpha: 1)
    })
    static let border = Color(uiColor: UIColor { traits in
        traits.userInterfaceStyle == .dark
        ? UIColor.white.withAlphaComponent(0.075)
        : UIColor.black.withAlphaComponent(0.06)
    })
    static let shadow = Color.black.opacity(0.07)
}

enum DMPremiumAppearance {
    private static var applied = false

    static func apply() {
        guard !applied else { return }
        applied = true

        let nav = UINavigationBarAppearance()
        nav.configureWithTransparentBackground()
        nav.backgroundEffect = UIBlurEffect(style: .systemChromeMaterial)
        nav.backgroundColor = UIColor.systemBackground.withAlphaComponent(0.88)
        nav.shadowColor = .clear
        nav.titleTextAttributes = [
            .foregroundColor: UIColor.label,
            .font: UIFont.systemFont(ofSize: 17, weight: .semibold)
        ]
        nav.largeTitleTextAttributes = [
            .foregroundColor: UIColor.label,
            .font: UIFont.systemFont(ofSize: 34, weight: .bold)
        ]
        UINavigationBar.appearance().standardAppearance = nav
        UINavigationBar.appearance().scrollEdgeAppearance = nav
        UINavigationBar.appearance().compactAppearance = nav
        UINavigationBar.appearance().tintColor = UIColor(red: 0.025, green: 0.355, blue: 0.265, alpha: 1)

        let tab = UITabBarAppearance()
        tab.configureWithTransparentBackground()
        tab.backgroundEffect = UIBlurEffect(style: .systemChromeMaterial)
        tab.backgroundColor = UIColor.systemBackground.withAlphaComponent(0.94)
        tab.shadowColor = UIColor.separator.withAlphaComponent(0.16)
        UITabBar.appearance().standardAppearance = tab
        UITabBar.appearance().scrollEdgeAppearance = tab
        UITabBar.appearance().tintColor = UIColor(red: 0.025, green: 0.355, blue: 0.265, alpha: 1)
        UITabBar.appearance().unselectedItemTintColor = UIColor.secondaryLabel.withAlphaComponent(0.8)

        UITableView.appearance().backgroundColor = .clear
        UITableView.appearance().sectionHeaderTopPadding = 12
        UISegmentedControl.appearance().selectedSegmentTintColor = UIColor(red: 0.025, green: 0.355, blue: 0.265, alpha: 1)
        UISegmentedControl.appearance().setTitleTextAttributes([.foregroundColor: UIColor.white], for: .selected)
        UISegmentedControl.appearance().setTitleTextAttributes([.foregroundColor: UIColor.label], for: .normal)
    }
}

struct RootTabView: View {
    @EnvironmentObject var state: AppState
    var body: some View {
        TabView(selection: $state.selectedTab) {
            NavigationStack { HomeView() }.tag(MainTab.home).tabItem { Label("Home", systemImage: MainTab.home.icon) }
            NavigationStack {
                if APIConfiguration.isConnectedMode { ConnectedMyMoveView() } else { MyMoveView() }
            }.tag(MainTab.move).tabItem { Label("My Move", systemImage: MainTab.move.icon) }
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
        .background(DMTheme.page.ignoresSafeArea())
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
            VStack(alignment: .leading, spacing: 4) { Text("Good morning").font(.subheadline.weight(.medium)).foregroundStyle(.secondary); Text("Your Dubai move").font(.largeTitle.bold()).tracking(-0.7) }
            Spacer()
            NavigationLink(destination: OriginalScreenIndexView()) {
                Circle().fill(DMTheme.green).frame(width: 44, height: 44).overlay(Text("DM").foregroundStyle(.white).font(.caption.bold()))
                    .shadow(color: DMTheme.green.opacity(0.18), radius: 8, y: 4)
            }.accessibilityLabel("Open full Dubai Move tools")
        }
    }

    private var routeCard: some View {
        NavigationLink(value: AppRoute.map) {
            VStack(alignment: .leading, spacing: 12) {
                Label("Move route", systemImage: "map.fill").font(.headline)
                HStack(alignment: .top, spacing: 14) {
                    VStack(spacing: 6) { Circle().fill(DMTheme.green).frame(width: 10, height: 10); Rectangle().fill(.secondary.opacity(0.25)).frame(width: 2, height: 24); Circle().stroke(DMTheme.green, lineWidth: 2).frame(width: 10, height: 10) }
                    VStack(alignment: .leading, spacing: 14) { Text("Dubai Marina · \(state.currentProperty.name)").font(.subheadline.bold()); Text("Dubai Hills · \(state.newProperty.name)").font(.subheadline.bold()) }
                    Spacer(); Image(systemName: "chevron.right").font(.footnote.weight(.bold)).foregroundStyle(.tertiary)
                }
            }.dmCard()
        }.buttonStyle(.plain)
    }

    private var readinessCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 3) { Text("MOVE READINESS").font(.caption2.bold()).tracking(0.7).foregroundStyle(DMTheme.green); Text("\(state.readiness)% READY").font(.title2.bold()) }
                Spacer()
                ZStack { Circle().stroke(.gray.opacity(0.14), lineWidth: 8); Circle().trim(from: 0, to: Double(state.readiness) / 100).stroke(DMTheme.green, style: .init(lineWidth: 8, lineCap: .round)).rotationEffect(.degrees(-90)); Text("\(state.readiness)%").font(.caption.bold()) }.frame(width: 62, height: 62)
            }
            ProgressView(value: Double(state.readiness), total: 100).tint(DMTheme.green)
            Text("8 completed · 3 waiting · 2 blocked").font(.footnote).foregroundStyle(.secondary)
            NavigationLink(destination: OriginalAppCoverageView(screen: .readinessDetail)) { Label("Open readiness detail", systemImage: "arrow.right.circle.fill").font(.subheadline.weight(.semibold)) }
        }.dmCard(background: DMTheme.mint)
    }

    private var nextAction: some View {
        NavigationLink(value: AppRoute.ejari) {
            VStack(alignment: .leading, spacing: 10) { Text("NEXT ACTION").font(.caption2.bold()).tracking(0.8).foregroundStyle(DMTheme.green); Text("Complete your new Ejari").font(.title3.bold()); Text("DEWA Move-To stays blocked until Ejari readiness is complete.").foregroundStyle(.secondary); Label("Continue Ejari", systemImage: "arrow.right.circle.fill").font(.headline).foregroundStyle(DMTheme.green) }.dmCard(background: DMTheme.mint)
        }.buttonStyle(.plain)
    }

    private var importantDates: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack { Text("Important dates").font(.title3.bold()); Spacer(); NavigationLink("Calendar", value: AppRoute.calendar).font(.subheadline.bold()) }
            dateRow("Ejari target", "18 Sep", "doc.text.fill"); dateRow("Move permit", "20 Sep", "building.2.fill"); dateRow("DEWA", "24 Sep", "bolt.fill"); dateRow("Move day", "28 Sep", "truck.box.fill")
        }.dmCard()
    }
    private func dateRow(_ title: String, _ date: String, _ icon: String) -> some View { HStack(spacing: 12) { Image(systemName: icon).font(.subheadline.weight(.semibold)).foregroundStyle(DMTheme.green).frame(width: 32, height: 32).background(DMTheme.mint).clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous)); Text(title); Spacer(); Text(date).font(.subheadline.weight(.medium)).foregroundStyle(.secondary) } }

    private var moneySnapshot: some View {
        NavigationLink(value: AppRoute.deposit) {
            HStack { VStack(alignment: .leading, spacing: 5) { Text("Money & refunds").font(.headline); Text("Estimated move cost · AED 4,850").font(.subheadline); Text("Expected refunds · AED 6,500").font(.subheadline.weight(.semibold)).foregroundStyle(DMTheme.green) }; Spacer(); Image(systemName: "chevron.right").font(.footnote.weight(.bold)).foregroundStyle(.tertiary) }.dmCard()
        }.buttonStyle(.plain)
    }

    private var aiCard: some View {
        NavigationLink(value: AppRoute.aiCopilot) {
            HStack(spacing: 14) { Image(systemName: "sparkles").font(.title2).foregroundStyle(DMTheme.green).frame(width: 42, height: 42).background(DMTheme.mint).clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous)); VStack(alignment: .leading, spacing: 4) { Text("Ask Dubai Move").font(.headline); Text("What should I do next? What is blocking my move?").font(.subheadline).foregroundStyle(.secondary) }; Spacer(); Image(systemName: "chevron.right").font(.footnote.weight(.bold)).foregroundStyle(.tertiary) }.dmCard(background: DMTheme.sand)
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
    private func tool(_ title: String, _ icon: String, _ route: AppRoute) -> some View { NavigationLink(value: route) { VStack(alignment: .leading, spacing: 12) { Image(systemName: icon).font(.title3.weight(.semibold)).foregroundStyle(DMTheme.green).frame(width: 38, height: 38).background(DMTheme.mint).clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous)); Text(title).font(.subheadline.bold()).foregroundStyle(DMTheme.ink) }.frame(maxWidth: .infinity, minHeight: 96, alignment: .leading).dmCard() }.buttonStyle(.plain) }
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
        }.scrollContentBackground(.hidden).background(DMTheme.page).navigationTitle("My Move").navigationDestination(for: AppRoute.self) { FeatureRouter(route: $0) }
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
        }.scrollContentBackground(.hidden).background(DMTheme.page).navigationTitle("Documents").navigationDestination(for: AppRoute.self) { FeatureRouter(route: $0) }
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
        }.scrollContentBackground(.hidden).background(DMTheme.page).navigationTitle("Money").navigationDestination(for: AppRoute.self) { FeatureRouter(route: $0) }
    }
    private func moneyRow(_ title: String, _ value: String) -> some View { HStack { Text(title); Spacer(); Text(value).foregroundStyle(.secondary) } }
}

private struct DMCardModifier: ViewModifier {
    let background: Color

    func body(content: Content) -> some View {
        content
            .padding(16)
            .background(background)
            .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .stroke(DMTheme.border, lineWidth: 0.75)
            }
            .shadow(color: DMTheme.shadow, radius: 13, x: 0, y: 5)
    }
}

extension View {
    func dmCard(background: Color = DMTheme.card) -> some View {
        modifier(DMCardModifier(background: background))
    }

    func dmScreenBackground() -> some View {
        self.background(DMTheme.page.ignoresSafeArea())
    }

    func dmPremiumList() -> some View {
        self.scrollContentBackground(.hidden).background(DMTheme.page)
    }
}
