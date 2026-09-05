import SwiftUI

struct CompleteMoveCommandCenterView: View {
    @AppStorage("dubaimove.v2.moveDate") private var moveDateEpoch = Date().addingTimeInterval(86400 * 21).timeIntervalSince1970
    @AppStorage("dubaimove.property.building") private var building = ""
    @AppStorage("dubaimove.property.unit") private var unit = ""
    @AppStorage("dubaimove.property.permit") private var permitStatus = "Unknown"
    @AppStorage("dubaimove.property.lift") private var liftStatus = "Not booked"

    private var daysToMove: Int {
        Calendar.current.dateComponents(
            [.day],
            from: Calendar.current.startOfDay(for: Date()),
            to: Calendar.current.startOfDay(for: Date(timeIntervalSince1970: moveDateEpoch))
        ).day ?? 0
    }

    private var propertyReady: Bool {
        !building.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        permitStatus != "Unknown" &&
        liftStatus != "Not checked"
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                hero
                readinessStrip
                planCard
                operationsGrid
                evidenceCard
                supportCard
            }
            .padding(16)
            .padding(.bottom, 110)
        }
        .background(Color(uiColor: .systemGroupedBackground).ignoresSafeArea())
        .navigationTitle("My Move")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var hero: some View {
        ZStack(alignment: .bottomLeading) {
            LinearGradient(colors: [DMTheme.greenDeep, DMTheme.green, .teal], startPoint: .topLeading, endPoint: .bottomTrailing)
            Image(systemName: "house.and.flag.fill")
                .font(.system(size: 125))
                .foregroundStyle(.white.opacity(0.10))
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
                .offset(x: 16, y: -8)
            VStack(alignment: .leading, spacing: 8) {
                Text("MY MOVE CONTROL CENTER")
                    .font(.caption2.bold())
                    .tracking(1.4)
                    .foregroundStyle(.white.opacity(0.78))
                Text(daysToMove >= 0 ? "\(daysToMove) days to move day" : "Move day has passed")
                    .font(.system(size: 31, weight: .heavy, design: .rounded))
                    .foregroundStyle(.white)
                Text("Plan it, verify the building, save contacts, track appointments, keep proof and handle problems from one place.")
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.88))
            }
            .padding(20)
        }
        .frame(maxWidth: .infinity, minHeight: 215)
        .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
    }

    private var readinessStrip: some View {
        HStack(spacing: 12) {
            Image(systemName: propertyReady ? "checkmark.shield.fill" : "exclamationmark.triangle.fill")
                .font(.title2)
                .foregroundStyle(propertyReady ? DMTheme.green : .orange)
            VStack(alignment: .leading, spacing: 2) {
                Text(propertyReady ? "Property operations captured" : "Property details still need attention")
                    .font(.headline)
                Text(building.isEmpty ? "Add your building and access rules before move day." : "\(building)\(unit.isEmpty ? "" : " · Unit \(unit)")")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
        }
        .moveOpsSurface()
    }

    private var planCard: some View {
        NavigationLink(destination: SmartMoveCommandCenterView()) {
            HStack(spacing: 14) {
                Image(systemName: "list.number")
                    .font(.title2.bold())
                    .foregroundStyle(.white)
                    .frame(width: 52, height: 52)
                    .background(DMTheme.green)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                VStack(alignment: .leading, spacing: 4) {
                    Text("Smart Move Plan")
                        .font(.title3.bold())
                        .foregroundStyle(DMTheme.ink)
                    Text("Personalized tasks, blockers, T-minus recommendations and official step-by-step routes.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.leading)
                }
                Spacer()
                Image(systemName: "chevron.right").foregroundStyle(.secondary)
            }
            .padding(16)
            .background(.white)
            .clipShape(RoundedRectangle(cornerRadius: 22))
        }
        .buttonStyle(.plain)
    }

    private var operationsGrid: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Move operations").font(.title2.bold())
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                NavigationLink(destination: PropertyMoveProfileView()) { tile("Property", "Building rules & access", "building.2.fill", .orange) }
                NavigationLink(destination: MoveContactsHubView()) { tile("Contacts", "Everyone in one place", "person.crop.circle.badge.checkmark", .blue) }
                NavigationLink(destination: MoveAppointmentsHubView()) { tile("Appointments", "Mover, internet, handover", "calendar.badge.clock", .purple) }
                NavigationLink(destination: EnhancedMoveDayModeView()) { tile("Move Day", "Live critical checklist", "figure.walk.motion", .orange) }
                NavigationLink(destination: MoveRescueCenterView()) { tile("Something wrong?", "Recovery paths", "lifepreserver.fill", .red) }
                NavigationLink(destination: RefundTrackerView()) { tile("Refunds", "Deposits & money back", "banknote.fill", .mint) }
            }
            .buttonStyle(.plain)
        }
    }

    private var evidenceCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Label("Evidence & records", systemImage: "folder.badge.plus").font(.headline).foregroundStyle(.blue)
            Text("Keep Ejari, permits, receipts, appointment confirmations, condition photos and handover evidence together. Task pages also let you attach proof directly to the relevant step.")
                .font(.caption)
                .foregroundStyle(.secondary)
            NavigationLink(destination: FunctionalV2DocumentsView()) {
                Label("Open Documents", systemImage: "folder.fill").frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .tint(.blue)
        }
        .moveOpsSurface()
    }

    private var supportCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Label("Do it yourself or get help", systemImage: "arrow.triangle.branch").font(.headline).foregroundStyle(.purple)
            Text("Official and provider actions stay on their own channels. Dubai Move explains the process, sends you to the right place, and lets you choose a service provider when you do not want to handle the operational work yourself.")
                .font(.caption)
                .foregroundStyle(.secondary)
            HStack(spacing: 10) {
                NavigationLink(destination: GuidedMovePlanView()) { Text("Guides").frame(maxWidth: .infinity) }.buttonStyle(.bordered)
                NavigationLink(destination: ServicesMarketplaceV6View()) { Text("Services").frame(maxWidth: .infinity) }.buttonStyle(.borderedProminent).tint(.purple)
            }
        }
        .moveOpsSurface()
    }

    private func tile(_ title: String, _ subtitle: String, _ icon: String, _ tint: Color) -> some View {
        VStack(alignment: .leading, spacing: 9) {
            Image(systemName: icon)
                .font(.title2.bold())
                .foregroundStyle(tint)
                .frame(width: 44, height: 44)
                .background(tint.opacity(0.12))
                .clipShape(RoundedRectangle(cornerRadius: 14))
            Text(title).font(.headline).foregroundStyle(DMTheme.ink)
            Text(subtitle).font(.caption).foregroundStyle(.secondary).lineLimit(2)
        }
        .frame(maxWidth: .infinity, minHeight: 132, alignment: .leading)
        .padding(13)
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
}

struct PropertyMoveProfileView: View {
    @AppStorage("dubaimove.property.building") private var building = ""
    @AppStorage("dubaimove.property.unit") private var unit = ""
    @AppStorage("dubaimove.property.managementName") private var managementName = ""
    @AppStorage("dubaimove.property.managementPhone") private var managementPhone = ""
    @AppStorage("dubaimove.property.managementEmail") private var managementEmail = ""
    @AppStorage("dubaimove.property.permit") private var permitStatus = "Unknown"
    @AppStorage("dubaimove.property.lift") private var liftStatus = "Not checked"
    @AppStorage("dubaimove.property.loading") private var loading = ""
    @AppStorage("dubaimove.property.moveHours") private var moveHours = ""
    @AppStorage("dubaimove.property.coolingProvider") private var coolingProvider = "Not sure"
    @AppStorage("dubaimove.property.notes") private var notes = ""

    var body: some View {
        Form {
            Section("Property") {
                TextField("Building / community", text: $building)
                TextField("Unit", text: $unit)
            }
            Section("Building management") {
                TextField("Management / concierge name", text: $managementName)
                TextField("Phone", text: $managementPhone).keyboardType(.phonePad)
                TextField("Email", text: $managementEmail).textInputAutocapitalization(.never).keyboardType(.emailAddress)
            }
            Section("Move access") {
                Picker("Move permit / NOC", selection: $permitStatus) {
                    Text("Unknown").tag("Unknown")
                    Text("Not required").tag("Not required")
                    Text("Required").tag("Required")
                    Text("Requested").tag("Requested")
                    Text("Approved").tag("Approved")
                }
                Picker("Service lift", selection: $liftStatus) {
                    Text("Not checked").tag("Not checked")
                    Text("Not required").tag("Not required")
                    Text("Needs booking").tag("Needs booking")
                    Text("Booked").tag("Booked")
                }
                TextField("Loading bay / truck entrance", text: $loading)
                TextField("Allowed move hours", text: $moveHours)
            }
            Section("Cooling") {
                Picker("Building cooling provider", selection: $coolingProvider) {
                    Text("Not sure").tag("Not sure")
                    Text("Chiller free / included").tag("Chiller free / included")
                    Text("Empower").tag("Empower")
                    Text("Emicool").tag("Emicool")
                    Text("Other").tag("Other")
                }
            }
            Section("Verified notes") {
                TextField("Anything management confirmed", text: $notes, axis: .vertical).lineLimit(3...7)
                Text("Dubai Move does not guess building-specific rules. Save only what your tenancy, building management or official provider has confirmed.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Section {
                NavigationLink("Open building move guide", destination: BuildingGuidedView())
            }
        }
        .navigationTitle("Property Profile")
    }
}

struct MoveContactsHubView: View {
    @Environment(\.openURL) private var openURL
    @AppStorage("dubaimove.contact.landlord.name") private var landlordName = ""
    @AppStorage("dubaimove.contact.landlord.phone") private var landlordPhone = ""
    @AppStorage("dubaimove.contact.management.name") private var managementName = ""
    @AppStorage("dubaimove.contact.management.phone") private var managementPhone = ""
    @AppStorage("dubaimove.contact.mover.name") private var moverName = ""
    @AppStorage("dubaimove.contact.mover.phone") private var moverPhone = ""
    @AppStorage("dubaimove.contact.internet.name") private var internetName = ""
    @AppStorage("dubaimove.contact.internet.phone") private var internetPhone = ""
    @AppStorage("dubaimove.contact.cooling.name") private var coolingName = ""
    @AppStorage("dubaimove.contact.cooling.phone") private var coolingPhone = ""

    var body: some View {
        Form {
            contactSection("Landlord / agent", name: $landlordName, phone: $landlordPhone)
            contactSection("Building management", name: $managementName, phone: $managementPhone)
            contactSection("Mover", name: $moverName, phone: $moverPhone)
            contactSection("Internet provider / technician", name: $internetName, phone: $internetPhone)
            contactSection("Cooling provider / support", name: $coolingName, phone: $coolingPhone)
            Section {
                Text("These are your saved operational contacts. Authority emergency numbers are shown only inside the relevant verified guide.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .navigationTitle("Move Contacts")
    }

    @ViewBuilder
    private func contactSection(_ title: String, name: Binding<String>, phone: Binding<String>) -> some View {
        Section(title) {
            TextField("Name / company", text: name)
            TextField("Phone", text: phone).keyboardType(.phonePad)
            if !phone.wrappedValue.isEmpty {
                Button {
                    let clean = phone.wrappedValue.filter { "+0123456789".contains($0) }
                    if let url = URL(string: "tel:\(clean)") { openURL(url) }
                } label: {
                    Label("Call", systemImage: "phone.fill")
                }
            }
        }
    }
}

struct MoveAppointmentsHubView: View {
    @AppStorage("dubaimove.appointment.mover") private var moverEpoch = Date().addingTimeInterval(86400 * 14).timeIntervalSince1970
    @AppStorage("dubaimove.appointment.internet") private var internetEpoch = Date().addingTimeInterval(86400 * 15).timeIntervalSince1970
    @AppStorage("dubaimove.appointment.handover") private var handoverEpoch = Date().addingTimeInterval(86400 * 21).timeIntervalSince1970
    @AppStorage("dubaimove.appointment.mover.confirmed") private var moverConfirmed = false
    @AppStorage("dubaimove.appointment.internet.confirmed") private var internetConfirmed = false
    @AppStorage("dubaimove.appointment.handover.confirmed") private var handoverConfirmed = false
    @AppStorage("dubaimove.appointment.notes") private var notes = ""

    var body: some View {
        Form {
            appointment("Mover arrival", epoch: $moverEpoch, confirmed: $moverConfirmed)
            appointment("Internet technician / activation", epoch: $internetEpoch, confirmed: $internetConfirmed)
            appointment("Handover / keys", epoch: $handoverEpoch, confirmed: $handoverConfirmed)
            Section("Notes") {
                TextField("Reference numbers, access window, contact notes", text: $notes, axis: .vertical).lineLimit(3...7)
            }
            Section {
                Text("Only mark an appointment confirmed when the provider/building has actually confirmed it. Dubai Move does not create provider bookings by itself.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .navigationTitle("Appointments")
    }

    @ViewBuilder
    private func appointment(_ title: String, epoch: Binding<Double>, confirmed: Binding<Bool>) -> some View {
        Section(title) {
            DatePicker("Date & time", selection: Binding(get: { Date(timeIntervalSince1970: epoch.wrappedValue) }, set: { epoch.wrappedValue = $0.timeIntervalSince1970 }))
            Toggle("Confirmed", isOn: confirmed).tint(DMTheme.green)
        }
    }
}

struct MoveRescueCenterView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 14) {
                VStack(alignment: .leading, spacing: 7) {
                    Text("SOMETHING WENT WRONG?").font(.caption2.bold()).foregroundStyle(.red)
                    Text("Recovery paths").font(.largeTitle.bold())
                    Text("Choose the problem. We take you to the safest next step instead of pretending the issue is resolved.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .moveOpsSurface()

                rescue("Building permit is delayed", "Confirm what is missing, ask management for the exact approval path and do not send the mover before access is confirmed.", "building.2.fill", .orange, BuildingGuidedView())
                rescue("DEWA is not active", "Open the DEWA guide, verify the journey/reference/payment status and use the official customer-care route shown there if the published activation window has passed.", "bolt.fill", .blue, DewaGuidedView())
                rescue("No internet appointment", "Use the provider-aware guide, check exact-address availability and ask for the earliest confirmed slot before relying on service for move day.", "wifi", .purple, TelecomGuidedView())
                rescue("Cooling provider is unclear", "Do not guess. Ask building management whether cooling is included and, if separately billed, which provider serves the unit.", "snowflake", .cyan, CoolingGuidedView())
                rescue("Mover cancelled", "Keep building access rules intact and compare another provider before confirming a replacement slot.", "truck.box.fill", .red, ServicesMarketplaceV6View())
                rescue("Handover / keys issue", "Record what was handed over, keep dated evidence and use the handover flow to avoid losing track of keys, cards and condition records.", "key.fill", .brown, FunctionalV2HandoverView())
            }
            .padding(16)
            .padding(.bottom, 80)
        }
        .background(Color(uiColor: .systemGroupedBackground).ignoresSafeArea())
        .navigationTitle("Move Help")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func rescue<Destination: View>(_ title: String, _ text: String, _ icon: String, _ tint: Color, _ destination: Destination) -> some View {
        NavigationLink(destination: destination) {
            HStack(alignment: .top, spacing: 12) {
                Image(systemName: icon)
                    .font(.title3.bold())
                    .foregroundStyle(tint)
                    .frame(width: 42, height: 42)
                    .background(tint.opacity(0.12))
                    .clipShape(RoundedRectangle(cornerRadius: 13))
                VStack(alignment: .leading, spacing: 4) {
                    Text(title).font(.headline).foregroundStyle(DMTheme.ink)
                    Text(text).font(.caption).foregroundStyle(.secondary).multilineTextAlignment(.leading)
                }
                Spacer()
                Image(systemName: "chevron.right").foregroundStyle(.secondary)
            }
            .padding(14)
            .background(.white)
            .clipShape(RoundedRectangle(cornerRadius: 19))
        }
        .buttonStyle(.plain)
    }
}

struct EnhancedMoveDayModeView: View {
    @Environment(\.openURL) private var openURL
    @AppStorage("dubaimove.property.building") private var building = ""
    @AppStorage("dubaimove.property.unit") private var unit = ""
    @AppStorage("dubaimove.property.permit") private var permitStatus = "Unknown"
    @AppStorage("dubaimove.property.lift") private var liftStatus = "Not checked"
    @AppStorage("dubaimove.contact.management.phone") private var managementPhone = ""
    @AppStorage("dubaimove.contact.mover.phone") private var moverPhone = ""
    @AppStorage("dubaimove.appointment.mover") private var moverEpoch = Date().timeIntervalSince1970
    @AppStorage("dubaimove.appointment.internet") private var internetEpoch = Date().timeIntervalSince1970
    @AppStorage("dubaimove.appointment.mover.confirmed") private var moverConfirmed = false
    @AppStorage("dubaimove.appointment.internet.confirmed") private var internetConfirmed = false
    @State private var refresh = UUID()

    private let checklist = [
        "Mover arrival confirmed",
        "Building permit / NOC available if required",
        "Service lift / loading access confirmed",
        "Old-home condition photos saved",
        "Keys and access cards counted",
        "DEWA / cooling status checked",
        "New-home condition photos saved",
        "Internet appointment / status checked",
        "Handover proof and receipts saved"
    ]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 14) {
                VStack(alignment: .leading, spacing: 7) {
                    Text("MOVE DAY LIVE").font(.caption2.bold()).tracking(1.3).foregroundStyle(.orange)
                    Text(building.isEmpty ? "Your move day" : building + (unit.isEmpty ? "" : " · Unit \(unit)"))
                        .font(.largeTitle.bold())
                    Text("Critical operational information only. A checked box records your own confirmation; it does not mean an authority or provider completed an action.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .moveOpsSurface()

                HStack(spacing: 10) {
                    statusChip("Permit", permitStatus, permitStatus == "Approved" || permitStatus == "Not required" ? .green : .orange)
                    statusChip("Lift", liftStatus, liftStatus == "Booked" || liftStatus == "Not required" ? .green : .orange)
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text("Today's key appointments").font(.headline)
                    appointmentRow("Mover", moverEpoch, moverConfirmed, .orange)
                    appointmentRow("Internet", internetEpoch, internetConfirmed, .purple)
                }
                .moveOpsSurface()

                if !managementPhone.isEmpty || !moverPhone.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("One-tap contacts").font(.headline)
                        if !managementPhone.isEmpty { callButton("Building management", managementPhone, .blue) }
                        if !moverPhone.isEmpty { callButton("Mover", moverPhone, .orange) }
                    }
                    .moveOpsSurface()
                }

                Text("Critical checklist").font(.title2.bold())
                ForEach(Array(checklist.enumerated()), id: \.offset) { index, item in
                    let key = "dubaimove.moveday.live.\(index)"
                    let done = UserDefaults.standard.bool(forKey: key)
                    Button {
                        UserDefaults.standard.set(!done, forKey: key)
                        refresh = UUID()
                    } label: {
                        HStack(spacing: 12) {
                            Image(systemName: done ? "checkmark.circle.fill" : "circle")
                                .foregroundStyle(done ? DMTheme.green : .orange)
                                .font(.title3)
                            Text(item).font(.subheadline.bold()).foregroundStyle(DMTheme.ink)
                            Spacer()
                        }
                        .padding(14)
                        .background(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 17))
                    }
                    .buttonStyle(.plain)
                }
                .id(refresh)

                NavigationLink(destination: FunctionalV2DocumentsView()) {
                    Label("Save / review evidence", systemImage: "folder.fill").frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .tint(.blue)
            }
            .padding(16)
            .padding(.bottom, 80)
        }
        .background(Color(uiColor: .systemGroupedBackground).ignoresSafeArea())
        .navigationTitle("Move Day")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func statusChip(_ title: String, _ value: String, _ tint: Color) -> some View {
        VStack(alignment: .leading, spacing: 3) {
            Text(title).font(.caption.bold()).foregroundStyle(.secondary)
            Text(value).font(.subheadline.bold()).foregroundStyle(tint)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 15))
    }

    private func appointmentRow(_ title: String, _ epoch: Double, _ confirmed: Bool, _ tint: Color) -> some View {
        HStack {
            Image(systemName: "calendar.badge.clock").foregroundStyle(tint)
            VStack(alignment: .leading, spacing: 2) {
                Text(title).font(.subheadline.bold())
                Text(Date(timeIntervalSince1970: epoch).formatted(date: .abbreviated, time: .shortened)).font(.caption).foregroundStyle(.secondary)
            }
            Spacer()
            Text(confirmed ? "Confirmed" : "Unconfirmed")
                .font(.caption2.bold())
                .foregroundStyle(confirmed ? DMTheme.green : .orange)
        }
    }

    private func callButton(_ title: String, _ number: String, _ tint: Color) -> some View {
        Button {
            let clean = number.filter { "+0123456789".contains($0) }
            if let url = URL(string: "tel:\(clean)") { openURL(url) }
        } label: {
            Label("\(title) · \(number)", systemImage: "phone.fill")
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .buttonStyle(.bordered)
        .tint(tint)
    }
}

private extension View {
    func moveOpsSurface() -> some View {
        self
            .padding(15)
            .background(.white)
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color.black.opacity(0.05), lineWidth: 1))
    }
}
