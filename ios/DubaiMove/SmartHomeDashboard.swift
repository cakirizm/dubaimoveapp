import SwiftUI

struct SmartHomeDashboardView: View {
    @EnvironmentObject private var state: AppState
    @AppStorage("dubaimove.v2.moveKind") private var moveKind = LocalMoveKind.withinDubai.rawValue
    @AppStorage("dubaimove.v2.currentArea") private var currentArea = ""
    @AppStorage("dubaimove.v2.newArea") private var newArea = ""
    @AppStorage("dubaimove.v2.moveDate") private var moveDateEpoch = Date().addingTimeInterval(86400 * 21).timeIntervalSince1970

    private var plan: PremiumMovePlan { PremiumMovePlan.plan(for: moveKind) }

    private var readiness: Int {
        let completed = plan.steps.filter { UserDefaults.standard.bool(forKey: $0.storageKey) }.count
        guard !plan.steps.isEmpty else { return 0 }
        return Int((Double(completed) / Double(plan.steps.count) * 100).rounded())
    }

    private var currentHome: String { currentArea.isEmpty ? "Motor City" : currentArea }
    private var newHome: String { newArea.isEmpty ? "The Greens" : newArea }

    var body: some View {
        GeometryReader { proxy in
            let horizontalPadding: CGFloat = 16
            let contentWidth = max(0, proxy.size.width - horizontalPadding * 2)

            ScrollView(.vertical, showsIndicators: true) {
                VStack(alignment: .leading, spacing: 20) {
                    brandHeader(width: contentWidth)
                    heroCard(width: contentWidth)
                    quickActions(width: contentWidth)
                    nextStep
                    officialEssentials(width: contentWidth)
                }
                .frame(width: contentWidth, alignment: .leading)
                .padding(.horizontal, horizontalPadding)
                .padding(.top, 10)
                .padding(.bottom, 110)
            }
            .frame(width: proxy.size.width)
            .clipped()
            .background(Color(uiColor: .systemGroupedBackground).ignoresSafeArea())
        }
        .navigationBarTitleDisplayMode(.inline)
        .task { state.readiness = readiness }
    }

    private func brandHeader(width: CGFloat) -> some View {
        HStack(spacing: 13) {
            Image("BrandLogo")
                .resizable()
                .scaledToFit()
                .frame(width: 64, height: 64)
                .fixedSize()

            VStack(alignment: .leading, spacing: 2) {
                HStack(alignment: .firstTextBaseline, spacing: 5) {
                    Text("Dubai")
                        .font(.system(size: 34, weight: .black, design: .rounded))
                        .kerning(-1.2)
                        .foregroundStyle(DMTheme.ink)
                    Text("Move")
                        .font(.system(size: 34, weight: .black, design: .rounded))
                        .kerning(-1.0)
                        .foregroundStyle(DMTheme.greenDeep)
                }
                .lineLimit(1)
                .minimumScaleFactor(0.82)

                Text("Your move, organized.")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundStyle(.secondary)
            }
            .layoutPriority(1)

            Spacer(minLength: 6)

            NavigationLink(destination: FunctionalV2MoreView()) {
                ZStack {
                    Circle().fill(.white)
                    Circle().stroke(Color.black.opacity(0.06), lineWidth: 1)
                    Image(systemName: "person.crop.circle.fill")
                        .font(.system(size: 30, weight: .semibold))
                        .foregroundStyle(DMTheme.greenDeep)
                }
                .frame(width: 52, height: 52)
                .shadow(color: .black.opacity(0.07), radius: 10, y: 4)
            }
            .buttonStyle(.plain)
            .fixedSize()
        }
        .frame(width: width, alignment: .leading)
    }

    private func heroCard(width: CGFloat) -> some View {
        let compact = width < 370
        let heroHeight: CGFloat = compact ? 398 : 420
        let summaryWidth = min(max(width * 0.43, 146), 174)
        let ctaWidth = min(max(width * 0.47, 166), 194)

        return ZStack {
            AsyncImage(url: URL(string: "https://images.unsplash.com/photo-1512453979798-5ea266f8880c?auto=format&fit=crop&w=1600&q=92")) { phase in
                switch phase {
                case .success(let image):
                    image
                        .resizable()
                        .scaledToFill()
                        .frame(width: width, height: heroHeight)
                        .clipped()
                default:
                    LinearGradient(
                        colors: [Color(red: 0.91, green: 0.97, blue: 0.99), Color(red: 1.0, green: 0.94, blue: 0.85)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                }
            }
            .frame(width: width, height: heroHeight)
            .clipped()

            LinearGradient(
                stops: [
                    .init(color: .white.opacity(0.96), location: 0.00),
                    .init(color: .white.opacity(0.80), location: 0.34),
                    .init(color: .white.opacity(0.22), location: 0.61),
                    .init(color: .clear, location: 0.82)
                ],
                startPoint: .leading,
                endPoint: .trailing
            )

            LinearGradient(
                colors: [.clear, .black.opacity(0.04), .black.opacity(0.10)],
                startPoint: .top,
                endPoint: .bottom
            )

            VStack(alignment: .leading, spacing: 11) {
                Text(heroTitle)
                    .font(.system(size: compact ? 31 : 35, weight: .black, design: .rounded))
                    .kerning(-0.9)
                    .foregroundStyle(Color(red: 0.01, green: 0.16, blue: 0.13))
                    .lineLimit(3)
                    .minimumScaleFactor(0.80)
                    .frame(width: width * (compact ? 0.66 : 0.62), alignment: .leading)

                Text("All your move tasks, services and official steps in one place.")
                    .font(.system(size: compact ? 14 : 16, weight: .medium))
                    .foregroundStyle(DMTheme.ink.opacity(0.82))
                    .lineLimit(3)
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(width: width * 0.61, alignment: .leading)

                Spacer()
            }
            .padding(.leading, 20)
            .padding(.top, 24)
            .padding(.trailing, 16)
            .padding(.bottom, 18)
            .frame(width: width, height: heroHeight, alignment: .topLeading)

            weatherChip
                .scaleEffect(compact ? 0.90 : 1, anchor: .topTrailing)
                .padding(.top, 18)
                .padding(.trailing, 14)
                .frame(width: width, height: heroHeight, alignment: .topTrailing)

            NavigationLink(destination: SmartMoveCommandCenterView()) {
                HStack(spacing: 9) {
                    Text("Start My Move").lineLimit(1)
                    Image(systemName: "arrow.right")
                }
                .font(.system(size: compact ? 16 : 17, weight: .bold))
                .foregroundStyle(.white)
                .frame(width: ctaWidth, height: 60)
                .background(
                    LinearGradient(colors: [DMTheme.greenDeep, DMTheme.green], startPoint: .leading, endPoint: .trailing)
                )
                .clipShape(RoundedRectangle(cornerRadius: 19, style: .continuous))
                .overlay(RoundedRectangle(cornerRadius: 19).stroke(.white.opacity(0.12), lineWidth: 1))
                .shadow(color: DMTheme.greenDeep.opacity(0.25), radius: 12, y: 5)
            }
            .buttonStyle(.plain)
            .padding(.leading, 18)
            .padding(.bottom, 18)
            .frame(width: width, height: heroHeight, alignment: .bottomLeading)

            moveSummaryCard(width: summaryWidth)
                .padding(.trailing, 14)
                .padding(.bottom, 14)
                .frame(width: width, height: heroHeight, alignment: .bottomTrailing)
        }
        .frame(width: width, height: heroHeight)
        .clipped()
        .clipShape(RoundedRectangle(cornerRadius: 30, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 30).stroke(Color.white.opacity(0.55), lineWidth: 1))
        .shadow(color: .black.opacity(0.10), radius: 18, y: 9)
        .contentShape(RoundedRectangle(cornerRadius: 30, style: .continuous))
    }

    private var weatherChip: some View {
        HStack(spacing: 9) {
            Image(systemName: "sun.max.fill")
                .font(.system(size: 20, weight: .semibold))
                .foregroundStyle(.orange)
            VStack(alignment: .leading, spacing: 1) {
                Text("32°C")
                    .font(.system(size: 15, weight: .heavy))
                    .foregroundStyle(DMTheme.ink)
                Text("Dubai")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.horizontal, 13)
        .padding(.vertical, 11)
        .background(.ultraThinMaterial)
        .background(.white.opacity(0.70))
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 18).stroke(.white.opacity(0.75), lineWidth: 1))
        .shadow(color: .black.opacity(0.07), radius: 10, y: 4)
    }

    private func moveSummaryCard(width: CGFloat) -> some View {
        VStack(alignment: .leading, spacing: 11) {
            moveSummaryRow(icon: "house.fill", tint: DMTheme.green, label: "Current Home", value: currentHome)
            Divider().opacity(0.45)
            moveSummaryRow(icon: "mappin.circle.fill", tint: .red, label: "New Home", value: newHome)
            Divider().opacity(0.45)
            moveSummaryRow(icon: "calendar", tint: DMTheme.green, label: "Move Date", value: Date(timeIntervalSince1970: moveDateEpoch).formatted(date: .abbreviated, time: .omitted))
        }
        .padding(13)
        .frame(width: width)
        .background(.ultraThinMaterial)
        .background(.white.opacity(0.76))
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 22).stroke(.white.opacity(0.82), lineWidth: 1))
        .shadow(color: .black.opacity(0.10), radius: 13, y: 5)
    }

    private func moveSummaryRow(icon: String, tint: Color, label: String, value: String) -> some View {
        HStack(alignment: .center, spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 13, weight: .bold))
                .foregroundStyle(tint)
                .frame(width: 22, height: 22)
                .background(tint.opacity(0.10))
                .clipShape(RoundedRectangle(cornerRadius: 7))
            VStack(alignment: .leading, spacing: 1) {
                Text(label)
                    .font(.system(size: 9, weight: .semibold))
                    .foregroundStyle(.secondary)
                Text(value)
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(DMTheme.ink)
                    .lineLimit(1)
                    .minimumScaleFactor(0.70)
            }
        }
    }

    private func quickActions(width: CGFloat) -> some View {
        let spacing: CGFloat = 12
        let cardWidth = max(0, (width - spacing) / 2)
        let columns = [
            GridItem(.fixed(cardWidth), spacing: spacing),
            GridItem(.fixed(cardWidth), spacing: spacing)
        ]

        return VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Quick actions")
                    .font(.system(size: 25, weight: .heavy, design: .rounded))
                    .foregroundStyle(DMTheme.ink)
                Spacer()
                Button { state.selectedTab = .services } label: {
                    HStack(spacing: 4) {
                        Text("See all")
                        Image(systemName: "chevron.right")
                    }
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
            }

            LazyVGrid(columns: columns, spacing: 12) {
                quickAction("Book a Service", "Cleaning, Moving...", "truck.box.fill", .orange, width: cardWidth) { state.selectedTab = .services }
                quickAction("Official Guides", "Ejari, DEWA, internet...", "map.fill", .green, width: cardWidth) { state.selectedTab = .move }
                quickAction("Buy Supplies", "Boxes, packing...", "shippingbox.fill", .blue, width: cardWidth) { state.selectedTab = .services }
                quickAction("Edit Move", "Areas & date", "building.2.fill", .purple, width: cardWidth) { state.selectedTab = .move }
            }
            .frame(width: width)
        }
        .frame(width: width, alignment: .leading)
    }

    private func quickAction(_ title: String, _ subtitle: String, _ icon: String, _ tint: Color, width: CGFloat, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 11) {
                Image(systemName: icon)
                    .font(.system(size: 19, weight: .bold))
                    .foregroundStyle(tint)
                    .frame(width: 48, height: 48)
                    .background(tint.opacity(0.12))
                    .clipShape(RoundedRectangle(cornerRadius: 15))

                VStack(alignment: .leading, spacing: 3) {
                    Text(title)
                        .font(.system(size: 13, weight: .bold))
                        .foregroundStyle(DMTheme.ink)
                        .lineLimit(2)
                        .minimumScaleFactor(0.80)
                    Text(subtitle)
                        .font(.system(size: 10.5, weight: .medium))
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                        .minimumScaleFactor(0.80)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(13)
            .frame(width: width, alignment: .leading)
            .frame(minHeight: 92, alignment: .leading)
            .background(.white)
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color.black.opacity(0.04), lineWidth: 1))
            .shadow(color: .black.opacity(0.035), radius: 9, y: 4)
        }
        .buttonStyle(.plain)
    }

    private var nextStep: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("Next step")
                    .font(.system(size: 25, weight: .heavy, design: .rounded))
                Spacer()
                Text("\(completedCount) of \(plan.steps.count)")
                    .font(.caption.bold())
                    .foregroundStyle(DMTheme.greenDeep)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(DMTheme.mint)
                    .clipShape(Capsule())
            }

            NavigationLink(destination: SmartMoveCommandCenterView()) {
                HStack(spacing: 14) {
                    Image(systemName: nextStepItem?.icon ?? "checkmark.circle.fill")
                        .font(.title2.bold())
                        .foregroundStyle(DMTheme.green)
                        .frame(width: 48, height: 48)
                        .background(DMTheme.mint)
                        .clipShape(RoundedRectangle(cornerRadius: 15))
                    VStack(alignment: .leading, spacing: 4) {
                        Text(nextStepItem?.title ?? "Move plan complete")
                            .font(.headline)
                            .foregroundStyle(DMTheme.ink)
                        Text(nextStepItem?.note ?? "Review your move plan and keep your records together.")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .lineLimit(3)
                    }
                    Spacer(minLength: 4)
                    Image(systemName: "chevron.right").foregroundStyle(.secondary)
                }
                .padding(16)
                .background(.white)
                .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
                .overlay(RoundedRectangle(cornerRadius: 22).stroke(Color.black.opacity(0.04), lineWidth: 1))
                .shadow(color: .black.opacity(0.04), radius: 9, y: 4)
            }
            .buttonStyle(.plain)
        }
    }

    private func officialEssentials(width: CGFloat) -> some View {
        let spacing: CGFloat = 12
        let cardWidth = max(0, (width - spacing) / 2)
        let columns = [GridItem(.fixed(cardWidth), spacing: spacing), GridItem(.fixed(cardWidth), spacing: spacing)]

        return VStack(alignment: .leading, spacing: 11) {
            VStack(alignment: .leading, spacing: 3) {
                Text("Official essentials")
                    .font(.system(size: 25, weight: .heavy, design: .rounded))
                Text("Beginner guides with verified channels, phone support and nearby locations where relevant.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            LazyVGrid(columns: columns, spacing: 12) {
                NavigationLink(destination: EjariGuidedView()) {
                    officialCard(title: "Ejari", subtitle: "DLD · docs · fees · locations", icon: "doc.text.fill", colors: [DMTheme.greenDeep, DMTheme.green], width: cardWidth)
                }
                NavigationLink(destination: DewaGuidedView()) {
                    officialCard(title: "DEWA", subtitle: "Move-In · Move-To · Move-Out", icon: "bolt.fill", colors: [.blue, .cyan], width: cardWidth)
                }
                NavigationLink(destination: TelecomGuidedView()) {
                    officialCard(title: "Internet", subtitle: "du · e& · Virgin · nearby stores", icon: "wifi", colors: [.purple, .indigo], width: cardWidth)
                }
                NavigationLink(destination: CoolingGuidedView()) {
                    officialCard(title: "Cooling", subtitle: "Chiller free? · Empower · Emicool", icon: "snowflake", colors: [.cyan, .teal], width: cardWidth)
                }
                NavigationLink(destination: BuildingGuidedView()) {
                    officialCard(title: "Building", subtitle: "Permit · lift · access · contacts", icon: "building.2.fill", colors: [.orange, .pink], width: cardWidth)
                }
                NavigationLink(destination: SmartMoveCommandCenterView()) {
                    officialCard(title: "Full Guide", subtitle: "Every move step in the right order", icon: "map.fill", colors: [DMTheme.green, .teal], width: cardWidth)
                }
            }
            .buttonStyle(.plain)
            .frame(width: width)
        }
        .frame(width: width, alignment: .leading)
    }

    private func officialCard(title: String, subtitle: String, icon: String, colors: [Color], width: CGFloat) -> some View {
        ZStack(alignment: .bottomLeading) {
            LinearGradient(colors: colors, startPoint: .topLeading, endPoint: .bottomTrailing)
            Image(systemName: icon)
                .font(.system(size: 62, weight: .thin))
                .foregroundStyle(.white.opacity(0.18))
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
                .padding(13)
            VStack(alignment: .leading, spacing: 4) {
                Text(title).font(.title3.bold())
                Text(subtitle).font(.caption).lineLimit(2)
            }
            .foregroundStyle(.white)
            .padding(15)
        }
        .frame(width: width, height: 122)
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
        .shadow(color: colors.first?.opacity(0.18) ?? .clear, radius: 8, y: 4)
    }

    private var completedCount: Int {
        plan.steps.filter { UserDefaults.standard.bool(forKey: $0.storageKey) }.count
    }

    private var nextStepItem: PremiumMoveStep? {
        plan.steps.first { !UserDefaults.standard.bool(forKey: $0.storageKey) }
    }

    private var heroTitle: String {
        switch moveKind {
        case LocalMoveKind.toDubai.rawValue: return "Move to Dubai with confidence"
        case LocalMoveKind.leavingDubai.rawValue: return "Leave Dubai with confidence"
        case LocalMoveKind.serviceOnly.rawValue: return "Get your home sorted with confidence"
        default: return "Move across Dubai with confidence"
        }
    }
}
