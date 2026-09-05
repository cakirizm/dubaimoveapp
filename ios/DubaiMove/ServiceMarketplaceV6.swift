import SwiftUI

struct PremiumRootTabViewV6: View {
    @EnvironmentObject private var state: AppState

    var body: some View {
        TabView(selection: $state.selectedTab) {
            NavigationStack { PremiumHomeView() }
                .tag(MainTab.home)
                .tabItem { Label("Home", systemImage: "house.fill") }

            NavigationStack { PremiumJourneyView() }
                .tag(MainTab.move)
                .tabItem { Label("My Move", systemImage: "list.number") }

            NavigationStack { ServicesMarketplaceV6View() }
                .tag(MainTab.services)
                .tabItem { Label("Services", systemImage: "square.grid.2x2.fill") }

            NavigationStack { FunctionalV2DocumentsView() }
                .tag(MainTab.documents)
                .tabItem { Label("Documents", systemImage: "folder.fill") }

            NavigationStack { ConnectedMoneyView() }
                .tag(MainTab.money)
                .tabItem { Label("Money", systemImage: "banknote.fill") }
        }
        .tint(DMTheme.green)
        .toolbarBackground(.visible, for: .tabBar)
    }
}

struct ServicesMarketplaceV6View: View {
    @State private var search = ""

    private var categories: [V5Category] {
        guard !search.isEmpty else { return V5MarketplaceData.categories }
        return V5MarketplaceData.categories.filter {
            $0.name.localizedCaseInsensitiveContains(search) ||
            $0.subtitle.localizedCaseInsensitiveContains(search)
        }
    }

    var body: some View {
        GeometryReader { proxy in
            let horizontalPadding: CGFloat = 16
            let columnSpacing: CGFloat = 12
            let availableWidth = max(0, proxy.size.width - (horizontalPadding * 2))
            let cardWidth = max(0, (availableWidth - columnSpacing) / 2)
            let columns = [
                GridItem(.fixed(cardWidth), spacing: columnSpacing, alignment: .top),
                GridItem(.fixed(cardWidth), spacing: columnSpacing, alignment: .top)
            ]

            ScrollView(.vertical, showsIndicators: true) {
                VStack(alignment: .leading, spacing: 18) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Services")
                            .font(.system(size: 40, weight: .bold, design: .rounded))
                            .foregroundStyle(.primary)
                            .lineLimit(1)

                        Text("Professional help for your home and move. Compare providers, check availability and book from one place.")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .frame(width: availableWidth, alignment: .leading)

                    HStack(spacing: 12) {
                        Image(systemName: "magnifyingglass")
                            .font(.title3)
                            .foregroundStyle(.secondary)
                        TextField("Search services or providers…", text: $search)
                            .textInputAutocapitalization(.never)
                            .lineLimit(1)
                    }
                    .padding(.horizontal, 16)
                    .frame(width: availableWidth, height: 54)
                    .background(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                    .shadow(color: .black.opacity(0.04), radius: 8, y: 3)

                    LazyVGrid(columns: columns, alignment: .leading, spacing: 14) {
                        ForEach(categories) { category in
                            NavigationLink(destination: ServiceCategoryV5View(category: category)) {
                                serviceCard(category, width: cardWidth)
                            }
                            .buttonStyle(.plain)
                            .frame(width: cardWidth)
                        }
                    }
                    .frame(width: availableWidth, alignment: .leading)

                    ecoBanner(width: availableWidth)
                }
                .frame(width: availableWidth, alignment: .leading)
                .padding(.horizontal, horizontalPadding)
                .padding(.top, 8)
                .padding(.bottom, 110)
            }
            .frame(width: proxy.size.width)
            .clipped()
            .background(Color(uiColor: .systemGroupedBackground).ignoresSafeArea())
        }
        .navigationBarTitleDisplayMode(.inline)
    }

    private func serviceCard(_ category: V5Category, width: CGFloat) -> some View {
        VStack(spacing: 0) {
            V5RemotePhoto(url: category.imageURL, fallbackURL: category.fallbackImageURL)
                .frame(width: width, height: 112)
                .clipped()

            HStack(spacing: 7) {
                ZStack {
                    Circle().fill(category.iconTint.background)
                    Image(systemName: category.icon)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(category.iconTint.foreground)
                }
                .frame(width: 36, height: 36)
                .fixedSize()

                VStack(alignment: .leading, spacing: 2) {
                    Text(category.name)
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(DMTheme.ink)
                        .lineLimit(2)
                        .minimumScaleFactor(0.7)
                        .multilineTextAlignment(.leading)

                    Text(category.subtitle)
                        .font(.system(size: 10.5))
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                        .minimumScaleFactor(0.75)
                        .multilineTextAlignment(.leading)
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                Image(systemName: "chevron.right")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundStyle(DMTheme.ink.opacity(0.62))
                    .frame(width: 18)
                    .fixedSize()
            }
            .padding(.horizontal, 9)
            .frame(width: width, height: 82, alignment: .leading)
            .background(.white)
        }
        .frame(width: width, height: 194)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(Color.black.opacity(0.04), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.055), radius: 8, y: 4)
        .contentShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
    }

    private func ecoBanner(width: CGFloat) -> some View {
        HStack(spacing: 12) {
            Image(systemName: "leaf.fill")
                .font(.title2)
                .foregroundStyle(DMTheme.green)
                .frame(width: 44, height: 44)
                .background(DMTheme.mint)
                .clipShape(Circle())

            VStack(alignment: .leading, spacing: 3) {
                Text("Eco-Friendly Providers")
                    .font(.headline)
                    .foregroundStyle(DMTheme.greenDeep)
                Text("Find sustainable and eco-friendly service options.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            Image(systemName: "chevron.right")
                .font(.caption.bold())
                .foregroundStyle(DMTheme.green)
        }
        .padding(14)
        .frame(width: width)
        .background(DMTheme.mint.opacity(0.62))
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
}
