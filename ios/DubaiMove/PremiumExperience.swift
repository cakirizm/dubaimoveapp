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

// MARK: - Home

struct PremiumHomeView: View {
    @EnvironmentObject private var state: AppState
    @AppStorage("dubaimove.v2.moveKind") private var moveKind = LocalMoveKind.withinDubai.rawValue
    @AppStorage("dubaimove.v2.currentArea") private var currentArea = ""
    @AppStorage("dubaimove.v2.newArea") private var newArea = ""
    @AppStorage("dubaimove.v2.moveDate") private var moveDateEpoch = Date().addingTimeInterval(86400 * 21).timeIntervalSince1970

    private var plan: PremiumMovePlan { PremiumMovePlan.plan(for: moveKind) }
    private var readiness: Int { LocalChecklistSnapshot.current.readiness }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 22) {
                topBar
                hero
                nextStep
                officialStrip
                journeyPreview
                servicesPreview
                guidanceCard
            }
            .padding(.horizontal, 16)
            .padding(.top, 10)
            .padding(.bottom, 30)
        }
        .background(DMTheme.page.ignoresSafeArea())
        .navigationBarTitleDisplayMode(.inline)
        .task { state.readiness = readiness }
    }

    private var topBar: some View {
        HStack(spacing: 12) {
            Image("BrandLogo").resizable().scaledToFit().frame(width: 52, height: 52)
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
        VStack(alignment: .leading, spacing: 16) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 6) {
                    Text(plan.shortTitle.uppercased())
                        .font(.caption2.bold()).tracking(1.5).foregroundStyle(.white.opacity(0.78))
                    Text(plan.heroTitle)
                        .font(.system(size: 29, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                    Text(routeSubtitle)
                        .font(.subheadline).foregroundStyle(.white.opacity(0.78))
                }
                Spacer()
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
                VStack {
                    HStack { Spacer(); Image(systemName: plan.heroIcon).font(.system(size: 120, weight: .thin)).foregroundStyle(.white.opacity(0.08)).offset(x: 25, y: -5) }
                    Spacer()
                }
            }
        )
        .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
        .shadow(color: DMTheme.greenDeep.opacity(0.20), radius: 20, y: 10)
    }

    private var readinessRing: some View {
        ZStack {
            Circle().stroke(.white.opacity(0.20), lineWidth: 7)
            Circle().trim(from: 0, to: max(0.02, Double(readiness)/100)).stroke(.white, style: StrokeStyle(lineWidth: 7, lineCap: .round)).rotationEffect(.degrees(-90))
            VStack(spacing: -1) {
                Text("\(readiness)%").font(.headline.bold())
                Text("READY").font(.system(size: 8, weight: .bold)).tracking(1)
            }.foregroundStyle(.white)
        }.frame(width: 76, height: 76)
    }

    private var routeSubtitle: String {
        let from = currentArea.isEmpty ? "Current home" : currentArea
        let to = newArea.isEmpty ? "Destination" : newArea
        switch moveKind {
        case LocalMoveKind.toDubai.rawValue: return "Arrival plan → \(to)"
        case LocalMoveKind.leavingDubai.rawValue: return "\(from) → departure"
        case LocalMoveKind.serviceOnly.rawValue: return "Home services workspace"
        default: return "\(from) → \(to)"
        }
    }

    private var nextStep: some View {
        let step = plan.steps.first { !UserDefaults.standard.bool(forKey: $0.storageKey) } ?? plan.steps.last!
        return NavigationLink(destination: destination(for: step.destination)) {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text("DO THIS NEXT").font(.caption2.bold()).tracking(1.2).foregroundStyle(DMTheme.green)
                    Spacer()
                    Image(systemName: "arrow.right.circle.fill").foregroundStyle(DMTheme.green)
                }
                HStack(alignment: .top, spacing: 14) {
                    Image(systemName: step.icon).font(.title2.weight(.semibold)).foregroundStyle(DMTheme.green).frame(width: 48, height: 48).background(DMTheme.mint).clipShape(RoundedRectangle(cornerRadius: 15))
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

    private var officialStrip: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionTitle("Official essentials", "Verified channels for the tasks Dubai Move cannot complete on your behalf")
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    officialVisual("Ejari", "DLD", "doc.text.fill", [DMTheme.greenDeep, DMTheme.green], EjariV2View())
                    officialVisual("DEWA", "Electricity & water", "bolt.fill", [.blue, .cyan], DewaV2View())
                    officialVisual("du", "Home internet", "wifi", [.purple, .pink], TelecomV2View())
                    officialVisual("e&", "Home move", "antenna.radiowaves.left.and.right", [.red, .orange], TelecomV2View())
                    officialVisual("Cooling", "Empower / Emicool", "snowflake", [.cyan, .teal], CoolingV2View())
                }
            }
        }
    }

    private func officialVisual<Destination: View>(_ name: String, _ subtitle: String, _ icon: String, _ colors: [Color], _ destination: Destination) -> some View {
        NavigationLink(destination: destination) {
            ZStack(alignment: .bottomLeading) {
                LinearGradient(colors: colors, startPoint: .topLeading, endPoint: .bottomTrailing)
                Image(systemName: icon).font(.system(size: 72, weight: .thin)).foregroundStyle(.white.opacity(0.18)).offset(x: 72, y: -25)
                VStack(alignment: .leading, spacing: 4) {
                    Text(name).font(.title2.bold()).foregroundStyle(.white)
                    Text(subtitle).font(.caption).foregroundStyle(.white.opacity(0.82))
                    HStack(spacing: 4) { Image(systemName: "checkmark.shield.fill"); Text("Official route") }.font(.caption2.bold()).foregroundStyle(.white.opacity(0.90)).padding(.top, 6)
                }.padding(15)
            }
            .frame(width: 178, height: 132)
            .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
        }.buttonStyle(.plain)
    }

    private var journeyPreview: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionTitle("Your ordered plan", "No guessing — follow the sequence and read the note under each step")
            ForEach(Array(plan.steps.prefix(4).enumerated()), id: \.offset) { index, step in
                NavigationLink(destination: destination(for: step.destination)) {
                    HStack(alignment: .top, spacing: 13) {
                        ZStack {
                            Circle().fill(UserDefaults.standard.bool(forKey: step.storageKey) ? DMTheme.green : DMTheme.mint)
                            Text("\(index + 1)").font(.caption.bold()).foregroundStyle(UserDefaults.standard.bool(forKey: step.storageKey) ? .white : DMTheme.green)
                        }.frame(width: 32, height: 32)
                        VStack(alignment: .leading, spacing: 4) {
                            Text(step.title).font(.headline).foregroundStyle(DMTheme.ink)
                            Text(step.note).font(.caption).foregroundStyle(.secondary).lineLimit(2)
                        }
                        Spacer()
                        Image(systemName: "chevron.right").font(.caption.bold()).foregroundStyle(.tertiary)
                    }
                    .padding(14)
                    .background(DMTheme.card)
                    .clipShape(RoundedRectangle(cornerRadius: 18))
                }.buttonStyle(.plain)
            }
            NavigationLink("Open full move plan", destination: PremiumJourneyView()).font(.subheadline.bold()).foregroundStyle(DMTheme.green).padding(.leading, 4)
        }
    }

    private var servicesPreview: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionTitle("Book home services", "Browse providers first — you do not need to request a quote blindly")
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    serviceVisual("Cleaning", "sparkles", [.mint, .green])
                    serviceVisual("Moving", "truck.box.fill", [.orange, .yellow])
                    serviceVisual("Painting", "paintbrush.fill", [.indigo, .purple])
                    serviceVisual("Maintenance", "wrench.and.screwdriver.fill", [.blue, .teal])
                }
            }
            NavigationLink("Explore all services", destination: PremiumServicesView()).font(.subheadline.bold()).foregroundStyle(DMTheme.green).padding(.leading, 4)
        }
    }

    private func serviceVisual(_ title: String, _ icon: String, _ colors: [Color]) -> some View {
        NavigationLink(destination: PremiumServiceCategoryView(category: title)) {
            ZStack(alignment: .bottomLeading) {
                LinearGradient(colors: colors, startPoint: .topLeading, endPoint: .bottomTrailing)
                Image(systemName: icon).font(.system(size: 68, weight: .thin)).foregroundStyle(.white.opacity(0.24)).offset(x: 70, y: -28)
                Text(title).font(.headline.bold()).foregroundStyle(.white).padding(14)
            }
            .frame(width: 150, height: 105)
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        }.buttonStyle(.plain)
    }

    private var guidanceCard: some View {
        VStack(alignment: .leading, spacing: 9) {
            Label("How Dubai Move guides you", systemImage: "sparkles")
                .font(.headline).foregroundStyle(DMTheme.green)
            Text("We organize practical move tasks, show dependencies, store your own notes and send regulated actions to the relevant official channel. We do not provide legal advice or make legal determinations.")
                .font(.subheadline).foregroundStyle(.secondary)
        }
        .padding(16)
        .background(DMTheme.sand)
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }

    private func sectionTitle(_ title: String, _ subtitle: String) -> some View {
        VStack(alignment: .leading, spacing: 3) { Text(title).font(.title3.bold()); Text(subtitle).font(.caption).foregroundStyle(.secondary) }
    }

    @ViewBuilder private func destination(for target: PremiumMoveTarget) -> some View {
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
}

// MARK: - Guided move plan

enum PremiumMoveTarget { case documents, ejari, dewa, telecom, cooling, building, services, inspection, handover, money, leaving, setup }

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
            return .init(shortTitle: "Moving to Dubai", heroTitle: "Settle in with a clear order", heroIcon: "airplane.arrival", intro: "Start with your home documents, then activate the essentials around the property.", steps: [
                .init(title:"Confirm your tenancy documents", note:"Keep the signed tenancy contract and key property details together before starting regulated utility steps.", why:"These details are commonly needed repeatedly during setup.", icon:"doc.text.fill", target:.documents, key:"toDubai.docs"),
                .init(title:"Register / confirm Ejari", note:"Use the matching Dubai Land Department channel. Dubai Move will not mark it complete just because the page opened.", why:"Ejari is a core tenancy record used across many Dubai move processes.", icon:"checkmark.seal.fill", target:.ejari, key:"toDubai.ejari"),
                .init(title:"Activate DEWA", note:"Choose Move-In for the new premise and keep the account/premise details ready.", why:"Electricity and water should be scheduled around your occupancy date.", icon:"bolt.fill", target:.dewa, key:"toDubai.dewa"),
                .init(title:"Arrange home internet", note:"Compare the available home-service route and book installation early enough for your move date.", why:"Installation availability can affect your first days in the property.", icon:"wifi", target:.telecom, key:"toDubai.telecom"),
                .init(title:"Check cooling provider", note:"Confirm whether the building uses Empower, Emicool or another building-managed arrangement.", why:"Cooling can be separate from DEWA depending on the property.", icon:"snowflake", target:.cooling, key:"toDubai.cooling"),
                .init(title:"Check building move-in rules", note:"Ask about permits, lift bookings, mover access windows and security deposits.", why:"Many buildings control move access and elevator slots.", icon:"building.2.fill", target:.building, key:"toDubai.building"),
                .init(title:"Book move-in services", note:"Browse providers, compare availability and message them before booking.", why:"You can coordinate cleaning, moving and maintenance around one date.", icon:"sparkles", target:.services, key:"toDubai.services")
            ])
        }
        if kind == LocalMoveKind.leavingDubai.rawValue {
            return .init(shortTitle:"Leaving Dubai", heroTitle:"Close your home cleanly", heroIcon:"airplane.departure", intro:"Work backwards from your handover date so utilities, property condition and refunds are not forgotten.", steps:[
                .init(title:"Set your final handover date", note:"Use this as the anchor date for utilities, internet, cleaning and key return.", why:"Every other move-out task can be scheduled around one confirmed date.", icon:"calendar", target:.setup, key:"leave.date"),
                .init(title:"Review tenancy / Ejari exit", note:"Choose the correct official cancellation or certificate route for your situation.", why:"The tenancy record and landlord handover should stay aligned.", icon:"doc.text.fill", target:.ejari, key:"leave.ejari"),
                .init(title:"Schedule DEWA Move-Out", note:"Plan deactivation for the correct date and follow the official final-bill/refund process.", why:"Ending service too early or late can create avoidable issues.", icon:"bolt.slash.fill", target:.dewa, key:"leave.dewa"),
                .init(title:"Cancel / relocate internet", note:"Choose the relevant provider route and do not assume home service ends automatically.", why:"Telecom often has its own cancellation or relocation process.", icon:"wifi.slash", target:.telecom, key:"leave.telecom"),
                .init(title:"Book inspection and repairs", note:"Photograph the property, note damage, then arrange cleaning, painting or maintenance if needed.", why:"A clear condition record helps you manage handover conversations factually.", icon:"camera.viewfinder", target:.inspection, key:"leave.inspect"),
                .init(title:"Prepare keys & handover pack", note:"Track key return, meter/final-bill references and the documents you want to retain.", why:"A complete handover pack reduces forgotten items.", icon:"key.fill", target:.handover, key:"leave.handover"),
                .init(title:"Track deposits & refunds", note:"Record expected amounts and status; Dubai Move does not decide entitlement or legal responsibility.", why:"Refunds can arrive on different timelines.", icon:"banknote.fill", target:.money, key:"leave.money")
            ])
        }
        if kind == LocalMoveKind.serviceOnly.rawValue {
            return .init(shortTitle:"Home services", heroTitle:"Find the right provider first", heroIcon:"sparkles.rectangle.stack.fill", intro:"Browse the service, compare providers and message before you commit.", steps:[
                .init(title:"Choose a service", note:"Cleaning, moving, painting, maintenance, storage or inspection.", why:"Starting with the job type keeps the provider list relevant.", icon:"square.grid.2x2.fill", target:.services, key:"service.choose"),
                .init(title:"Compare providers", note:"Review sample price ranges, rating, availability and service scope.", why:"You should be able to browse before making a request.", icon:"arrow.left.arrow.right", target:.services, key:"service.compare"),
                .init(title:"Message before booking", note:"Ask scope questions and confirm what is included in the price.", why:"Clear scope reduces surprises on service day.", icon:"message.fill", target:.services, key:"service.message")
            ])
        }
        return .init(shortTitle:"Within Dubai", heroTitle:"Move across Dubai step by step", heroIcon:"arrow.left.arrow.right", intro:"Finish the old-home tasks while preparing the new home in the correct dependency order.", steps:[
            .init(title:"Confirm both tenancy details", note:"Keep the current-home and new-home contract/property details ready before starting transfer tasks.", why:"You will repeatedly need both premises during a Dubai-to-Dubai move.", icon:"doc.on.doc.fill", target:.documents, key:"within.docs"),
            .init(title:"Prepare the new Ejari", note:"Use the relevant DLD route for the new tenancy and keep the status visible in your checklist.", why:"It is a key new-home tenancy record.", icon:"checkmark.seal.fill", target:.ejari, key:"within.ejari"),
            .init(title:"Plan DEWA Move-To", note:"Use Move-To when transferring the utility lifecycle between Dubai premises, rather than mixing Move-In and Move-Out journeys.", why:"This keeps the old and new premise transition coordinated.", icon:"bolt.fill", target:.dewa, key:"within.dewa"),
            .init(title:"Relocate internet", note:"Check your home provider’s relocation path and book a suitable date before move day.", why:"A transfer may require an appointment or new equipment.", icon:"wifi", target:.telecom, key:"within.telecom"),
            .init(title:"Check both buildings’ move rules", note:"Confirm permits, lift slots, loading access and any management deposits at both ends.", why:"Building access can block the moving company even when everything else is ready.", icon:"building.2.fill", target:.building, key:"within.building"),
            .init(title:"Browse and book movers", note:"Compare provider profile, availability, price range and included services before requesting or booking.", why:"The provider should fit your building rules and date.", icon:"truck.box.fill", target:.services, key:"within.movers"),
            .init(title:"Inspect the old home", note:"Capture condition photos and note cleaning/painting/repair needs before handover.", why:"It gives you an organized factual record of condition.", icon:"camera.viewfinder", target:.inspection, key:"within.inspect"),
            .init(title:"Complete old-home handover", note:"Track keys, relevant final bills and the documents you want in your handover pack.", why:"This closes the operational move-out side cleanly.", icon:"key.fill", target:.handover, key:"within.handover")
        ])
    }
}

struct PremiumJourneyView: View {
    @AppStorage("dubaimove.v2.moveKind") private var moveKind = LocalMoveKind.withinDubai.rawValue
    @State private var refresh = UUID()
    private var plan: PremiumMovePlan { .plan(for: moveKind) }

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

                VStack(alignment:.leading, spacing:8) {
                    Label("Important boundary", systemImage:"checkmark.shield.fill").font(.headline).foregroundStyle(DMTheme.green)
                    Text("Dubai Move provides practical organization and verified-channel navigation. It does not provide legal advice, determine rights or liabilities, or represent a government authority.").font(.footnote).foregroundStyle(.secondary)
                }.padding(16).background(DMTheme.sand).clipShape(RoundedRectangle(cornerRadius:18))
            }
            .id(refresh)
            .padding(16)
            .padding(.bottom, 20)
        }
        .background(DMTheme.page.ignoresSafeArea())
        .navigationTitle("My Move")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func stepCard(index: Int, step: PremiumMoveStep) -> some View {
        let done = UserDefaults.standard.bool(forKey: step.storageKey)
        return VStack(alignment: .leading, spacing: 13) {
            HStack(alignment: .top, spacing: 13) {
                ZStack { Circle().fill(done ? DMTheme.green : DMTheme.mint); Text("\(index+1)").font(.headline.bold()).foregroundStyle(done ? .white : DMTheme.green) }.frame(width:42,height:42)
                VStack(alignment:.leading, spacing:4) { Text(step.title).font(.headline); Text(step.note).font(.subheadline).foregroundStyle(.secondary) }
                Spacer()
            }
            HStack(alignment:.top, spacing:8) { Image(systemName:"lightbulb.fill").foregroundStyle(.orange); Text("Why this matters: \(step.why)").font(.caption).foregroundStyle(.secondary) }
            Divider()
            HStack {
                Button { UserDefaults.standard.set(!done, forKey: step.storageKey); refresh = UUID() } label: { Label(done ? "Mark not done" : "Mark done", systemImage: done ? "arrow.uturn.backward" : "checkmark.circle.fill") }.buttonStyle(.bordered).tint(DMTheme.green)
                Spacer()
                NavigationLink(destination: destination(for: step.target)) { Label("Open", systemImage:"arrow.right") }.buttonStyle(.borderedProminent).tint(DMTheme.green)
            }
        }
        .padding(16)
        .background(DMTheme.card)
        .clipShape(RoundedRectangle(cornerRadius:22, style:.continuous))
        .overlay(RoundedRectangle(cornerRadius:22).stroke(done ? DMTheme.green.opacity(0.35) : DMTheme.border, lineWidth:1))
    }

    @ViewBuilder private func destination(for target: PremiumMoveTarget) -> some View {
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
}

extension PremiumProvider {
    static let samples: [PremiumProvider] = [
        .init(name:"BrightNest Cleaning", category:"Cleaning", rating:4.8, reviews:312, startingPrice:45, priceUnit:"AED/hour", nextSlot:"Today · 18:00", response:"~5 min", verified:true, tags:["Move-out","Deep clean","Supplies included"], about:"Sample provider profile for TestFlight. Deep cleaning, regular cleaning and move-out packages."),
        .init(name:"Palm & Polish", category:"Cleaning", rating:4.7, reviews:184, startingPrice:160, priceUnit:"AED/studio from", nextSlot:"Tomorrow · 09:00", response:"~12 min", verified:true, tags:["Studio","1–3 BR","Same-week"], about:"Sample provider profile for TestFlight. Fixed-package cleaning with selectable time slots."),
        .init(name:"MoveCraft Dubai", category:"Moving", rating:4.9, reviews:428, startingPrice:850, priceUnit:"AED from", nextSlot:"Tomorrow · 08:00", response:"~7 min", verified:true, tags:["Packing","Truck","Unpacking"], about:"Sample moving provider profile. Pricing varies by home size, access and packing scope."),
        .init(name:"UrbanShift Movers", category:"Moving", rating:4.6, reviews:205, startingPrice:650, priceUnit:"AED from", nextSlot:"Sun · 10:00", response:"~15 min", verified:true, tags:["Budget","Boxes","Dubai-wide"], about:"Sample provider profile with flexible small-move packages."),
        .init(name:"FreshCoat Homes", category:"Painting", rating:4.8, reviews:147, startingPrice:499, priceUnit:"AED/room from", nextSlot:"Mon · 08:30", response:"~10 min", verified:true, tags:["Touch-up","Full repaint","Move-out"], about:"Sample provider profile for interior painting and move-out touch-ups."),
        .init(name:"FixRight Home Care", category:"Maintenance", rating:4.7, reviews:296, startingPrice:120, priceUnit:"AED visit from", nextSlot:"Today · 20:00", response:"~8 min", verified:true, tags:["Handyman","AC","Plumbing"], about:"Sample provider profile covering common apartment and villa maintenance jobs."),
        .init(name:"BoxSafe Storage", category:"Storage", rating:4.6, reviews:119, startingPrice:199, priceUnit:"AED/month from", nextSlot:"Pickup tomorrow", response:"~20 min", verified:true, tags:["Pickup","Short-term","Long-term"], about:"Sample storage provider profile with pickup and monthly storage options."),
        .init(name:"HomeCheck Dubai", category:"Inspection", rating:4.9, reviews:96, startingPrice:350, priceUnit:"AED from", nextSlot:"Tomorrow · 11:00", response:"~9 min", verified:true, tags:["Photo report","Move-in","Move-out"], about:"Sample property condition inspection profile. This is operational documentation, not legal advice."),
    ]
}

struct PremiumServicesView: View {
    private let categories: [(String,String,[Color],String)] = [
        ("Cleaning","sparkles",[.mint,.green],"Deep, regular and move-out cleaning"),
        ("Moving","truck.box.fill",[.orange,.yellow],"Packing, transport and unpacking"),
        ("Painting","paintbrush.fill",[.indigo,.purple],"Touch-ups and full repaint"),
        ("Maintenance","wrench.and.screwdriver.fill",[.blue,.teal],"Handyman, AC and repairs"),
        ("Storage","archivebox.fill",[.brown,.orange],"Pickup and flexible storage"),
        ("Inspection","camera.viewfinder",[.teal,.cyan],"Condition capture and reports")
    ]

    var body: some View {
        ScrollView {
            VStack(alignment:.leading, spacing:18) {
                VStack(alignment:.leading, spacing:6) {
                    Text("SERVICES").font(.caption2.bold()).tracking(1.5).foregroundStyle(DMTheme.green)
                    Text("Browse before you book").font(.largeTitle.bold()).tracking(-0.8)
                    Text("See providers, example price ranges, next available slots and message them inside Dubai Move before choosing.").font(.subheadline).foregroundStyle(.secondary)
                }

                ForEach(categories, id:\.0) { category in
                    NavigationLink(destination: PremiumServiceCategoryView(category: category.0)) {
                        ZStack(alignment:.bottomLeading) {
                            LinearGradient(colors: category.2, startPoint:.topLeading, endPoint:.bottomTrailing)
                            HStack { Spacer(); Image(systemName:category.1).font(.system(size:90,weight:.thin)).foregroundStyle(.white.opacity(0.20)).padding(.trailing,20) }
                            VStack(alignment:.leading, spacing:5) {
                                Text(category.0).font(.title2.bold()).foregroundStyle(.white)
                                Text(category.3).font(.caption).foregroundStyle(.white.opacity(0.85))
                                Text("\(PremiumProvider.samples.filter{$0.category == category.0}.count) sample providers").font(.caption2.bold()).foregroundStyle(.white.opacity(0.9)).padding(.top,5)
                            }.padding(17)
                        }
                        .frame(height:132)
                        .clipShape(RoundedRectangle(cornerRadius:24, style:.continuous))
                    }.buttonStyle(.plain)
                }

                Text("Provider names, prices and availability shown in backend-free TestFlight mode are clearly marked sample data. Production will load provider-managed profiles and live slots from the connected marketplace backend.").font(.caption).foregroundStyle(.secondary).padding(.horizontal,4)
            }.padding(16).padding(.bottom,20)
        }
        .background(DMTheme.page.ignoresSafeArea())
        .navigationTitle("Services")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct PremiumServiceCategoryView: View {
    let category: String
    @State private var sort = "Recommended"
    private var providers: [PremiumProvider] {
        var list = PremiumProvider.samples.filter { $0.category == category }
        if sort == "Price" { list.sort { $0.startingPrice < $1.startingPrice } }
        if sort == "Rating" { list.sort { $0.rating > $1.rating } }
        return list
    }

    var body: some View {
        ScrollView {
            VStack(alignment:.leading, spacing:16) {
                serviceHeader
                Picker("Sort", selection:$sort) { ForEach(["Recommended","Price","Rating"], id:\.self) { Text($0) } }.pickerStyle(.segmented)
                HStack { Text("Providers").font(.title3.bold()); Spacer(); Text("SAMPLE DATA").font(.caption2.bold()).foregroundStyle(DMTheme.green).padding(.horizontal,8).padding(.vertical,5).background(DMTheme.mint).clipShape(Capsule()) }
                if providers.isEmpty {
                    VStack(spacing:10) { Image(systemName:"building.2.crop.circle").font(.largeTitle).foregroundStyle(DMTheme.green); Text("Live provider profiles will appear here when the marketplace backend is connected.").multilineTextAlignment(.center).foregroundStyle(.secondary) }.frame(maxWidth:.infinity).padding(30).background(DMTheme.card).clipShape(RoundedRectangle(cornerRadius:20))
                }
                ForEach(providers) { provider in NavigationLink(destination: PremiumProviderProfileView(provider:provider)) { providerCard(provider) }.buttonStyle(.plain) }
            }.padding(16).padding(.bottom,20)
        }.background(DMTheme.page.ignoresSafeArea()).navigationTitle(category).navigationBarTitleDisplayMode(.inline)
    }

    private var serviceHeader: some View {
        ZStack(alignment:.bottomLeading) {
            LinearGradient(colors:[DMTheme.greenDeep,DMTheme.greenBright],startPoint:.topLeading,endPoint:.bottomTrailing)
            HStack { Spacer(); Image(systemName:icon).font(.system(size:96,weight:.thin)).foregroundStyle(.white.opacity(0.18)).padding(.trailing,22) }
            VStack(alignment:.leading,spacing:5) { Text(category).font(.largeTitle.bold()).foregroundStyle(.white); Text("Compare scope, price and next available time before you message or book.").font(.caption).foregroundStyle(.white.opacity(0.83)).frame(maxWidth:260,alignment:.leading) }.padding(18)
        }.frame(height:155).clipShape(RoundedRectangle(cornerRadius:26))
    }

    private var icon:String { switch category { case "Cleaning":"sparkles"; case "Moving":"truck.box.fill"; case "Painting":"paintbrush.fill"; case "Maintenance":"wrench.and.screwdriver.fill"; case "Storage":"archivebox.fill"; default:"camera.viewfinder" } }

    private func providerCard(_ provider:PremiumProvider)->some View {
        VStack(alignment:.leading,spacing:12) {
            HStack(alignment:.top,spacing:12) {
                ZStack { RoundedRectangle(cornerRadius:16).fill(DMTheme.mint); Text(provider.name.split(separator:" ").prefix(2).compactMap{$0.first}.map(String.init).joined()).font(.headline.bold()).foregroundStyle(DMTheme.green) }.frame(width:54,height:54)
                VStack(alignment:.leading,spacing:4) { HStack(spacing:5){ Text(provider.name).font(.headline).foregroundStyle(DMTheme.ink); if provider.verified { Image(systemName:"checkmark.seal.fill").foregroundStyle(DMTheme.green) } }; HStack(spacing:5){ Image(systemName:"star.fill").foregroundStyle(.orange); Text(String(format:"%.1f",provider.rating)).font(.subheadline.bold()).foregroundStyle(DMTheme.ink); Text("(\(provider.reviews))").font(.caption).foregroundStyle(.secondary) } }
                Spacer(); Image(systemName:"chevron.right").font(.caption.bold()).foregroundStyle(.tertiary)
            }
            HStack { VStack(alignment:.leading,spacing:2){Text("FROM").font(.caption2.bold()).foregroundStyle(.secondary);Text("\(provider.startingPrice) \(provider.priceUnit)").font(.subheadline.bold()).foregroundStyle(DMTheme.ink)}; Spacer(); VStack(alignment:.trailing,spacing:2){Text("NEXT SLOT").font(.caption2.bold()).foregroundStyle(.secondary);Text(provider.nextSlot).font(.subheadline.bold()).foregroundStyle(DMTheme.green)} }
            ScrollView(.horizontal,showsIndicators:false){HStack(spacing:6){ForEach(provider.tags,id:\.self){Text($0).font(.caption2.weight(.medium)).padding(.horizontal,8).padding(.vertical,5).background(DMTheme.cardMuted).clipShape(Capsule())}}}
        }.padding(15).background(DMTheme.card).clipShape(RoundedRectangle(cornerRadius:21)).overlay(RoundedRectangle(cornerRadius:21).stroke(DMTheme.border,lineWidth:1))
    }
}

struct PremiumProviderProfileView: View {
    let provider: PremiumProvider
    @State private var selectedSlot = ""
    @State private var showingMessage = false

    private var slots:[String] { [provider.nextSlot,"Tomorrow · 14:00","Sun · 09:30","Mon · 17:00"] }

    var body: some View {
        ScrollView {
            VStack(alignment:.leading,spacing:18) {
                VStack(alignment:.leading,spacing:13){
                    HStack(alignment:.top){ZStack{RoundedRectangle(cornerRadius:20).fill(DMTheme.mint);Text(provider.name.split(separator:" ").prefix(2).compactMap{$0.first}.map(String.init).joined()).font(.title2.bold()).foregroundStyle(DMTheme.green)}.frame(width:72,height:72);Spacer();Text("SAMPLE PROVIDER").font(.caption2.bold()).foregroundStyle(DMTheme.green).padding(.horizontal,9).padding(.vertical,6).background(DMTheme.mint).clipShape(Capsule())}
                    HStack(spacing:7){Text(provider.name).font(.title.bold());if provider.verified{Image(systemName:"checkmark.seal.fill").foregroundStyle(DMTheme.green)}}
                    HStack{Label(String(format:"%.1f",provider.rating),systemImage:"star.fill").foregroundStyle(.orange);Text("\(provider.reviews) reviews").foregroundStyle(.secondary);Spacer();Text("Replies \(provider.response)").font(.caption).foregroundStyle(.secondary)}.font(.subheadline)
                    Text(provider.about).font(.subheadline).foregroundStyle(.secondary)
                }.padding(17).background(DMTheme.card).clipShape(RoundedRectangle(cornerRadius:24)).overlay(RoundedRectangle(cornerRadius:24).stroke(DMTheme.border,lineWidth:1))

                VStack(alignment:.leading,spacing:10){Text("Included / popular").font(.headline);FlowTags(tags:provider.tags)}.padding(16).background(DMTheme.card).clipShape(RoundedRectangle(cornerRadius:20))

                VStack(alignment:.leading,spacing:12){Text("Example pricing").font(.headline);HStack{Text("Starting from");Spacer();Text("AED \(provider.startingPrice)").font(.headline)};Text("Final price depends on scope, home size, access, materials and selected extras. Confirm the full scope in chat before booking.").font(.caption).foregroundStyle(.secondary)}.padding(16).background(DMTheme.card).clipShape(RoundedRectangle(cornerRadius:20))

                VStack(alignment:.leading,spacing:12){Text("Choose a slot").font(.headline);ScrollView(.horizontal,showsIndicators:false){HStack(spacing:8){ForEach(slots,id:\.self){slot in Button{selectedSlot=slot}label:{Text(slot).font(.caption.bold()).padding(.horizontal,12).padding(.vertical,10).background(selectedSlot==slot ? DMTheme.green : DMTheme.card).foregroundStyle(selectedSlot==slot ? .white : DMTheme.ink).clipShape(RoundedRectangle(cornerRadius:12)).overlay(RoundedRectangle(cornerRadius:12).stroke(DMTheme.border,lineWidth:1))}.buttonStyle(.plain)}}}}
                .padding(16).background(DMTheme.cardMuted).clipShape(RoundedRectangle(cornerRadius:20))

                Button{showingMessage=true}label:{HStack{Image(systemName:"message.fill");Text("Message provider");Spacer();Image(systemName:"arrow.right")}.font(.headline).foregroundStyle(.white).padding(.horizontal,17).frame(height:56).background(DMTheme.green).clipShape(RoundedRectangle(cornerRadius:17))}.buttonStyle(.plain)
                Button{}label:{HStack{Image(systemName:"calendar.badge.plus");Text(selectedSlot.isEmpty ? "Select a slot to continue" : "Continue with \(selectedSlot)");Spacer()}.font(.headline).foregroundStyle(DMTheme.green).padding(.horizontal,17).frame(height:54).background(DMTheme.mint).clipShape(RoundedRectangle(cornerRadius:17))}.buttonStyle(.plain).disabled(selectedSlot.isEmpty).opacity(selectedSlot.isEmpty ? 0.55:1)

                Text("TestFlight note: this is sample marketplace data used to validate the user experience. Provider-managed listings, live availability, chat and bookings will use the connected backend rather than fabricated production data.").font(.caption).foregroundStyle(.secondary)
            }.padding(16).padding(.bottom,20)
        }.background(DMTheme.page.ignoresSafeArea()).navigationTitle("Provider").navigationBarTitleDisplayMode(.inline).sheet(isPresented:$showingMessage){NavigationStack{PremiumProviderMessageView(provider:provider)}}
    }
}

struct FlowTags: View {
    let tags:[String]
    var body:some View { VStack(alignment:.leading,spacing:8){ForEach(tags,id:\.self){Label($0,systemImage:"checkmark.circle.fill").font(.subheadline).foregroundStyle(DMTheme.ink)}} }
}

struct PremiumProviderMessageView: View {
    let provider:PremiumProvider
    @Environment(\.dismiss) private var dismiss
    @State private var message=""
    @State private var sent:[String]=[]

    var body:some View {
        VStack(spacing:0){
            List{Section{Text("Sample in-app conversation with \(provider.name). Messages stay local in this TestFlight mode.").font(.caption).foregroundStyle(.secondary)};ForEach(sent,id:\.self){text in HStack{Spacer();Text(text).padding(10).background(DMTheme.green).foregroundStyle(.white).clipShape(RoundedRectangle(cornerRadius:14))}}}
            HStack{TextField("Ask about scope, price or slot…",text:$message,axis:.vertical).textFieldStyle(.roundedBorder);Button{let clean=message.trimmingCharacters(in:.whitespacesAndNewlines);if !clean.isEmpty{sent.append(clean);message=""}}label:{Image(systemName:"arrow.up.circle.fill").font(.title2).foregroundStyle(DMTheme.green)}.disabled(message.trimmingCharacters(in:.whitespacesAndNewlines).isEmpty)}.padding()
        }.navigationTitle(provider.name).navigationBarTitleDisplayMode(.inline).toolbar{ToolbarItem(placement:.topBarLeading){Button("Close"){dismiss()}}}
    }
}
