import SwiftUI

// MARK: - Premium customer shell

struct PremiumRootTabView: View {
    @EnvironmentObject private var state: AppState

    var body: some View {
        TabView(selection: $state.selectedTab) {
            NavigationStack { PremiumHomeView() }
                .tag(MainTab.home)
                .tabItem { Label("Home", systemImage: "house.fill") }

            NavigationStack { PremiumJourneyView() }
                .tag(MainTab.move)
                .tabItem { Label("My Move", systemImage: "list.number") }

            NavigationStack { PremiumServicesView() }
                .tag(MainTab.services)
                .tabItem { Label("Services", systemImage: "sparkles.rectangle.stack.fill") }

            NavigationStack { FunctionalV2DocumentsView() }
                .tag(MainTab.documents)
                .tabItem { Label("Documents", systemImage: "folder.fill") }

            NavigationStack { ConnectedMoneyView() }
                .tag(MainTab.money)
                .tabItem { Label("Money", systemImage: "banknote.fill") }
        }
        .tint(DMTheme.green)
        .toolbarBackground(.visible, for: .tabBar)
    }
}

// MARK: - Journey model

enum PremiumMoveTarget {
    case documents, ejari, dewa, telecom, cooling, building, services, inspection, handover, money, leaving, setup
}

struct PremiumMoveStep: Identifiable {
    let id = UUID()
    let title: String
    let note: String
    let why: String
    let icon: String
    let target: PremiumMoveTarget
    let key: String

    var storageKey: String { "dubaimove.premium.step.\(key)" }
}

struct PremiumMovePlan {
    let shortTitle: String
    let heroTitle: String
    let heroIcon: String
    let intro: String
    let steps: [PremiumMoveStep]

    static func plan(for kind: String) -> PremiumMovePlan {
        if kind == LocalMoveKind.toDubai.rawValue {
            return PremiumMovePlan(
                shortTitle: "Moving to Dubai",
                heroTitle: "Settle in with a clear order",
                heroIcon: "airplane.arrival",
                intro: "Start with your home documents, then activate the essentials around the property.",
                steps: [
                    step("Confirm your tenancy documents", "Keep the signed tenancy contract and key property details together before starting regulated utility steps.", "These details are commonly needed repeatedly during setup.", "doc.text.fill", .documents, "toDubai.docs"),
                    step("Register / confirm Ejari", "Use the matching Dubai Land Department channel. Opening the official page never marks the task completed automatically.", "Ejari is a core tenancy record used across many Dubai move processes.", "checkmark.seal.fill", .ejari, "toDubai.ejari"),
                    step("Activate DEWA", "Choose Move-In for the new premise and keep the account and premise details ready.", "Electricity and water should be scheduled around your occupancy date.", "bolt.fill", .dewa, "toDubai.dewa"),
                    step("Arrange home internet", "Check home internet options and book installation early enough for your move date.", "Installation availability can affect your first days in the property.", "wifi", .telecom, "toDubai.telecom"),
                    step("Check the cooling provider", "Confirm whether the building uses Empower, Emicool or a building-managed arrangement.", "Cooling can be separate from DEWA depending on the property.", "snowflake", .cooling, "toDubai.cooling"),
                    step("Check building move-in rules", "Ask management about permits, lift booking, mover access windows and any operational deposits.", "Building access rules can determine when your mover is allowed in.", "building.2.fill", .building, "toDubai.building"),
                    step("Book move-in services", "Browse cleaning, moving, painting and maintenance providers before booking.", "Coordinating providers around one move date reduces last-minute gaps.", "sparkles", .services, "toDubai.services")
                ]
            )
        }

        if kind == LocalMoveKind.leavingDubai.rawValue {
            return PremiumMovePlan(
                shortTitle: "Leaving Dubai",
                heroTitle: "Close your home cleanly",
                heroIcon: "airplane.departure",
                intro: "Work backwards from your handover date so utilities, property condition and refunds are not forgotten.",
                steps: [
                    step("Set your final handover date", "Use one confirmed date as the anchor for utilities, internet, cleaning and key return.", "Every move-out task becomes easier to schedule around one date.", "calendar", .setup, "leave.date"),
                    step("Review Ejari exit tasks", "Use the correct official cancellation or certificate route for your situation.", "Your tenancy record and physical handover should stay coordinated.", "doc.text.fill", .ejari, "leave.ejari"),
                    step("Schedule DEWA Move-Out", "Plan deactivation for the correct date and follow the official final-bill and refund process.", "Ending service on the wrong day can create avoidable operational problems.", "bolt.slash.fill", .dewa, "leave.dewa"),
                    step("Cancel or relocate internet", "Use the matching provider route and do not assume the home service closes automatically.", "Telecom has a separate operational process from DEWA.", "wifi.slash", .telecom, "leave.telecom"),
                    step("Inspect, clean and repair", "Capture condition photos first, then arrange cleaning, painting or maintenance if needed.", "A factual condition record helps you manage the handover in an organized way.", "camera.viewfinder", .inspection, "leave.inspect"),
                    step("Prepare keys and handover", "Track keys, final-bill references and the documents you want to keep together.", "A structured handover pack reduces forgotten items.", "key.fill", .handover, "leave.handover"),
                    step("Track deposits and refunds", "Record expected amounts and status. Dubai Move does not decide entitlement or legal responsibility.", "Different refunds can arrive on different timelines.", "banknote.fill", .money, "leave.money")
                ]
            )
        }

        if kind == LocalMoveKind.serviceOnly.rawValue {
            return PremiumMovePlan(
                shortTitle: "Home services",
                heroTitle: "Find the right provider first",
                heroIcon: "sparkles.rectangle.stack.fill",
                intro: "Browse the service, compare provider profiles and message before you commit.",
                steps: [
                    step("Choose a service", "Cleaning, moving, painting, maintenance, storage or inspection.", "Starting with the job type keeps the provider list relevant.", "square.grid.2x2.fill", .services, "service.choose"),
                    step("Compare providers", "Review sample prices, ratings, availability and what is included.", "You should be able to browse before making a request.", "arrow.left.arrow.right", .services, "service.compare"),
                    step("Message before booking", "Ask scope questions and confirm what the price includes.", "Clear scope reduces surprises on service day.", "message.fill", .services, "service.message")
                ]
            )
        }

        return PremiumMovePlan(
            shortTitle: "Within Dubai",
            heroTitle: "Move across Dubai step by step",
            heroIcon: "arrow.left.arrow.right",
            intro: "Finish old-home tasks while preparing the new home in the right dependency order.",
            steps: [
                step("Confirm both tenancy details", "Keep the current-home and new-home contract and property details ready before starting transfer tasks.", "You will repeatedly need both premises during a Dubai-to-Dubai move.", "doc.on.doc.fill", .documents, "within.docs"),
                step("Prepare the new Ejari", "Use the relevant DLD route for the new tenancy and keep its status visible in your checklist.", "It is a key new-home tenancy record.", "checkmark.seal.fill", .ejari, "within.ejari"),
                step("Plan DEWA Move-To", "Use Move-To when transferring between Dubai premises instead of mixing Move-In and Move-Out journeys.", "This keeps the old and new premise transition coordinated.", "bolt.fill", .dewa, "within.dewa"),
                step("Relocate internet", "Check your provider’s home relocation route and reserve a suitable date before move day.", "A transfer may require an appointment or new equipment.", "wifi", .telecom, "within.telecom"),
                step("Check both buildings’ move rules", "Confirm permits, lift slots, loading access and management requirements at both ends.", "Building access can block the mover even when everything else is ready.", "building.2.fill", .building, "within.building"),
                step("Browse and book movers", "Compare provider profile, availability, price range and included services before booking.", "The provider should fit your building rules and your move date.", "truck.box.fill", .services, "within.movers"),
                step("Inspect the old home", "Capture condition photos and note cleaning, painting or repair needs before handover.", "It gives you an organized factual record of condition.", "camera.viewfinder", .inspection, "within.inspect"),
                step("Complete old-home handover", "Track keys, relevant final bills and the documents you want in your handover pack.", "This closes the operational move-out side cleanly.", "key.fill", .handover, "within.handover")
            ]
        )
    }

    private static func step(_ title: String, _ note: String, _ why: String, _ icon: String, _ target: PremiumMoveTarget, _ key: String) -> PremiumMoveStep {
        PremiumMoveStep(title: title, note: note, why: why, icon: icon, target: target, key: key)
    }
}

// MARK: - Shared visual components

private struct PremiumSectionTitle: View {
    let title: String
    let subtitle: String

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title).font(.title3.bold()).foregroundStyle(DMTheme.ink)
            Text(subtitle).font(.caption).foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

private struct PremiumPhotoCard: View {
    let title: String
    let subtitle: String
    let icon: String
    let colors: [Color]

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            LinearGradient(colors: colors, startPoint: .topLeading, endPoint: .bottomTrailing)
            VStack {
                HStack {
                    Spacer()
                    Image(systemName: icon)
                        .font(.system(size: 72, weight: .thin))
                        .foregroundStyle(.white.opacity(0.22))
                        .padding(.top, 6)
                        .padding(.trailing, 5)
                }
                Spacer()
            }
            VStack(alignment: .leading, spacing: 4) {
                Text(title).font(.title3.bold()).foregroundStyle(.white)
                Text(subtitle).font(.caption).foregroundStyle(.white.opacity(0.82)).lineLimit(2)
            }
            .padding(15)
        }
        .frame(width: 180, height: 132)
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
        .shadow(color: Color.black.opacity(0.08), radius: 10, y: 5)
    }
}

// MARK: - Home

struct PremiumHomeView: View {
    @EnvironmentObject private var state: AppState
    @AppStorage("dubaimove.v2.moveKind") private var moveKind = LocalMoveKind.withinDubai.rawValue
    @AppStorage("dubaimove.v2.currentArea") private var currentArea = ""
    @AppStorage("dubaimove.v2.newArea") private var newArea = ""
    @AppStorage("dubaimove.v2.moveDate") private var moveDateEpoch = Date().addingTimeInterval(86400 * 21).timeIntervalSince1970
    @State private var refreshID = UUID()

    private var plan: PremiumMovePlan { PremiumMovePlan.plan(for: moveKind) }
    private var readiness: Int {
        let completed = plan.steps.filter { UserDefaults.standard.bool(forKey: $0.storageKey) }.count
        guard !plan.steps.isEmpty else { return 0 }
        return Int((Double(completed) / Double(plan.steps.count) * 100).rounded())
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 22) {
                topBar
                hero
                nextStepCard
                officialEssentials
                journeyPreview
                servicesPreview
                smartHints
                guidanceBoundary
            }
            .id(refreshID)
            .padding(.horizontal, 16)
            .padding(.top, 10)
            .padding(.bottom, 34)
        }
        .background(DMTheme.page.ignoresSafeArea())
        .navigationBarTitleDisplayMode(.inline)
        .task { state.readiness = readiness }
    }

    private var topBar: some View {
        HStack(spacing: 12) {
            Image("BrandLogo").resizable().scaledToFit().frame(width: 54, height: 54)
            VStack(alignment: .leading, spacing: 2) {
                Text("Dubai Move").font(.title2.bold()).foregroundStyle(DMTheme.ink)
                Text("Your move, organized.").font(.caption).foregroundStyle(.secondary)
            }
            Spacer()
            NavigationLink(destination: FunctionalV2MoreView()) {
                Image(systemName: "person.crop.circle.fill")
                    .font(.title2)
                    .foregroundStyle(DMTheme.green)
                    .frame(width: 44, height: 44)
                    .background(DMTheme.card)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(DMTheme.border, lineWidth: 1))
            }
        }
    }

    private var hero: some View {
        VStack(alignment: .leading, spacing: 18) {
            HStack(alignment: .top, spacing: 14) {
                VStack(alignment: .leading, spacing: 7) {
                    Text(plan.shortTitle.uppercased())
                        .font(.caption2.bold())
                        .tracking(1.5)
                        .foregroundStyle(.white.opacity(0.78))
                    Text(plan.heroTitle)
                        .font(.system(size: 29, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                    Text(routeSubtitle)
                        .font(.subheadline)
                        .foregroundStyle(.white.opacity(0.80))
                }
                Spacer(minLength: 8)
                readinessRing
            }

            HStack(spacing: 12) {
                Label(Date(timeIntervalSince1970: moveDateEpoch).formatted(date: .abbreviated, time: .omitted), systemImage: "calendar")
                Spacer()
                NavigationLink(destination: FunctionalV2MoveSetupView()) {
                    Label("Edit move", systemImage: "slider.horizontal.3")
                }
            }
            .font(.caption.bold())
            .foregroundStyle(.white)
        }
        .padding(20)
        .background(
            ZStack {
                LinearGradient(colors: [DMTheme.greenDeep, DMTheme.green, DMTheme.greenBright], startPoint: .topLeading, endPoint: .bottomTrailing)
                Image(systemName: plan.heroIcon)
                    .font(.system(size: 150, weight: .ultraLight))
                    .foregroundStyle(.white.opacity(0.07))
                    .offset(x: 115, y: 35)
            }
        )
        .clipShape(RoundedRectangle(cornerRadius: 30, style: .continuous))
        .shadow(color: DMTheme.greenDeep.opacity(0.22), radius: 22, y: 11)
    }

    private var readinessRing: some View {
        ZStack {
            Circle().stroke(Color.white.opacity(0.20), lineWidth: 7)
            Circle()
                .trim(from: 0, to: max(0.02, Double(readiness) / 100.0))
                .stroke(Color.white, style: StrokeStyle(lineWidth: 7, lineCap: .round))
                .rotationEffect(.degrees(-90))
            VStack(spacing: -1) {
                Text("\(readiness)%").font(.headline.bold())
                Text("READY").font(.system(size: 8, weight: .bold)).tracking(1)
            }
            .foregroundStyle(.white)
        }
        .frame(width: 76, height: 76)
    }

    private var routeSubtitle: String {
        let from = currentArea.isEmpty ? "Current home" : currentArea
        let to = newArea.isEmpty ? "Destination" : newArea
        if moveKind == LocalMoveKind.toDubai.rawValue { return "Arrival plan → \(to)" }
        if moveKind == LocalMoveKind.leavingDubai.rawValue { return "\(from) → departure" }
        if moveKind == LocalMoveKind.serviceOnly.rawValue { return "Home services workspace" }
        return "\(from) → \(to)"
    }

    @ViewBuilder
    private var nextStepCard: some View {
        if let step = plan.steps.first(where: { !UserDefaults.standard.bool(forKey: $0.storageKey) }) ?? plan.steps.last {
            NavigationLink(destination: premiumDestination(for: step.target)) {
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text("DO THIS NEXT").font(.caption2.bold()).tracking(1.2).foregroundStyle(DMTheme.green)
                        Spacer()
                        Image(systemName: "arrow.right.circle.fill").foregroundStyle(DMTheme.green)
                    }
                    HStack(alignment: .top, spacing: 14) {
                        Image(systemName: step.icon)
                            .font(.title2.weight(.semibold))
                            .foregroundStyle(DMTheme.green)
                            .frame(width: 48, height: 48)
                            .background(DMTheme.mint)
                            .clipShape(RoundedRectangle(cornerRadius: 15))
                        VStack(alignment: .leading, spacing: 5) {
                            Text(step.title).font(.title3.bold()).foregroundStyle(DMTheme.ink)
                            Text(step.note).font(.subheadline).foregroundStyle(.secondary).fixedSize(horizontal: false, vertical: true)
                        }
                    }
                }
                .padding(17)
                .background(DMTheme.card)
                .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
                .overlay(RoundedRectangle(cornerRadius: 22).stroke(DMTheme.border, lineWidth: 1))
                .shadow(color: DMTheme.shadow, radius: 12, y: 6)
            }
            .buttonStyle(.plain)
        }
    }

    private var officialEssentials: some View {
        VStack(alignment: .leading, spacing: 12) {
            PremiumSectionTitle(title: "Official essentials", subtitle: "Operational guidance plus the correct official channel when the action belongs outside Dubai Move")
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    NavigationLink(destination: EjariV2View()) { PremiumPhotoCard(title: "Ejari", subtitle: "Dubai Land Department", icon: "doc.text.fill", colors: [DMTheme.greenDeep, DMTheme.green]) }
                    NavigationLink(destination: DewaV2View()) { PremiumPhotoCard(title: "DEWA", subtitle: "Move-In · Move-To · Move-Out", icon: "bolt.fill", colors: [.blue, .cyan]) }
                    NavigationLink(destination: TelecomV2View()) { PremiumPhotoCard(title: "du", subtitle: "Home relocation", icon: "wifi", colors: [.purple, .pink]) }
                    NavigationLink(destination: TelecomV2View()) { PremiumPhotoCard(title: "e&", subtitle: "Home move", icon: "antenna.radiowaves.left.and.right", colors: [.red, .orange]) }
                    NavigationLink(destination: CoolingV2View()) { PremiumPhotoCard(title: "Cooling", subtitle: "Empower · Emicool", icon: "snowflake", colors: [.cyan, .teal]) }
                }
                .buttonStyle(.plain)
            }
        }
    }

    private var journeyPreview: some View {
        VStack(alignment: .leading, spacing: 12) {
            PremiumSectionTitle(title: "Your ordered plan", subtitle: "Follow the sequence. Every step explains what to do and why it matters.")

            ForEach(Array(plan.steps.prefix(4).enumerated()), id: \.element.id) { index, step in
                journeyRow(index: index, step: step)
            }

            NavigationLink("Open full move plan", destination: PremiumJourneyView())
                .font(.subheadline.bold())
                .foregroundStyle(DMTheme.green)
                .padding(.leading, 4)
        }
    }

    private func journeyRow(index: Int, step: PremiumMoveStep) -> some View {
        let completed = UserDefaults.standard.bool(forKey: step.storageKey)
        let circleColor: Color = completed ? DMTheme.green : DMTheme.mint
        let numberColor: Color = completed ? Color.white : DMTheme.green

        return NavigationLink(destination: premiumDestination(for: step.target)) {
            HStack(alignment: .top, spacing: 13) {
                ZStack {
                    Circle().fill(circleColor)
                    Text("\(index + 1)")
                        .font(.caption.bold())
                        .foregroundStyle(numberColor)
                }
                .frame(width: 34, height: 34)

                VStack(alignment: .leading, spacing: 4) {
                    Text(step.title).font(.headline).foregroundStyle(DMTheme.ink)
                    Text(step.note).font(.caption).foregroundStyle(.secondary).lineLimit(2)
                }
                Spacer()
                Image(systemName: "chevron.right").font(.caption.bold()).foregroundStyle(Color.tertiary)
            }
            .padding(14)
            .background(DMTheme.card)
            .clipShape(RoundedRectangle(cornerRadius: 18))
            .overlay(RoundedRectangle(cornerRadius: 18).stroke(completed ? DMTheme.green.opacity(0.24) : DMTheme.border, lineWidth: 1))
        }
        .buttonStyle(.plain)
    }

    private var servicesPreview: some View {
        VStack(alignment: .leading, spacing: 12) {
            PremiumSectionTitle(title: "Book home services", subtitle: "Browse providers first. Compare profiles, prices and available slots before you contact them.")
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    NavigationLink(destination: PremiumServiceCategoryView(category: "Cleaning")) { PremiumPhotoCard(title: "Cleaning", subtitle: "Deep · Regular · Move-out", icon: "sparkles", colors: [.mint, .green]) }
                    NavigationLink(destination: PremiumServiceCategoryView(category: "Moving")) { PremiumPhotoCard(title: "Moving", subtitle: "Packing · Truck · Unpacking", icon: "truck.box.fill", colors: [.orange, .yellow]) }
                    NavigationLink(destination: PremiumServiceCategoryView(category: "Painting")) { PremiumPhotoCard(title: "Painting", subtitle: "Touch-up · Full repaint", icon: "paintbrush.fill", colors: [.indigo, .purple]) }
                    NavigationLink(destination: PremiumServiceCategoryView(category: "Maintenance")) { PremiumPhotoCard(title: "Maintenance", subtitle: "Handyman · AC · Plumbing", icon: "wrench.and.screwdriver.fill", colors: [.blue, .teal]) }
                }
                .buttonStyle(.plain)
            }
            NavigationLink("Explore all services", destination: PremiumServicesView())
                .font(.subheadline.bold())
                .foregroundStyle(DMTheme.green)
                .padding(.leading, 4)
        }
    }

    private var smartHints: some View {
        VStack(alignment: .leading, spacing: 12) {
            PremiumSectionTitle(title: "Before move day", subtitle: "Small operational details that are easy to forget")
            hint("Check both building access windows", "building.2.fill")
            hint("Keep key documents together in Documents", "folder.fill")
            hint("Do not schedule utility shut-off before your actual handover", "calendar.badge.exclamationmark")
            hint("Confirm what a provider price includes before booking", "checklist")
        }
        .padding(16)
        .background(DMTheme.card)
        .clipShape(RoundedRectangle(cornerRadius: 22))
        .overlay(RoundedRectangle(cornerRadius: 22).stroke(DMTheme.border, lineWidth: 1))
    }

    private func hint(_ text: String, _ icon: String) -> some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: icon).foregroundStyle(DMTheme.green).frame(width: 24)
            Text(text).font(.subheadline).foregroundStyle(.secondary)
        }
    }

    private var guidanceBoundary: some View {
        VStack(alignment: .leading, spacing: 9) {
            Label("How Dubai Move guides you", systemImage: "checkmark.shield.fill")
                .font(.headline)
                .foregroundStyle(DMTheme.green)
            Text("Dubai Move organizes practical move tasks, explains operational dependencies, stores your own notes and opens verified official channels when the transaction belongs to an authority or provider. We do not provide legal advice, decide rights or liabilities, or represent a government authority.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding(16)
        .background(DMTheme.sand)
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
}

// MARK: - Full guided move plan

struct PremiumJourneyView: View {
    @AppStorage("dubaimove.v2.moveKind") private var moveKind = LocalMoveKind.withinDubai.rawValue
    @State private var refreshID = UUID()

    private var plan: PremiumMovePlan { PremiumMovePlan.plan(for: moveKind) }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                VStack(alignment: .leading, spacing: 7) {
                    Text(plan.shortTitle.uppercased()).font(.caption2.bold()).tracking(1.5).foregroundStyle(DMTheme.green)
                    Text("Your move plan").font(.largeTitle.bold()).tracking(-0.8)
                    Text(plan.intro).font(.subheadline).foregroundStyle(.secondary)
                }

                ForEach(Array(plan.steps.enumerated()), id: \.element.id) { index, step in
                    stepCard(index: index, step: step)
                }

                VStack(alignment: .leading, spacing: 8) {
                    Label("Important boundary", systemImage: "checkmark.shield.fill").font(.headline).foregroundStyle(DMTheme.green)
                    Text("Dubai Move provides practical organization and verified-channel navigation. It does not provide legal advice, determine rights or liabilities, or represent a government authority.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
                .padding(16)
                .background(DMTheme.sand)
                .clipShape(RoundedRectangle(cornerRadius: 18))
            }
            .id(refreshID)
            .padding(16)
            .padding(.bottom, 24)
        }
        .background(DMTheme.page.ignoresSafeArea())
        .navigationTitle("My Move")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func stepCard(index: Int, step: PremiumMoveStep) -> some View {
        let completed = UserDefaults.standard.bool(forKey: step.storageKey)
        let circleColor: Color = completed ? DMTheme.green : DMTheme.mint
        let numberColor: Color = completed ? Color.white : DMTheme.green

        return VStack(alignment: .leading, spacing: 13) {
            HStack(alignment: .top, spacing: 13) {
                ZStack {
                    Circle().fill(circleColor)
                    Text("\(index + 1)").font(.headline.bold()).foregroundStyle(numberColor)
                }
                .frame(width: 42, height: 42)

                VStack(alignment: .leading, spacing: 4) {
                    Text(step.title).font(.headline)
                    Text(step.note).font(.subheadline).foregroundStyle(.secondary)
                }
                Spacer()
            }

            HStack(alignment: .top, spacing: 8) {
                Image(systemName: "lightbulb.fill").foregroundStyle(.orange)
                Text("Why this matters: \(step.why)").font(.caption).foregroundStyle(.secondary)
            }

            Divider()

            HStack {
                Button {
                    UserDefaults.standard.set(!completed, forKey: step.storageKey)
                    refreshID = UUID()
                } label: {
                    Label(completed ? "Mark not done" : "Mark done", systemImage: completed ? "arrow.uturn.backward" : "checkmark.circle.fill")
                }
                .buttonStyle(.bordered)
                .tint(DMTheme.green)

                Spacer()

                NavigationLink(destination: premiumDestination(for: step.target)) {
                    Label("Open", systemImage: "arrow.right")
                }
                .buttonStyle(.borderedProminent)
                .tint(DMTheme.green)
            }
        }
        .padding(16)
        .background(DMTheme.card)
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 22).stroke(completed ? DMTheme.green.opacity(0.35) : DMTheme.border, lineWidth: 1))
    }
}

// MARK: - Provider discovery

struct PremiumProvider: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let category: String
    let rating: Double
    let reviews: Int
    let startingPrice: Int
    let priceUnit: String
    let nextSlot: String
    let response: String
    let verified: Bool
    let tags: [String]
    let about: String
    let slots: [String]
}

extension PremiumProvider {
    static let samples: [PremiumProvider] = [
        PremiumProvider(name: "BrightNest Cleaning", category: "Cleaning", rating: 4.8, reviews: 312, startingPrice: 45, priceUnit: "AED/hour", nextSlot: "Today · 18:00", response: "~5 min", verified: true, tags: ["Move-out", "Deep clean", "Supplies included"], about: "Sample provider profile for TestFlight. Deep cleaning, regular cleaning and move-out packages.", slots: ["Today 18:00", "Tomorrow 09:00", "Tomorrow 14:00"]),
        PremiumProvider(name: "Palm & Polish", category: "Cleaning", rating: 4.7, reviews: 184, startingPrice: 160, priceUnit: "AED/studio from", nextSlot: "Tomorrow · 09:00", response: "~12 min", verified: true, tags: ["Studio", "1–3 BR", "Same-week"], about: "Sample provider profile for TestFlight. Fixed-package cleaning with selectable time slots.", slots: ["Tomorrow 09:00", "Tomorrow 13:00", "Sun 10:00"]),
        PremiumProvider(name: "MoveCraft Dubai", category: "Moving", rating: 4.9, reviews: 428, startingPrice: 850, priceUnit: "AED from", nextSlot: "Tomorrow · 08:00", response: "~7 min", verified: true, tags: ["Packing", "Truck", "Unpacking"], about: "Sample moving provider profile. Pricing varies by home size, access and packing scope.", slots: ["Tomorrow 08:00", "Tomorrow 12:00", "Sun 08:00"]),
        PremiumProvider(name: "UrbanShift Movers", category: "Moving", rating: 4.6, reviews: 205, startingPrice: 650, priceUnit: "AED from", nextSlot: "Sun · 10:00", response: "~15 min", verified: true, tags: ["Budget", "Boxes", "Dubai-wide"], about: "Sample provider profile with flexible small-move packages.", slots: ["Sun 10:00", "Sun 14:00", "Mon 09:00"]),
        PremiumProvider(name: "FreshCoat Homes", category: "Painting", rating: 4.8, reviews: 147, startingPrice: 499, priceUnit: "AED/room from", nextSlot: "Mon · 08:30", response: "~10 min", verified: true, tags: ["Touch-up", "Full repaint", "Move-out"], about: "Sample provider profile for interior painting and move-out touch-ups.", slots: ["Mon 08:30", "Mon 13:00", "Tue 09:00"]),
        PremiumProvider(name: "FixRight Home Care", category: "Maintenance", rating: 4.7, reviews: 296, startingPrice: 120, priceUnit: "AED visit from", nextSlot: "Today · 20:00", response: "~8 min", verified: true, tags: ["Handyman", "AC", "Plumbing"], about: "Sample provider profile covering common apartment and villa maintenance jobs.", slots: ["Today 20:00", "Tomorrow 10:00", "Tomorrow 16:00"]),
        PremiumProvider(name: "BoxSafe Storage", category: "Storage", rating: 4.6, reviews: 119, startingPrice: 199, priceUnit: "AED/month from", nextSlot: "Pickup tomorrow", response: "~20 min", verified: true, tags: ["Pickup", "Short-term", "Long-term"], about: "Sample storage provider profile with pickup and monthly storage options.", slots: ["Tomorrow AM", "Tomorrow PM", "Sun AM"]),
        PremiumProvider(name: "HomeCheck Dubai", category: "Inspection", rating: 4.9, reviews: 96, startingPrice: 350, priceUnit: "AED from", nextSlot: "Tomorrow · 11:00", response: "~9 min", verified: true, tags: ["Photo report", "Move-in", "Move-out"], about: "Sample property condition inspection profile. This is operational documentation, not legal advice.", slots: ["Tomorrow 11:00", "Tomorrow 15:00", "Sun 09:30"])
    ]
}

struct PremiumServicesView: View {
    private let categories: [(String, String, String, [Color])] = [
        ("Cleaning", "Deep, regular and move-out cleaning", "sparkles", [.mint, .green]),
        ("Moving", "Packing, transport and unpacking", "truck.box.fill", [.orange, .yellow]),
        ("Painting", "Touch-ups and full repainting", "paintbrush.fill", [.indigo, .purple]),
        ("Maintenance", "Handyman, AC and common repairs", "wrench.and.screwdriver.fill", [.blue, .teal]),
        ("Storage", "Pickup and short/long-term storage", "archivebox.fill", [.brown, .orange]),
        ("Inspection", "Operational condition documentation", "camera.viewfinder", [.teal, .cyan])
    ]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Home services").font(.largeTitle.bold()).tracking(-0.8)
                    Text("Browse the market before you request anything. Compare sample profiles, price ranges, availability and service scope.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                ForEach(categories, id: \.0) { item in
                    NavigationLink(destination: PremiumServiceCategoryView(category: item.0)) {
                        ZStack(alignment: .bottomLeading) {
                            LinearGradient(colors: item.3, startPoint: .topLeading, endPoint: .bottomTrailing)
                            Image(systemName: item.2)
                                .font(.system(size: 94, weight: .ultraLight))
                                .foregroundStyle(.white.opacity(0.18))
                                .offset(x: 220, y: -22)
                            VStack(alignment: .leading, spacing: 6) {
                                Text(item.0).font(.title2.bold()).foregroundStyle(.white)
                                Text(item.1).font(.subheadline).foregroundStyle(.white.opacity(0.82))
                                Text("Browse providers →").font(.caption.bold()).foregroundStyle(.white)
                            }
                            .padding(18)
                        }
                        .frame(maxWidth: .infinity, minHeight: 142)
                        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                    }
                    .buttonStyle(.plain)
                }

                Text("Provider names, prices and slots shown in backend-free TestFlight mode are clearly marked sample data. Live provider listings will come from the provider platform when connected.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .padding(14)
                    .background(DMTheme.sand)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
            }
            .padding(16)
            .padding(.bottom, 24)
        }
        .background(DMTheme.page.ignoresSafeArea())
        .navigationTitle("Services")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct PremiumServiceCategoryView: View {
    let category: String
    private var providers: [PremiumProvider] { PremiumProvider.samples.filter { $0.category == category } }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                categoryHeader

                HStack {
                    Label("Sample provider market", systemImage: "testtube.2")
                    Spacer()
                    Text("TESTFLIGHT").font(.caption2.bold())
                }
                .font(.caption.bold())
                .foregroundStyle(DMTheme.green)
                .padding(12)
                .background(DMTheme.mint)
                .clipShape(RoundedRectangle(cornerRadius: 14))

                if providers.isEmpty {
                    ContentUnavailableView("Provider listings coming soon", systemImage: "building.2.crop.circle", description: Text("The provider platform will supply live listings for this category."))
                } else {
                    ForEach(providers) { provider in
                        NavigationLink(destination: PremiumProviderDetailView(provider: provider)) {
                            providerCard(provider)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .padding(16)
            .padding(.bottom, 24)
        }
        .background(DMTheme.page.ignoresSafeArea())
        .navigationTitle(category)
        .navigationBarTitleDisplayMode(.inline)
    }

    private var categoryHeader: some View {
        VStack(alignment: .leading, spacing: 7) {
            Text(category).font(.largeTitle.bold()).tracking(-0.8)
            Text(categoryDescription).font(.subheadline).foregroundStyle(.secondary)
        }
    }

    private var categoryDescription: String {
        switch category {
        case "Cleaning": return "Compare cleaning firms by package, next slot and starting price before messaging or booking."
        case "Moving": return "Compare movers by availability, included scope and starting price before choosing one."
        case "Painting": return "Browse painters for touch-ups, rooms or full move-out repainting."
        case "Maintenance": return "Find handyman, AC and common home-repair providers."
        case "Storage": return "Compare pickup and storage options before choosing a duration."
        case "Inspection": return "Browse operational property-condition documentation services."
        default: return "Browse providers and compare before booking."
        }
    }

    private func providerCard(_ provider: PremiumProvider) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top, spacing: 12) {
                providerLogo(provider)
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 6) {
                        Text(provider.name).font(.headline).foregroundStyle(DMTheme.ink)
                        if provider.verified { Image(systemName: "checkmark.seal.fill").foregroundStyle(DMTheme.green) }
                    }
                    HStack(spacing: 4) {
                        Image(systemName: "star.fill").foregroundStyle(.orange)
                        Text(String(format: "%.1f", provider.rating)).bold()
                        Text("(\(provider.reviews))").foregroundStyle(.secondary)
                    }
                    .font(.caption)
                }
                Spacer()
                Image(systemName: "chevron.right").font(.caption.bold()).foregroundStyle(Color.tertiary)
            }

            HStack(spacing: 10) {
                metric("From", "\(provider.startingPrice) \(provider.priceUnit)")
                metric("Next slot", provider.nextSlot)
                metric("Replies", provider.response)
            }

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 7) {
                    ForEach(provider.tags, id: \.self) { tag in
                        Text(tag).font(.caption2.bold()).foregroundStyle(DMTheme.green).padding(.horizontal, 9).padding(.vertical, 6).background(DMTheme.mint).clipShape(Capsule())
                    }
                }
            }
        }
        .padding(15)
        .background(DMTheme.card)
        .clipShape(RoundedRectangle(cornerRadius: 22))
        .overlay(RoundedRectangle(cornerRadius: 22).stroke(DMTheme.border, lineWidth: 1))
        .shadow(color: DMTheme.shadow, radius: 10, y: 5)
    }

    private func providerLogo(_ provider: PremiumProvider) -> some View {
        let initials = provider.name.split(separator: " ").prefix(2).compactMap { $0.first }.map(String.init).joined()
        return Text(initials)
            .font(.headline.bold())
            .foregroundStyle(.white)
            .frame(width: 48, height: 48)
            .background(DMTheme.green)
            .clipShape(RoundedRectangle(cornerRadius: 15))
    }

    private func metric(_ title: String, _ value: String) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(title).font(.caption2).foregroundStyle(.secondary)
            Text(value).font(.caption.bold()).foregroundStyle(DMTheme.ink).lineLimit(2)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct PremiumProviderDetailView: View {
    let provider: PremiumProvider
    @State private var selectedSlot: String?
    @State private var message = ""
    @State private var savedMessages: [String] = []
    @State private var bookingNote: String?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                providerHero

                VStack(alignment: .leading, spacing: 8) {
                    Text("About").font(.headline)
                    Text(provider.about).font(.subheadline).foregroundStyle(.secondary)
                    Text("Provider details shown here are sample TestFlight data until the provider backend is live.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .premiumSurface()

                VStack(alignment: .leading, spacing: 12) {
                    Text("Available slots").font(.headline)
                    ForEach(provider.slots, id: \.self) { slot in
                        Button {
                            selectedSlot = slot
                        } label: {
                            HStack {
                                Image(systemName: selectedSlot == slot ? "checkmark.circle.fill" : "circle")
                                Text(slot)
                                Spacer()
                                Text("Select").font(.caption)
                            }
                            .foregroundStyle(selectedSlot == slot ? DMTheme.green : DMTheme.ink)
                            .padding(12)
                            .background(selectedSlot == slot ? DMTheme.mint : DMTheme.cardMuted)
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                        }
                        .buttonStyle(.plain)
                    }

                    Button {
                        guard let selectedSlot else { return }
                        bookingNote = "Selected \(selectedSlot). Final booking will be created through the live provider backend."
                    } label: {
                        Label("Continue with selected slot", systemImage: "calendar.badge.checkmark")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(DMTheme.green)
                    .disabled(selectedSlot == nil)

                    if let bookingNote {
                        Text(bookingNote).font(.caption).foregroundStyle(.secondary)
                    }
                }
                .premiumSurface()

                VStack(alignment: .leading, spacing: 10) {
                    Text("Message provider").font(.headline)
                    TextField("Ask what is included, timing, access or equipment", text: $message, axis: .vertical)
                        .lineLimit(3...6)
                        .padding(11)
                        .background(DMTheme.cardMuted)
                        .clipShape(RoundedRectangle(cornerRadius: 14))

                    Button {
                        let clean = message.trimmingCharacters(in: .whitespacesAndNewlines)
                        guard !clean.isEmpty else { return }
                        savedMessages.append(clean)
                        message = ""
                    } label: {
                        Label("Send sample message", systemImage: "paperplane.fill").frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(DMTheme.green)
                    .disabled(message.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)

                    ForEach(Array(savedMessages.enumerated()), id: \.offset) { _, item in
                        HStack {
                            Spacer()
                            Text(item).font(.subheadline).padding(10).background(DMTheme.green).foregroundStyle(.white).clipShape(RoundedRectangle(cornerRadius: 14))
                        }
                    }

                    Text("Messages stay local in backend-free TestFlight mode. Live provider chat will use the connected messaging system.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .premiumSurface()
            }
            .padding(16)
            .padding(.bottom, 26)
        }
        .background(DMTheme.page.ignoresSafeArea())
        .navigationTitle(provider.name)
        .navigationBarTitleDisplayMode(.inline)
    }

    private var providerHero: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 5) {
                    HStack(spacing: 6) {
                        Text(provider.name).font(.title2.bold())
                        if provider.verified { Image(systemName: "checkmark.seal.fill").foregroundStyle(DMTheme.green) }
                    }
                    HStack(spacing: 5) {
                        Image(systemName: "star.fill").foregroundStyle(.orange)
                        Text(String(format: "%.1f", provider.rating)).bold()
                        Text("· \(provider.reviews) reviews").foregroundStyle(.secondary)
                    }
                    .font(.subheadline)
                }
                Spacer()
                Text("SAMPLE").font(.caption2.bold()).foregroundStyle(DMTheme.green).padding(.horizontal, 9).padding(.vertical, 6).background(DMTheme.mint).clipShape(Capsule())
            }

            HStack(spacing: 12) {
                Label("From AED \(provider.startingPrice)", systemImage: "banknote")
                Label(provider.response, systemImage: "message")
            }
            .font(.caption.bold())
            .foregroundStyle(.secondary)
        }
        .padding(18)
        .background(DMTheme.card)
        .clipShape(RoundedRectangle(cornerRadius: 24))
        .overlay(RoundedRectangle(cornerRadius: 24).stroke(DMTheme.border, lineWidth: 1))
    }
}

// MARK: - Destination router

@ViewBuilder
private func premiumDestination(for target: PremiumMoveTarget) -> some View {
    switch target {
    case .documents: FunctionalV2DocumentsView()
    case .ejari: EjariV2View()
    case .dewa: DewaV2View()
    case .telecom: TelecomV2View()
    case .cooling: CoolingV2View()
    case .building: FunctionalV2BuildingView()
    case .services: PremiumServicesView()
    case .inspection: ConnectedInspectionHubView()
    case .handover: FunctionalV2HandoverView()
    case .money: ConnectedMoneyView()
    case .leaving: FunctionalV2LeavingDubaiView()
    case .setup: FunctionalV2MoveSetupView()
    }
}

private extension View {
    func premiumSurface() -> some View {
        self
            .padding(16)
            .background(DMTheme.card)
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .overlay(RoundedRectangle(cornerRadius: 20).stroke(DMTheme.border, lineWidth: 1))
    }
}
