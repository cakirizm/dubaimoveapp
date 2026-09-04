import SwiftUI

struct OnboardingView: View {
    @Binding var completed: Bool
    @State private var step = 0
    @State private var situation = "Moving within Dubai"

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Spacer()
                Image(systemName: stepIcon).font(.system(size: 64)).foregroundStyle(DMTheme.green)
                VStack(spacing: 10) {
                    Text(stepTitle).font(.largeTitle.bold()).multilineTextAlignment(.center)
                    Text(stepBody).foregroundStyle(.secondary).multilineTextAlignment(.center)
                }
                .padding(.horizontal)
                if step == 2 {
                    Picker("Situation", selection: $situation) {
                        Text("Moving within Dubai").tag("Moving within Dubai")
                        Text("Moving to Dubai").tag("Moving to Dubai")
                        Text("Leaving Dubai").tag("Leaving Dubai")
                        Text("I only need a home service").tag("I only need a home service")
                        Text("Manage an existing property").tag("Manage an existing property")
                    }.pickerStyle(.menu).padding().background(DMTheme.card).clipShape(RoundedRectangle(cornerRadius: 16))
                }
                Spacer()
                HStack { ForEach(0..<4, id: \.self) { i in Capsule().fill(i == step ? DMTheme.green : .gray.opacity(0.25)).frame(width: i == step ? 28 : 8, height: 8) } }
                Button(step == 3 ? "Start Dubai Move" : "Continue") {
                    if step < 3 { step += 1 } else { completed = true }
                }.buttonStyle(.borderedProminent).tint(DMTheme.green).controlSize(.large)
            }.padding()
        }
    }

    private var stepIcon: String { ["location.viewfinder", "checklist", "house.and.flag.fill", "lock.shield.fill"][step] }
    private var stepTitle: String { ["Move smarter in Dubai", "Know what to do next", "Tell us your situation", "Private by default"][step] }
    private var stepBody: String {
        [
            "One place for your move route, building requirements, utilities, providers, documents and money.",
            "Dubai Move builds a practical task order, shows blockers and sends you to official channels when an official action is required.",
            "Your plan changes depending on whether you are moving within Dubai, arriving, leaving, or only requesting a service.",
            "Home photos, documents and chats are not broadly shared. Provider access is scoped to the job and user-reviewed data."
        ][step]
    }
}

struct MoreView: View {
    var body: some View {
        List {
            Section("Government & utilities") {
                link("Ejari", "doc.text.fill", .ejari)
                link("DEWA", "bolt.fill", .dewa)
                link("Cooling", "snowflake", .cooling)
                link("Telecom", "wifi", .telecom)
                link("Rental Increase Check", "percent", .rentalIncrease)
            }
            Section("Building & move operations") {
                link("Building Intelligence", "building.2.fill", .building)
                link("Building Access Pack", "person.badge.key.fill", .buildingAccess)
                link("Move Map", "map.fill", .map)
                link("Move Day Live", "truck.box.fill", .moveDay)
                link("Smart Rescheduling", "calendar.badge.clock", .reschedule)
                link("Packing Labels", "tag.fill", .packingLabels)
            }
            Section("Inspection, handover & money") {
                link("Move-in Inspection", "camera.fill", .moveInInspection)
                link("Move-out Inspection", "camera.viewfinder", .moveOutInspection)
                link("Condition Report", "doc.text.image", .conditionReport)
                link("Landlord Handover Pack", "doc.richtext.fill", .handover)
                link("Deposit Tracker", "banknote.fill", .deposit)
                link("Dispute Evidence", "doc.text.magnifyingglass", .disputeEvidence)
            }
            Section("Relocation tools") {
                link("Leaving Dubai Center", "airplane.departure", .leavingDubai)
                link("New-home Starter Pack", "shippingbox.fill", .starterPack)
                link("Status Sharing", "link", .statusShare)
                link("Calendar Sync", "calendar", .calendar)
                link("Multi-property", "building.2.crop.circle", .multiProperty)
                link("Emergency Move", "exclamationmark.triangle.fill", .emergencyMove)
                link("Concierge", "person.crop.circle.badge.checkmark", .concierge)
                link("Corporate Relocation", "briefcase.fill", .corporateRelocation)
                link("Shared Move / Family", "person.2.fill", .family)
            }
            Section("Marketplace & protection") {
                link("Smart Provider Matching", "sparkles", .providerMatching)
                link("Quote Comparison", "arrow.left.arrow.right", .quoteComparison)
                link("Quote Protection", "shield.checkered", .quoteProtection)
                link("AI Video Inventory", "video.fill", .videoInventory)
            }
            Section("Account & safety") {
                link("AI Copilot", "sparkles", .aiCopilot)
                link("Notifications", "bell.fill", .notifications)
                link("Privacy & Security", "lock.shield.fill", .privacy)
                link("Offline & Sync", "arrow.triangle.2.circlepath", .offlineSync)
                link("Help & Support", "questionmark.circle.fill", .support)
            }
            Section { Text("Dubai Move provides practical assistance and official-source navigation. It does not give legal advice, decide legal responsibility, or impersonate government/regulatory services.").font(.footnote).foregroundStyle(.secondary) }
        }
        .navigationTitle("More & Move Tools")
        .navigationDestination(for: AppRoute.self) { FeatureRouter(route: $0) }
    }

    private func link(_ title: String, _ icon: String, _ route: AppRoute) -> some View {
        NavigationLink(value: route) { Label(title, systemImage: icon) }
    }
}
