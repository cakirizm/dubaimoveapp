import SwiftUI

// MARK: - Photo-first services marketplace

struct PremiumRootTabViewV2: View {
    @EnvironmentObject private var state: AppState

    var body: some View {
        TabView(selection: $state.selectedTab) {
            NavigationStack { PremiumHomeView() }
                .tag(MainTab.home)
                .tabItem { Label("Home", systemImage: "house.fill") }

            NavigationStack { PremiumJourneyView() }
                .tag(MainTab.move)
                .tabItem { Label("My Move", systemImage: "list.number") }

            NavigationStack { ServiceMarketplaceV2View() }
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

private struct MarketCategory: Identifiable, Hashable {
    let id = UUID()
    let title: String
    let subtitle: String
    let imageURL: String
}

private struct MarketProvider: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let service: String
    let rating: Double
    let reviews: Int
    let location: String
    let nextSlot: String
    let price: String
    let responseTime: String
    let verified: Bool
    let heroURL: String
    let about: String
    let specialties: [String]
    let slots: [String]
}

private enum MarketplaceData {
    static let categories: [MarketCategory] = [
        .init(title: "Cleaning", subtitle: "Deep, regular and move-out cleaning", imageURL: "https://images.unsplash.com/photo-1581578731548-c64695cc6952?auto=format&fit=crop&w=1200&q=85"),
        .init(title: "Moving", subtitle: "Packing, transport and unpacking", imageURL: "https://images.unsplash.com/photo-1600518464441-9154a4dea21b?auto=format&fit=crop&w=1200&q=85"),
        .init(title: "Painting", subtitle: "Touch-ups and full repainting", imageURL: "https://images.unsplash.com/photo-1562259949-e8e7689d7828?auto=format&fit=crop&w=1200&q=85"),
        .init(title: "Maintenance", subtitle: "Handyman, AC and common repairs", imageURL: "https://images.unsplash.com/photo-1621905251918-48416bd8575a?auto=format&fit=crop&w=1200&q=85"),
        .init(title: "Storage", subtitle: "Short and long-term storage", imageURL: "https://images.unsplash.com/photo-1600566753190-17f0baa2a6c3?auto=format&fit=crop&w=1200&q=85"),
        .init(title: "Electrical & Plumbing", subtitle: "Home electrical and plumbing jobs", imageURL: "https://images.unsplash.com/photo-1504148455328-c376907d081c?auto=format&fit=crop&w=1200&q=85"),
        .init(title: "Appliance Repair", subtitle: "Washer, dryer and appliance support", imageURL: "https://images.unsplash.com/photo-1626806787461-102c1bfaaea1?auto=format&fit=crop&w=1200&q=85"),
        .init(title: "Pest Control", subtitle: "Home pest treatment and prevention", imageURL: "https://images.unsplash.com/photo-1581579185169-7d6a6f78ec82?auto=format&fit=crop&w=1200&q=85")
    ]

    static let providers: [MarketProvider] = [
        .init(name: "Sparkle Home Services", service: "Cleaning", rating: 4.8, reviews: 320, location: "Dubai", nextSlot: "Today · 14:00", price: "From AED 80/hour", responseTime: "Usually replies in 5 min", verified: true, heroURL: "https://images.unsplash.com/photo-1581578731548-c64695cc6952?auto=format&fit=crop&w=1400&q=90", about: "Cleaning packages for regular visits, deep cleaning and move-out preparation. Scope and final price are confirmed before booking.", specialties: ["Deep cleaning", "Move-out", "Supplies included"], slots: ["Today · 14:00", "Today · 18:00", "Tomorrow · 09:00"]),
        .init(name: "BrightNest Cleaning", service: "Cleaning", rating: 4.7, reviews: 214, location: "Dubai Marina", nextSlot: "Tomorrow · 09:00", price: "From AED 65/hour", responseTime: "Usually replies in 8 min", verified: true, heroURL: "https://images.unsplash.com/photo-1527515637462-cff94eecc1ac?auto=format&fit=crop&w=1400&q=90", about: "Home cleaning focused on apartments, move-in and move-out jobs, and scheduled recurring visits.", specialties: ["Apartments", "Move-in", "Recurring"], slots: ["Tomorrow · 09:00", "Tomorrow · 13:00", "Sunday · 10:00"]),
        .init(name: "MovePro UAE", service: "Moving", rating: 4.7, reviews: 215, location: "Dubai", nextSlot: "Tomorrow · 08:00", price: "From AED 350", responseTime: "Usually replies in 7 min", verified: true, heroURL: "https://images.unsplash.com/photo-1600518464441-9154a4dea21b?auto=format&fit=crop&w=1400&q=90", about: "Apartment and villa moves with optional packing, boxes, transport and unpacking. Building access requirements can be discussed before booking.", specialties: ["Packing", "Truck", "Unpacking"], slots: ["Tomorrow · 08:00", "Tomorrow · 12:00", "Sunday · 08:00"]),
        .init(name: "UrbanShift Movers", service: "Moving", rating: 4.6, reviews: 174, location: "Dubai", nextSlot: "Sunday · 10:00", price: "From AED 650", responseTime: "Usually replies in 12 min", verified: true, heroURL: "https://images.unsplash.com/photo-1505693416388-ac5ce068fe85?auto=format&fit=crop&w=1400&q=90", about: "Flexible moving packages for smaller apartments through larger family homes, including optional packing support.", specialties: ["Dubai-wide", "Boxes", "Flexible scope"], slots: ["Sunday · 10:00", "Sunday · 14:00", "Monday · 09:00"]),
        .init(name: "ColorTop Painting", service: "Painting", rating: 4.6, reviews: 98, location: "Dubai", nextSlot: "In 2 days", price: "From AED 600", responseTime: "Usually replies in 10 min", verified: true, heroURL: "https://images.unsplash.com/photo-1562259949-e8e7689d7828?auto=format&fit=crop&w=1400&q=90", about: "Interior painting for touch-ups, individual rooms and full-property repainting before move-out or move-in.", specialties: ["Touch-ups", "Full repaint", "Move-out"], slots: ["Monday · 08:30", "Monday · 13:00", "Tuesday · 09:00"]),
        .init(name: "FixRight Home Care", service: "Maintenance", rating: 4.8, reviews: 287, location: "Dubai", nextSlot: "Today · 20:00", price: "From AED 120", responseTime: "Usually replies in 8 min", verified: true, heroURL: "https://images.unsplash.com/photo-1621905251918-48416bd8575a?auto=format&fit=crop&w=1400&q=90", about: "General handyman, AC troubleshooting and common home maintenance jobs. Final scope is confirmed in chat before booking.", specialties: ["Handyman", "AC", "Minor repairs"], slots: ["Today · 20:00", "Tomorrow · 10:00", "Tomorrow · 16:00"]),
        .init(name: "BoxSafe Storage", service: "Storage", rating: 4.6, reviews: 121, location: "Dubai", nextSlot: "Pickup tomorrow", price: "From AED 199/month", responseTime: "Usually replies in 18 min", verified: true, heroURL: "https://images.unsplash.com/photo-1600566753190-17f0baa2a6c3?auto=format&fit=crop&w=1400&q=90", about: "Short- and long-term storage with optional pickup. Pricing depends on volume and storage duration.", specialties: ["Pickup", "Short-term", "Long-term"], slots: ["Tomorrow · AM", "Tomorrow · PM", "Sunday · AM"]),
        .init(name: "HomeFlow Technical", service: "Electrical & Plumbing", rating: 4.7, reviews: 166, location: "Dubai", nextSlot: "Today · 19:00", price: "From AED 150", responseTime: "Usually replies in 9 min", verified: true, heroURL: "https://images.unsplash.com/photo-1504148455328-c376907d081c?auto=format&fit=crop&w=1400&q=90", about: "General electrical and plumbing assistance for common residential jobs. Exact work and materials are confirmed before attendance.", specialties: ["Electrical", "Plumbing", "Home visits"], slots: ["Today · 19:00", "Tomorrow · 09:30", "Tomorrow · 15:00"]),
        .init(name: "ApplianceCare Dubai", service: "Appliance Repair", rating: 4.5, reviews: 132, location: "Dubai", nextSlot: "Tomorrow · 11:00", price: "From AED 130", responseTime: "Usually replies in 14 min", verified: true, heroURL: "https://images.unsplash.com/photo-1626806787461-102c1bfaaea1?auto=format&fit=crop&w=1400&q=90", about: "Diagnostic visits for common household appliances. Parts and final repair cost are quoted after inspection.", specialties: ["Washer", "Dryer", "Kitchen appliances"], slots: ["Tomorrow · 11:00", "Tomorrow · 15:00", "Sunday · 12:00"]),
        .init(name: "SafeHome Pest Control", service: "Pest Control", rating: 4.8, reviews: 201, location: "Dubai", nextSlot: "Tomorrow · 08:30", price: "From AED 180", responseTime: "Usually replies in 11 min", verified: true, heroURL: "https://images.unsplash.com/photo-1581579185169-7d6a6f78ec82?auto=format&fit=crop&w=1400&q=90", about: "Residential pest-control visits with service scope confirmed before booking. Follow-up timing depends on the selected service.", specialties: ["Apartment", "Villa", "Follow-up"], slots: ["Tomorrow · 08:30", "Tomorrow · 13:30", "Sunday · 09:00"])
    ]
}

private struct RemotePhoto: View {
    let url: String

    var body: some View {
        AsyncImage(url: URL(string: url)) { phase in
            switch phase {
            case .success(let image):
                image.resizable().scaledToFill()
            case .failure:
                LinearGradient(colors: [DMTheme.greenDeep, DMTheme.green], startPoint: .topLeading, endPoint: .bottomTrailing)
            case .empty:
                ZStack {
                    DMTheme.cardMuted
                    ProgressView().tint(DMTheme.green)
                }
            @unknown default:
                DMTheme.cardMuted
            }
        }
    }
}

struct ServiceMarketplaceV2View: View {
    @State private var search = ""
    @State private var showFilters = false

    private var filteredCategories: [MarketCategory] {
        guard !search.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return MarketplaceData.categories }
        return MarketplaceData.categories.filter { $0.title.localizedCaseInsensitiveContains(search) || $0.subtitle.localizedCaseInsensitiveContains(search) }
    }

    private var popularProviders: [MarketProvider] {
        Array(MarketplaceData.providers.sorted { $0.rating > $1.rating }.prefix(5))
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                header
                searchBar
                categoryGrid
                popularSection
                trustNote
            }
            .padding(.horizontal, 16)
            .padding(.top, 8)
            .padding(.bottom, 30)
        }
        .background(Color(uiColor: .systemGroupedBackground).ignoresSafeArea())
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showFilters) { filterSheet }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text("Services")
                .font(.system(size: 40, weight: .bold, design: .rounded))
                .tracking(-1.1)
            Text("Professional help for your home and move. Compare, message and book from one place.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    }

    private var searchBar: some View {
        HStack(spacing: 10) {
            HStack(spacing: 9) {
                Image(systemName: "magnifyingglass").foregroundStyle(.secondary)
                TextField("Search services", text: $search)
                    .textInputAutocapitalization(.never)
            }
            .padding(.horizontal, 14)
            .frame(height: 48)
            .background(.white)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))

            Button { showFilters = true } label: {
                Image(systemName: "slider.horizontal.3")
                    .font(.headline)
                    .frame(width: 48, height: 48)
                    .background(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            }
            .buttonStyle(.plain)
            .foregroundStyle(DMTheme.ink)
        }
    }

    private var categoryGrid: some View {
        LazyVGrid(columns: [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)], spacing: 12) {
            ForEach(filteredCategories) { category in
                NavigationLink(destination: ServiceCategoryV2View(category: category.title)) {
                    ZStack(alignment: .bottomLeading) {
                        RemotePhoto(url: category.imageURL)
                        LinearGradient(colors: [.clear, .black.opacity(0.68)], startPoint: .center, endPoint: .bottom)
                        VStack(alignment: .leading, spacing: 4) {
                            Text(category.title)
                                .font(.headline.bold())
                                .foregroundStyle(.white)
                                .lineLimit(2)
                            Text(category.subtitle)
                                .font(.caption2)
                                .foregroundStyle(.white.opacity(0.84))
                                .lineLimit(2)
                        }
                        .padding(12)
                    }
                    .frame(height: 168)
                    .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
                    .overlay(RoundedRectangle(cornerRadius: 22).stroke(.white.opacity(0.7), lineWidth: 0.5))
                    .shadow(color: .black.opacity(0.08), radius: 10, y: 5)
                }
                .buttonStyle(.plain)
            }
        }
    }

    private var popularSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Popular providers").font(.title2.bold())
                Spacer()
                Text("Browse all").font(.subheadline.bold()).foregroundStyle(DMTheme.green)
            }

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(popularProviders) { provider in
                        NavigationLink(destination: ProviderDetailV2View(provider: provider)) {
                            popularProviderCard(provider)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
    }

    private func popularProviderCard(_ provider: MarketProvider) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            RemotePhoto(url: provider.heroURL)
                .frame(height: 116)
                .clipped()

            VStack(alignment: .leading, spacing: 5) {
                HStack(spacing: 4) {
                    Image(systemName: "star.fill").foregroundStyle(DMTheme.green)
                    Text(String(format: "%.1f", provider.rating)).bold()
                    Text("(\(provider.reviews))").foregroundStyle(.secondary)
                }
                .font(.caption)

                Text(provider.name).font(.headline).foregroundStyle(DMTheme.ink).lineLimit(1)
                Text(provider.service).font(.caption.bold()).foregroundStyle(DMTheme.green)
                Label(provider.location, systemImage: "mappin.and.ellipse").font(.caption).foregroundStyle(.secondary)
                Label("Next: \(provider.nextSlot)", systemImage: "clock").font(.caption).foregroundStyle(.secondary).lineLimit(1)
                Text(provider.price).font(.subheadline.bold()).foregroundStyle(DMTheme.ink)
            }
            .padding(.horizontal, 11)
            .padding(.bottom, 12)
        }
        .frame(width: 238, alignment: .leading)
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color.black.opacity(0.05), lineWidth: 1))
        .shadow(color: .black.opacity(0.07), radius: 12, y: 6)
    }

    private var trustNote: some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: "checkmark.shield.fill").foregroundStyle(DMTheme.green)
            Text("Provider profiles, availability and prices shown in backend-free TestFlight are sample marketplace data. When the provider platform is connected, these cards will be supplied and maintained by providers through Dubai Move.")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(14)
        .background(DMTheme.sand)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private var filterSheet: some View {
        NavigationStack {
            List {
                Section("Sort") {
                    Label("Recommended", systemImage: "sparkles")
                    Label("Highest rated", systemImage: "star.fill")
                    Label("Earliest availability", systemImage: "clock.fill")
                    Label("Lowest starting price", systemImage: "arrow.down.circle.fill")
                }
                Section("Filters") {
                    Label("Verified providers", systemImage: "checkmark.seal.fill")
                    Label("Available today", systemImage: "calendar.badge.checkmark")
                    Label("Instant message", systemImage: "message.fill")
                }
            }
            .navigationTitle("Service filters")
            .toolbar { ToolbarItem(placement: .topBarTrailing) { Button("Done") { showFilters = false } } }
        }
    }
}

struct ServiceCategoryV2View: View {
    let category: String
    @State private var search = ""

    private var providers: [MarketProvider] {
        MarketplaceData.providers.filter { provider in
            provider.service == category && (search.isEmpty || provider.name.localizedCaseInsensitiveContains(search) || provider.specialties.joined(separator: " ").localizedCaseInsensitiveContains(search))
        }
    }

    private var categoryData: MarketCategory? { MarketplaceData.categories.first { $0.title == category } }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                if let categoryData {
                    ZStack(alignment: .bottomLeading) {
                        RemotePhoto(url: categoryData.imageURL)
                        LinearGradient(colors: [.clear, .black.opacity(0.74)], startPoint: .center, endPoint: .bottom)
                        VStack(alignment: .leading, spacing: 5) {
                            Text(category).font(.largeTitle.bold()).foregroundStyle(.white)
                            Text(categoryData.subtitle).font(.subheadline).foregroundStyle(.white.opacity(0.86))
                        }
                        .padding(18)
                    }
                    .frame(height: 220)
                    .clipShape(RoundedRectangle(cornerRadius: 26, style: .continuous))
                }

                HStack(spacing: 9) {
                    Image(systemName: "magnifyingglass").foregroundStyle(.secondary)
                    TextField("Search providers", text: $search)
                }
                .padding(.horizontal, 14)
                .frame(height: 48)
                .background(.white)
                .clipShape(RoundedRectangle(cornerRadius: 16))

                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Providers").font(.title2.bold())
                        Text("Compare profile, service, rating, availability and price before you message.").font(.caption).foregroundStyle(.secondary)
                    }
                    Spacer()
                }

                if providers.isEmpty {
                    ContentUnavailableView("No providers found", systemImage: "building.2.crop.circle", description: Text("Try another search or service category."))
                } else {
                    ForEach(providers) { provider in
                        NavigationLink(destination: ProviderDetailV2View(provider: provider)) {
                            providerCard(provider)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .padding(16)
            .padding(.bottom, 28)
        }
        .background(Color(uiColor: .systemGroupedBackground).ignoresSafeArea())
        .navigationTitle(category)
        .navigationBarTitleDisplayMode(.inline)
    }

    private func providerCard(_ provider: MarketProvider) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            ZStack(alignment: .bottomLeading) {
                RemotePhoto(url: provider.heroURL)
                LinearGradient(colors: [.clear, .black.opacity(0.65)], startPoint: .center, endPoint: .bottom)
                VStack(alignment: .leading, spacing: 3) {
                    HStack(spacing: 6) {
                        Text(provider.name).font(.title3.bold()).foregroundStyle(.white)
                        if provider.verified { Image(systemName: "checkmark.seal.fill").foregroundStyle(.white) }
                    }
                    Text(provider.service).font(.caption.bold()).foregroundStyle(.white.opacity(0.9))
                }
                .padding(15)
            }
            .frame(height: 190)

            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    HStack(spacing: 4) {
                        Image(systemName: "star.fill").foregroundStyle(DMTheme.green)
                        Text(String(format: "%.1f", provider.rating)).bold()
                        Text("(\(provider.reviews))").foregroundStyle(.secondary)
                    }
                    .font(.caption)
                    Spacer()
                    Text(provider.price).font(.subheadline.bold())
                }

                HStack(spacing: 14) {
                    Label(provider.location, systemImage: "mappin.and.ellipse")
                    Label(provider.nextSlot, systemImage: "clock")
                }
                .font(.caption)
                .foregroundStyle(.secondary)

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 7) {
                        ForEach(provider.specialties, id: \.self) { tag in
                            Text(tag).font(.caption2.bold()).foregroundStyle(DMTheme.green).padding(.horizontal, 9).padding(.vertical, 6).background(DMTheme.mint).clipShape(Capsule())
                        }
                    }
                }

                HStack {
                    Text(provider.responseTime).font(.caption).foregroundStyle(.secondary)
                    Spacer()
                    Label("View profile", systemImage: "arrow.right").font(.caption.bold()).foregroundStyle(DMTheme.green)
                }
            }
            .padding(14)
        }
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 24).stroke(Color.black.opacity(0.05), lineWidth: 1))
        .shadow(color: .black.opacity(0.07), radius: 12, y: 6)
    }
}

struct ProviderDetailV2View: View {
    let provider: MarketProvider
    @State private var selectedSlot: String?
    @State private var message = ""
    @State private var localMessages: [String] = []
    @State private var bookingStatus: String?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                hero
                quickFacts
                about
                specialties
                availability
                messagePanel
                boundary
            }
            .padding(.bottom, 30)
        }
        .background(Color(uiColor: .systemGroupedBackground).ignoresSafeArea())
        .navigationTitle(provider.name)
        .navigationBarTitleDisplayMode(.inline)
    }

    private var hero: some View {
        ZStack(alignment: .bottomLeading) {
            RemotePhoto(url: provider.heroURL)
            LinearGradient(colors: [.clear, .black.opacity(0.78)], startPoint: .center, endPoint: .bottom)
            VStack(alignment: .leading, spacing: 5) {
                HStack(spacing: 6) {
                    Text(provider.name).font(.system(size: 30, weight: .bold, design: .rounded)).foregroundStyle(.white)
                    if provider.verified { Image(systemName: "checkmark.seal.fill").foregroundStyle(.white) }
                }
                Text(provider.service).font(.headline).foregroundStyle(.white.opacity(0.9))
                HStack(spacing: 5) {
                    Image(systemName: "star.fill")
                    Text(String(format: "%.1f", provider.rating)).bold()
                    Text("· \(provider.reviews) reviews")
                }
                .font(.subheadline)
                .foregroundStyle(.white)
            }
            .padding(18)
        }
        .frame(height: 300)
        .clipped()
    }

    private var quickFacts: some View {
        HStack(spacing: 10) {
            fact("Price", provider.price, "banknote")
            fact("Next slot", provider.nextSlot, "clock")
            fact("Area", provider.location, "mappin.and.ellipse")
        }
        .padding(.horizontal, 16)
    }

    private func fact(_ title: String, _ value: String, _ icon: String) -> some View {
        VStack(alignment: .leading, spacing: 5) {
            Image(systemName: icon).foregroundStyle(DMTheme.green)
            Text(title).font(.caption2).foregroundStyle(.secondary)
            Text(value).font(.caption.bold()).lineLimit(2)
        }
        .frame(maxWidth: .infinity, minHeight: 92, alignment: .leading)
        .padding(11)
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private var about: some View {
        panel {
            Text("About").font(.title3.bold())
            Text(provider.about).font(.subheadline).foregroundStyle(.secondary)
            HStack(spacing: 6) {
                Image(systemName: "bolt.horizontal.circle.fill").foregroundStyle(DMTheme.green)
                Text(provider.responseTime).font(.caption.bold())
            }
        }
    }

    private var specialties: some View {
        panel {
            Text("Services & strengths").font(.title3.bold())
            FlowTags(tags: provider.specialties)
        }
    }

    private var availability: some View {
        panel {
            Text("Available slots").font(.title3.bold())
            Text("Choose a preferred slot. The provider confirms final availability before booking.").font(.caption).foregroundStyle(.secondary)

            ForEach(provider.slots, id: \.self) { slot in
                Button { selectedSlot = slot } label: {
                    HStack {
                        Image(systemName: selectedSlot == slot ? "checkmark.circle.fill" : "circle")
                        Text(slot)
                        Spacer()
                        Text("Select").font(.caption)
                    }
                    .foregroundStyle(selectedSlot == slot ? DMTheme.green : DMTheme.ink)
                    .padding(12)
                    .background(selectedSlot == slot ? DMTheme.mint : DMTheme.cardMuted)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                }
                .buttonStyle(.plain)
            }

            Button {
                guard let selectedSlot else { return }
                bookingStatus = "Preferred slot saved: \(selectedSlot). Final booking confirmation will come from the provider."
            } label: {
                Label("Continue with selected slot", systemImage: "calendar.badge.checkmark").frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .tint(DMTheme.green)
            .disabled(selectedSlot == nil)

            if let bookingStatus { Text(bookingStatus).font(.caption).foregroundStyle(.secondary) }
        }
    }

    private var messagePanel: some View {
        panel {
            Text("Message provider").font(.title3.bold())
            Text("Ask what is included, building access needs, timing, equipment or final scope before booking.").font(.caption).foregroundStyle(.secondary)

            TextField("Write a message", text: $message, axis: .vertical)
                .lineLimit(3...6)
                .padding(12)
                .background(DMTheme.cardMuted)
                .clipShape(RoundedRectangle(cornerRadius: 14))

            Button {
                let clean = message.trimmingCharacters(in: .whitespacesAndNewlines)
                guard !clean.isEmpty else { return }
                localMessages.append(clean)
                message = ""
            } label: {
                Label("Send message", systemImage: "paperplane.fill").frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .tint(DMTheme.green)
            .disabled(message.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)

            ForEach(Array(localMessages.enumerated()), id: \.offset) { _, item in
                HStack {
                    Spacer()
                    Text(item).font(.subheadline).padding(10).background(DMTheme.green).foregroundStyle(.white).clipShape(RoundedRectangle(cornerRadius: 14))
                }
            }

            if !APIConfiguration.isConnectedMode {
                Text("Messages remain on this iPhone in backend-free TestFlight mode. Live provider chat activates with the connected provider backend.")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
    }

    private var boundary: some View {
        HStack(alignment: .top, spacing: 9) {
            Image(systemName: "checkmark.shield.fill").foregroundStyle(DMTheme.green)
            Text("Dubai Move helps you discover and coordinate operational services. It does not provide legal advice or make legal determinations.")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(.horizontal, 16)
    }

    private func panel<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 11, content: content)
            .padding(16)
            .background(.white)
            .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: 22).stroke(Color.black.opacity(0.05), lineWidth: 1))
            .padding(.horizontal, 16)
    }
}

private struct FlowTags: View {
    let tags: [String]

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(tags, id: \.self) { tag in
                    Text(tag)
                        .font(.caption.bold())
                        .foregroundStyle(DMTheme.green)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 7)
                        .background(DMTheme.mint)
                        .clipShape(Capsule())
                }
            }
        }
    }
}
