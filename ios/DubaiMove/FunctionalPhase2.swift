import SwiftUI
import UIKit
import UniformTypeIdentifiers
import QuickLook

// MARK: - Premium building blocks

private struct DMSectionTitle: View {
    let title: String
    var subtitle: String? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: 3) {
            Text(title).font(.title3.bold()).foregroundStyle(DMTheme.ink)
            if let subtitle { Text(subtitle).font(.subheadline).foregroundStyle(.secondary) }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

private struct DMBadgeIcon: View {
    let icon: String
    var tone: Color = DMTheme.green

    var body: some View {
        Image(systemName: icon)
            .font(.system(size: 17, weight: .semibold))
            .foregroundStyle(tone)
            .frame(width: 42, height: 42)
            .background(tone.opacity(0.11))
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
    }
}

private struct DMDisclosureCard<Destination: View>: View {
    let title: String
    let subtitle: String
    let icon: String
    var tone: Color = DMTheme.green
    @ViewBuilder let destination: () -> Destination

    var body: some View {
        NavigationLink(destination: destination()) {
            HStack(spacing: 14) {
                DMBadgeIcon(icon: icon, tone: tone)
                VStack(alignment: .leading, spacing: 4) {
                    Text(title).font(.headline).foregroundStyle(DMTheme.ink)
                    Text(subtitle).font(.caption).foregroundStyle(.secondary).lineLimit(2)
                }
                Spacer(minLength: 10)
                Image(systemName: "chevron.right")
                    .font(.caption.bold())
                    .foregroundStyle(.tertiary)
            }
            .dmCard()
        }
        .buttonStyle(.plain)
    }
}

private struct DMOfficialChip: View {
    let text: String
    var body: some View {
        HStack(spacing: 5) {
            Image(systemName: "checkmark.shield.fill")
            Text(text)
        }
        .font(.caption2.bold())
        .foregroundStyle(DMTheme.green)
        .padding(.horizontal, 9)
        .padding(.vertical, 6)
        .background(DMTheme.mint)
        .clipShape(Capsule())
    }
}

private extension View {
    func dmGroupedSurface() -> some View {
        self
            .scrollContentBackground(.hidden)
            .background(DMTheme.page.ignoresSafeArea())
            .listStyle(.insetGrouped)
    }
}

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
        .toolbarBackground(.visible, for: .tabBar)
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
    @AppStorage("dubaimove.v2.moveDate") private var moveDateEpoch = Date().addingTimeInterval(86400 * 21).timeIntervalSince1970

    private var checklist: LocalChecklistSnapshot { LocalChecklistSnapshot.current }
    private var targetDate: Date { Date(timeIntervalSince1970: moveDateEpoch) }
    private var routeTitle: String {
        if moveKind == LocalMoveKind.serviceOnly.rawValue { return "Service-only workspace" }
        if currentBuilding.isEmpty && newBuilding.isEmpty { return "Set up your move" }
        return "\(currentBuilding.isEmpty ? "Current home" : currentBuilding) → \(newBuilding.isEmpty ? "Destination" : newBuilding)"
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                header
                readinessHero
                moveSnapshot

                DMSectionTitle(title: "Next actions", subtitle: "The most important move steps, in the right order")
                VStack(spacing: 12) {
                    DMDisclosureCard(title: "Ejari", subtitle: "Register, renew, cancel or check through official DLD channels", icon: "doc.text.fill") { EjariV2View() }
                    DMDisclosureCard(title: "DEWA", subtitle: "Choose Move-In, Move-To or Move-Out without mixing the journeys", icon: "bolt.fill") { DewaV2View() }
                    DMDisclosureCard(title: "Internet & telecom", subtitle: "Official du, e& and Virgin Mobile routes", icon: "wifi") { TelecomV2View() }
                    DMDisclosureCard(title: "Leaving Dubai", subtitle: "Home exit, utilities, handover and departure guidance", icon: "airplane.departure", tone: .orange) { FunctionalV2LeavingDubaiView() }
                }

                DMSectionTitle(title: "Move tools", subtitle: "Everything else you need around the move")
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                    toolTile("Home services", "square.grid.2x2.fill", DMTheme.green, FunctionalV2ServicesView())
                    toolTile("Inspection", "camera.viewfinder", .blue, ConnectedInspectionHubView())
                    toolTile("Handover", "key.fill", .orange, FunctionalV2HandoverView())
                    toolTile("Documents", "folder.fill", .indigo, FunctionalV2DocumentsView())
                }

                HStack(spacing: 8) {
                    Image(systemName: APIConfiguration.isConnectedMode ? "network" : "iphone")
                    Text(APIConfiguration.isConnectedMode ? "Connected environment" : "Local TestFlight mode · private drafts stay on this iPhone")
                }
                .font(.caption)
                .foregroundStyle(.secondary)
                .padding(.horizontal, 4)
            }
            .padding(.horizontal, 16)
            .padding(.top, 10)
            .padding(.bottom, 28)
        }
        .background(DMTheme.page.ignoresSafeArea())
        .navigationBarTitleDisplayMode(.inline)
        .task { state.readiness = checklist.readiness }
    }

    private var header: some View {
        HStack(alignment: .center, spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text("DUBAI MOVE")
                    .font(.caption2.bold())
                    .tracking(1.3)
                    .foregroundStyle(DMTheme.green)
                Text("Your move, organized.")
                    .font(.largeTitle.bold())
                    .tracking(-0.8)
                    .foregroundStyle(DMTheme.ink)
                Text(moveKind).font(.subheadline.weight(.medium)).foregroundStyle(.secondary)
            }
            Spacer()
            NavigationLink(destination: FunctionalV2MoreView()) {
                Image(systemName: "square.grid.3x3.fill")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(DMTheme.green)
                    .frame(width: 44, height: 44)
                    .background(DMTheme.card)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(DMTheme.border, lineWidth: 0.8))
                    .shadow(color: DMTheme.shadow, radius: 10, y: 4)
            }
            .accessibilityLabel("More")
        }
    }

    private var readinessHero: some View {
        HStack(spacing: 18) {
            ZStack {
                Circle().stroke(Color.white.opacity(0.18), lineWidth: 9)
                Circle()
                    .trim(from: 0, to: max(0.015, Double(checklist.readiness) / 100))
                    .stroke(Color.white, style: StrokeStyle(lineWidth: 9, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                VStack(spacing: 0) {
                    Text("\(checklist.readiness)%").font(.title2.bold())
                    Text("READY").font(.caption2.bold()).opacity(0.78)
                }
                .foregroundStyle(.white)
            }
            .frame(width: 94, height: 94)

            VStack(alignment: .leading, spacing: 7) {
                Text("Move readiness").font(.title3.bold()).foregroundStyle(.white)
                Text("\(checklist.completed) of \(checklist.total) core tasks completed")
                    .font(.subheadline).foregroundStyle(.white.opacity(0.78))
                NavigationLink(destination: FunctionalV2MoveCenterView()) {
                    HStack(spacing: 6) {
                        Text("Open checklist")
                        Image(systemName: "arrow.right")
                    }
                    .font(.subheadline.bold())
                    .foregroundStyle(DMTheme.greenDeep)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(.white)
                    .clipShape(Capsule())
                }
                .buttonStyle(.plain)
            }
            Spacer(minLength: 0)
        }
        .padding(20)
        .background(
            LinearGradient(colors: [DMTheme.greenDeep, DMTheme.green, DMTheme.greenBright], startPoint: .topLeading, endPoint: .bottomTrailing)
        )
        .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
        .overlay(alignment: .topTrailing) {
            Circle().fill(.white.opacity(0.06)).frame(width: 130, height: 130).offset(x: 45, y: -55)
        }
        .shadow(color: DMTheme.greenDeep.opacity(0.18), radius: 18, y: 9)
    }

    private var moveSnapshot: some View {
        NavigationLink(destination: FunctionalV2MoveSetupView()) {
            HStack(spacing: 14) {
                DMBadgeIcon(icon: currentBuilding.isEmpty ? "house.badge.plus" : "arrow.left.arrow.right")
                VStack(alignment: .leading, spacing: 4) {
                    Text(routeTitle).font(.headline).foregroundStyle(DMTheme.ink).lineLimit(1)
                    HStack(spacing: 6) {
                        Image(systemName: "calendar")
                        Text(targetDate.formatted(date: .abbreviated, time: .omitted))
                    }
                    .font(.caption).foregroundStyle(.secondary)
                }
                Spacer()
                Image(systemName: "chevron.right").font(.caption.bold()).foregroundStyle(.tertiary)
            }
            .dmCard()
        }
        .buttonStyle(.plain)
    }

    private func toolTile<Destination: View>(_ title: String, _ icon: String, _ tone: Color, _ destination: Destination) -> some View {
        NavigationLink(destination: destination) {
            VStack(alignment: .leading, spacing: 14) {
                DMBadgeIcon(icon: icon, tone: tone)
                Text(title).font(.subheadline.bold()).foregroundStyle(DMTheme.ink)
                HStack { Text("Open").font(.caption).foregroundStyle(.secondary); Spacer(); Image(systemName: "arrow.up.right").font(.caption.bold()).foregroundStyle(tone) }
            }
            .frame(maxWidth: .infinity, minHeight: 118, alignment: .leading)
            .dmCard()
        }
        .buttonStyle(.plain)
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
            Section {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Set up your move").font(.title2.bold())
                    Text("A few details let Dubai Move organize the right checklist without guessing.").font(.subheadline).foregroundStyle(.secondary)
                }.padding(.vertical, 5)
            }
            Section("Journey") {
                Picker("What are you doing?", selection: $moveKind) { ForEach(LocalMoveKind.allCases) { Text($0.rawValue).tag($0.rawValue) } }
                DatePicker("Target date", selection: moveDate, displayedComponents: [.date])
                Picker("Property", selection: $propertyType) { ForEach(["Apartment", "Villa", "Townhouse", "Other"], id: \.self) { Text($0) } }
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
            Section { Label("Saved privately on this iPhone", systemImage: "lock.fill").font(.footnote).foregroundStyle(.secondary) }
        }
        .dmGroupedSurface()
        .navigationTitle("Move Setup")
        .navigationBarTitleDisplayMode(.inline)
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

    private var completedCount: Int { [contractDone, ejariDone, dewaDone, internetDone, buildingDone, moverDone, inspectionDone, handoverDone].filter { $0 }.count }
    private var readiness: Int { Int((Double(completedCount) / 8.0 * 100).rounded()) }

    var body: some View {
        List {
            Section {
                HStack(spacing: 18) {
                    ZStack {
                        Circle().stroke(DMTheme.mintStrong, lineWidth: 8)
                        Circle().trim(from: 0, to: max(0.01, Double(readiness) / 100)).stroke(DMTheme.green, style: StrokeStyle(lineWidth: 8, lineCap: .round)).rotationEffect(.degrees(-90))
                        Text("\(readiness)%").font(.headline.bold()).foregroundStyle(DMTheme.green)
                    }.frame(width: 72, height: 72)
                    VStack(alignment: .leading, spacing: 5) {
                        Text("Move readiness").font(.title3.bold())
                        Text("\(completedCount) of 8 core tasks complete").font(.subheadline).foregroundStyle(.secondary)
                        Label(Date(timeIntervalSince1970: moveDateEpoch).formatted(date: .abbreviated, time: .omitted), systemImage: "calendar")
                            .font(.caption).foregroundStyle(.secondary)
                    }
                }.padding(.vertical, 8)
            }
            Section("Core checklist") {
                checklistRow("Tenancy contract", "doc.text", isOn: $contractDone, destination: AnyView(FunctionalV2DocumentsView()))
                checklistRow("Ejari", "checkmark.seal", isOn: $ejariDone, destination: AnyView(EjariV2View()))
                checklistRow("DEWA", "bolt", isOn: $dewaDone, destination: AnyView(DewaV2View()))
                checklistRow("Internet / telecom", "wifi", isOn: $internetDone, destination: AnyView(TelecomV2View()))
                checklistRow("Building permit / lift", "building.2", isOn: $buildingDone, destination: AnyView(FunctionalV2BuildingView()))
                checklistRow("Moving service", "truck.box", isOn: $moverDone, destination: AnyView(FunctionalV2ServicesView()))
                checklistRow("Move-out inspection", "camera.viewfinder", isOn: $inspectionDone, destination: AnyView(ConnectedInspectionHubView()))
                checklistRow("Keys & handover", "key", isOn: $handoverDone, destination: AnyView(FunctionalV2HandoverView()))
            }
            Section("Planning") {
                NavigationLink("Edit move setup", destination: FunctionalV2MoveSetupView())
                NavigationLink("Reschedule move", destination: FunctionalV2RescheduleView())
                NavigationLink("Leaving Dubai Center", destination: FunctionalV2LeavingDubaiView())
            }
        }
        .dmGroupedSurface()
        .navigationTitle("My Move")
        .onAppear { state.readiness = readiness }
        .onChange(of: completedCount) { _, _ in state.readiness = readiness }
    }

    private func checklistRow(_ title: String, _ icon: String, isOn: Binding<Bool>, destination: AnyView) -> some View {
        HStack(spacing: 12) {
            Button { isOn.wrappedValue.toggle() } label: {
                Image(systemName: isOn.wrappedValue ? "checkmark.circle.fill" : "circle")
                    .foregroundStyle(isOn.wrappedValue ? DMTheme.green : .tertiary)
                    .font(.title3)
            }.buttonStyle(.plain)
            Image(systemName: icon).foregroundStyle(DMTheme.green).frame(width: 24)
            NavigationLink(destination: destination) { Text(title).foregroundStyle(.primary) }
        }.padding(.vertical, 3)
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
    var icon: String {
        switch self {
        case .rentalIndex: return "chart.bar.doc.horizontal"
        case .ejariRegister, .ejariCancel, .ejariCertificate: return "doc.badge.gearshape"
        case .dewaMoveIn, .dewaMoveTo, .dewaMoveOut: return "bolt.fill"
        case .duHomeMove, .etisalatSupport: return "wifi"
        case .virginMobile: return "iphone"
        case .empower, .emicool: return "snowflake"
        case .uaeResidence: return "airplane.departure"
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
        case .etisalatSupport: return "Official e& support route for Home Move and home-service changes."
        case .virginMobile: return "Virgin Mobile UAE mobile-service channel. It is not treated as fixed-home fibre."
        case .empower: return "Official Empower customer channel for account, move and final-bill actions."
        case .emicool: return "Official Emicool customer channel for applicable move-in/move-out actions."
        case .uaeResidence: return "Official UAE Government information; sponsorship/employment rules may apply."
        }
    }
}

struct OfficialV2ActionView: View {
    let action: OfficialV2Action
    @Environment(\.openURL) private var openURL

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                VStack(alignment: .leading, spacing: 14) {
                    HStack { DMBadgeIcon(icon: action.icon); Spacer(); DMOfficialChip(text: "Official channel") }
                    Text(action.title).font(.title.bold()).tracking(-0.4)
                    Text(action.detail).font(.subheadline).foregroundStyle(.secondary)
                    Divider()
                    LabeledContent("Provider", value: action.authority).font(.subheadline)
                }.dmCard()

                VStack(alignment: .leading, spacing: 10) {
                    Label("External handoff", systemImage: "arrow.up.right.square.fill").font(.headline)
                    Text("Dubai Move opens the authority/provider HTTPS channel. Opening the page never marks the external transaction as completed.")
                        .font(.subheadline).foregroundStyle(.secondary)
                    Button { openURL(action.url) } label: {
                        HStack { Text("Open official channel"); Spacer(); Image(systemName: "arrow.up.right") }
                            .font(.headline).frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent).tint(DMTheme.green)
                }.dmCard(background: DMTheme.mint)
            }
            .padding()
        }
        .background(DMTheme.page.ignoresSafeArea())
        .navigationTitle(action.title)
        .navigationBarTitleDisplayMode(.inline)
    }
}

private struct OfficialJourneyRow: View {
    let title: String
    let subtitle: String
    let icon: String
    let destination: OfficialV2Action
    var body: some View {
        NavigationLink(destination: OfficialV2ActionView(action: destination)) {
            HStack(spacing: 12) {
                DMBadgeIcon(icon: icon)
                VStack(alignment: .leading, spacing: 3) { Text(title).font(.headline); Text(subtitle).font(.caption).foregroundStyle(.secondary) }
            }.padding(.vertical, 3)
        }
    }
}

struct EjariV2View: View {
    var body: some View {
        List {
            Section { VStack(alignment: .leading, spacing: 6) { HStack { Text("Ejari").font(.title2.bold()); Spacer(); DMOfficialChip(text: "DLD") }; Text("Choose the exact journey you need. Dubai Move sends you to the matching official service.").font(.subheadline).foregroundStyle(.secondary) }.padding(.vertical, 6) }
            Section("Choose journey") {
                OfficialJourneyRow(title: "Register / Renew", subtitle: "Create or renew an Ejari registration", icon: "plus.rectangle.on.rectangle", destination: .ejariRegister)
                OfficialJourneyRow(title: "Cancel", subtitle: "Cancel an eligible Ejari contract", icon: "xmark.circle", destination: .ejariCancel)
                OfficialJourneyRow(title: "Download / Check", subtitle: "Retrieve or review your certificate", icon: "doc.text.magnifyingglass", destination: .ejariCertificate)
            }
            Section { Text("Requirements can differ by contract state and applicant role. Review the official DLD requirements before submission.").font(.footnote).foregroundStyle(.secondary) }
        }.dmGroupedSurface().navigationTitle("Ejari")
    }
}

struct DewaV2View: View {
    var body: some View {
        List {
            Section { VStack(alignment: .leading, spacing: 6) { HStack { Text("DEWA").font(.title2.bold()); Spacer(); DMOfficialChip(text: "DEWA") }; Text("Move-In, Move-To and Move-Out are different official journeys.").font(.subheadline).foregroundStyle(.secondary) }.padding(.vertical, 6) }
            Section("Choose journey") {
                OfficialJourneyRow(title: "Move-In", subtitle: "Activate a new premise", icon: "bolt.badge.a", destination: .dewaMoveIn)
                OfficialJourneyRow(title: "Move-To", subtitle: "Transfer from old to new premise", icon: "arrow.left.arrow.right", destination: .dewaMoveTo)
                OfficialJourneyRow(title: "Move-Out", subtitle: "Deactivate and manage final bill", icon: "bolt.slash", destination: .dewaMoveOut)
            }
            Section("Move-To preparation") {
                Label("Existing contract account", systemImage: "number")
                Label("New Ejari", systemImage: "doc.text")
                Label("New 9-digit premise number", systemImage: "building.2")
                Label("Move-out and move-in dates", systemImage: "calendar")
            }
        }.dmGroupedSurface().navigationTitle("DEWA")
    }
}

struct TelecomV2View: View {
    var body: some View {
        List {
            Section { VStack(alignment: .leading, spacing: 6) { Text("Internet & Telecom").font(.title2.bold()); Text("Use the provider's own official channel; Dubai Move does not invent address availability.").font(.subheadline).foregroundStyle(.secondary) }.padding(.vertical, 6) }
            Section("Home internet") {
                OfficialJourneyRow(title: "du Home relocation", subtitle: "Move an existing du Home service", icon: "wifi", destination: .duHomeMove)
                OfficialJourneyRow(title: "e& Home Move", subtitle: "Move or manage an e& Home service", icon: "wifi.router", destination: .etisalatSupport)
            }
            Section("Mobile service") { OfficialJourneyRow(title: "Virgin Mobile UAE", subtitle: "Manage mobile service separately", icon: "iphone", destination: .virginMobile) }
            Section { Text("Virgin Mobile is shown under mobile service, not as a fixed-fibre provider.").font(.footnote).foregroundStyle(.secondary) }
        }.dmGroupedSurface().navigationTitle("Internet & Telecom")
    }
}

struct CoolingV2View: View {
    @State private var provider = "Not sure"
    var body: some View {
        List {
            Section { VStack(alignment: .leading, spacing: 6) { Text("District Cooling").font(.title2.bold()); Text("Your building determines the provider. Confirm it before continuing.").font(.subheadline).foregroundStyle(.secondary) }.padding(.vertical, 6) }
            Section("Provider") {
                Picker("District cooling", selection: $provider) { Text("Not sure").tag("Not sure"); Text("Empower").tag("Empower"); Text("Emicool").tag("Emicool") }
                    .pickerStyle(.segmented)
            }
            if provider == "Empower" { Section { OfficialJourneyRow(title: "Open Empower", subtitle: "Official customer services", icon: "snowflake", destination: .empower) } }
            else if provider == "Emicool" { Section { OfficialJourneyRow(title: "Open Emicool", subtitle: "Official customer services", icon: "snowflake", destination: .emicool) } }
            else { Section { Label("Check building management or your latest cooling bill", systemImage: "info.circle").font(.subheadline).foregroundStyle(.secondary) } }
        }.dmGroupedSurface().navigationTitle("Cooling")
    }
}

// MARK: - Real local service request queue

struct LocalV2ServiceRequest: Codable, Identifiable {
    var id = UUID(); var service: String; var note: String; var requestedDate: Date; var createdAt = Date()
}

@MainActor final class LocalV2ServiceStore: ObservableObject {
    @Published var requests: [LocalV2ServiceRequest] = [] { didSet { save() } }
    private let key = "dubaimove.v2.requests"
    init() { if let data = UserDefaults.standard.data(forKey: key), let saved = try? JSONDecoder().decode([LocalV2ServiceRequest].self, from: data) { requests = saved } }
    func add(service: String, note: String, date: Date) { requests.insert(.init(service: service, note: note, requestedDate: date), at: 0) }
    func delete(at offsets: IndexSet) { requests.remove(atOffsets: offsets) }
    private func save() { if let data = try? JSONEncoder().encode(requests) { UserDefaults.standard.set(data, forKey: key) } }
}

struct FunctionalV2ServicesView: View {
    @StateObject private var store = LocalV2ServiceStore()
    var body: some View {
        List {
            Section { VStack(alignment: .leading, spacing: 6) { Text("Home Services").font(.title2.bold()); Text("Create a request now. Live matching begins only when the connected provider backend is available.").font(.subheadline).foregroundStyle(.secondary) }.padding(.vertical, 6) }
            Section("Home services") {
                ForEach(Array(ServiceCategory.all.prefix(6))) { service in
                    NavigationLink(destination: FunctionalV2ServiceRequestForm(service: service, store: store)) {
                        HStack(spacing: 12) {
                            DMBadgeIcon(icon: service.icon)
                            VStack(alignment: .leading, spacing: 3) { Text(service.title).font(.headline); Text(service.subtitle).font(.caption).foregroundStyle(.secondary) }
                        }.padding(.vertical, 2)
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
                if store.requests.isEmpty { Label("No local requests yet", systemImage: "tray").foregroundStyle(.secondary) }
                ForEach(store.requests) { request in
                    VStack(alignment: .leading, spacing: 4) {
                        HStack { Text(request.service).font(.headline); Spacer(); Text("LOCAL").font(.caption2.bold()).foregroundStyle(DMTheme.green) }
                        Label(request.requestedDate.formatted(date: .abbreviated, time: .shortened), systemImage: "calendar").font(.caption).foregroundStyle(.secondary)
                        if !request.note.isEmpty { Text(request.note).font(.caption).foregroundStyle(.secondary) }
                    }.padding(.vertical, 3)
                }.onDelete(perform: store.delete)
            }
            Section { Label("No fake quotes or provider acceptance", systemImage: "checkmark.shield.fill").font(.footnote).foregroundStyle(.secondary) }
        }.dmGroupedSurface().navigationTitle("Services")
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
            Section { HStack(spacing: 14) { DMBadgeIcon(icon: service.icon); VStack(alignment: .leading, spacing: 4) { Text(service.title).font(.title3.bold()); Text(service.subtitle).font(.subheadline).foregroundStyle(.secondary) } }.padding(.vertical, 6) }
            Section("Request") { DatePicker("Preferred date", selection: $date, displayedComponents: [.date, .hourAndMinute]); TextField("Scope / notes", text: $note, axis: .vertical).lineLimit(3...7) }
            Section { Button { store.add(service: service.title, note: note, date: date); dismiss() } label: { HStack { Text("Save request"); Spacer(); Image(systemName: "checkmark.circle.fill") }.font(.headline) }.buttonStyle(.borderedProminent).tint(DMTheme.green) }
            Section { Text("Saved locally until the provider backend is connected.").font(.footnote).foregroundStyle(.secondary) }
        }.dmGroupedSurface().navigationTitle(service.title).navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Real local document wallet

struct LocalV2Document: Codable, Identifiable {
    var id = UUID(); var type: String; var originalName: String; var storedPath: String; var addedAt = Date()
}

@MainActor final class LocalV2DocumentStore: ObservableObject {
    @Published var items: [LocalV2Document] = [] { didSet { saveIndex() } }
    private let key = "dubaimove.v2.documents.index"
    init() { if let data = UserDefaults.standard.data(forKey: key), let saved = try? JSONDecoder().decode([LocalV2Document].self, from: data) { items = saved } }
    func importFile(from source: URL, type: String) throws {
        let scoped = source.startAccessingSecurityScopedResource(); defer { if scoped { source.stopAccessingSecurityScopedResource() } }
        let folder = try documentFolder(); let ext = source.pathExtension.isEmpty ? "dat" : source.pathExtension
        let destination = folder.appendingPathComponent("\(UUID().uuidString).\(ext)")
        try FileManager.default.copyItem(at: source, to: destination)
        items.insert(.init(type: type, originalName: source.lastPathComponent, storedPath: destination.path), at: 0)
    }
    func delete(at offsets: IndexSet) { for index in offsets { try? FileManager.default.removeItem(atPath: items[index].storedPath) }; items.remove(atOffsets: offsets) }
    private func documentFolder() throws -> URL {
        let base = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
        let folder = base.appendingPathComponent("DubaiMoveDocuments", isDirectory: true)
        try FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true); return folder
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
            Section { VStack(alignment: .leading, spacing: 6) { HStack { Text("Document Wallet").font(.title2.bold()); Spacer(); Image(systemName: "lock.shield.fill").foregroundStyle(DMTheme.green) }; Text("Private local copies with in-app preview.").font(.subheadline).foregroundStyle(.secondary) }.padding(.vertical, 6) }
            Section("Add document") {
                Picker("Type", selection: $type) { ForEach(["Tenancy Contract", "Ejari", "DEWA", "Cooling", "Building Permit", "Provider", "Inspection", "Handover", "Receipt"], id: \.self) { Text($0) } }
                Button { importing = true } label: { Label("Choose PDF / image", systemImage: "plus.circle.fill").font(.headline) }
            }
            Section("Private local wallet") {
                if store.items.isEmpty { ContentUnavailableView("No documents yet", systemImage: "folder", description: Text("Add a PDF or image to start your private move wallet.")) }
                ForEach(store.items) { item in
                    Button {
                        let url = URL(fileURLWithPath: item.storedPath); if FileManager.default.fileExists(atPath: url.path) { previewURL = url }
                    } label: {
                        HStack(spacing: 12) {
                            DMBadgeIcon(icon: item.originalName.lowercased().hasSuffix(".pdf") ? "doc.richtext.fill" : "photo.fill", tone: .indigo)
                            VStack(alignment: .leading, spacing: 3) { Text(item.type).font(.headline).foregroundStyle(.primary); Text(item.originalName).font(.caption).foregroundStyle(.secondary).lineLimit(1); Text(item.addedAt.formatted(date: .abbreviated, time: .shortened)).font(.caption2).foregroundStyle(.tertiary) }
                            Spacer(); Image(systemName: "eye.fill").foregroundStyle(.secondary)
                        }.padding(.vertical, 2)
                    }
                }.onDelete(perform: store.delete)
            }
            if let errorMessage { Section { Label(errorMessage, systemImage: "exclamationmark.triangle.fill").foregroundStyle(.red) } }
            Section { Label("Files stay in Dubai Move's private app container", systemImage: "lock.fill").font(.footnote).foregroundStyle(.secondary) }
        }
        .dmGroupedSurface().navigationTitle("Documents")
        .fileImporter(isPresented: $importing, allowedContentTypes: [.pdf, .image]) { result in
            do { let url = try result.get(); try store.importFile(from: url, type: type); errorMessage = nil } catch { errorMessage = error.localizedDescription }
        }
        .sheet(isPresented: Binding(get: { previewURL != nil }, set: { if !$0 { previewURL = nil } })) { if let previewURL { QuickLookPreview(url: previewURL) } }
    }
}

struct QuickLookPreview: UIViewControllerRepresentable {
    let url: URL
    func makeCoordinator() -> Coordinator { Coordinator(url: url) }
    func makeUIViewController(context: Context) -> QLPreviewController { let controller = QLPreviewController(); controller.dataSource = context.coordinator; return controller }
    func updateUIViewController(_ uiViewController: QLPreviewController, context: Context) {}
    final class Coordinator: NSObject, QLPreviewControllerDataSource {
        let url: URL; init(url: URL) { self.url = url }
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
            Section { VStack(alignment: .leading, spacing: 6) { Text("Building Access").font(.title2.bold()); Text("Keep management contacts, permit portal and lift/loading notes together.").font(.subheadline).foregroundStyle(.secondary) }.padding(.vertical, 6) }
            Section("Building management") {
                TextField("Phone", text: $phone).keyboardType(.phonePad)
                TextField("Email", text: $email).keyboardType(.emailAddress).textInputAutocapitalization(.never)
                TextField("Verified portal URL (optional)", text: $portal).textInputAutocapitalization(.never).keyboardType(.URL)
                HStack {
                    Button("Call") { if let url = URL(string: "tel:\(phone.filter { "+0123456789".contains($0) })") { openURL(url) } }.disabled(phone.isEmpty)
                    Spacer()
                    Button("Email") { if let url = URL(string: "mailto:\(email)") { openURL(url) } }.disabled(!email.contains("@"))
                }
                Button("Open saved HTTPS portal") { guard let url = URL(string: portal), url.scheme == "https" else { return }; openURL(url) }.disabled(!(URL(string: portal)?.scheme == "https"))
            }
            Section("Permit / lift / loading") { TextField("Requirements and notes", text: $notes, axis: .vertical).lineLimit(4...10) }
            Section { Label("Dubai Move never guesses a building-management portal", systemImage: "checkmark.shield.fill").font(.footnote).foregroundStyle(.secondary) }
        }.dmGroupedSurface().navigationTitle("Building Access")
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

    private var doneCount: Int { [cleaning, inspection, dewa, cooling, telecom, keys, deposit].filter { $0 }.count }

    var body: some View {
        List {
            Section { HStack { VStack(alignment: .leading, spacing: 5) { Text("Handover").font(.title2.bold()); Text("\(doneCount) of 7 handover items complete").font(.subheadline).foregroundStyle(.secondary) }; Spacer(); Text("\(Int((Double(doneCount) / 7 * 100).rounded()))%").font(.title.bold()).foregroundStyle(DMTheme.green) }.padding(.vertical, 6) }
            Section("Handover checklist") {
                Toggle("Final cleaning", isOn: $cleaning); Toggle("Move-out inspection", isOn: $inspection); Toggle("DEWA final bill / clearance", isOn: $dewa); Toggle("Cooling move-out", isOn: $cooling); Toggle("Telecom transfer / cancellation", isOn: $telecom); Toggle("Keys & access returned", isOn: $keys); Toggle("Deposit follow-up started", isOn: $deposit)
            }
            Section("Actions") {
                NavigationLink("Move-out inspection", destination: ConnectedInspectionHubView())
                NavigationLink("DEWA Move-Out", destination: OfficialV2ActionView(action: .dewaMoveOut))
                NavigationLink("Cooling", destination: CoolingV2View())
                NavigationLink("Internet / telecom", destination: TelecomV2View())
            }
            Section("Handover pack") {
                Button { pdfURL = generatePDF() } label: { Label("Generate local PDF summary", systemImage: "doc.badge.plus") }
                if let pdfURL { ShareLink(item: pdfURL) { Label("Share PDF", systemImage: "square.and.arrow.up") } }
            }
        }.dmGroupedSurface().navigationTitle("Handover")
    }

    private func generatePDF() -> URL? {
        let url = FileManager.default.temporaryDirectory.appendingPathComponent("DubaiMove-Handover-\(UUID().uuidString).pdf")
        let renderer = UIGraphicsPDFRenderer(bounds: CGRect(x: 0, y: 0, width: 595, height: 842))
        do {
            try renderer.writePDF(to: url) { context in
                context.beginPage()
                "Dubai Move – Handover Summary".draw(at: CGPoint(x: 48, y: 48), withAttributes: [.font: UIFont.boldSystemFont(ofSize: 22)])
                "Generated privately on this iPhone".draw(at: CGPoint(x: 48, y: 80), withAttributes: [.font: UIFont.systemFont(ofSize: 11), .foregroundColor: UIColor.secondaryLabel])
                let rows = [("Final cleaning", cleaning), ("Move-out inspection", inspection), ("DEWA final bill / clearance", dewa), ("Cooling move-out", cooling), ("Telecom transfer / cancellation", telecom), ("Keys & access returned", keys), ("Deposit follow-up", deposit)]
                var y: CGFloat = 120
                for row in rows { "\(row.1 ? "✓" : "○")  \(row.0)".draw(at: CGPoint(x: 48, y: y), withAttributes: [.font: UIFont.systemFont(ofSize: 15)]); y += 30 }
                "External utility/government completion is never inferred from this summary.".draw(in: CGRect(x: 48, y: y + 22, width: 500, height: 80), withAttributes: [.font: UIFont.systemFont(ofSize: 11), .foregroundColor: UIColor.secondaryLabel])
            }
            return url
        } catch { return nil }
    }
}

struct FunctionalV2LeavingDubaiView: View {
    var body: some View {
        List {
            Section { VStack(alignment: .leading, spacing: 7) { HStack { DMBadgeIcon(icon: "airplane.departure", tone: .orange); Spacer(); Text("EXIT CENTER").font(.caption2.bold()).foregroundStyle(.orange) }; Text("Leaving Dubai").font(.title2.bold()); Text("Home exit and UAE departure are separate journeys, so nothing important gets mixed together.").font(.subheadline).foregroundStyle(.secondary) }.padding(.vertical, 7) }
            Section("Home exit") {
                NavigationLink("Ejari cancellation", destination: OfficialV2ActionView(action: .ejariCancel)); NavigationLink("DEWA Move-Out", destination: OfficialV2ActionView(action: .dewaMoveOut)); NavigationLink("Cooling Move-Out", destination: CoolingV2View()); NavigationLink("Internet / telecom", destination: TelecomV2View()); NavigationLink("Move-out inspection", destination: ConnectedInspectionHubView()); NavigationLink("Cleaning", destination: FunctionalV2ServicesView()); NavigationLink("Keys & handover", destination: FunctionalV2HandoverView()); NavigationLink("Deposit / refunds", destination: ConnectedMoneyView())
            }
            Section("UAE departure") {
                NavigationLink("Residence cancellation guidance", destination: OfficialV2ActionView(action: .uaeResidence)); NavigationLink("Mobile service", destination: OfficialV2ActionView(action: .virginMobile))
            }
            Section { Text("Visa and work-permit cancellation can depend on sponsorship/employment circumstances. Dubai Move links to official guidance; it does not give immigration or legal advice.").font(.footnote).foregroundStyle(.secondary) }
        }.dmGroupedSurface().navigationTitle("Leaving Dubai")
    }
}

// MARK: - Reschedule, support, privacy and more

struct FunctionalV2RescheduleView: View {
    @AppStorage("dubaimove.v2.moveDate") private var moveDateEpoch = Date().addingTimeInterval(86400 * 21).timeIntervalSince1970
    private var dateBinding: Binding<Date> { Binding(get: { Date(timeIntervalSince1970: moveDateEpoch) }, set: { moveDateEpoch = $0.timeIntervalSince1970 }) }
    var body: some View {
        Form {
            Section { VStack(alignment: .leading, spacing: 6) { Text("Reschedule safely").font(.title2.bold()); Text("The move date changes here, but external bookings never change silently.").font(.subheadline).foregroundStyle(.secondary) }.padding(.vertical, 6) }
            Section("New move date") { DatePicker("Move date", selection: dateBinding, displayedComponents: .date) }
            Section("Review affected items") { NavigationLink("Mover / home services", destination: FunctionalV2ServicesView()); NavigationLink("Building permit / lift", destination: FunctionalV2BuildingView()); NavigationLink("DEWA", destination: DewaV2View()); NavigationLink("Internet", destination: TelecomV2View()); NavigationLink("Cleaning", destination: FunctionalV2ServicesView()) }
            Section { Label("Each external item must be reviewed separately", systemImage: "exclamationmark.triangle").font(.footnote).foregroundStyle(.secondary) }
        }.dmGroupedSurface().navigationTitle("Reschedule")
    }
}

struct LocalSupportTicket: Codable, Identifiable { var id = UUID(); var category: String; var message: String; var createdAt = Date() }
@MainActor final class LocalSupportStore: ObservableObject {
    @Published var tickets: [LocalSupportTicket] = [] { didSet { save() } }; private let key = "dubaimove.v2.support"
    init() { if let data = UserDefaults.standard.data(forKey: key), let saved = try? JSONDecoder().decode([LocalSupportTicket].self, from: data) { tickets = saved } }
    func add(category: String, message: String) { tickets.insert(.init(category: category, message: message), at: 0) }
    private func save() { if let data = try? JSONEncoder().encode(tickets) { UserDefaults.standard.set(data, forKey: key) } }
}

struct FunctionalV2SupportView: View {
    @StateObject private var store = LocalSupportStore(); @State private var category = "App issue"; @State private var message = ""; @State private var saved = false
    var body: some View {
        Form {
            Section { VStack(alignment: .leading, spacing: 5) { Text("Support").font(.title2.bold()); Text("Save a clear local support draft while the public backend is not connected.").font(.subheadline).foregroundStyle(.secondary) }.padding(.vertical, 6) }
            Section("New ticket") {
                Picker("Category", selection: $category) { ForEach(["App issue", "Service request", "Government link", "Building info", "Other"], id: \.self) { Text($0) } }
                TextField("Describe the issue", text: $message, axis: .vertical).lineLimit(4...10)
                Button(saved ? "Saved" : "Save support ticket") { store.add(category: category, message: message); saved = true; message = "" }.disabled(message.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
            Section("Saved tickets") {
                if store.tickets.isEmpty { Text("No tickets yet").foregroundStyle(.secondary) }
                ForEach(store.tickets) { ticket in VStack(alignment: .leading, spacing: 4) { HStack { Text(ticket.category).font(.headline); Spacer(); Text("LOCAL").font(.caption2.bold()).foregroundStyle(DMTheme.green) }; Text(ticket.message); Text(ticket.createdAt.formatted()).font(.caption).foregroundStyle(.secondary) }.padding(.vertical, 2) }
            }
            Section { Text("This is a local draft in backend-free TestFlight mode, not a submitted server ticket.").font(.footnote).foregroundStyle(.secondary) }
        }.dmGroupedSurface().navigationTitle("Support")
    }
}

struct FunctionalV2StatusShareView: View {
    @AppStorage("dubaimove.v2.currentBuilding") private var currentBuilding = ""
    @AppStorage("dubaimove.v2.newBuilding") private var newBuilding = ""
    @AppStorage("dubaimove.v2.moveDate") private var moveDateEpoch = Date().timeIntervalSince1970
    private var summary: String { "Dubai Move status\nRoute: \(currentBuilding.isEmpty ? "Current home" : currentBuilding) → \(newBuilding.isEmpty ? "Destination" : newBuilding)\nMove date: \(Date(timeIntervalSince1970: moveDateEpoch).formatted(date: .abbreviated, time: .omitted))\nReadiness: \(LocalChecklistSnapshot.current.readiness)%\n\nShared manually by the user. Documents, photos, chats and phone number are not included." }
    var body: some View {
        Form {
            Section { VStack(alignment: .leading, spacing: 5) { Text("Share move status").font(.title2.bold()); Text("Only a minimal summary is included by default.").font(.subheadline).foregroundStyle(.secondary) }.padding(.vertical, 6) }
            Section("Included") { Label("Route", systemImage: "checkmark.circle.fill"); Label("Move date", systemImage: "checkmark.circle.fill"); Label("Readiness percentage", systemImage: "checkmark.circle.fill") }
            Section("Excluded") { Label("Documents", systemImage: "xmark.circle"); Label("Photos", systemImage: "xmark.circle"); Label("Chats", systemImage: "xmark.circle"); Label("Phone number", systemImage: "xmark.circle") }
            Section { ShareLink(item: summary) { Label("Share status summary", systemImage: "square.and.arrow.up").font(.headline) } }
            Section { Text("A public revocable status URL requires the connected backend. This mode shares only the text you explicitly choose.").font(.footnote).foregroundStyle(.secondary) }
        }.dmGroupedSurface().navigationTitle("Status Sharing")
    }
}

struct FunctionalV2PrivacyView: View {
    var body: some View {
        List {
            Section { VStack(alignment: .leading, spacing: 6) { HStack { DMBadgeIcon(icon: "lock.shield.fill"); Spacer(); DMOfficialChip(text: "Private by default") }; Text("Privacy & Data").font(.title2.bold()); Text("Dubai Move makes local and connected behavior explicit instead of pretending data synced.").font(.subheadline).foregroundStyle(.secondary) }.padding(.vertical, 6) }
            Section("Local TestFlight mode") { Label("Move profile and drafts stay on this iPhone", systemImage: "iphone"); Label("Documents are copied into the private app container", systemImage: "lock.doc.fill"); Label("No fake cloud sync or provider acceptance", systemImage: "checkmark.shield.fill") }
            Section("Connected mode") { Text("When a staging/production backend is configured, secure session, scoped document upload, provider requests and official handoff registry are used.").font(.footnote) }
            Section("Government boundary") { Text("Dubai Move never claims a government/utility transaction is complete simply because an external page was opened.").font(.footnote) }
        }.dmGroupedSurface().navigationTitle("Privacy & Data")
    }
}

struct FunctionalV2MoreView: View {
    @AppStorage("dubaimove.onboarding.completed") private var onboardingCompleted = true
    var body: some View {
        List {
            Section { VStack(alignment: .leading, spacing: 5) { Text("Dubai Move").font(.title2.bold()); Text("Settings, privacy and move utilities").font(.subheadline).foregroundStyle(.secondary) }.padding(.vertical, 6) }
            Section("Move") { NavigationLink("Move setup", destination: FunctionalV2MoveSetupView()); NavigationLink("Reschedule", destination: FunctionalV2RescheduleView()); NavigationLink("Status sharing", destination: FunctionalV2StatusShareView()); NavigationLink("Leaving Dubai", destination: FunctionalV2LeavingDubaiView()) }
            Section("Account & device") { Button("Enable notifications") { Task { await PushRegistration.request() } }; NavigationLink("Privacy & data", destination: FunctionalV2PrivacyView()); NavigationLink("Support", destination: FunctionalV2SupportView()) }
            Section("Environment") { LabeledContent("Mode", value: APIConfiguration.isConnectedMode ? "Connected" : "Local TestFlight"); Text("Provider marketplace, server messaging and secure cloud OCR activate only when the public backend is configured.").font(.footnote).foregroundStyle(.secondary) }
            Section { Button("Run onboarding again") { onboardingCompleted = false } }
        }.dmGroupedSurface().navigationTitle("More")
    }
}
