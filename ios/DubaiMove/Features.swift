import SwiftUI
import MapKit

struct ServicesView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                Text("Services for your move").font(.largeTitle.bold())
                Text("Home services, move administration and verified assistance. Official fees stay separate from provider fees.")
                    .foregroundStyle(.secondary)
                serviceSection("HOME SERVICES", items: Array(ServiceCategory.all.prefix(6)))
                serviceSection("GOVERNMENT, UTILITY & MOVE ADMIN", items: Array(ServiceCategory.all.dropFirst(6)))
                NavigationLink(value: AppRoute.emergencyMove) {
                    Label("Emergency / Last-minute Move", systemImage: "exclamationmark.triangle.fill")
                        .frame(maxWidth: .infinity, alignment: .leading).dmCard(background: DMTheme.sand)
                }.buttonStyle(.plain)
            }.padding()
        }
        .background(Color(uiColor: .systemGroupedBackground))
        .navigationTitle("Services")
        .navigationBarTitleDisplayMode(.inline)
        .navigationDestination(for: AppRoute.self) { FeatureRouter(route: $0) }
    }

    private func serviceSection(_ title: String, items: [ServiceCategory]) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title).font(.caption.bold()).foregroundStyle(.secondary)
            ForEach(items) { service in
                NavigationLink(value: AppRoute.serviceRequest(service)) {
                    HStack(spacing: 14) {
                        Image(systemName: service.icon).font(.title3).foregroundStyle(DMTheme.green).frame(width: 34)
                        VStack(alignment: .leading, spacing: 3) {
                            HStack { Text(service.title).font(.headline); if service.regulated { Text("VERIFIED").font(.caption2.bold()).padding(.horizontal, 6).padding(.vertical, 3).background(DMTheme.mint).clipShape(Capsule()) } }
                            Text(service.subtitle).font(.caption).foregroundStyle(.secondary)
                        }
                        Spacer(); Image(systemName: "chevron.right").foregroundStyle(.secondary)
                    }.dmCard()
                }.buttonStyle(.plain)
            }
        }
    }
}

struct FeatureRouter: View {
    let route: AppRoute
    var body: some View {
        switch route {
        case .notifications: ToolListView(title: "Notifications", subtitle: "Deadlines, provider updates and move alerts", icon: "bell.fill", rows: ["Ejari is blocking DEWA", "Lift reservation is due tomorrow", "A provider revised your quote"])
        case .aiCopilot: AICopilotView()
        case .map: MoveMapView(live: false)
        case .contract: ContractView()
        case .rentalIncrease: RentalIncreaseView()
        case .ejari: EjariView()
        case .dewa: DewaView()
        case .cooling: OfficialGuidanceView(title: "Cooling", systemImage: "snowflake", intro: "Your building determines the applicable cooling provider.", needs: ["Confirm building", "Identify provider", "Choose Move-In / Move-Out"], officialLabel: "Open official cooling provider", assistance: true)
        case .telecom: OfficialGuidanceView(title: "Telecom Relocation", systemImage: "wifi", intro: "Transfer, cancel or set up connectivity for your move.", needs: ["Current address", "New address", "Move date"], officialLabel: "Continue with telecom provider", assistance: true)
        case .building: BuildingView()
        case .buildingAccess: BuildingAccessView()
        case .serviceRequest(let service): ServiceRequestView(service: service)
        case .videoInventory: VideoInventoryView()
        case .providerMatching: ProviderMatchingView()
        case .quoteComparison: QuoteComparisonView()
        case .providerProfile(let quote): ProviderProfileView(quote: quote)
        case .chat(let quote): ChatView(quote: quote)
        case .booking(let quote): BookingView(quote: quote)
        case .moveDay: MoveMapView(live: true)
        case .moveInInspection: InspectionView(mode: "Move-in")
        case .moveOutInspection: InspectionView(mode: "Move-out")
        case .conditionReport: ConditionReportView()
        case .handover: HandoverView()
        case .deposit: DepositView()
        case .starterPack: StarterPackView()
        case .leavingDubai: LeavingDubaiView()
        case .reschedule: RescheduleView()
        case .calendar: ToolListView(title: "Move Calendar", subtitle: "Only move dates and deadlines are synced", icon: "calendar", rows: ["18 Sep · Ejari target", "20 Sep · Move permit", "24 Sep · DEWA", "28 Sep · Move day", "29 Sep · Inspection"])
        case .statusShare: StatusShareView()
        case .multiProperty: MultiPropertyView()
        case .emergencyMove: ToolListView(title: "Emergency Move", subtitle: "Find genuinely available providers for today, tomorrow or within 48 hours", icon: "exclamationmark.triangle.fill", rows: ["Today", "Tomorrow", "Within 48 hours", "Keep my original service scope"])
        case .concierge: ToolListView(title: "Concierge", subtitle: "Operational coordination without pretending to perform regulated actions", icon: "person.crop.circle.badge.checkmark", rows: ["Move checklist coordination", "Provider appointments", "Building coordination", "Utility status tracking"])
        case .corporateRelocation: ToolListView(title: "Corporate Relocation", subtitle: "Employer-sponsored move workspace", icon: "briefcase.fill", rows: ["Employee & family", "Relocation allowance", "Company contact", "Scoped status sharing"])
        case .family: ToolListView(title: "Shared Move", subtitle: "Invite family members with scoped permissions", icon: "person.2.fill", rows: ["View move", "Complete tasks", "Upload documents", "Manage providers", "View money"])
        case .privacy: ToolListView(title: "Privacy & Security", subtitle: "Private by default, scoped only when needed", icon: "lock.shield.fill", rows: ["Document sharing scopes", "Status link expiry", "AI media review controls", "Export / delete account data"])
        case .offlineSync: ToolListView(title: "Offline & Sync", subtitle: "Safe drafts and retry-aware states", icon: "arrow.triangle.2.circlepath", rows: ["Pending uploads", "Draft service requests", "Last sync status"])
        case .quoteProtection: ToolListView(title: "Quote Protection", subtitle: "Revision history and hidden-cost visibility", icon: "shield.checkered", rows: ["Quote version history", "Expiry date", "Scope differences", "Hidden-cost risk"])
        case .packingLabels: ToolListView(title: "Packing Labels", subtitle: "Create room and box labels", icon: "tag.fill", rows: ["Living room", "Kitchen", "Bedroom", "Fragile", "Priority unpack"])
        case .disputeEvidence: ToolListView(title: "Dispute Evidence", subtitle: "Organize user-selected evidence; Dubai Move does not decide legal responsibility", icon: "doc.text.magnifyingglass", rows: ["Inspection photos", "Condition report", "Receipts", "Selected messages", "Generate evidence pack"])
        case .support: ToolListView(title: "Help & Support", subtitle: "Product and operational support", icon: "questionmark.circle.fill", rows: ["FAQs", "Contact support", "Report a problem"])
        }
    }
}

struct MoveMapView: View {
    @EnvironmentObject var state: AppState
    let live: Bool
    @State private var position: MapCameraPosition = .automatic

    var body: some View {
        VStack(spacing: 0) {
            Map(position: $position) {
                Marker("Current home", coordinate: state.currentProperty.coordinate).tint(DMTheme.green)
                Marker("New home", coordinate: state.newProperty.coordinate).tint(.orange)
            }
            .mapControls { MapCompass(); MapScale() }
            .frame(minHeight: 380)
            ScrollView {
                VStack(alignment: .leading, spacing: 14) {
                    Text(live ? "Move Day Live" : "Your route").font(.title.bold())
                    routeLine("A", "Dubai Marina", state.currentProperty.name)
                    routeLine("B", "Dubai Hills", state.newProperty.name)
                    if live {
                        Label("Provider ETA · connect live provider location in production", systemImage: "location.fill").foregroundStyle(DMTheme.green)
                        Divider()
                        Text("Live checklist").font(.headline)
                        checklist("Move permit", true); checklist("Parking / loading access", true); checklist("Lift slot", true); checklist("Provider contact", true)
                        NavigationLink("Chat with provider", value: AppRoute.chat(ProviderQuote.samples[0])).buttonStyle(.borderedProminent).tint(DMTheme.green)
                    } else {
                        Text("MapKit displays the actual map. Route distance and ETA should use production routing once credentials/network services are enabled.").font(.footnote).foregroundStyle(.secondary)
                    }
                }.padding()
            }
        }
        .navigationTitle(live ? "Move Day" : "Move Map")
        .navigationBarTitleDisplayMode(.inline)
        .navigationDestination(for: AppRoute.self) { FeatureRouter(route: $0) }
    }
    private func routeLine(_ badge: String, _ area: String, _ building: String) -> some View { HStack { Text(badge).font(.caption.bold()).foregroundStyle(.white).frame(width: 26, height: 26).background(DMTheme.green).clipShape(Circle()); VStack(alignment: .leading) { Text(area).font(.headline); Text(building).font(.caption).foregroundStyle(.secondary) } } }
    private func checklist(_ text: String, _ done: Bool) -> some View { Label(text, systemImage: done ? "checkmark.circle.fill" : "circle").foregroundStyle(done ? DMTheme.green : .primary) }
}

struct ContractView: View {
    @State private var confirmed = false
    var body: some View {
        Form {
            Section("Tenancy Contract") { Label("Upload PDF / JPG / PNG", systemImage: "square.and.arrow.up"); Label("Take photo", systemImage: "camera.fill") }
            Section("Extracted details — review required") { detail("Property", "Marina Gate Tower 2"); detail("Tenancy", "1 Oct 2025 – 30 Sep 2026"); detail("Annual rent", "AED 90,000"); detail("Deposit", "AED 5,000") }
            Section { Toggle("I reviewed these extracted details", isOn: $confirmed); Button("Confirm contract") { confirmed = true }.disabled(!confirmed) }
            Section { Text("AI/OCR suggestions are never treated as final until the user reviews them.").font(.footnote).foregroundStyle(.secondary) }
        }.navigationTitle("Rental Contract")
    }
    private func detail(_ a: String, _ b: String) -> some View { HStack { Text(a); Spacer(); Text(b).foregroundStyle(.secondary) } }
}

struct RentalIncreaseView: View {
    @State private var current = "90000"
    @State private var proposed = "103500"
    var increase: Double { guard let c = Double(current), let p = Double(proposed), c > 0 else { return 0 }; return ((p-c)/c)*100 }
    var body: some View {
        Form {
            Section("Landlord proposal") { TextField("Current rent", text: $current).keyboardType(.numberPad); TextField("Proposed rent", text: $proposed).keyboardType(.numberPad); HStack { Text("Calculated change"); Spacer(); Text(String(format: "%.1f%%", increase)).font(.headline).foregroundStyle(DMTheme.green) } }
            Section("Official reference") { Text("Dubai Move organizes the information and sends you to the applicable official Rental Index/service. It does not give a legal ruling.").font(.footnote); Button("Open Official Rental Index") { }; Label("Enter / attach official result", systemImage: "link") }
            Section("Report") { Button("Generate Rental Increase Check PDF") { }; Label("Share report", systemImage: "square.and.arrow.up") }
        }.navigationTitle("Rental Increase Check")
    }
}

struct EjariView: View {
    var body: some View {
        List {
            Section { VStack(alignment: .leading, spacing: 7) { Text("Ejari").font(.largeTitle.bold()); Text("Guidance + official handoff + verified assistance").foregroundStyle(.secondary) } }
            Section("Choose a journey") { NavigationLink("Register / Renew", value: AppRoute.serviceRequest(ServiceCategory.all[6])); Label("Cancel", systemImage: "xmark.circle"); Label("View status", systemImage: "checkmark.circle") }
            Section("Cancellation readiness") { Label("Tenancy / Ejari details", systemImage: "checkmark.circle.fill"); Label("Identity information if officially required", systemImage: "person.text.rectangle"); Label("Landlord / representative requirement may apply", systemImage: "exclamationmark.circle") }
            Section("Where to do it") { Button("Open applicable official DLD / Dubai REST / Ejari channel") { }; NavigationLink("Get verified assistance", value: AppRoute.serviceRequest(ServiceCategory.all[6])) }
            Section { Text("Dubai Move guides and tracks status. It does not claim to cancel or register Ejari itself unless an explicitly authorized integration is implemented.").font(.footnote).foregroundStyle(.secondary) }
        }.navigationTitle("Ejari").navigationDestination(for: AppRoute.self) { FeatureRouter(route: $0) }
    }
}

struct DewaView: View {
    var body: some View {
        List {
            Section("DEWA Services") { dewaRow("Move-In", "Activate electricity and water at a new premise"); dewaRow("Move-To", "Transfer from old to new premise"); dewaRow("Move-Out", "Close the current premise lifecycle") }
            Section("Move-To readiness") { Label("Existing account reference", systemImage: "checkmark.circle.fill"); Label("Move-out date", systemImage: "checkmark.circle.fill"); Label("New premise number", systemImage: "checkmark.circle.fill"); Label("Valid Ejari", systemImage: "exclamationmark.circle.fill"); Label("Move-in date", systemImage: "checkmark.circle.fill") }
            Section { Button("Continue to official DEWA service") { }; NavigationLink("Get verified assistance", value: AppRoute.serviceRequest(ServiceCategory.all[7])) }
            Section("Track after handoff") { Text("Submitted → Payment pending → Scheduled → Activated / Problem").font(.footnote) }
        }.navigationTitle("DEWA").navigationDestination(for: AppRoute.self) { FeatureRouter(route: $0) }
    }
    private func dewaRow(_ title: String, _ text: String) -> some View { VStack(alignment: .leading) { Text(title).font(.headline); Text(text).font(.caption).foregroundStyle(.secondary) } }
}

struct BuildingView: View {
    var body: some View {
        List {
            Section { VStack(alignment: .leading) { Text("Marina Gate Tower 2").font(.title.bold()); Text("Dubai Marina · source confidence: verified").foregroundStyle(.secondary) } }
            Section("Moving rules") { rule("Move permit", "Required"); rule("Lift reservation", "Required"); rule("Moving hours", "08:00–18:00"); rule("Mover insurance", "Required"); rule("Loading bay", "Available"); rule("Parking registration", "Required") }
            Section("Actions") { NavigationLink("Generate Building Access Pack", value: AppRoute.buildingAccess); Button("Contact building management") { }; NavigationLink("Report correction", value: AppRoute.support) }
        }.navigationTitle("Building Intelligence").navigationDestination(for: AppRoute.self) { FeatureRouter(route: $0) }
    }
    private func rule(_ a: String, _ b: String) -> some View { HStack { Text(a); Spacer(); Text(b).foregroundStyle(.secondary) } }
}

struct BuildingAccessView: View {
    @State private var generated = false
    var body: some View {
        List {
            Section("Access readiness") { access("Move permit", true); access("Mover insurance", true); access("Vehicle plate", false); access("Crew details — only if required", false); access("Lift reservation", true); access("Parking / loading bay", true); access("Management approval", false) }
            Section { Button(generated ? "Access Pack Generated" : "Generate Access Pack") { generated = true }.disabled(generated) }
        }.navigationTitle("Building Access Pack")
    }
    private func access(_ text: String, _ done: Bool) -> some View { Label(text, systemImage: done ? "checkmark.circle.fill" : "circle").foregroundStyle(done ? DMTheme.green : .primary) }
}

struct ServiceRequestView: View {
    @EnvironmentObject var state: AppState
    let service: ServiceCategory
    @State private var notes = ""
    @State private var date = Date().addingTimeInterval(60*60*24*7)
    var body: some View {
        Form {
            Section { Label(service.title, systemImage: service.icon).font(.title2.bold()); Text(service.subtitle).foregroundStyle(.secondary) }
            if service.title == "Moving" { Section("Route") { NavigationLink("Dubai Marina → Dubai Hills", value: AppRoute.map); NavigationLink("Create inventory from video", value: AppRoute.videoInventory) } }
            Section("Request details") { DatePicker("Preferred date", selection: $date); TextField("Requirements / notes", text: $notes, axis: .vertical).lineLimit(3...6); Label("Attach photos or files", systemImage: "paperclip") }
            if service.regulated { Section("Regulated-service protection") { Text("Only providers verified for this specific service capability can be matched. Official/government fees must remain separate from provider fees.").font(.footnote).foregroundStyle(.secondary) } }
            Section { NavigationLink("Request Quotes", value: AppRoute.providerMatching).buttonStyle(.borderedProminent).tint(DMTheme.green) }
        }.navigationTitle(service.title).navigationDestination(for: AppRoute.self) { FeatureRouter(route: $0) }
    }
}

struct VideoInventoryView: View {
    @State private var reviewed = false
    let inventory = ["3-seater sofa", "65-inch TV", "Dining table + 6 chairs", "King bed", "Wardrobe", "20–25 estimated boxes"]
    var body: some View {
        List {
            Section { Button("Record / upload walkthrough video") { }; Text("Original home video remains private. Derived inventory is not shared with providers until you review it.").font(.footnote).foregroundStyle(.secondary) }
            Section("AI suggestions") { ForEach(inventory, id: \.self) { Label($0, systemImage: "square.and.pencil") } }
            Section { Toggle("I reviewed this inventory", isOn: $reviewed); NavigationLink("Confirm & use for quotes", value: AppRoute.providerMatching).disabled(!reviewed) }
        }.navigationTitle("AI Video Inventory").navigationDestination(for: AppRoute.self) { FeatureRouter(route: $0) }
    }
}

struct ProviderMatchingView: View {
    @EnvironmentObject var state: AppState
    var body: some View {
        List {
            Section { Text("Smart Provider Matching").font(.largeTitle.bold()); Text("Coverage, availability, capacity and operational fit are considered.").foregroundStyle(.secondary) }
            Section("3 matching providers") {
                ForEach(state.quotes) { quote in
                    NavigationLink(value: AppRoute.providerProfile(quote)) { QuoteRow(quote: quote) }
                }
            }
            Section { NavigationLink("Compare all quotes", value: AppRoute.quoteComparison); NavigationLink("No quotes? Recovery options", value: AppRoute.quoteProtection) }
        }.navigationDestination(for: AppRoute.self) { FeatureRouter(route: $0) }
    }
}

struct QuoteRow: View {
    let quote: ProviderQuote
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack { Text(quote.provider).font(.headline); Spacer(); Text("AED \(quote.price)").font(.headline) }
            HStack { Label(String(format: "%.1f", quote.rating), systemImage: "star.fill"); Text("DM Score \(quote.score)"); Spacer(); Text(quote.badge).foregroundStyle(DMTheme.green) }.font(.caption)
            Text("\(quote.availability) · Hidden-cost risk: \(quote.hiddenCostRisk)").font(.caption).foregroundStyle(.secondary)
        }.padding(.vertical, 4)
    }
}

struct QuoteComparisonView: View {
    @EnvironmentObject var state: AppState
    var body: some View {
        ScrollView(.horizontal) {
            HStack(alignment: .top, spacing: 12) {
                ForEach(state.quotes) { quote in
                    VStack(alignment: .leading, spacing: 10) {
                        Text(quote.badge.uppercased()).font(.caption.bold()).foregroundStyle(DMTheme.green)
                        Text(quote.provider).font(.headline)
                        Text("AED \(quote.price)").font(.title.bold())
                        Label(String(format: "%.1f", quote.rating), systemImage: "star.fill")
                        Text("Dubai Move Score \(quote.score)")
                        Text("Hidden-cost risk: \(quote.hiddenCostRisk)")
                        Text("Packing: \(quote.provider == "SwiftMove" ? "+ AED 250" : "Included")")
                        Text("Insurance: Verified")
                        NavigationLink("View provider", value: AppRoute.providerProfile(quote)).buttonStyle(.bordered)
                        NavigationLink("Message", value: AppRoute.chat(quote)).buttonStyle(.bordered)
                        NavigationLink("Accept", value: AppRoute.booking(quote)).buttonStyle(.borderedProminent).tint(DMTheme.green)
                    }.frame(width: 250, alignment: .leading).dmCard()
                }
            }.padding()
        }.navigationTitle("Compare Quotes").navigationDestination(for: AppRoute.self) { FeatureRouter(route: $0) }
    }
}

struct ProviderProfileView: View {
    let quote: ProviderQuote
    var body: some View {
        List {
            Section { VStack(alignment: .leading, spacing: 7) { Text(quote.provider).font(.largeTitle.bold()); Label("Verified provider", systemImage: "checkmark.seal.fill").foregroundStyle(DMTheme.green); Text("Dubai Move Score \(quote.score) · \(String(format: "%.1f", quote.rating)) ★") } }
            Section("Trust") { Label("Trade licence verified", systemImage: "checkmark.circle.fill"); Label("Insurance verified", systemImage: "checkmark.circle.fill"); Label("Service capability verified where applicable", systemImage: "checkmark.circle.fill") }
            Section("Score breakdown") { metric("Punctuality", "94"); metric("Price accuracy", "91"); metric("Response time", "96"); metric("Cancellation", "Low"); metric("Complaints", "Low") }
            Section { NavigationLink("Message Provider", value: AppRoute.chat(quote)); NavigationLink("Book AED \(quote.price)", value: AppRoute.booking(quote)) }
        }.navigationDestination(for: AppRoute.self) { FeatureRouter(route: $0) }
    }
    private func metric(_ a: String, _ b: String) -> some View { HStack { Text(a); Spacer(); Text(b).foregroundStyle(.secondary) } }
}

struct ChatView: View {
    let quote: ProviderQuote
    @State private var message = ""
    var body: some View {
        VStack {
            ScrollView { VStack(alignment: .leading, spacing: 12) { bubble("Hi, we reviewed your move request. Packing is included.", mine: false); bubble("Can you also handle TV disassembly?", mine: true); VStack(alignment: .leading) { Text("QUOTE UPDATED").font(.caption.bold()).foregroundStyle(DMTheme.green); Text("AED \(quote.price) · Latest version").font(.headline); NavigationLink("View quote", value: AppRoute.quoteComparison) }.dmCard(background: DMTheme.mint) }.padding() }
            HStack { TextField("Message", text: $message).textFieldStyle(.roundedBorder); Button { message = "" } label: { Image(systemName: "arrow.up.circle.fill").font(.title2) } }.padding()
        }.navigationTitle(quote.provider).navigationDestination(for: AppRoute.self) { FeatureRouter(route: $0) }
    }
    private func bubble(_ text: String, mine: Bool) -> some View { Text(text).padding(12).background(mine ? DMTheme.mint : DMTheme.card).clipShape(RoundedRectangle(cornerRadius: 16)).frame(maxWidth: .infinity, alignment: mine ? .trailing : .leading) }
}

struct BookingView: View {
    let quote: ProviderQuote
    @State private var confirmed = false
    var body: some View {
        List {
            Section("Booking") { detail("Provider", quote.provider); detail("Price", "AED \(quote.price)"); detail("Route", "Dubai Marina → Dubai Hills"); detail("Date", "28 September"); detail("Service", "Moving + packing") }
            Section("Status") { Text(confirmed ? "CONFIRMED → ON THE WAY → ARRIVED → IN PROGRESS → PROVIDER COMPLETED → CUSTOMER CONFIRMED" : "Not confirmed") }
            Section { Button(confirmed ? "Booking confirmed" : "Confirm Booking") { confirmed = true }.disabled(confirmed); if confirmed { NavigationLink("Open Move Day Live", value: AppRoute.moveDay) } }
        }.navigationTitle("Booking").navigationDestination(for: AppRoute.self) { FeatureRouter(route: $0) }
    }
    private func detail(_ a: String, _ b: String) -> some View { HStack { Text(a); Spacer(); Text(b).foregroundStyle(.secondary) } }
}

struct InspectionView: View {
    let mode: String
    let rooms = ["Living room", "Kitchen", "Bedroom 1", "Bedroom 2", "Bathroom 1", "Bathroom 2", "Balcony"]
    var body: some View {
        List {
            Section { Text("\(mode) condition capture").font(.title.bold()); Text("Timestamped room-by-room evidence. Home media stays private unless explicitly shared.").foregroundStyle(.secondary) }
            Section("Rooms") { ForEach(rooms, id: \.self) { room in NavigationLink { RoomCaptureView(room: room, mode: mode) } label: { Label(room, systemImage: "camera.fill") } } }
            if mode == "Move-out" { Section { NavigationLink("Compare move-in vs move-out", value: AppRoute.conditionReport) } }
        }.navigationTitle("\(mode) Inspection").navigationDestination(for: AppRoute.self) { FeatureRouter(route: $0) }
    }
}

struct RoomCaptureView: View {
    let room: String; let mode: String
    @State private var note = ""
    var body: some View { Form { Section { Label("Take photos", systemImage: "camera.fill"); Label("Record video", systemImage: "video.fill"); TextField("Add note", text: $note, axis: .vertical) }; Section { Text("AI can suggest observations, but no damage finding is conclusive until you confirm it.").font(.footnote).foregroundStyle(.secondary) } }.navigationTitle(room) }
}

struct ConditionReportView: View {
    @State private var aiConfirmed = false
    var body: some View {
        List {
            Section { Text("Before / After Comparison").font(.title.bold()) }
            Section("Living room") { Label("Move-in reference photos", systemImage: "photo.on.rectangle"); Label("Move-out photos", systemImage: "photo.on.rectangle"); Text("AI suggestion: potential new wall marking detected.").foregroundStyle(.orange); Toggle("I confirm this observation", isOn: $aiConfirmed) }
            Section("Room summary") { status("Living room", aiConfirmed ? "Review" : "Good"); status("Kitchen", "Good"); status("Bedroom 1", "Good"); status("Bedroom 2", "Good"); status("Bathrooms", "Good") }
            Section { Button("Generate Condition Report PDF") { }; NavigationLink("Add to Landlord Handover Pack", value: AppRoute.handover) }
        }.navigationTitle("Condition Report").navigationDestination(for: AppRoute.self) { FeatureRouter(route: $0) }
    }
    private func status(_ a: String, _ b: String) -> some View { HStack { Text(a); Spacer(); Text(b).foregroundStyle(b == "Good" ? DMTheme.green : .orange) } }
}

struct HandoverView: View {
    @State private var generated = false
    var body: some View {
        List {
            Section { VStack(alignment: .leading) { Text("Handover Readiness").font(.title.bold()); Text("91% ready").foregroundStyle(DMTheme.green) } }
            Section("Handover checklist") { handover("Final cleaning", true); handover("Move-out inspection", true); handover("DEWA final bill / clearance", true); handover("Cooling status", true); handover("Telecom", true); handover("Ejari evidence", true); handover("Keys & access", true); handover("Deposit", false) }
            Section("Keys") { key("Apartment keys", "3"); key("Access cards", "2"); key("Parking remote", "1"); key("Mailbox key", "1") }
            Section("Privacy") { Text("Private chats, unrelated identity documents, payment-card data and non-handover media are excluded by default.").font(.footnote) }
            Section { Button(generated ? "PDF Ready" : "Generate Landlord Handover PDF") { generated = true }; if generated { Label("Preview & share selected handover data", systemImage: "square.and.arrow.up") } }
        }.navigationTitle("Landlord Handover")
    }
    private func handover(_ a: String, _ done: Bool) -> some View { Label(a, systemImage: done ? "checkmark.circle.fill" : "clock.fill").foregroundStyle(done ? DMTheme.green : .orange) }
    private func key(_ a: String, _ b: String) -> some View { HStack { Text(a); Spacer(); Text(b) } }
}

struct DepositView: View {
    var body: some View {
        List {
            Section { VStack(alignment: .leading) { Text("Security Deposit").font(.headline); Text("AED 5,000").font(.largeTitle.bold()); Text("REFUND PENDING").foregroundStyle(.orange).font(.caption.bold()) } }
            Section("Timeline") { Label("Requested", systemImage: "checkmark.circle.fill"); Label("Acknowledged", systemImage: "checkmark.circle.fill"); Label("Pending", systemImage: "clock.fill"); Label("Returned / issue", systemImage: "circle") }
            Section("Evidence") { Text("Contract"); Text("Inspection"); Text("Handover"); Text("Receipts"); Text("User-selected messages") }
            Section { Button("Generate Deposit Evidence Pack") { }; NavigationLink("Get assistance", value: AppRoute.serviceRequest(ServiceCategory.all[11])) }
            Section { Text("Dubai Move organizes evidence and status. It does not determine who is legally responsible for a deduction or refund.").font(.footnote).foregroundStyle(.secondary) }
        }.navigationTitle("Deposit Center").navigationDestination(for: AppRoute.self) { FeatureRouter(route: $0) }
    }
}

struct StarterPackView: View {
    @State private var selected = Set<String>()
    let items = ["Internet", "Cleaning", "Curtains", "AC", "Handyman", "TV mounting", "Furniture assembly", "Pest control"]
    var body: some View { List { Section { Text("New-home Starter Pack").font(.largeTitle.bold()); Text("Each selected item progresses independently.").foregroundStyle(.secondary) }; Section("Choose setup tasks") { ForEach(items, id: \.self) { item in Button { if selected.contains(item) { selected.remove(item) } else { selected.insert(item) } } label: { HStack { Text(item).foregroundStyle(.primary); Spacer(); Image(systemName: selected.contains(item) ? "checkmark.circle.fill" : "circle").foregroundStyle(DMTheme.green) } } } }; Section { NavigationLink("Find providers for selected services", value: AppRoute.providerMatching).disabled(selected.isEmpty) } }.navigationDestination(for: AppRoute.self) { FeatureRouter(route: $0) } }
}

struct LeavingDubaiView: View {
    var body: some View {
        List {
            Section { Text("Leaving Dubai").font(.largeTitle.bold()); Text("Home exit and UAE departure are treated as separate operational journeys.").foregroundStyle(.secondary) }
            Section("Home exit") { task("Ejari cancellation / expiry", .ejari); task("DEWA Move-Out", .dewa); task("Cooling Move-Out", .cooling); task("Telecom transfer / cancel", .telecom); task("Move-out inspection", .moveOutInspection); task("Cleaning", .serviceRequest(ServiceCategory.all[1])); task("Keys & handover", .handover); task("Deposit", .deposit) }
            Section("UAE departure guidance") { Text("Where applicable, Dubai Move may point to official residence/work-permit information but does not provide immigration or legal advice.").font(.footnote); Button("Open official guidance") { } }
        }.navigationTitle("Leaving Dubai Center").navigationDestination(for: AppRoute.self) { FeatureRouter(route: $0) }
    }
    private func task(_ title: String, _ route: AppRoute) -> some View { NavigationLink(title, value: route) }
}

struct RescheduleView: View {
    @State private var newDate = Date().addingTimeInterval(60*60*24*28)
    var body: some View { Form { Section("New move date") { DatePicker("Move date", selection: $newDate, displayedComponents: .date) }; Section("6 affected items") { Text("Mover booking"); Text("Lift slot"); Text("Move permit"); Text("DEWA date"); Text("Cleaning"); Text("Internet") }; Section { Text("External bookings are never silently changed. Review each impact before confirming.").font(.footnote).foregroundStyle(.secondary); Button("Review affected items") { } } }.navigationTitle("Smart Rescheduling") }
}

struct StatusShareView: View {
    @State private var days = 7.0
    var body: some View { Form { Section("Share") { Label("Timeline", systemImage: "checkmark.circle.fill"); Label("Completed tasks", systemImage: "checkmark.circle.fill"); Label("Upcoming deadlines", systemImage: "checkmark.circle.fill") }; Section("Not shared by default") { Label("Documents", systemImage: "xmark.circle"); Label("Photos", systemImage: "xmark.circle"); Label("Chats", systemImage: "xmark.circle"); Label("Phone number", systemImage: "xmark.circle") }; Section("Expiry") { Slider(value: $days, in: 1...30, step: 1); Text("Expires in \(Int(days)) days"); Button("Create revocable status link") { } } }.navigationTitle("Status Sharing") }
}

struct MultiPropertyView: View {
    var body: some View { List { Section("My Properties") { property("Marina Gate Tower 2", "Tenant"); property("Collective 2.0", "Tenant"); property("JVC Apartment", "Owner") } }.navigationTitle("Properties") }
    private func property(_ a: String, _ b: String) -> some View { HStack { Image(systemName: "building.2.fill").foregroundStyle(DMTheme.green); VStack(alignment: .leading) { Text(a).font(.headline); Text(b).font(.caption).foregroundStyle(.secondary) } } }
}

struct AICopilotView: View {
    @State private var prompt = ""
    var body: some View { VStack { ScrollView { VStack(alignment: .leading, spacing: 12) { Text("Dubai Move Copilot").font(.largeTitle.bold()); Text("Ask about your move, blockers, documents, building requirements, quotes, money or official-service navigation.").foregroundStyle(.secondary); ForEach(["What should I do next?", "Why is DEWA blocked?", "My landlord proposed a rent increase — what should I check?", "What do I need for move-out handover?"], id: \.self) { q in Button(q) { prompt = q }.buttonStyle(.bordered).tint(DMTheme.green) }; Text("Boundary: practical assistance and official-source navigation, not legal advice or legal decisions.").font(.footnote).foregroundStyle(.secondary).padding(.top) }.padding() }; HStack { TextField("Ask Dubai Move", text: $prompt).textFieldStyle(.roundedBorder); Button { prompt = "" } label: { Image(systemName: "arrow.up.circle.fill").font(.title2) } }.padding() }.navigationTitle("AI Copilot").navigationBarTitleDisplayMode(.inline) }
}

struct OfficialGuidanceView: View {
    let title: String; let systemImage: String; let intro: String; let needs: [String]; let officialLabel: String; let assistance: Bool
    var body: some View { List { Section { Label(title, systemImage: systemImage).font(.largeTitle.bold()); Text(intro).foregroundStyle(.secondary) }; Section("What you need") { ForEach(needs, id: \.self) { Label($0, systemImage: "checkmark.circle") } }; Section("Official route") { Button(officialLabel) { } }; if assistance { Section("Need help?") { NavigationLink("Find verified assistance", value: AppRoute.providerMatching) } }; Section { Text("Official availability, requirements and fees should be refreshed from approved sources before production release.").font(.footnote).foregroundStyle(.secondary) } }.navigationDestination(for: AppRoute.self) { FeatureRouter(route: $0) } }
}

struct ToolListView: View {
    let title: String; let subtitle: String; let icon: String; let rows: [String]
    var body: some View { List { Section { Label(title, systemImage: icon).font(.title.bold()); Text(subtitle).foregroundStyle(.secondary) }; Section { ForEach(rows, id: \.self) { Label($0, systemImage: "chevron.right.circle") } } }.navigationTitle(title).navigationBarTitleDisplayMode(.inline) }
}
