import SwiftUI
import MapKit
import CoreLocation

// MARK: - Guided move plan and beginner-first Dubai guides

private let guideVerifiedDate = "6 Sep 2026"

private struct GuideSurface<Content: View>: View {
    let title: String
    let icon: String
    let tint: Color
    @ViewBuilder let content: () -> Content

    var body: some View {
        VStack(alignment: .leading, spacing: 13) {
            HStack(spacing: 10) {
                Image(systemName: icon)
                    .font(.system(size: 17, weight: .bold))
                    .foregroundStyle(tint)
                    .frame(width: 40, height: 40)
                    .background(tint.opacity(0.12))
                    .clipShape(RoundedRectangle(cornerRadius: 13, style: .continuous))
                Text(title).font(.headline).foregroundStyle(DMTheme.ink)
                Spacer(minLength: 0)
            }
            content()
        }
        .padding(16)
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 22).stroke(Color.black.opacity(0.05), lineWidth: 1))
        .shadow(color: .black.opacity(0.035), radius: 10, y: 4)
    }
}

private struct GuideHero: View {
    let eyebrow: String
    let title: String
    let subtitle: String
    let icon: String
    let colors: [Color]

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            LinearGradient(colors: colors, startPoint: .topLeading, endPoint: .bottomTrailing)
            Image(systemName: icon)
                .font(.system(size: 132, weight: .ultraLight))
                .foregroundStyle(.white.opacity(0.13))
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
                .offset(x: 22, y: -8)
            VStack(alignment: .leading, spacing: 8) {
                Text(eyebrow.uppercased())
                    .font(.caption2.bold()).tracking(1.5).foregroundStyle(.white.opacity(0.8))
                Text(title)
                    .font(.system(size: 31, weight: .heavy, design: .rounded))
                    .foregroundStyle(.white)
                    .fixedSize(horizontal: false, vertical: true)
                Text(subtitle)
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(.white.opacity(0.86))
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(20)
        }
        .frame(maxWidth: .infinity, minHeight: 205)
        .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
        .shadow(color: colors.first?.opacity(0.22) ?? .clear, radius: 16, y: 8)
    }
}

private struct GuideBullet: View {
    let text: String
    let icon: String
    let tint: Color

    init(_ text: String, icon: String = "checkmark.circle.fill", tint: Color = DMTheme.green) {
        self.text = text
        self.icon = icon
        self.tint = tint
    }

    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: icon).foregroundStyle(tint).frame(width: 20).padding(.top, 1)
            Text(text).font(.subheadline).foregroundStyle(DMTheme.ink.opacity(0.88)).fixedSize(horizontal: false, vertical: true)
            Spacer(minLength: 0)
        }
    }
}

private struct GuideNumberedStep: View {
    let number: Int
    let title: String
    let detail: String
    var tint: Color = .blue

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Text("\(number)")
                .font(.subheadline.bold())
                .foregroundStyle(.white)
                .frame(width: 32, height: 32)
                .background(tint)
                .clipShape(Circle())
            VStack(alignment: .leading, spacing: 3) {
                Text(title).font(.subheadline.bold()).foregroundStyle(DMTheme.ink)
                Text(detail).font(.caption).foregroundStyle(.secondary).fixedSize(horizontal: false, vertical: true)
            }
            Spacer(minLength: 0)
        }
    }
}

private struct VerifiedFooter: View {
    let source: String
    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            Image(systemName: "checkmark.shield.fill").foregroundStyle(DMTheme.green)
            Text("Guidance checked against \(source). Last verified \(guideVerifiedDate). Requirements, fees and service channels can change — confirm the official page before you submit or pay.")
                .font(.caption).foregroundStyle(.secondary).fixedSize(horizontal: false, vertical: true)
        }
        .padding(14)
        .background(DMTheme.mint.opacity(0.6))
        .clipShape(RoundedRectangle(cornerRadius: 17))
    }
}

private struct OfficialLinkButton: View {
    let title: String
    let url: String
    var tint: Color = DMTheme.green
    @Environment(\.openURL) private var openURL

    var body: some View {
        Button {
            guard let target = URL(string: url) else { return }
            openURL(target)
        } label: {
            HStack {
                Text(title).font(.subheadline.bold())
                Spacer()
                Image(systemName: "arrow.up.right")
            }
            .foregroundStyle(.white)
            .padding(.horizontal, 14)
            .frame(maxWidth: .infinity, minHeight: 48)
            .background(tint)
            .clipShape(RoundedRectangle(cornerRadius: 14))
        }
        .buttonStyle(.plain)
    }
}

private struct PhoneButton: View {
    let label: String
    let number: String
    var tint: Color = .blue
    @Environment(\.openURL) private var openURL

    var body: some View {
        Button {
            let clean = number.filter { "+0123456789".contains($0) }
            if let url = URL(string: "tel:\(clean)") { openURL(url) }
        } label: {
            Label("\(label) · \(number)", systemImage: "phone.fill")
                .font(.subheadline.bold())
                .foregroundStyle(tint)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(13)
                .background(tint.opacity(0.09))
                .clipShape(RoundedRectangle(cornerRadius: 14))
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Location-powered official/service-centre finder

@MainActor
private final class GuideLocationStore: NSObject, ObservableObject, CLLocationManagerDelegate {
    @Published var location: CLLocation?
    @Published var message = "Use your location to find nearby branches."
    private let manager = CLLocationManager()

    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyKilometer
    }

    func request() {
        switch manager.authorizationStatus {
        case .notDetermined:
            manager.requestWhenInUseAuthorization()
        case .authorizedAlways, .authorizedWhenInUse:
            manager.requestLocation()
        case .denied, .restricted:
            message = "Location is off. You can still search around central Dubai or enable location in Settings."
        @unknown default:
            break
        }
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        if manager.authorizationStatus == .authorizedAlways || manager.authorizationStatus == .authorizedWhenInUse {
            manager.requestLocation()
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        location = locations.last
        message = "Nearby results are based on your current location."
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        message = "Could not read your location. Showing a Dubai-area search instead."
    }
}

private struct GuidePlace: Identifiable {
    let id = UUID()
    let item: MKMapItem
    var name: String { item.name ?? "Location" }
    var coordinate: CLLocationCoordinate2D { item.placemark.coordinate }
    var subtitle: String {
        [item.placemark.subLocality, item.placemark.locality].compactMap { $0 }.joined(separator: " · ")
    }
}

private struct NearbyGuidePlacesView: View {
    let title: String
    let query: String
    let icon: String
    @StateObject private var locationStore = GuideLocationStore()
    @State private var places: [GuidePlace] = []
    @State private var loading = false
    @State private var position: MapCameraPosition = .region(
        MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 25.2048, longitude: 55.2708), span: MKCoordinateSpan(latitudeDelta: 0.22, longitudeDelta: 0.22))
    )

    var body: some View {
        GuideSurface(title: title, icon: icon, tint: .red) {
            VStack(alignment: .leading, spacing: 12) {
                Text(locationStore.message).font(.caption).foregroundStyle(.secondary)

                Map(position: $position) {
                    ForEach(places) { place in
                        Marker(place.name, coordinate: place.coordinate)
                    }
                }
                .frame(height: 175)
                .clipShape(RoundedRectangle(cornerRadius: 16))

                Button {
                    locationStore.request()
                    Task { await search() }
                } label: {
                    Label(loading ? "Finding nearby…" : "Find nearest", systemImage: "location.fill")
                        .font(.subheadline.bold()).frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent).tint(.red).disabled(loading)

                ForEach(places.prefix(3)) { place in
                    Button {
                        place.item.openInMaps(launchOptions: [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving])
                    } label: {
                        HStack(spacing: 10) {
                            Image(systemName: "mappin.circle.fill").foregroundStyle(.red)
                            VStack(alignment: .leading, spacing: 2) {
                                Text(place.name).font(.subheadline.bold()).foregroundStyle(DMTheme.ink).lineLimit(1)
                                if !place.subtitle.isEmpty { Text(place.subtitle).font(.caption).foregroundStyle(.secondary) }
                            }
                            Spacer()
                            Image(systemName: "arrow.triangle.turn.up.right.diamond.fill").foregroundStyle(.secondary)
                        }
                        .padding(11).background(Color(uiColor: .secondarySystemGroupedBackground)).clipShape(RoundedRectangle(cornerRadius: 14))
                    }
                    .buttonStyle(.plain)
                }
            }
            .task { await search() }
            .onChange(of: locationStore.location?.coordinate.latitude) { _, _ in Task { await search() } }
        }
    }

    private func search() async {
        guard !loading else { return }
        loading = true
        defer { loading = false }
        let center = locationStore.location?.coordinate ?? CLLocationCoordinate2D(latitude: 25.2048, longitude: 55.2708)
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = query
        request.region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.18, longitudeDelta: 0.18))
        do {
            let response = try await MKLocalSearch(request: request).start()
            places = Array(response.mapItems.prefix(5)).map(GuidePlace.init)
            if let first = places.first {
                position = .region(MKCoordinateRegion(center: first.coordinate, span: MKCoordinateSpan(latitudeDelta: 0.08, longitudeDelta: 0.08)))
            } else {
                position = .region(request.region)
            }
        } catch {
            places = []
        }
    }
}

// MARK: - Smart move plan

struct GuidedMovePlanView: View {
    @AppStorage("dubaimove.v2.moveKind") private var moveKind = LocalMoveKind.withinDubai.rawValue
    @AppStorage("dubaimove.v2.moveDate") private var moveDateEpoch = Date().addingTimeInterval(86400 * 21).timeIntervalSince1970
    @State private var refreshID = UUID()

    private var plan: PremiumMovePlan { PremiumMovePlan.plan(for: moveKind) }
    private var moveDate: Date { Date(timeIntervalSince1970: moveDateEpoch) }
    private var completed: Int { plan.steps.filter { UserDefaults.standard.bool(forKey: $0.storageKey) }.count }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                GuideHero(
                    eyebrow: plan.shortTitle,
                    title: "We tell you exactly what to do",
                    subtitle: "Open every step for documents, official channels, click-by-click guidance, locations and what to do next.",
                    icon: "map.fill",
                    colors: [DMTheme.greenDeep, DMTheme.green, .teal]
                )

                HStack(spacing: 10) {
                    Label(moveDate.formatted(date: .abbreviated, time: .omitted), systemImage: "calendar")
                    Spacer()
                    Text("\(completed)/\(plan.steps.count) complete")
                }
                .font(.caption.bold()).foregroundStyle(DMTheme.greenDeep)
                .padding(13).background(DMTheme.mint).clipShape(RoundedRectangle(cornerRadius: 15))

                GuideSurface(title: "How this plan works", icon: "hand.point.up.left.fill", tint: .purple) {
                    VStack(spacing: 9) {
                        GuideBullet("You do not need to know Dubai processes before you start.", icon: "person.crop.circle.badge.questionmark", tint: .purple)
                        GuideBullet("Each task explains what it is, whether you need it, what to prepare, where to go and how you know it is finished.", icon: "list.bullet.rectangle", tint: .purple)
                        GuideBullet("Government or utility actions stay on the official authority/provider channel; Dubai Move guides the handoff but never pretends to complete it for you.", icon: "checkmark.shield.fill", tint: .purple)
                    }
                }

                ForEach(Array(plan.steps.enumerated()), id: \.element.id) { index, step in
                    planCard(index: index, step: step)
                }
            }
            .id(refreshID)
            .padding(16)
            .padding(.bottom, 90)
        }
        .background(Color(uiColor: .systemGroupedBackground).ignoresSafeArea())
        .navigationTitle("Your Move Plan")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func planCard(index: Int, step: PremiumMoveStep) -> some View {
        let done = UserDefaults.standard.bool(forKey: step.storageKey)
        return VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top, spacing: 12) {
                ZStack {
                    Circle().fill(done ? DMTheme.green : timingTint(step.target).opacity(0.14))
                    if done { Image(systemName: "checkmark").font(.headline.bold()).foregroundStyle(.white) }
                    else { Text("\(index + 1)").font(.headline.bold()).foregroundStyle(timingTint(step.target)) }
                }.frame(width: 42, height: 42)
                VStack(alignment: .leading, spacing: 4) {
                    Text(timingLabel(step.target)).font(.caption2.bold()).foregroundStyle(timingTint(step.target)).textCase(.uppercase)
                    Text(step.title).font(.headline).foregroundStyle(DMTheme.ink)
                    Text(step.note).font(.caption).foregroundStyle(.secondary).fixedSize(horizontal: false, vertical: true)
                }
                Spacer(minLength: 0)
            }

            HStack(spacing: 9) {
                Button {
                    UserDefaults.standard.set(!done, forKey: step.storageKey)
                    refreshID = UUID()
                } label: {
                    Label(done ? "Undo" : "Mark done", systemImage: done ? "arrow.uturn.backward" : "checkmark.circle")
                        .frame(maxWidth: .infinity)
                }.buttonStyle(.bordered).tint(DMTheme.green)

                NavigationLink(destination: guidedDestination(for: step.target)) {
                    Label("Open guide", systemImage: "arrow.right").frame(maxWidth: .infinity)
                }.buttonStyle(.borderedProminent).tint(DMTheme.green)
            }
        }
        .padding(16).background(.white).clipShape(RoundedRectangle(cornerRadius: 22))
        .overlay(RoundedRectangle(cornerRadius: 22).stroke(done ? DMTheme.green.opacity(0.35) : Color.black.opacity(0.05), lineWidth: 1))
    }

    private func timingLabel(_ target: PremiumMoveTarget) -> String {
        switch target {
        case .documents: return "Start here"
        case .ejari: return "After tenancy is ready"
        case .dewa: return "Before occupancy"
        case .telecom: return "Book early"
        case .cooling: return "Check early"
        case .building: return "Before mover is final"
        case .services: return "Once access rules are clear"
        case .inspection: return "Before handover"
        case .handover: return "Handover stage"
        case .money: return "After final bills"
        case .leaving: return "Before departure"
        case .setup: return "Do now"
        }
    }

    private func timingTint(_ target: PremiumMoveTarget) -> Color {
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

@ViewBuilder
private func guidedDestination(for target: PremiumMoveTarget) -> some View {
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

// MARK: - Ejari complete beginner guide

struct EjariGuidedView: View {
    @Environment(\.openURL) private var openURL

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                GuideHero(
                    eyebrow: "Essential tenancy record",
                    title: "Ejari",
                    subtitle: "Register or renew your Dubai tenancy through Dubai Land Department channels — with every step explained before you leave the app.",
                    icon: "doc.text.fill",
                    colors: [.blue, .indigo, .purple]
                )

                GuideSurface(title: "Do I need this?", icon: "questionmark.circle.fill", tint: .teal) {
                    VStack(spacing: 9) {
                        GuideBullet("If you are renting a property in Dubai, Ejari is the official tenancy registration record used across many move-related services.")
                        GuideBullet("If your property is in a special/free-zone situation or your landlord/property manager handles registration, follow the route that applies to your tenancy and confirm it on DLD/DEWA before acting.", icon: "info.circle.fill", tint: .orange)
                    }
                }

                GuideSurface(title: "What you need before you start", icon: "folder.fill", tint: .blue) {
                    VStack(spacing: 10) {
                        GuideBullet("Online / Dubai REST: a copy of the Unified Tenancy Contract for individual/company registration.")
                        GuideBullet("At a Real Estate Services Trustee Center: original Unified Tenancy Contract and the applicant's Emirates ID.")
                        GuideBullet("If a representative applies at a trustee centre, an official Power of Attorney may be required; DLD gives different attachment instructions depending on where it was issued.")
                        GuideBullet("Keep the property, tenant and landlord details exactly as they appear on the signed contract.", icon: "exclamationmark.circle.fill", tint: .orange)
                    }
                }

                GuideSurface(title: "Register online — step by step", icon: "list.number", tint: .indigo) {
                    VStack(spacing: 13) {
                        GuideNumberedStep(number: 1, title: "Open the official DLD Ejari service", detail: "Use DLD / Dubai REST. Avoid search ads or unofficial payment pages.", tint: .indigo)
                        GuideNumberedStep(number: 2, title: "Log in and choose registration / renewal", detail: "Select the Ejari tenancy registration service that matches what you are doing.", tint: .indigo)
                        GuideNumberedStep(number: 3, title: "Enter the tenancy information", detail: "Copy the contract and property details carefully. Do not guess missing numbers.", tint: .indigo)
                        GuideNumberedStep(number: 4, title: "Upload the requested document(s)", detail: "DLD currently lists the Unified Tenancy Contract for the app route; the official page remains the source of truth for your case.", tint: .indigo)
                        GuideNumberedStep(number: 5, title: "Pay on the official channel", detail: "DLD currently lists AED 177.75 total for the website / Dubai REST route. Verify the live total before payment.", tint: .indigo)
                        GuideNumberedStep(number: 6, title: "Wait for review / approval", detail: "DLD states the request is reviewed in the system before the certificate is issued.", tint: .indigo)
                        GuideNumberedStep(number: 7, title: "Save the e-Contract Registration Certificate", detail: "The digital certificate is the output you want to keep in your Dubai Move document wallet.", tint: .indigo)
                        OfficialLinkButton(title: "Open official DLD Ejari service", url: "https://dubailand.gov.ae/en/eservices/register-renew-ejari-contract/", tint: .indigo)
                    }
                }

                GuideSurface(title: "Prefer to go in person?", icon: "building.columns.fill", tint: .orange) {
                    VStack(spacing: 10) {
                        GuideBullet("DLD says you may visit a Real Estate Services Trustee Center, or the property management company if the property is managed by one.", tint: .orange)
                        GuideBullet("The current DLD total shown for a trustee-centre registration is AED 220. DLD lists 25 minutes service time excluding waiting; verify before visiting.", tint: .orange)
                        OfficialLinkButton(title: "Open DLD Trustee Center locator", url: "https://dubailand.gov.ae/en/eservices/real-estate-service-trustees-centers/", tint: .orange)
                    }
                }

                NearbyGuidePlacesView(title: "Nearest Ejari / DLD service options", query: "Dubai Land Department Real Estate Services Trustee Center", icon: "map.fill")

                GuideSurface(title: "What does an Ejari document contain?", icon: "doc.richtext.fill", tint: .purple) {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("SAMPLE FIELD GUIDE").font(.caption2.bold()).tracking(1.2).foregroundStyle(.purple)
                        VStack(alignment: .leading, spacing: 11) {
                            sampleField("Ejari Contract Number", "Used to identify the registered tenancy")
                            sampleField("DEWA Premise Number", "Useful when connecting utility steps")
                            sampleField("Property details", "Building / unit / tenancy information")
                            sampleField("Tenant & landlord details", "Check names and details before relying on the certificate")
                        }
                        .padding(14).background(.purple.opacity(0.07)).clipShape(RoundedRectangle(cornerRadius: 16))
                        Text("Illustrative field guide only — not an official Ejari certificate.").font(.caption).foregroundStyle(.secondary)
                        OfficialLinkButton(title: "Open DLD Ejari certificate service", url: "https://dubailand.gov.ae/en/eservices/download-ejari-certificate/", tint: .purple)
                        OfficialLinkButton(title: "View DLD Ejari templates", url: "https://dubailand.gov.ae/en/eservices/ejari-templates/", tint: .purple)
                    }
                }

                GuideSurface(title: "What happens next?", icon: "arrow.right.circle.fill", tint: DMTheme.green) {
                    VStack(spacing: 9) {
                        GuideBullet("Save the issued certificate in Documents so you can find it again.")
                        NavigationLink(destination: DewaGuidedView()) {
                            HStack { Text("Continue to DEWA guide").bold(); Spacer(); Image(systemName: "chevron.right") }
                                .foregroundStyle(DMTheme.green).padding(12).background(DMTheme.mint).clipShape(RoundedRectangle(cornerRadius: 13))
                        }.buttonStyle(.plain)
                        GuideBullet("Also review building move-in rules, internet and cooling — those are separate setup tasks.", icon: "building.2.fill", tint: .orange)
                    }
                }

                GuideSurface(title: "Need help?", icon: "lifepreserver.fill", tint: .blue) {
                    VStack(spacing: 10) {
                        PhoneButton(label: "Dubai Land Department", number: "8004488")
                        OfficialLinkButton(title: "Open DLD Ejari awareness guide", url: "https://dubailand.gov.ae/en/eservices/campaign-for-ejari-services/", tint: .blue)
                    }
                }

                VerifiedFooter(source: "Dubai Land Department official Ejari service pages")
            }
            .padding(16).padding(.bottom, 90)
        }
        .background(Color(uiColor: .systemGroupedBackground).ignoresSafeArea())
        .navigationTitle("Ejari Guide")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func sampleField(_ title: String, _ subtitle: String) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(title).font(.subheadline.bold())
            Text(subtitle).font(.caption).foregroundStyle(.secondary)
        }
    }
}

// MARK: - DEWA complete guide

struct DewaGuidedView: View {
    @State private var journey = "Move-In"

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                GuideHero(
                    eyebrow: "Electricity & water",
                    title: "DEWA",
                    subtitle: "First choose the correct journey. Then Dubai Move tells you what to prepare, what to press and what confirmation to keep.",
                    icon: "bolt.fill",
                    colors: [.cyan, .blue, .indigo]
                )

                Picker("DEWA journey", selection: $journey) {
                    Text("Move-In").tag("Move-In")
                    Text("Move-To").tag("Move-To")
                    Text("Move-Out").tag("Move-Out")
                }
                .pickerStyle(.segmented)

                GuideSurface(title: "Which one do I choose?", icon: "point.3.connected.trianglepath.dotted", tint: .blue) {
                    VStack(spacing: 9) {
                        GuideBullet("Move-In: you need electricity/water activated at a new premise.", tint: .blue)
                        GuideBullet("Move-To: you already have DEWA and are moving from one Dubai premise to another.", tint: .blue)
                        GuideBullet("Move-Out: you are leaving the premise and need deactivation, final bill and deposit/refund handling.", tint: .blue)
                    }
                }

                if journey == "Move-In" { moveIn }
                else if journey == "Move-To" { moveTo }
                else { moveOut }

                GuideSurface(title: "DEWA help", icon: "phone.fill", tint: .blue) {
                    VStack(spacing: 10) {
                        PhoneButton(label: "DEWA Customer Care", number: "04 601 9999")
                        Text("DEWA specifically asks customers to call this number if supply is not activated within 15 working hours after the required security-deposit payment.").font(.caption).foregroundStyle(.secondary)
                    }
                }

                VerifiedFooter(source: "DEWA official Move-In, Move-To and Move-Out service guides")
            }
            .padding(16).padding(.bottom, 90)
        }
        .background(Color(uiColor: .systemGroupedBackground).ignoresSafeArea())
        .navigationTitle("DEWA Guide")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var moveIn: some View {
        Group {
            GuideSurface(title: "Move-In — prepare this", icon: "folder.fill", tint: .cyan) {
                VStack(spacing: 9) {
                    GuideBullet("Tenant: valid Ejari number. DEWA says a valid Ejari can replace document upload in the normal tenant Move-In flow.")
                    GuideBullet("For tenants outside free zones, DEWA says the Ejari integration can send you a welcome email/SMS with the new account number, security-deposit details and payment link.")
                    GuideBullet("Residential refundable security deposit currently: AED 2,000 apartment / AED 4,000 villa. Typical small-meter activation total is currently AED 155. Verify live charges before paying.", icon: "banknote.fill", tint: .orange)
                }
            }
            GuideSurface(title: "Move-In — step by step", icon: "list.number", tint: .blue) {
                VStack(spacing: 13) {
                    GuideNumberedStep(number: 1, title: "Finish / confirm Ejari", detail: "For a normal Dubai tenant journey, have the valid Ejari number ready.")
                    GuideNumberedStep(number: 2, title: "Open DEWA Move-In", detail: "Existing customers can sign in with UAE PASS or DEWA ID; DEWA also provides a New Customer in Dubai route.")
                    GuideNumberedStep(number: 3, title: "Enter the requested premise / customer information", detail: "Use the real details from Ejari / DEWA — do not guess premise numbers.")
                    GuideNumberedStep(number: 4, title: "Pay security deposit and activation fees", detail: "Pay only on an official DEWA channel and keep the receipt.")
                    GuideNumberedStep(number: 5, title: "Keep the reference number", detail: "DEWA provides an on-screen confirmation and tracking reference after submission.")
                    GuideNumberedStep(number: 6, title: "Check the supply is active", detail: "DEWA states connection is within 15 working hours after required payment; use Customer Care if this window passes.")
                    OfficialLinkButton(title: "Open official DEWA Move-In", url: "https://www.dewa.gov.ae/en/about-us/service-guide/consumer-services/move-in", tint: .blue)
                }
            }
        }
    }

    private var moveTo: some View {
        Group {
            GuideSurface(title: "Move-To — prepare this", icon: "arrow.left.arrow.right", tint: .indigo) {
                VStack(spacing: 9) {
                    GuideBullet("Your existing DEWA contract account / current premise details.")
                    GuideBullet("Valid new Ejari and the new premise information.")
                    GuideBullet("Your chosen old-premise move-out date and new-premise move-in date.")
                    GuideBullet("Settle outstanding amounts and any security-deposit difference DEWA requires before submission.", icon: "exclamationmark.circle.fill", tint: .orange)
                }
            }
            GuideSurface(title: "Move-To — step by step", icon: "list.number", tint: .indigo) {
                VStack(spacing: 13) {
                    GuideNumberedStep(number: 1, title: "Open DEWA Move-To", detail: "Use the transfer service rather than separately guessing at Move-In / Move-Out.", tint: .indigo)
                    GuideNumberedStep(number: 2, title: "Select your current account", detail: "Confirm the premise you are leaving.", tint: .indigo)
                    GuideNumberedStep(number: 3, title: "Enter the new premise / Ejari information", detail: "Use the new registered tenancy details.", tint: .indigo)
                    GuideNumberedStep(number: 4, title: "Choose the two dates", detail: "Set the old-premise deactivation and new-premise activation around your real handover/occupancy plan.", tint: .indigo)
                    GuideNumberedStep(number: 5, title: "Pay any required balance / deposit difference", detail: "Review the official calculation before payment.", tint: .indigo)
                    GuideNumberedStep(number: 6, title: "Save the tracking confirmation", detail: "Then verify the old and new premise status separately.", tint: .indigo)
                    OfficialLinkButton(title: "Open official DEWA Move-To", url: "https://www.dewa.gov.ae/en/about-us/service-guide/consumer-services/move-to", tint: .indigo)
                }
            }
        }
    }

    private var moveOut: some View {
        Group {
            GuideSurface(title: "Move-Out — before you submit", icon: "bolt.slash.fill", tint: .orange) {
                VStack(spacing: 9) {
                    GuideBullet("Choose the actual deactivation date carefully — do not shut utilities off before you still need the home for inspection / handover.", icon: "exclamationmark.triangle.fill", tint: .orange)
                    GuideBullet("Pay outstanding bills as required by DEWA.")
                    GuideBullet("If using an IBAN for refund, DEWA may require proof showing the beneficiary matches the DEWA customer.")
                }
            }
            GuideSurface(title: "Move-Out — step by step", icon: "list.number", tint: .orange) {
                VStack(spacing: 13) {
                    GuideNumberedStep(number: 1, title: "Open DEWA Move-Out", detail: "Select the premise/account you are leaving.", tint: .orange)
                    GuideNumberedStep(number: 2, title: "Choose disconnection date and time", detail: "Anchor this to your real handover plan.", tint: .orange)
                    GuideNumberedStep(number: 3, title: "Choose refund method", detail: "Follow DEWA's live instructions for security-deposit credit/refund.", tint: .orange)
                    GuideNumberedStep(number: 4, title: "Submit and save request number", detail: "Keep the SMS/email/reference in your move records.", tint: .orange)
                    GuideNumberedStep(number: 5, title: "Receive and settle final bill", detail: "DEWA states final bill is issued within 24 working hours from the requested disconnection date/time.", tint: .orange)
                    GuideNumberedStep(number: 6, title: "Keep the clearance confirmation", detail: "DEWA states a clearance certificate is generated after final-bill settlement.", tint: .orange)
                    OfficialLinkButton(title: "Open official DEWA Move-Out", url: "https://www.dewa.gov.ae/en/about-us/service-guide/consumer-services/move-out", tint: .orange)
                }
            }
        }
    }
}

// MARK: - Telecom guide

struct TelecomGuidedView: View {
    @State private var provider = "du"

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                GuideHero(
                    eyebrow: "Home internet & connectivity",
                    title: "Internet",
                    subtitle: "Choose your provider, follow its real relocation/setup route, call support when needed and find a nearby branch from your location.",
                    icon: "wifi.router.fill",
                    colors: [.purple, .indigo, .blue]
                )

                Picker("Provider", selection: $provider) {
                    Text("du").tag("du")
                    Text("e&").tag("e&")
                    Text("Virgin").tag("Virgin")
                }.pickerStyle(.segmented)

                if provider == "du" { duGuide }
                else if provider == "e&" { etisalatGuide }
                else { virginGuide }

                VerifiedFooter(source: "official du, e& UAE and Virgin Mobile UAE support/service pages")
            }
            .padding(16).padding(.bottom, 90)
        }
        .background(Color(uiColor: .systemGroupedBackground).ignoresSafeArea())
        .navigationTitle("Internet Guide")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var duGuide: some View {
        Group {
            GuideSurface(title: "du — moving an existing Home service", icon: "wifi", tint: .blue) {
                VStack(spacing: 10) {
                    GuideBullet("Use du App or My Account for the official home-relocation flow.", tint: .blue)
                    GuideBullet("du says to upload the new tenancy contract/title deed; proof of relationship may be needed if the tenancy is not in your name.", tint: .blue)
                    GuideBullet("du currently lists a AED 100 relocation fee on the next bill and says an agent contacts you within 24 hours to arrange installation, subject to technician availability.", icon: "banknote", tint: .orange)
                    OfficialLinkButton(title: "Open du Home relocation", url: "https://www.du.ae/personal/at-home/moving-to-a-new-home", tint: .blue)
                    PhoneButton(label: "du customer care", number: "155", tint: .blue)
                }
            }
            NearbyGuidePlacesView(title: "Nearest du stores", query: "du store", icon: "mappin.and.ellipse")
        }
    }

    private var etisalatGuide: some View {
        Group {
            GuideSurface(title: "e& — Home Move", icon: "wifi.router.fill", tint: .green) {
                VStack(spacing: 11) {
                    GuideNumberedStep(number: 1, title: "Open the e& UAE app", detail: "Go to Home → Manage → Home Move → Get Started.", tint: .green)
                    GuideNumberedStep(number: 2, title: "Find the new location", detail: "The official flow supports location/map information and other premise identifiers shown by e&.", tint: .green)
                    GuideNumberedStep(number: 3, title: "Set move-out and move-in dates", detail: "Choose the dates that match your handover and access plan.", tint: .green)
                    GuideNumberedStep(number: 4, title: "Choose the available appointment", detail: "Review the installation visit / availability offered by e&.", tint: .green)
                    GuideNumberedStep(number: 5, title: "Review and submit", detail: "Keep the order/reference and re-check your service status before move day.", tint: .green)
                    OfficialLinkButton(title: "Open e& home support", url: "https://www.etisalat.ae/en/c/support/home.html", tint: .green)
                    PhoneButton(label: "e& customer care", number: "101", tint: .green)
                    PhoneButton(label: "From a non-e& line", number: "800101", tint: .green)
                }
            }
            NearbyGuidePlacesView(title: "Nearest e& stores", query: "e& Etisalat store", icon: "mappin.and.ellipse")
        }
    }

    private var virginGuide: some View {
        Group {
            GuideSurface(title: "Virgin Mobile UAE — Home Internet", icon: "antenna.radiowaves.left.and.right", tint: .red) {
                VStack(spacing: 10) {
                    GuideBullet("Virgin Mobile UAE offers Home Internet as mobile broadband / 5G home connectivity. It is different from a fixed-fibre relocation journey.", tint: .red)
                    GuideBullet("Check current plan/device coverage for your exact home before you rely on it as your move-day connection.", icon: "location.magnifyingglass", tint: .orange)
                    GuideBullet("Virgin publishes a Home Internet setup guide; customer support is also available through the Virgin Mobile app.", tint: .red)
                    OfficialLinkButton(title: "Open Virgin Home Internet setup", url: "https://www.virginmobile.ae/home-internet-setup/", tint: .red)
                }
            }
            NearbyGuidePlacesView(title: "Nearest Virgin Mobile stores", query: "Virgin Mobile UAE store", icon: "mappin.and.ellipse")
        }
    }
}

// MARK: - Cooling guide

struct CoolingGuidedView: View {
    @AppStorage("dubaimove.guide.cooling.arrangement") private var arrangement = "Not sure"
    @AppStorage("dubaimove.guide.cooling.provider") private var provider = "Not sure"

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                GuideHero(
                    eyebrow: "Check before opening an account",
                    title: "Cooling",
                    subtitle: "Some homes need a separate district-cooling account. Others have cooling included. Dubai Move first helps you identify which situation you actually have.",
                    icon: "snowflake",
                    colors: [.teal, .cyan, .blue]
                )

                GuideSurface(title: "How is cooling handled in your home?", icon: "questionmark.diamond.fill", tint: .cyan) {
                    VStack(spacing: 10) {
                        Picker("Cooling arrangement", selection: $arrangement) {
                            Text("Not sure").tag("Not sure")
                            Text("Chiller free").tag("Chiller free")
                            Text("Separate bill").tag("Separate bill")
                        }.pickerStyle(.segmented)
                        Text("Use your tenancy contract / building management confirmation. Dubai Move will not guess the building's cooling arrangement.").font(.caption).foregroundStyle(.secondary)
                    }
                }

                if arrangement == "Chiller free" { chillerFree }
                else if arrangement == "Separate bill" { separateCooling }
                else { unknownCooling }

                VerifiedFooter(source: "official Empower and Emicool customer information; building-specific arrangements must be confirmed with your property/building management")
            }
            .padding(16).padding(.bottom, 90)
        }
        .background(Color(uiColor: .systemGroupedBackground).ignoresSafeArea())
        .navigationTitle("Cooling Guide")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var chillerFree: some View {
        GuideSurface(title: "Cooling included / chiller-free", icon: "checkmark.circle.fill", tint: DMTheme.green) {
            VStack(spacing: 9) {
                GuideBullet("If your tenancy/building management confirms cooling is included and no separate district-cooling account is required, you can skip a separate Empower/Emicool registration.")
                GuideBullet("Still confirm what 'included' covers and who you contact if cooling is not working.", icon: "info.circle.fill", tint: .orange)
            }
        }
    }

    private var unknownCooling: some View {
        GuideSurface(title: "Find out before you register", icon: "magnifyingglass", tint: .orange) {
            VStack(spacing: 9) {
                GuideBullet("Check the tenancy contract for cooling/chiller wording.", tint: .orange)
                GuideBullet("Ask building management: Is cooling included? If not, who is the district-cooling provider?", tint: .orange)
                GuideBullet("Check any previous cooling bill / handover pack for the provider name.", tint: .orange)
                NavigationLink(destination: BuildingGuidedView()) {
                    HStack { Text("Open Building Access guide").bold(); Spacer(); Image(systemName: "chevron.right") }
                        .foregroundStyle(.orange).padding(12).background(.orange.opacity(0.09)).clipShape(RoundedRectangle(cornerRadius: 13))
                }.buttonStyle(.plain)
            }
        }
    }

    private var separateCooling: some View {
        Group {
            GuideSurface(title: "Who is the provider?", icon: "building.2.fill", tint: .cyan) {
                Picker("Provider", selection: $provider) {
                    Text("Not sure").tag("Not sure")
                    Text("Empower").tag("Empower")
                    Text("Emicool").tag("Emicool")
                    Text("Other").tag("Other")
                }.pickerStyle(.segmented)
            }
            if provider == "Empower" { empower }
            else if provider == "Emicool" { emicool }
            else if provider == "Other" {
                GuideSurface(title: "Building-specific provider", icon: "info.circle.fill", tint: .orange) {
                    Text("Ask building management for the exact provider name and official onboarding channel. Do not create an Empower or Emicool account unless your building confirms that provider.").font(.subheadline).foregroundStyle(.secondary)
                }
            } else { unknownCooling }
        }
    }

    private var empower: some View {
        GuideSurface(title: "Empower tenant setup", icon: "snowflake", tint: .cyan) {
            VStack(spacing: 10) {
                GuideBullet("Empower currently lists tenant documents including tenancy contract, Ejari, visa and Emirates ID front/back.")
                GuideBullet("Empower says registration charges depend on the project/building and are shown during online registration; published processing is 1–3 working days.")
                GuideBullet("Keep the confirmation email/SMS and new account number after activation.")
                OfficialLinkButton(title: "Open Empower official site", url: "https://www.empower.ae/", tint: .cyan)
                PhoneButton(label: "Empower Customer Care", number: "+971 4 559 2888", tint: .cyan)
            }
        }
    }

    private var emicool: some View {
        GuideSurface(title: "Emicool tenant setup", icon: "snowflake", tint: .blue) {
            VStack(spacing: 10) {
                GuideBullet("Emicool currently lists tenant items including Ejari, passport copy, Emirates ID copy, mobile/email and updated IBAN.")
                GuideBullet("Emicool's official customer information currently lists a AED 200 activation fee; security deposit / connection charges can depend on the contracted capacity and case — confirm the live amount before payment.", icon: "banknote", tint: .orange)
                OfficialLinkButton(title: "Open Emicool customer portal", url: "https://www.emicool.com/en/customers", tint: .blue)
                PhoneButton(label: "Emicool Customer Care", number: "600 534440", tint: .blue)
            }
        }
    }
}

// MARK: - Building move permit / access guide

struct BuildingGuidedView: View {
    @AppStorage("dubaimove.v2.buildingPhone") private var phone = ""
    @AppStorage("dubaimove.v2.buildingEmail") private var email = ""
    @AppStorage("dubaimove.v2.buildingPortal") private var portal = ""
    @AppStorage("dubaimove.v2.buildingNotes") private var notes = ""
    @Environment(\.openURL) private var openURL

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                GuideHero(
                    eyebrow: "Building-specific",
                    title: "Move Permit & Access",
                    subtitle: "Your building can decide lift slots, loading access, mover documents and deposits. Confirm these before locking in the mover time.",
                    icon: "building.2.fill",
                    colors: [.orange, .pink, .purple]
                )

                GuideSurface(title: "Ask management these exact questions", icon: "text.bubble.fill", tint: .orange) {
                    VStack(spacing: 9) {
                        GuideBullet("Do I need a move-in / move-out permit or NOC?", tint: .orange)
                        GuideBullet("How do I reserve the service lift and loading bay?", tint: .orange)
                        GuideBullet("What days and hours are movers allowed?", tint: .orange)
                        GuideBullet("Do you need the mover's trade licence, insurance, vehicle details or staff IDs?", tint: .orange)
                        GuideBullet("Is there an access / move deposit, and how is it refunded?", tint: .orange)
                        GuideBullet("Where should the truck enter and where do I collect keys/access cards?", tint: .orange)
                    }
                }

                GuideSurface(title: "Save your building contact", icon: "person.crop.circle.badge.checkmark", tint: .purple) {
                    VStack(spacing: 10) {
                        TextField("Management phone", text: $phone).keyboardType(.phonePad).textFieldStyle(.roundedBorder)
                        TextField("Management email", text: $email).keyboardType(.emailAddress).textInputAutocapitalization(.never).textFieldStyle(.roundedBorder)
                        TextField("Official / verified building portal URL", text: $portal).keyboardType(.URL).textInputAutocapitalization(.never).textFieldStyle(.roundedBorder)
                        TextField("Permit, lift, loading and access notes", text: $notes, axis: .vertical).lineLimit(4...8).textFieldStyle(.roundedBorder)
                        HStack {
                            Button("Call") {
                                let clean = phone.filter { "+0123456789".contains($0) }
                                if let url = URL(string: "tel:\(clean)") { openURL(url) }
                            }.disabled(phone.isEmpty)
                            Spacer()
                            Button("Email") {
                                if let url = URL(string: "mailto:\(email)") { openURL(url) }
                            }.disabled(!email.contains("@"))
                        }
                        .buttonStyle(.bordered).tint(.purple)
                    }
                }

                GuideSurface(title: "Correct order", icon: "arrow.down", tint: .orange) {
                    VStack(spacing: 12) {
                        GuideNumberedStep(number: 1, title: "Confirm the building requirements", detail: "Get the real rules from management; do not rely on another building's process.", tint: .orange)
                        GuideNumberedStep(number: 2, title: "Prepare requested mover / tenancy documents", detail: "Only collect what your building actually asks for.", tint: .orange)
                        GuideNumberedStep(number: 3, title: "Get permit / reserve lift", detail: "Record the approved time window and loading instructions.", tint: .orange)
                        GuideNumberedStep(number: 4, title: "Then confirm the mover slot", detail: "Make the provider booking fit the building's approved access window.", tint: .orange)
                    }
                }

                Text("Building rules are private-property operational requirements and vary by property. Dubai Move stores your confirmed details; it does not invent a permit portal or claim approval.")
                    .font(.caption).foregroundStyle(.secondary).padding(14).background(.orange.opacity(0.08)).clipShape(RoundedRectangle(cornerRadius: 16))
            }
            .padding(16).padding(.bottom, 90)
        }
        .background(Color(uiColor: .systemGroupedBackground).ignoresSafeArea())
        .navigationTitle("Building Access")
        .navigationBarTitleDisplayMode(.inline)
    }
}
