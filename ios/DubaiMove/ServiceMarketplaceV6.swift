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
                            NavigationLink(destination: ServiceCategoryV6View(category: category)) {
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

struct ServiceCategoryV6View: View {
    let category: V5Category
    @State private var search = ""
    @State private var selectedChip = "All"

    private var providers: [V5Provider] {
        V5MarketplaceData.providers.filter {
            $0.category == category.name &&
            (search.isEmpty || $0.name.localizedCaseInsensitiveContains(search))
        }
    }

    var body: some View {
        GeometryReader { proxy in
            let horizontalPadding: CGFloat = 16
            let contentWidth = max(0, proxy.size.width - horizontalPadding * 2)

            ScrollView(.vertical, showsIndicators: true) {
                VStack(alignment: .leading, spacing: 16) {
                    ZStack(alignment: .bottomLeading) {
                        V5RemotePhoto(url: category.imageURL, fallbackURL: category.fallbackImageURL)
                            .frame(width: contentWidth, height: 220)
                            .clipped()

                        LinearGradient(
                            colors: [.clear, .black.opacity(0.68)],
                            startPoint: .center,
                            endPoint: .bottom
                        )

                        VStack(alignment: .leading, spacing: 4) {
                            Text(category.name)
                                .font(.system(size: 31, weight: .bold))
                                .lineLimit(1)
                                .minimumScaleFactor(0.8)
                            Text(category.subtitle)
                                .font(.subheadline)
                                .lineLimit(2)
                        }
                        .foregroundStyle(.white)
                        .padding(16)
                    }
                    .frame(width: contentWidth, height: 220)
                    .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            chip("All")
                            ForEach(category.chips, id: \.self) { chip($0) }
                        }
                    }
                    .frame(width: contentWidth, alignment: .leading)

                    HStack(spacing: 10) {
                        Image(systemName: "magnifyingglass").foregroundStyle(.secondary)
                        TextField("Search providers", text: $search)
                            .lineLimit(1)
                    }
                    .padding(.horizontal, 14)
                    .frame(width: contentWidth, height: 48)
                    .background(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 16))

                    Text("\(providers.count) providers")
                        .font(.headline)
                        .frame(width: contentWidth, alignment: .leading)

                    ForEach(providers) { provider in
                        NavigationLink(destination: ProviderV5DetailView(provider: provider)) {
                            providerCard(provider, width: contentWidth)
                        }
                        .buttonStyle(.plain)
                        .frame(width: contentWidth)
                    }
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
        .navigationTitle(category.name)
        .navigationBarTitleDisplayMode(.inline)
    }

    private func chip(_ text: String) -> some View {
        Button { selectedChip = text } label: {
            Text(text)
                .font(.caption.bold())
                .padding(.horizontal, 12)
                .padding(.vertical, 9)
                .background(selectedChip == text ? DMTheme.green : .white)
                .foregroundStyle(selectedChip == text ? .white : DMTheme.ink)
                .clipShape(Capsule())
        }
        .buttonStyle(.plain)
    }

    private func providerCard(_ provider: V5Provider, width: CGFloat) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            V5RemotePhoto(url: provider.imageURL, fallbackURL: provider.fallbackImageURL)
                .frame(width: width - 24, height: 170)
                .clipped()
                .clipShape(RoundedRectangle(cornerRadius: 18))

            HStack(alignment: .top, spacing: 6) {
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 5) {
                        Text(provider.name)
                            .font(.headline)
                            .foregroundStyle(DMTheme.ink)
                            .lineLimit(2)
                        Image(systemName: "checkmark.seal.fill")
                            .foregroundStyle(DMTheme.green)
                    }
                    Text(provider.category)
                        .font(.caption.bold())
                        .foregroundStyle(DMTheme.green)
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                HStack(spacing: 3) {
                    Text(String(format: "%.1f", provider.rating)).bold()
                    Image(systemName: "star.fill").foregroundStyle(.orange)
                }
                .font(.caption)
                .fixedSize()
            }

            HStack {
                Label(provider.location, systemImage: "mappin.and.ellipse")
                Spacer()
                Text("\(provider.reviews) reviews")
            }
            .font(.caption)
            .foregroundStyle(.secondary)

            HStack(alignment: .firstTextBaseline, spacing: 8) {
                Text(provider.nextSlot)
                    .font(.caption.bold())
                    .foregroundStyle(DMTheme.green)
                    .lineLimit(2)
                Spacer(minLength: 8)
                Text(provider.price)
                    .font(.headline)
                    .foregroundStyle(DMTheme.ink)
                    .multilineTextAlignment(.trailing)
                    .lineLimit(2)
            }

            HStack(spacing: 10) {
                Text("View Profile")
                    .font(.subheadline.bold())
                    .foregroundStyle(DMTheme.green)
                    .frame(maxWidth: .infinity)
                    .frame(height: 44)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(DMTheme.border, lineWidth: 1)
                    )

                Text("Book Now")
                    .font(.subheadline.bold())
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 44)
                    .background(DMTheme.green)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
        }
        .padding(12)
        .frame(width: width, alignment: .leading)
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 24))
        .shadow(color: .black.opacity(0.06), radius: 9, y: 4)
    }
}
