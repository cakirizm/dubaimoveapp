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
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                brandHeader
                heroCard
                quickActions
                nextStep
                officialEssentials
            }
            .padding(.horizontal, 16)
            .padding(.top, 8)
            .padding(.bottom, 110)
        }
        .background(Color(uiColor: .systemGroupedBackground).ignoresSafeArea())
        .navigationBarTitleDisplayMode(.inline)
        .task { state.readiness = readiness }
    }

    private var brandHeader: some View {
        HStack(spacing: 12) {
            Image("BrandLogo")
                .resizable()
                .scaledToFit()
                .frame(width: 54, height: 54)

            VStack(alignment: .leading, spacing: 1) {
                HStack(alignment: .firstTextBaseline, spacing: 3) {
                    Text("Dubai")
                        .font(.system(size: 29, weight: .heavy, design: .rounded))
                        .kerning(-0.8)
                        .foregroundStyle(DMTheme.ink)
                    Text("Move")
                        .font(.system(size: 29, weight: .semibold, design: .serif))
                        .italic()
                        .kerning(-0.5)
                        .foregroundStyle(DMTheme.green)
                }
                Text("Your move, organized.")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(.secondary)
            }

            Spacer(minLength: 8)

            NavigationLink(destination: FunctionalV2MoreView()) {
                Image(systemName: "person.crop.circle.fill")
                    .font(.system(size: 28))
                    .foregroundStyle(DMTheme.green)
                    .frame(width: 50, height: 50)
                    .background(.white)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(Color.black.opacity(0.06), lineWidth: 1))
                    .shadow(color: .black.opacity(0.05), radius: 8, y: 3)
            }
            .buttonStyle(.plain)
        }
    }

    private var heroCard: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let compact = w < 370
            let summaryWidth = min(max(w * 0.37, 132), 154)
            let ctaWidth = min(max(w * 0.43, 150), 180)

            ZStack {
                AsyncImage(url: URL(string: "https://images.unsplash.com/photo-1512453979798-5ea266f8880c?auto=format&fit=crop&w=1400&q=88")) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFill()
                    default:
                        LinearGradient(
                            colors: [Color(red: 0.90, green: 0.96, blue: 0.98), Color(red: 1.0, green: 0.94, blue: 0.87)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    }
                }
                .frame(width: w, height: 420)
                .offset(x: 18, y: -42)
                .clipped()

                LinearGradient(
                    colors: [Color.white.opacity(0.96), Color.white.opacity(0.83), Color.white.opacity(0.18), Color.clear],
                    startPoint: .leading,
                    endPoint: .trailing
                )

                VStack(alignment: .leading, spacing: 10) {
                    Text(heroTitle)
                        .font(.system(size: compact ? 28 : 32, weight: .heavy, design: .rounded))
                        .foregroundStyle(Color(red: 0.01, green: 0.20, blue: 0.16))
                        .lineLimit(3)
                        .minimumScaleFactor(0.82)
                        .frame(maxWidth: w * 0.66, alignment: .leading)

                    Text("All your move tasks, services and official steps in one place.")
                        .font(.system(size: compact ? 14 : 15, weight: .medium))
                        .foregroundStyle(DMTheme.ink.opacity(0.82))
                        .lineLimit(3)
                        .frame(maxWidth: w * 0.62, alignment: .leading)

                    Spacer()
                }
                .padding(20)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)

                weatherChip
                    .scaleEffect(compact ? 0.88 : 1, anchor: .topTrailing)
                    .padding(.top, 16)
                    .padding(.trailing, 14)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)

                NavigationLink(destination: GuidedMovePlanView()) {
                    HStack(spacing: 9) {
                        Text("Start My Move").lineLimit(1)
                        Image(systemName: "arrow.right")
                    }
                    .font(.system(size: compact ? 15 : 16, weight: .bold))
                    .foregroundStyle(.white)
                    .frame(width: ctaWidth, height: 58)
                    .background(DMTheme.greenDeep)
                    .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                    .shadow(color: DMTheme.greenDeep.opacity(0.22), radius: 10, y: 4)
                }
                .buttonStyle(.plain)
                .padding(.leading, 18)
                .padding(.bottom, 18)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomLeading)

                moveSummaryCard(width: summaryWidth)
                    .padding(.trailing, 14)
                    .padding(.bottom, 14)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
            }
            .frame(width: w, height: 350)
            .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: 28).stroke(Color.black.opacity(0.04), lineWidth: 1))
            .shadow(color: .black.opacity(0.08), radius: 16, y: 8)
        }
        .frame(height: 350)
    }

    private var weatherChip: some View {
        HStack(spacing: 8) {
            Image(systemName: "sun.max.fill")
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(.orange)
            VStack(alignment: .leading, spacing: 0) {
                Text("32°C")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(DMTheme.ink)
                Text("Dubai")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(.white.opacity(0.94))
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 18).stroke(Color.black.opacity(0.04), lineWidth: 1))
        .shadow(color: .black.opacity(0.05), radius: 8, y: 3)
    }

    private func moveSummaryCard(width: CGFloat) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            moveSummaryRow(icon: "house.fill", tint: DMTheme.green, label: "Current Home", value: currentHome)
            moveSummaryRow(icon: "mappin.circle.fill", tint: .red, label: "New Home", value: newHome)
            moveSummaryRow(icon: "calendar", tint: DMTheme.green, label: "Move Date", value: Date(timeIntervalSince1970: moveDateEpoch).formatted(date: .abbreviated, time: .omitted))
        }
        .padding(12)
        .frame(width: width)
        .background(.white.opacity(0.95))
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color.black.opacity(0.04), lineWidth: 1))
        .shadow(color: .black.opacity(0.06), radius: 10, y: 4)
    }

    private func moveSummaryRow(icon: String, tint: Color, label: String, value: String) -> some View {
        HStack(alignment: .center, spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 13, weight: .bold))
                .foregroundStyle(tint)
                .frame(width: 20)
            VStack(alignment: .leading, spacing: 1) {
                Text(label)
                    .font(.system(size: 9, weight: .medium))
                    .foregroundStyle(.secondary)
                Text(value)
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(DMTheme.ink)
                    .lineLimit(1)
                    .minimumScaleFactor(0.72)
            }
        }
    }

    private var quickActions: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("Quick actions").font(.title2.bold())
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

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                quickAction("Book a Service", "Cleaning, Moving...", "truck.box.fill", .orange) { state.selectedTab = .services }
                quickAction("Handle Documents", "Ejari, DEWA, etc.", "doc.fill", .green) { state.selectedTab = .documents }
                quickAction("Buy Supplies", "Boxes, packing...", "shippingbox.fill", .blue) { state.selectedTab = .services }
                quickAction("Edit Move", "Areas & date", "building.2.fill", .purple) { }
            }
        }
    }

    private func quickAction(_ title: String, _ subtitle: String, _ icon: String, _ tint: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(spacing: 10) {
                Image(systemName: icon)
                    .font(.title3.bold())
                    .foregroundStyle(tint)
                    .frame(width: 48, height: 48)
                    .background(tint.opacity(0.12))
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                Text(title)
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(DMTheme.ink)
                    .lineLimit(2)
                    .multilineTextAlignment(.center)
                Text(subtitle)
                    .font(.system(size: 10, weight: .medium))
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }
            .frame(maxWidth: .infinity, minHeight: 150)
            .padding(.horizontal, 8)
            .padding(.vertical, 12)
            .background(.white)
            .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
            .shadow(color: .black.opacity(0.03), radius: 8, y: 3)
        }
        .buttonStyle(.plain)
    }

    private var nextStep: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("Next step").font(.title2.bold())
                Spacer()
                Text("\(completedCount) of \(plan.steps.count)")
                    .font(.caption.bold())
                    .foregroundStyle(DMTheme.greenDeep)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(DMTheme.mint)
                    .clipShape(Capsule())
            }

            NavigationLink(destination: GuidedMovePlanView()) {
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
                .shadow(color: .black.opacity(0.04), radius: 8, y: 3)
            }
            .buttonStyle(.plain)
        }
    }

    private var officialEssentials: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Official essentials").font(.title2.bold())
            HStack(spacing: 12) {
                NavigationLink(destination: EjariGuidedView()) {
                    officialCard(title: "Ejari", subtitle: "Dubai Land Department", icon: "doc.text.fill", colors: [DMTheme.greenDeep, DMTheme.green])
                }.buttonStyle(.plain)
                NavigationLink(destination: DewaGuidedView()) {
                    officialCard(title: "DEWA", subtitle: "Move-In · Move-To · Move-Out", icon: "bolt.fill", colors: [.blue, .cyan])
                }.buttonStyle(.plain)
            }
        }
    }

    private func officialCard(title: String, subtitle: String, icon: String, colors: [Color]) -> some View {
        ZStack(alignment: .bottomLeading) {
            LinearGradient(colors: colors, startPoint: .topLeading, endPoint: .bottomTrailing)
            Image(systemName: icon)
                .font(.system(size: 64, weight: .thin))
                .foregroundStyle(.white.opacity(0.18))
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
                .padding(14)
            VStack(alignment: .leading, spacing: 4) {
                Text(title).font(.title3.bold())
                Text(subtitle).font(.caption).lineLimit(2)
            }
            .foregroundStyle(.white)
            .padding(16)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 120)
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
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
