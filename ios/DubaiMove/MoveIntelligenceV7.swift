import SwiftUI
import UIKit
import UniformTypeIdentifiers

struct SmartMoveCommandCenterView: View {
    @AppStorage("dubaimove.v2.moveKind") private var moveKind = LocalMoveKind.withinDubai.rawValue
    @AppStorage("dubaimove.v2.moveDate") private var moveDateEpoch = Date().addingTimeInterval(86400 * 21).timeIntervalSince1970
    @AppStorage("dubaimove.intelligence.homeType") private var homeType = "Apartment"
    @AppStorage("dubaimove.intelligence.occupancy") private var occupancy = "Tenant"
    @AppStorage("dubaimove.intelligence.internet") private var internetProvider = "Not sure"
    @AppStorage("dubaimove.guide.cooling.arrangement") private var coolingArrangement = "Not sure"

    private var plan: PremiumMovePlan { PremiumMovePlan.plan(for: moveKind) }
    private var daysToMove: Int {
        Calendar.current.dateComponents([.day], from: Calendar.current.startOfDay(for: Date()), to: Calendar.current.startOfDay(for: Date(timeIntervalSince1970: moveDateEpoch))).day ?? 0
    }
    private var steps: [PremiumMoveStep] {
        plan.steps.filter {
            !($0.target == .cooling && coolingArrangement == "Chiller free") &&
            !($0.target == .ejari && occupancy == "Owner")
        }
    }
    private var blockers: [PremiumMoveStep] {
        steps.filter { !done($0) && ($0.target == .dewa || $0.target == .building || ($0.target == .ejari && occupancy == "Tenant")) }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                hero
                profile
                routeResult
                status
                now
                tools
                Text("Your personalized timeline").font(.title2.bold())
                Text("T-minus timings are Dubai Move recommendations, not authority deadlines unless the official guide explicitly says so.")
                    .font(.caption).foregroundStyle(.secondary)
                ForEach(steps) { step in
                    NavigationLink(destination: SmartTaskGuideView(step: step, internetProvider: internetProvider, occupancy: occupancy, homeType: homeType)) {
                        HStack(spacing: 12) {
                            Image(systemName: done(step) ? "checkmark.circle.fill" : step.icon)
                                .foregroundStyle(done(step) ? DMTheme.green : tint(step.target)).frame(width: 30)
                            VStack(alignment: .leading, spacing: 3) {
                                Text(due(step)).font(.caption2.bold()).foregroundStyle(tint(step.target))
                                Text(step.title).font(.headline).foregroundStyle(DMTheme.ink)
                                Text(step.note).font(.caption).foregroundStyle(.secondary).lineLimit(2)
                            }
                            Spacer(); Image(systemName: "chevron.right").foregroundStyle(.secondary)
                        }.padding(14).background(.white).clipShape(RoundedRectangle(cornerRadius: 18))
                    }.buttonStyle(.plain)
                }
            }.padding(16).padding(.bottom, 100)
        }
        .background(Color(uiColor: .systemGroupedBackground).ignoresSafeArea())
        .navigationTitle("My Move").navigationBarTitleDisplayMode(.inline)
    }

    private var hero: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("YOUR MOVE COMMAND CENTER").font(.caption2.bold()).tracking(1.3)
            Text(daysToMove >= 0 ? "\(daysToMove) days to move day" : "Move day passed").font(.system(size: 30, weight: .heavy, design: .rounded))
            Text("Tenant/owner, home type, cooling, internet provider and move date now change the route you see.")
        }.foregroundStyle(.white).padding(20).frame(maxWidth: .infinity, minHeight: 190, alignment: .bottomLeading)
            .background(LinearGradient(colors: [DMTheme.greenDeep, DMTheme.green, .teal], startPoint: .topLeading, endPoint: .bottomTrailing))
            .clipShape(RoundedRectangle(cornerRadius: 28))
    }

    private var profile: some View {
        VStack(alignment: .leading, spacing: 10) {
            Label("Personalize my route", systemImage: "slider.horizontal.3").font(.headline)
            Picker("Occupancy", selection: $occupancy) { Text("Tenant").tag("Tenant"); Text("Owner").tag("Owner") }.pickerStyle(.segmented)
            Picker("Home", selection: $homeType) { Text("Apartment").tag("Apartment"); Text("Villa").tag("Villa") }.pickerStyle(.segmented)
            Text("Home internet").font(.caption.bold()).foregroundStyle(.secondary)
            Picker("Internet", selection: $internetProvider) {
                Text("Not sure").tag("Not sure"); Text("du").tag("du"); Text("e&").tag("e&"); Text("Virgin").tag("Virgin")
            }.pickerStyle(.segmented)
            Text("Cooling").font(.caption.bold()).foregroundStyle(.secondary)
            Picker("Cooling", selection: $coolingArrangement) {
                Text("Not sure").tag("Not sure"); Text("Chiller free").tag("Chiller free"); Text("Separate bill").tag("Separate bill")
            }.pickerStyle(.segmented)
        }.auditSurface()
    }

    private var routeResult: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label("Your route changed", systemImage: "wand.and.stars").font(.headline).foregroundStyle(.indigo)
            Text(occupancy == "Owner"
                 ? "Owner: tenant-only Ejari is removed. DEWA uses the owner route where applicable."
                 : "Tenant: Ejari remains because DEWA requires valid Ejari for the normal tenant Move-In route outside applicable exemptions.")
            Text(homeType == "Villa" ? "DEWA residential security-deposit reference: AED 4,000 villa." : "DEWA residential security-deposit reference: AED 2,000 apartment.")
            if coolingArrangement == "Chiller free" { Text("Chiller-free: separate district-cooling setup is removed.") }
            if internetProvider != "Not sure" { Text("Internet: \(internetProvider) opens first instead of defaulting to du.") }
        }.font(.caption).foregroundStyle(.secondary).auditSurface()
    }

    private var status: some View {
        HStack {
            Image(systemName: blockers.isEmpty ? "checkmark.shield.fill" : "exclamationmark.triangle.fill").font(.title2)
            VStack(alignment: .leading) {
                Text(blockers.isEmpty ? "No critical blockers detected" : "\(blockers.count) blocker\(blockers.count == 1 ? "" : "s")").font(.headline)
                Text("Verify building access, utilities and appointments before move day.").font(.caption)
            }
        }.foregroundStyle(blockers.isEmpty ? DMTheme.green : .red).auditSurface()
    }

    private var now: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label("What should I do now?", systemImage: "sun.max.fill").font(.headline).foregroundStyle(.orange)
            ForEach(steps.filter { !done($0) && lead($0.target) >= daysToMove }.prefix(4)) { step in
                NavigationLink(destination: SmartTaskGuideView(step: step, internetProvider: internetProvider, occupancy: occupancy, homeType: homeType)) {
                    HStack { Text(step.title).font(.subheadline.bold()); Spacer(); Text(due(step)).font(.caption).foregroundStyle(.secondary); Image(systemName: "chevron.right") }
                        .foregroundStyle(DMTheme.ink).padding(10).background(tint(step.target).opacity(0.07)).clipShape(RoundedRectangle(cornerRadius: 12))
                }.buttonStyle(.plain)
            }
        }.auditSurface()
    }

    private var tools: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
            NavigationLink(destination: MoveDayModeView()) { tool("Move Day", "figure.walk.motion", .orange) }
            NavigationLink(destination: RefundTrackerView()) { tool("Refunds", "banknote.fill", .mint) }
            NavigationLink(destination: FunctionalV2DocumentsView()) { tool("Documents", "folder.fill", .blue) }
            NavigationLink(destination: ServicesMarketplaceV6View()) { tool("Get help", "person.2.fill", .purple) }
        }.buttonStyle(.plain)
    }
    private func tool(_ title: String, _ icon: String, _ color: Color) -> some View {
        VStack(alignment: .leading, spacing: 8) { Image(systemName: icon).font(.title2).foregroundStyle(color); Text(title).font(.headline).foregroundStyle(DMTheme.ink) }
            .padding(14).frame(maxWidth: .infinity, minHeight: 90, alignment: .leading).background(.white).clipShape(RoundedRectangle(cornerRadius: 18))
    }
    private func done(_ s: PremiumMoveStep) -> Bool { UserDefaults.standard.bool(forKey: s.storageKey) }
    private func lead(_ t: PremiumMoveTarget) -> Int {
        switch t { case .documents,.setup: return 30; case .ejari: return 21; case .building,.telecom,.leaving: return 14; case .cooling,.services: return 10; case .dewa: return 7; case .inspection: return 3; case .handover: return 1; case .money: return 0 }
    }
    private func due(_ s: PremiumMoveStep) -> String {
        let l = lead(s.target); if daysToMove <= 0 { return "Do now" }; return daysToMove <= l ? "Do now · recommended T-\(l)" : "Upcoming · around T-\(l)"
    }
    private func tint(_ t: PremiumMoveTarget) -> Color {
        switch t { case .documents,.ejari: return .indigo; case .dewa: return .blue; case .telecom: return .purple; case .cooling: return .cyan; case .building: return .orange; case .services: return DMTheme.green; case .inspection,.handover: return .brown; case .money: return .mint; case .leaving: return .red; case .setup: return .teal }
    }
}

struct SmartTaskGuideView: View {
    let step: PremiumMoveStep
    let internetProvider: String
    let occupancy: String
    let homeType: String
    @State private var note = ""
    @State private var showImporter = false
    @State private var files: [URL] = []
    @State private var message: String?

    private var noteKey: String { "dubaimove.intelligence.proof.\(step.key)" }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 14) {
                VStack(alignment: .leading, spacing: 7) {
                    Text("BEGINNER MODE").font(.caption2.bold()).foregroundStyle(DMTheme.green)
                    Text(step.title).font(.largeTitle.bold())
                    Text(step.why).foregroundStyle(.secondary)
                }.auditSurface()

                VStack(alignment: .leading, spacing: 8) {
                    Label("Before you start", systemImage: "link").font(.headline).foregroundStyle(.orange)
                    ForEach(prereqs, id: \.self) { Text("• \($0)").font(.subheadline).foregroundStyle(.secondary) }
                }.auditSurface()

                if step.target == .dewa {
                    VStack(alignment: .leading, spacing: 7) {
                        Label("Your DEWA route", systemImage: "bolt.fill").font(.headline).foregroundStyle(.blue)
                        Text(occupancy == "Owner" ? "Owner route: do not use tenant Ejari as your prerequisite." : "Tenant route: valid Ejari is required for the normal tenant Move-In flow outside applicable exemptions.")
                        Text(homeType == "Villa" ? "Residential deposit reference: AED 4,000 villa." : "Residential deposit reference: AED 2,000 apartment.")
                        Text("Standard small-meter activation total on DEWA's current Move-In guide: AED 155. Confirm the live official amount before payment.")
                    }.font(.caption).foregroundStyle(.secondary).auditSurface()
                }

                if step.target == .ejari || step.target == .telecom {
                    VStack(alignment: .leading, spacing: 7) {
                        Label("Location verification", systemImage: "mappin.and.ellipse").font(.headline).foregroundStyle(.orange)
                        Text("Nearby results may come from Apple Maps local search. They are navigation suggestions, not proof of an officially approved branch. Verify regulated/official service centres on the authority/provider's own locator before visiting or paying.")
                            .font(.caption).foregroundStyle(.secondary)
                    }.auditSurface()
                }

                NavigationLink(destination: auditedDestination(step.target, provider: internetProvider)) {
                    Label("Do it myself · open guided official route", systemImage: "hand.point.up.left.fill")
                        .font(.headline).frame(maxWidth: .infinity).padding(13).foregroundStyle(.white).background(.blue).clipShape(RoundedRectangle(cornerRadius: 14))
                }.buttonStyle(.plain)

                NavigationLink(destination: ServicesMarketplaceV6View()) {
                    Label("Get help · browse services", systemImage: "person.2.fill")
                        .font(.headline).frame(maxWidth: .infinity).padding(13).foregroundStyle(.white).background(.purple).clipShape(RoundedRectangle(cornerRadius: 14))
                }.buttonStyle(.plain)

                VStack(alignment: .leading, spacing: 8) {
                    Label("Save real proof to this task", systemImage: "folder.badge.plus").font(.headline).foregroundStyle(.blue)
                    TextField("Reference / appointment / permit note", text: $note, axis: .vertical).lineLimit(2...4).textFieldStyle(.roundedBorder)
                    HStack {
                        Button("Save note") { UserDefaults.standard.set(note, forKey: noteKey) }.buttonStyle(.borderedProminent).tint(.blue)
                        Button { showImporter = true } label: { Label("Attach PDF/photo", systemImage: "paperclip") }.buttonStyle(.bordered).tint(.blue)
                    }
                    if let message { Text(message).font(.caption).foregroundStyle(.secondary) }
                    ForEach(files, id: \.path) { url in Label(url.lastPathComponent, systemImage: url.pathExtension.lowercased() == "pdf" ? "doc.richtext.fill" : "photo.fill").font(.caption).lineLimit(1) }
                    NavigationLink("Open Documents", destination: FunctionalV2DocumentsView()).font(.subheadline.bold())
                }.auditSurface()
            }.padding(16).padding(.bottom, 80)
        }
        .background(Color(uiColor: .systemGroupedBackground).ignoresSafeArea())
        .navigationTitle(step.title).navigationBarTitleDisplayMode(.inline)
        .onAppear { note = UserDefaults.standard.string(forKey: noteKey) ?? ""; files = ProofStore.list(step.key) }
        .fileImporter(isPresented: $showImporter, allowedContentTypes: [.pdf, .image], allowsMultipleSelection: true) { result in
            do {
                let selected = try result.get(); try ProofStore.save(selected, step.key); files = ProofStore.list(step.key); message = "\(selected.count) file(s) saved locally to this task."
            } catch { message = "Could not save the selected file." }
        }
    }

    private var prereqs: [String] {
        switch step.target {
        case .dewa: return occupancy == "Owner" ? ["Confirm premise and choose Move-In / Move-To / Move-Out.", "Use DEWA's owner route where applicable."] : ["Confirm premise and valid Ejari.", "Choose Move-In / Move-To / Move-Out."]
        case .telecom: return [internetProvider == "Not sure" ? "Confirm which provider serves the address." : "Selected provider: \(internetProvider).", "Have new address/tenancy proof and access date ready."]
        case .cooling: return ["Confirm chiller-free vs separately billed first.", "If separate, confirm Empower/Emicool/other provider with building management before registering."]
        case .building: return ["Confirm permit/NOC, service lift, loading bay, access hours and mover-document rules before final booking."]
        case .ejari: return ["Tenant route only.", "Use signed tenancy details and DLD/property-management route; do not guess property numbers."]
        default: return ["Gather the real property/provider details before acting."]
        }
    }
}

struct ProviderAwareTelecomGuideView: View {
    let provider: String
    @Environment(\.openURL) private var openURL
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 14) {
                Text(provider == "Not sure" ? "Choose your internet route" : "\(provider) first").font(.largeTitle.bold())
                Text(summary).foregroundStyle(.secondary).auditSurface()
                Button { if let u = URL(string: url) { openURL(u) } } label: { Label("Open official \(provider == "Not sure" ? "telecom" : provider) page", systemImage: "arrow.up.right").frame(maxWidth: .infinity) }
                    .buttonStyle(.borderedProminent).tint(.purple)
                if let phone {
                    Button { if let u = URL(string: "tel:\(phone)") { openURL(u) } } label: { Label("Call \(provider) · \(phone)", systemImage: "phone.fill").frame(maxWidth: .infinity) }
                        .buttonStyle(.bordered).tint(.purple)
                }
                Text("Nearby Apple Maps results are not an official-branch guarantee. Verify the store on the provider's own locator before visiting.").font(.caption).foregroundStyle(.secondary).auditSurface()
                NavigationLink(destination: TelecomGuidedView()) { Label("Open full internet comparison & nearby guide", systemImage: "wifi").frame(maxWidth: .infinity).padding(13).foregroundStyle(.white).background(.purple).clipShape(RoundedRectangle(cornerRadius: 14)) }
                    .buttonStyle(.plain)
            }.padding(16)
        }.background(Color(uiColor: .systemGroupedBackground).ignoresSafeArea()).navigationTitle("Internet").navigationBarTitleDisplayMode(.inline)
    }
    private var summary: String {
        switch provider { case "du": return "du relocation/support route selected. Current official contact page lists 155 inside the UAE."; case "e&": return "e& Home Move/support route selected. Use 101 from e&; official support also lists 800101 from other UAE lines."; case "Virgin": return "Virgin Mobile UAE Home Internet route selected. Confirm address availability/setup on the official app/site."; default: return "Check exact-address availability with du, e& and Virgin before choosing." }
    }
    private var url: String {
        switch provider { case "du": return "https://www.du.ae/personal/at-home/moving-to-a-new-home"; case "e&": return "https://www.etisalat.ae/en/c/support/home/elife/elife-ultra/others.html"; case "Virgin": return "https://www.virginmobile.ae/home-internet-setup/"; default: return "https://u.ae/en/information-and-services/infrastructure/telecommunications" }
    }
    private var phone: String? { provider == "du" ? "155" : (provider == "e&" ? "101" : nil) }
}

private enum ProofStore {
    static func folder(_ key: String) -> URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("DubaiMoveTaskProofs/\(key.replacingOccurrences(of: "/", with: "-"))", isDirectory: true)
    }
    static func list(_ key: String) -> [URL] {
        (try? FileManager.default.contentsOfDirectory(at: folder(key), includingPropertiesForKeys: nil, options: [.skipsHiddenFiles])) ?? []
    }
    static func save(_ urls: [URL], _ key: String) throws {
        let fm = FileManager.default; let destDir = folder(key); try fm.createDirectory(at: destDir, withIntermediateDirectories: true)
        for source in urls {
            let scoped = source.startAccessingSecurityScopedResource(); defer { if scoped { source.stopAccessingSecurityScopedResource() } }
            var dest = destDir.appendingPathComponent(source.lastPathComponent)
            if fm.fileExists(atPath: dest.path) { dest = destDir.appendingPathComponent("\(UUID().uuidString)-\(source.lastPathComponent)") }
            try fm.copyItem(at: source, to: dest)
        }
    }
}

struct MoveDayModeView: View {
    private let items = ["Mover/provider arrival confirmed","Building permit & service lift ready","Old-home photos saved","Keys/access cards counted","DEWA/cooling status checked","Internet appointment checked","Critical contacts available"]
    @State private var refresh = UUID()
    var body: some View {
        ScrollView { VStack(alignment: .leading, spacing: 12) {
            Text("MOVE DAY MODE").font(.caption2.bold()).foregroundStyle(.orange); Text("Only what matters today").font(.largeTitle.bold())
            ForEach(Array(items.enumerated()), id: \.offset) { i, text in
                let key = "dubaimove.moveday.\(i)"; let d = UserDefaults.standard.bool(forKey: key)
                Button { UserDefaults.standard.set(!d, forKey: key); refresh = UUID() } label: {
                    HStack { Image(systemName: d ? "checkmark.circle.fill" : "circle").foregroundStyle(d ? DMTheme.green : .orange); Text(text).foregroundStyle(DMTheme.ink); Spacer() }.padding(14).background(.white).clipShape(RoundedRectangle(cornerRadius: 16))
                }.buttonStyle(.plain)
            }
        }.id(refresh).padding(16) }.background(Color(uiColor: .systemGroupedBackground).ignoresSafeArea()).navigationTitle("Move Day")
    }
}

struct RefundTrackerView: View {
    @AppStorage("dubaimove.refund.landlord.amount") private var landlord = ""
    @AppStorage("dubaimove.refund.dewa.amount") private var dewa = ""
    @AppStorage("dubaimove.refund.cooling.amount") private var cooling = ""
    var body: some View {
        Form { Section("Expected refunds") { TextField("Landlord deposit AED", text: $landlord).keyboardType(.decimalPad); TextField("DEWA deposit AED", text: $dewa).keyboardType(.decimalPad); TextField("Cooling deposit AED", text: $cooling).keyboardType(.decimalPad) }
            Section { Text("Tracker only: it does not determine legal entitlement.").font(.caption).foregroundStyle(.secondary) } }
        .navigationTitle("Refunds")
    }
}

@ViewBuilder
private func auditedDestination(_ target: PremiumMoveTarget, provider: String) -> some View {
    switch target {
    case .documents: FunctionalV2DocumentsView()
    case .ejari: EjariGuidedView()
    case .dewa: DewaGuidedView()
    case .telecom: ProviderAwareTelecomGuideView(provider: provider)
    case .cooling: CoolingGuidedView()
    case .building: BuildingGuidedView()
    case .services: ServicesMarketplaceV6View()
    case .inspection: ConnectedInspectionHubView()
    case .handover: FunctionalV2HandoverView()
    case .money: ConnectedMoneyView()
    case .leaving: FunctionalV2LeavingDubaiView()
    case .setup: FunctionalV2MoveSetupView()
    }
}

private extension View {
    func auditSurface() -> some View {
        self.padding(15).background(.white).clipShape(RoundedRectangle(cornerRadius: 20)).overlay(RoundedRectangle(cornerRadius: 20).stroke(Color.black.opacity(0.05), lineWidth: 1))
    }
}
