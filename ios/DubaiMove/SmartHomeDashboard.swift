import SwiftUI

struct SmartHomeDashboardView: View {
    @EnvironmentObject private var state: AppState
    @AppStorage("dubaimove.v2.moveKind") private var moveKind = LocalMoveKind.withinDubai.rawValue
    @AppStorage("dubaimove.v2.currentArea") private var currentArea = ""
    @AppStorage("dubaimove.v2.newArea") private var newArea = ""
    @AppStorage("dubaimove.v2.moveDate") private var moveDateEpoch = Date().addingTimeInterval(86400 * 21).timeIntervalSince1970

    @State private var appeared = false

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
                    premiumHero(width: contentWidth)
                    quickActions(width: contentWidth)
                    nextStep
                    officialEssentials(width: contentWidth)
                }
                .frame(width: contentWidth, alignment: .leading)
                .padding(.horizontal, horizontalPadding)
                .padding(.top, 8)
                .padding(.bottom, 110)
            }
            .frame(width: proxy.size.width)
            .clipped()
            .background(Color(uiColor: .systemGroupedBackground).ignoresSafeArea())
        }
        .navigationBarTitleDisplayMode(.inline)
        .task {
            state.readiness = readiness
            guard !appeared else { return }
            withAnimation(.easeOut(duration: 0.52)) { appeared = true }
        }
    }

    private func premiumHero(width: CGFloat) -> some View {
        let compact = width < 370
        let heroHeight: CGFloat = compact ? 520 : 560
        let logoSize: CGFloat = compact ? 58 : 64
        let titleWidth = width * (compact ? 0.72 : 0.69)
        let ctaWidth = min(max(width * 0.54, 190), 228)
        let infoWidth = min(max(width * 0.38, 132), 158)

        return ZStack {
            AsyncImage(url: URL(string: "https://images.unsplash.com/photo-1512453979798-5ea266f8880c?auto=format&fit=crop&w=1800&q=94")) { phase in
                switch phase {
                case .success(let image):
                    image
                        .resizable()
                        .scaledToFill()
                        .frame(width: width, height: heroHeight)
                        .clipped()
                default:
                    LinearGradient(
                        colors: [
                            Color(red: 0.93, green: 0.98, blue: 1.00),
                            Color(red: 0.98, green: 0.97, blue: 0.91),
                            Color(red: 1.00, green: 0.92, blue: 0.78)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                }
            }
            .frame(width: width, height: heroHeight)
            .clipped()

            LinearGradient(
                stops: [
                    .init(color: .white.opacity(0.95), location: 0.00),
                    .init(color: .white.opacity(0.80), location: 0.24),
                    .init(color: .white.opacity(0.36), location: 0.47),
                    .init(color: .clear, location: 0.72)
                ],
                startPoint: .leading,
                endPoint: .trailing
            )

            LinearGradient(
                colors: [.white.opacity(0.30), .clear, .black.opacity(0.12)],
                startPoint: .top,
                endPoint: .bottom
            )

            VStack(spacing: 0) {
                HStack(spacing: 12) {
                    Image("BrandLogo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: logoSize, height: logoSize)
                        .scaleEffect(appeared ? 1 : 0.96)
                        .opacity(appeared ? 1 : 0)

                    VStack(alignment: .leading, spacing: 1) {
                        HStack(alignment: .firstTextBaseline, spacing: 2) {
                            Text("Dubai")
                                .font(.system(size: compact ? 31 : 36, weight: .black, design: .serif))
                                .foregroundStyle(Color(red: 0.02, green: 0.10, blue: 0.10))
                                .kerning(-1.1)
                            Text("Move")
                                .font(.system(size: compact ? 31 : 36, weight: .bold, design: .serif))
                                .italic()
                                .foregroundStyle(DMTheme.greenDeep)
                                .kerning(-1.2)
                        }
                        .lineLimit(1)
                        .minimumScaleFactor(0.80)

                        Text("Your move, organized.")
                            .font(.system(size: compact ? 13 : 14, weight: .medium))
                            .foregroundStyle(Color.secondary.opacity(0.92))
                    }
                    .layoutPriority(1)
                    .offset(y: appeared ? 0 : 8)
                    .opacity(appeared ? 1 : 0)

                    Spacer(minLength: 8)

                    NavigationLink(destination: FunctionalV2MoreView()) {
                        ZStack {
                            Circle().fill(.white.opacity(0.92))
                            Circle().stroke(.white.opacity(0.85), lineWidth: 1)
                            Image(systemName: "person.crop.circle.fill")
                                .font(.system(size: compact ? 28 : 30, weight: .semibold))
                                .foregroundStyle(DMTheme.greenDeep)
                        }
                        .frame(width: compact ? 50 : 54, height: compact ? 50 : 54)
                        .shadow(color: .black.opacity(0.09), radius: 12, y: 5)
                    }
                    .buttonStyle(.plain)
                }
                .padding(.horizontal, 18)
                .padding(.top, 18)

                Spacer().frame(height: compact ? 48 : 54)

                VStack(alignment: .leading, spacing: 10) {
                    Text("A Smoother")
                        .foregroundStyle(Color(red: 0.02, green: 0.08, blue: 0.09))
                    + Text("\nNew Chapter")
                        .foregroundStyle(DMTheme.greenDeep)
                    + Text("\nin Dubai")
                        .foregroundStyle(Color(red: 0.02, green: 0.08, blue: 0.09))
                }
                .font(.system(size: compact ? 38 : 43, weight: .black, design: .serif))
                .kerning(-1.2)
                .lineSpacing(-2)
                .frame(width: titleWidth, alignment: .leading)
                .offset(x: appeared ? 0 : -10, y: appeared ? 0 : 10)
                .opacity(appeared ? 1 : 0)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.leading, 18)

                Text("Everything you need for a confident move in or out of Dubai.")
                    .font(.system(size: compact ? 15 : 16, weight: .medium))
                    .foregroundStyle(DMTheme.ink.opacity(0.72))
                    .lineLimit(3)
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(width: width * 0.68, alignment: .leading)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.leading, 18)
                    .padding(.top, 14)
                    .offset(y: appeared ? 0 : 10)
                    .opacity(appeared ? 1 : 0)

                Spacer()

                HStack(alignment: .bottom, spacing: 10) {
                    NavigationLink(destination: SmartMoveCommandCenterView()) {
                        HStack(spacing: 12) {
                            Text("Start My Move")
                                .lineLimit(1)
                            Spacer(minLength: 4)
                            Image(systemName: "arrow.right")
                                .font(.system(size: 17, weight: .bold))
                                .frame(width: 40, height: 40)
                                .background(.white.opacity(0.16))
                                .clipShape(Circle())
                        }
                        .font(.system(size: compact ? 17 : 18, weight: .bold))
                        .foregroundStyle(.white)
                        .padding(.leading, 18)
                        .padding(.trailing, 8)
                        .frame(width: ctaWidth, height: 62)
                        .background(
                            LinearGradient(
                                colors: [DMTheme.greenDeep, DMTheme.green],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .clipShape(Capsule())
                        .overlay(Capsule().stroke(.white.opacity(0.45), lineWidth: 1))
                        .shadow(color: DMTheme.greenDeep.opacity(0.28), radius: 14, y: 6)
                    }
                    .buttonStyle(.plain)

                    moveInfoCard(width: infoWidth)
                }
                .padding(.horizontal, 14)
                .padding(.bottom, 16)
                .offset(y: appeared ? 0 : 12)
                .opacity(appeared ? 1 : 0)
            }
            .frame(width: width, height: heroHeight)
        }
        .frame(width: width, height: heroHeight)
        .clipShape(RoundedRectangle(cornerRadius: 30, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 30).stroke(.white.opacity(0.66), lineWidth: 1))
        .shadow(color: .black.opacity(0.11), radius: 20, y: 9)
    }

    private func moveInfoCard(width: CGFloat) -> some View {
        HStack(spacing: 8) {
            Image(systemName: "mappin.and.ellipse")
                .font(.system(size: 18, weight: .bold))
                .foregroundStyle(DMTheme.greenDeep)
                .frame(width: 34, height: 34)
                .background(DMTheme.mint)
                .clipShape(Circle())

            VStack(alignment: .leading, spacing: 2) {
                Text("Dubai")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(DMTheme.ink)
                Text("A smoother move is just a tap away.")
                    .font(.system(size: 9.5, weight: .medium))
                    .foregroundStyle(.secondary)
                    .lineLimit(3)
            }

            Image(systemName: "chevron.right")
                .font(.system(size: 12, weight: .bold))
                .foregroundStyle(DMTheme.ink.opacity(0.7))
        }
        .padding(11)
        .frame(width: width, minHeight: 78)
        .background(.ultraThinMaterial)
        .background(.white.opacity(0.78))
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 22).stroke(.white.opacity(0.82), lineWidth: 1))
        .shadow(color: .black.opacity(0.09), radius: 12, y: 5)
    }

    private func quickActions(width: CGFloat) -> some View {
        let spacing: CGFloat = 12
        let cardWidth = max(0, (width - spacing) / 2)
        let columns = [GridItem(.fixed(cardWidth), spacing: spacing), GridItem(.fixed(cardWidth), spacing: spacing)]

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
                    Image(systemName: "chevron.right")
                        .foregroundStyle(.secondary)
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
}
