import SwiftUI
import UIKit

// MARK: - Smart move command center

struct SmartMoveCommandCenterView: View {
    @AppStorage("dubaimove.v2.moveKind") private var moveKind = LocalMoveKind.withinDubai.rawValue
    @AppStorage("dubaimove.v2.moveDate") private var moveDateEpoch = Date().addingTimeInterval(86400 * 21).timeIntervalSince1970
    @AppStorage("dubaimove.intelligence.homeType") private var homeType = "Apartment"
    @AppStorage("dubaimove.intelligence.occupancy") private var occupancy = "Tenant"
    @AppStorage("dubaimove.intelligence.internet") private var internetProvider = "Not sure"
    @AppStorage("dubaimove.guide.cooling.arrangement") private var coolingArrangement = "Not sure"
    @State private var refreshID = UUID()

    private var plan: PremiumMovePlan { PremiumMovePlan.plan(for: moveKind) }
    private var moveDate: Date { Date(timeIntervalSince1970: moveDateEpoch) }
    private var daysToMove: Int { Calendar.current.dateComponents([.day], from: Calendar.current.startOfDay(for: Date()), to: Calendar.current.startOfDay(for: moveDate)).day ?? 0 }
    private var visibleSteps: [PremiumMoveStep] {
        plan.steps.filter { !($0.target == .cooling && coolingArrangement == "Chiller free") }
    }
    private var blockers: [PremiumMoveStep] {
        visibleSteps.filter { isBlocker($0) && !isDone($0) }
    }
    private var dueNow: [PremiumMoveStep] {
        visibleSteps.filter { !isDone($0) && recommendedDaysBefore($0.target) >= daysToMove }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                hero
                profileCard
                readinessCard
                todayCard
                blockersCard
                quickTools
                timeline
            }
            .id(refreshID)
            .padding(16)
            .padding(.bottom, 100)
        }
        .background(Color(uiColor: .systemGroupedBackground).ignoresSafeArea())
        .navigationTitle("My Move")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var hero: some View {
        ZStack(alignment: .bottomLeading) {
            LinearGradient(colors: [DMTheme.greenDeep, DMTheme.green, .teal], startPoint: .topLeading, endPoint: .bottomTrailing)
            Image(systemName: "sparkles.rectangle.stack.fill")
                .font(.system(size: 135, weight: .ultraLight))
                .foregroundStyle(.white.opacity(0.10))
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
                .offset(x: 18, y: -6)
            VStack(alignment: .leading, spacing: 8) {
                Text("YOUR MOVE COMMAND CENTER").font(.caption2.bold()).tracking(1.4).foregroundStyle(.white.opacity(0.78))
                Text(daysToMove >= 0 ? "\(daysToMove) days to move day" : "Move day passed")
                    .font(.system(size: 30, weight: .heavy, design: .rounded)).foregroundStyle(.white)
                Text("We decide what matters now, explain every task, show blockers and connect you to the right official guide or service.")
                    .font(.subheadline).foregroundStyle(.white.opacity(0.86))
            }.padding(20)
        }
        .frame(maxWidth: .infinity, minHeight: 210)
        .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
    }

    private var profileCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack { Label("Personalize my route", systemImage: "slider.horizontal.3").font(.headline); Spacer(); Text("SMART").font(.caption2.bold()).foregroundStyle(DMTheme.green) }
            Picker("Occupancy", selection: $occupancy) { Text("Tenant").tag("Tenant"); Text("Owner").tag("Owner") }.pickerStyle(.segmented)
            Picker("Home", selection: $homeType) { Text("Apartment").tag("Apartment"); Text("Villa").tag("Villa") }.pickerStyle(.segmented)
            VStack(alignment: .leading, spacing: 6) {
                Text("Home internet").font(.caption.bold()).foregroundStyle(.secondary)
                Picker("Internet", selection: $internetProvider) {
                    Text("Not sure").tag("Not sure"); Text("du").tag("du"); Text("e&").tag("e&"); Text("Virgin").tag("Virgin")
                }.pickerStyle(.segmented)
            }
            VStack(alignment: .leading, spacing: 6) {
                Text("Cooling").font(.caption.bold()).foregroundStyle(.secondary)
                Picker("Cooling", selection: $coolingArrangement) {
                    Text("Not sure").tag("Not sure"); Text("Chiller free").tag("Chiller free"); Text("Separate bill").tag("Separate bill")
                }.pickerStyle(.segmented)
            }
            if coolingArrangement == "Chiller free" {
                Label("Separate district-cooling setup is hidden because you marked this home chiller-free.", systemImage: "checkmark.circle.fill")
                    .font(.caption).foregroundStyle(DMTheme.green)
            }
        }.smartSurface()
    }

    private var readinessCard: some View {
        let done = visibleSteps.filter(isDone).count
        return HStack(spacing: 14) {
            ZStack {
                Circle().stroke(DMTheme.mint, lineWidth: 9)
                Circle().trim(from: 0, to: visibleSteps.isEmpty ? 0 : Double(done) / Double(visibleSteps.count))
                    .stroke(DMTheme.green, style: StrokeStyle(lineWidth: 9, lineCap: .round)).rotationEffect(.degrees(-90))
                Text("\(done)/\(visibleSteps.count)").font(.headline.bold())
            }.frame(width: 76, height: 76)
            VStack(alignment: .leading, spacing: 4) {
                Text(blockers.isEmpty ? "No critical blockers" : "\(blockers.count) move-day blocker\(blockers.count == 1 ? "" : "s")")
                    .font(.headline).foregroundStyle(blockers.isEmpty ? DMTheme.green : .red)
                Text(blockers.isEmpty ? "Keep following your timeline." : "Clear these before you rely on the move-day plan.")
                    .font(.caption).foregroundStyle(.secondary)
            }
            Spacer()
        }.smartSurface()
    }

    private var todayCard: some View {
        VStack(alignment: .leading, spacing: 11) {
            Label("What should I do now?", systemImage: "sun.max.fill").font(.title3.bold()).foregroundStyle(.orange)
            if dueNow.isEmpty {
                Text("Nothing urgent right now. Review the next upcoming task and keep your confirmations together.").font(.subheadline).foregroundStyle(.secondary)
            } else {
                ForEach(dueNow.prefix(4)) { step in
                    NavigationLink(destination: SmartTaskGuideView(step: step, internetProvider: internetProvider)) {
                        HStack(spacing: 11) {
                            Image(systemName: step.icon).foregroundStyle(tint(step.target)).frame(width: 28)
                            VStack(alignment: .leading, spacing: 2) {
                                Text(step.title).font(.subheadline.bold()).foregroundStyle(DMTheme.ink)
                                Text(dueLabel(step)).font(.caption).foregroundStyle(.secondary)
                            }
                            Spacer(); Image(systemName: "chevron.right").font(.caption.bold()).foregroundStyle(.secondary)
                        }.padding(11).background(tint(step.target).opacity(0.07)).clipShape(RoundedRectangle(cornerRadius: 14))
                    }.buttonStyle(.plain)
                }
            }
        }.smartSurface()
    }

    private var blockersCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Label("Can I move yet?", systemImage: blockers.isEmpty ? "checkmark.shield.fill" : "exclamationmark.triangle.fill")
                .font(.title3.bold()).foregroundStyle(blockers.isEmpty ? DMTheme.green : .red)
            if blockers.isEmpty {
                Text("No critical blocker is currently detected from your saved checklist. Still verify building access, utility status and provider appointments before move day.")
                    .font(.subheadline).foregroundStyle(.secondary)
            } else {
                ForEach(blockers) { step in
                    HStack(alignment: .top, spacing: 9) {
                        Image(systemName: "xmark.circle.fill").foregroundStyle(.red)
                        VStack(alignment: .leading, spacing: 2) {
                            Text(step.title).font(.subheadline.bold())
                            Text(blockerReason(step.target)).font(.caption).foregroundStyle(.secondary)
                        }
                    }
                }
            }
        }.smartSurface()
    }

    private var quickTools: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Move tools").font(.title3.bold())
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                NavigationLink(destination: MoveDayModeView()) { tool("Move Day", "Critical-only checklist", "figure.walk.motion", .orange) }
                NavigationLink(destination: RefundTrackerView()) { tool("Refunds", "Track expected money", "banknote.fill", .mint) }
                NavigationLink(destination: FunctionalV2DocumentsView()) { tool("Documents", "Keep proof together", "folder.fill", .blue) }
                NavigationLink(destination: ServicesMarketplaceV6View()) { tool("Get help", "Browse service providers", "person.2.fill", .purple) }
            }.buttonStyle(.plain)
        }
    }

    private func tool(_ title: String, _ subtitle: String, _ icon: String, _ color: Color) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Image(systemName: icon).font(.title2.bold()).foregroundStyle(color).frame(width: 44, height: 44).background(color.opacity(0.12)).clipShape(RoundedRectangle(cornerRadius: 14))
            Text(title).font(.headline).foregroundStyle(DMTheme.ink)
            Text(subtitle).font(.caption).foregroundStyle(.secondary).lineLimit(2)
        }.frame(maxWidth: .infinity, minHeight: 126, alignment: .leading).padding(13).background(.white).clipShape(RoundedRectangle(cornerRadius: 20))
    }

    private var timeline: some View {
        VStack(alignment: .leading, spacing: 11) {
            Text("Your personalized timeline").font(.title3.bold())
            Text("Tasks move with your move date. Chiller-free homes skip separate cooling setup.").font(.caption).foregroundStyle(.secondary)
            ForEach(Array(visibleSteps.enumerated()), id: \.element.id) { index, step in
                NavigationLink(destination: SmartTaskGuideView(step: step, internetProvider: internetProvider)) {
                    timelineRow(index + 1, step)
                }.buttonStyle(.plain)
            }
        }
    }

    private func timelineRow(_ index: Int, _ step: PremiumMoveStep) -> some View {
        let done = isDone(step)
        return HStack(alignment: .top, spacing: 12) {
            ZStack { Circle().fill(done ? DMTheme.green : tint(step.target).opacity(0.13)); Image(systemName: done ? "checkmark" : step.icon).font(.caption.bold()).foregroundStyle(done ? .white : tint(step.target)) }.frame(width: 38, height: 38)
            VStack(alignment: .leading, spacing: 3) {
                Text(dueLabel(step).uppercased()).font(.caption2.bold()).foregroundStyle(tint(step.target))
                Text(step.title).font(.headline).foregroundStyle(DMTheme.ink)
                Text(step.note).font(.caption).foregroundStyle(.secondary).lineLimit(2)
            }
            Spacer(); Image(systemName: "chevron.right").font(.caption.bold()).foregroundStyle(.secondary)
        }.padding(14).background(.white).clipShape(RoundedRectangle(cornerRadius: 18))
    }

    private func isDone(_ step: PremiumMoveStep) -> Bool { UserDefaults.standard.bool(forKey: step.storageKey) }
    private func isBlocker(_ step: PremiumMoveStep) -> Bool {
        switch step.target { case .ejari, .dewa, .building: return true; default: return false }
    }
    private func blockerReason(_ target: PremiumMoveTarget) -> String {
        switch target {
        case .ejari: return "Your tenancy record affects downstream setup and should be confirmed before relying on utility steps."
        case .dewa: return "Confirm electricity/water transition before occupancy."
        case .building: return "Mover access can fail without the building's permit, lift or loading instructions."
        default: return "Complete this before move day."
        }
    }
    private func recommendedDaysBefore(_ target: PremiumMoveTarget) -> Int {
        switch target {
        case .documents: return 30
        case .ejari: return 21
        case .building: return 14
        case .telecom: return 14
        case .cooling: return 10
        case .dewa: return 7
        case .services: return 10
        case .inspection: return 3
        case .handover: return 1
        case .money: return 0
        case .leaving: return 14
        case .setup: return 30
        }
    }
    private func dueLabel(_ step: PremiumMoveStep) -> String {
        let lead = recommendedDaysBefore(step.target)
        if daysToMove <= 0 { return "Do now" }
        if daysToMove <= lead { return "Do now · recommended by T-\(lead)" }
        return "Upcoming · around T-\(lead)"
    }
    private func tint(_ target: PremiumMoveTarget) -> Color {
        switch target {
        case .documents, .ejari: return .indigo
        case .dewa: return .blue
        case .telecom: return .purple
        case .cooling: return .cyan
        case .building: return .orange
        case .services: return DMTheme.green
        case .inspection, .handover: return .brown
        case .money: return .mint
        case .leaving: return .red
        case .setup: return .teal
        }
    }
}

// MARK: - Smart task wrapper

struct SmartTaskGuideView: View {
    let step: PremiumMoveStep
    let internetProvider: String
    @State private var proofNote = ""
    @State private var copied = false

    private var proofKey: String { "dubaimove.intelligence.proof.\(step.key)" }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                header
                whyAndDone
                prerequisites
                routeChoices
                templates
                proof
                NavigationLink(destination: officialDestination(step.target)) {
                    Label("Open full step-by-step guide", systemImage: "book.fill").font(.headline).frame(maxWidth: .infinity).padding(14).foregroundStyle(.white).background(DMTheme.green).clipShape(RoundedRectangle(cornerRadius: 16))
                }.buttonStyle(.plain)
            }.padding(16).padding(.bottom, 80)
        }
        .background(Color(uiColor: .systemGroupedBackground).ignoresSafeArea())
        .navigationTitle(step.title)
        .navigationBarTitleDisplayMode(.inline)
        .onAppear { proofNote = UserDefaults.standard.string(forKey: proofKey) ?? "" }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label("BEGINNER MODE", systemImage: "person.crop.circle.badge.questionmark").font(.caption.bold()).foregroundStyle(DMTheme.green)
            Text(step.title).font(.system(size: 30, weight: .heavy, design: .rounded))
            Text("You do not need to know the process beforehand. We explain what to prepare, what to do, where to go and what proof means you are finished.").font(.subheadline).foregroundStyle(.secondary)
        }.smartSurface()
    }

    private var whyAndDone: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("What is this for?").font(.headline)
            Text(step.why).font(.subheadline).foregroundStyle(.secondary)
            Divider()
            Label("How do I know I'm done?", systemImage: "checkmark.seal.fill").font(.headline).foregroundStyle(DMTheme.green)
            Text(doneDefinition(step.target)).font(.subheadline).foregroundStyle(.secondary)
        }.smartSurface()
    }

    private var prerequisites: some View {
        VStack(alignment: .leading, spacing: 9) {
            Label("Before you start", systemImage: "link").font(.headline).foregroundStyle(.orange)
            ForEach(prerequisiteText(step.target), id: \.self) { Text("• \($0)").font(.subheadline).foregroundStyle(.secondary) }
        }.smartSurface()
    }

    private var routeChoices: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Choose your route").font(.headline)
            NavigationLink(destination: officialDestination(step.target)) {
                HStack { Image(systemName: "hand.point.up.left.fill"); VStack(alignment: .leading) { Text("Do it myself").bold(); Text("Open the guided official route").font(.caption) }; Spacer(); Image(systemName: "chevron.right") }.padding(13).foregroundStyle(.blue).background(.blue.opacity(0.08)).clipShape(RoundedRectangle(cornerRadius: 15))
            }
            NavigationLink(destination: ServicesMarketplaceV6View()) {
                HStack { Image(systemName: "person.2.fill"); VStack(alignment: .leading) { Text("Get help").bold(); Text("Browse relevant service providers where appropriate").font(.caption) }; Spacer(); Image(systemName: "chevron.right") }.padding(13).foregroundStyle(.purple).background(.purple.opacity(0.08)).clipShape(RoundedRectangle(cornerRadius: 15))
            }
        }.buttonStyle(.plain).smartSurface()
    }

    private var templates: some View {
        let message = templateText(step.target)
        return VStack(alignment: .leading, spacing: 10) {
            Label("Ready-to-send message", systemImage: "text.bubble.fill").font(.headline).foregroundStyle(.purple)
            Text(message).font(.subheadline).foregroundStyle(.secondary).padding(12).background(.purple.opacity(0.06)).clipShape(RoundedRectangle(cornerRadius: 14))
            Button {
                UIPasteboard.general.string = message
                copied = true
            } label: { Label(copied ? "Copied" : "Copy message", systemImage: copied ? "checkmark" : "doc.on.doc").frame(maxWidth: .infinity) }
                .buttonStyle(.bordered).tint(.purple)
        }.smartSurface()
    }

    private var proof: some View {
        VStack(alignment: .leading, spacing: 10) {
            Label("Save your proof", systemImage: "folder.badge.plus").font(.headline).foregroundStyle(.blue)
            TextField("Reference number, appointment, permit or confirmation note", text: $proofNote, axis: .vertical).lineLimit(2...5).textFieldStyle(.roundedBorder)
            Button("Save note") { UserDefaults.standard.set(proofNote, forKey: proofKey) }.buttonStyle(.borderedProminent).tint(.blue)
            NavigationLink("Open Documents", destination: FunctionalV2DocumentsView()).font(.subheadline.bold()).foregroundStyle(.blue)
        }.smartSurface()
    }

    private func doneDefinition(_ target: PremiumMoveTarget) -> String {
        switch target {
        case .ejari: return "You have the issued Ejari / tenancy registration certificate or the official confirmation for your applicable route."
        case .dewa: return "You have the official request/reference and the supply/transfer/disconnection status matches your move plan."
        case .telecom: return "You have a confirmed installation/relocation/cancellation reference or appointment from your provider."
        case .cooling: return "You confirmed cooling is included, or you have the correct provider account/activation confirmation."
        case .building: return "Management confirmed whether a permit is needed and you have the approved lift/loading/access window."
        case .services: return "The provider, scope, date, access requirements and price are confirmed."
        case .inspection: return "You captured and saved a dated factual condition record before handover."
        case .handover: return "Keys/access items and the handover record are completed and saved."
        case .money: return "Expected refunds/deposits are recorded and later marked received."
        default: return "You have saved the confirmation or evidence that this operational step is complete."
        }
    }

    private func prerequisiteText(_ target: PremiumMoveTarget) -> [String] {
        switch target {
        case .dewa: return ["Confirm the correct premise and tenancy/Ejari information.", "Know whether you need Move-In, Move-To or Move-Out."]
        case .telecom: return ["Know your provider (\(internetProvider)).", "Have the new address/tenancy proof and access date ready."]
        case .cooling: return ["First confirm whether the home is chiller-free or separately billed.", "Do not register with Empower/Emicool until the building confirms the provider."]
        case .building: return ["Have unit/building details and move date ready.", "Ask for permit, service-lift, loading-bay and mover-document rules before confirming the mover slot."]
        case .ejari: return ["Have the signed tenancy details ready.", "Use the applicable DLD/property-management route and never guess missing property numbers."]
        default: return ["Read the task note and gather the real property/provider details before acting."]
        }
    }

    private func templateText(_ target: PremiumMoveTarget) -> String {
        switch target {
        case .building: return "Hi, I am moving to/from my unit on my planned move date. Could you please confirm the move permit/NOC process, service-lift booking, mover access hours, loading area, required mover documents and any deposit?"
        case .telecom: return "Hi, I am moving home and need to confirm the correct relocation/setup process for my new address. Please confirm required documents, available installation dates, fees and the reference I should keep."
        case .cooling: return "Hi, could you please confirm whether cooling for my unit is included/chiller-free or separately billed? If separate, please confirm the district-cooling provider and official registration route."
        case .services: return "Hi, please confirm the full scope, total price, arrival window, team size, equipment/materials included and any building-access requirements before I book."
        case .handover: return "Hi, please confirm the handover date/time, keys/access cards to return, any final documents required and the contact person for the handover."
        default: return "Hi, I am completing this move step and want to confirm the correct process, required documents, fees (if any), expected completion time and the confirmation/reference I should keep."
        }
    }
}

// MARK: - Move day and refunds

struct MoveDayModeView: View {
    private let items = [
        ("Mover / provider arrival confirmed", "truck.box.fill"),
        ("Building permit and service lift ready", "building.2.fill"),
        ("Old-home condition photos saved", "camera.fill"),
        ("Keys and access cards counted", "key.fill"),
        ("DEWA / cooling status checked", "bolt.fill"),
        ("New-home internet appointment checked", "wifi"),
        ("Critical contacts available", "phone.fill")
    ]
    @State private var refreshID = UUID()

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 15) {
                VStack(alignment: .leading, spacing: 7) {
                    Text("MOVE DAY MODE").font(.caption2.bold()).tracking(1.4).foregroundStyle(.orange)
                    Text("Only what matters today").font(.largeTitle.bold())
                    Text("Use this as an operational check, not as proof that an authority/provider action happened.").font(.subheadline).foregroundStyle(.secondary)
                }
                ForEach(Array(items.enumerated()), id: \.offset) { index, item in
                    let key = "dubaimove.moveday.\(index)"
                    let done = UserDefaults.standard.bool(forKey: key)
                    Button {
                        UserDefaults.standard.set(!done, forKey: key); refreshID = UUID()
                    } label: {
                        HStack(spacing: 12) {
                            Image(systemName: done ? "checkmark.circle.fill" : item.1).foregroundStyle(done ? DMTheme.green : .orange).frame(width: 28)
                            Text(item.0).font(.headline).foregroundStyle(DMTheme.ink)
                            Spacer()
                        }.padding(15).background(.white).clipShape(RoundedRectangle(cornerRadius: 18))
                    }.buttonStyle(.plain)
                }
            }.id(refreshID).padding(16).padding(.bottom, 70)
        }.background(Color(uiColor: .systemGroupedBackground).ignoresSafeArea()).navigationTitle("Move Day")
    }
}

struct RefundTrackerView: View {
    @AppStorage("dubaimove.refund.landlord.amount") private var landlordAmount = ""
    @AppStorage("dubaimove.refund.dewa.amount") private var dewaAmount = ""
    @AppStorage("dubaimove.refund.cooling.amount") private var coolingAmount = ""
    @AppStorage("dubaimove.refund.landlord.received") private var landlordReceived = false
    @AppStorage("dubaimove.refund.dewa.received") private var dewaReceived = false
    @AppStorage("dubaimove.refund.cooling.received") private var coolingReceived = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Refund tracker").font(.largeTitle.bold())
                Text("Record expected amounts and mark them received. This tracker does not determine whether you are legally entitled to a refund.").font(.subheadline).foregroundStyle(.secondary)
                refundCard("Landlord / tenancy deposit", amount: $landlordAmount, received: $landlordReceived, icon: "house.fill", tint: .orange)
                refundCard("DEWA security deposit", amount: $dewaAmount, received: $dewaReceived, icon: "bolt.fill", tint: .blue)
                refundCard("Cooling deposit", amount: $coolingAmount, received: $coolingReceived, icon: "snowflake", tint: .cyan)
            }.padding(16)
        }.background(Color(uiColor: .systemGroupedBackground).ignoresSafeArea()).navigationTitle("Refunds").navigationBarTitleDisplayMode(.inline)
    }

    private func refundCard(_ title: String, amount: Binding<String>, received: Binding<Bool>, icon: String, tint: Color) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack { Image(systemName: icon).foregroundStyle(tint); Text(title).font(.headline); Spacer(); Toggle("", isOn: received).labelsHidden().tint(DMTheme.green) }
            TextField("Expected amount (AED)", text: amount).keyboardType(.decimalPad).textFieldStyle(.roundedBorder)
            Text(received.wrappedValue ? "Received" : "Expected / pending").font(.caption.bold()).foregroundStyle(received.wrappedValue ? DMTheme.green : .secondary)
        }.smartSurface()
    }
}

@ViewBuilder
private func officialDestination(_ target: PremiumMoveTarget) -> some View {
    switch target {
    case .documents: FunctionalV2DocumentsView()
    case .ejari: EjariGuidedView()
    case .dewa: DewaGuidedView()
    case .telecom: TelecomGuidedView()
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
    func smartSurface() -> some View {
        self.padding(16).background(.white).clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous)).overlay(RoundedRectangle(cornerRadius: 22).stroke(Color.black.opacity(0.05), lineWidth: 1)).shadow(color: .black.opacity(0.025), radius: 8, y: 3)
    }
}
