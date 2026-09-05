import SwiftUI

// MARK: - Services marketplace V3

struct PremiumRootTabViewV3: View {
    @EnvironmentObject private var state: AppState

    var body: some View {
        TabView(selection: $state.selectedTab) {
            NavigationStack { PremiumHomeView() }
                .tag(MainTab.home)
                .tabItem { Label("Home", systemImage: "house.fill") }

            NavigationStack { PremiumJourneyView() }
                .tag(MainTab.move)
                .tabItem { Label("My Move", systemImage: "list.number") }

            NavigationStack { ServiceMarketplaceV3View() }
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

private struct V3Category: Identifiable, Hashable {
    let id = UUID()
    let title: String
    let subtitle: String
    let hero: String
    let icon: String
    let chips: [String]
}

private struct V3Provider: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let category: String
    let rating: Double
    let reviews: Int
    let location: String
    let nextSlot: String
    let price: String
    let response: String
    let verified: Bool
    let image: String
    let about: String
    let tags: [String]
    let slots: [String]
    let jobsDone: Int
    let repeatRate: Int
}

private enum V3MarketplaceData {
    static let categories: [V3Category] = [
        .init(title: "Cleaning", subtitle: "Deep, regular and move-out cleaning", hero: "https://images.unsplash.com/photo-1581578731548-c64695cc6952?auto=format&fit=crop&w=1400&q=88", icon: "sparkles", chips: ["Apartments & villas", "Regular", "Deep cleaning", "Move-in / Move-out", "Eco-friendly"]),
        .init(title: "Moving", subtitle: "Packing, transport and unpacking", hero: "https://images.unsplash.com/photo-1600518464441-9154a4dea21b?auto=format&fit=crop&w=1400&q=88", icon: "truck.box.fill", chips: ["Apartment moves", "Villa moves", "Packing", "Unpacking", "Boxes"]),
        .init(title: "Painting", subtitle: "Touch-ups and full repainting", hero: "https://images.unsplash.com/photo-1562259949-e8e7689d7828?auto=format&fit=crop&w=1400&q=88", icon: "paintbrush.fill", chips: ["Touch-up", "Single room", "Full repaint", "Move-out", "Ceilings"]),
        .init(title: "Maintenance", subtitle: "Handyman, AC and common repairs", hero: "https://images.unsplash.com/photo-1621905251918-48416bd8575a?auto=format&fit=crop&w=1400&q=88", icon: "wrench.and.screwdriver.fill", chips: ["Handyman", "AC", "Minor repairs", "Furniture assembly", "Mounting"]),
        .init(title: "Storage", subtitle: "Short and long-term storage", hero: "https://images.unsplash.com/photo-1600566753190-17f0baa2a6c3?auto=format&fit=crop&w=1400&q=88", icon: "archivebox.fill", chips: ["Pickup", "Monthly", "Short-term", "Long-term", "Boxes"]),
        .init(title: "Electrical & Plumbing", subtitle: "Residential electrical and plumbing work", hero: "https://images.unsplash.com/photo-1504148455328-c376907d081c?auto=format&fit=crop&w=1400&q=88", icon: "bolt.fill", chips: ["Electrical", "Plumbing", "Leaks", "Fixtures", "Home visit"]),
        .init(title: "Appliance Repair", subtitle: "Home appliance diagnostics and repair", hero: "https://images.unsplash.com/photo-1626806787461-102c1bfaaea1?auto=format&fit=crop&w=1400&q=88", icon: "washer.fill", chips: ["Washer", "Dryer", "Dishwasher", "Fridge", "Diagnostics"]),
        .init(title: "Pest Control", subtitle: "Treatment and prevention for homes", hero: "https://images.unsplash.com/photo-1581579185169-7d6a6f78ec82?auto=format&fit=crop&w=1400&q=88", icon: "ant.fill", chips: ["Apartment", "Villa", "Inspection", "Treatment", "Follow-up"])
    ]

    static let providers: [V3Provider] = [
        .init(name:"Sparkle Home Services", category:"Cleaning", rating:4.8, reviews:320, location:"Dubai", nextSlot:"Today · 14:00", price:"From AED 80/hour", response:"~5 min", verified:true, image:"https://images.unsplash.com/photo-1581578731548-c64695cc6952?auto=format&fit=crop&w=1200&q=90", about:"Regular, deep and move-out cleaning packages for apartments and villas. Scope is confirmed before booking.", tags:["Regular Cleaning","Deep Cleaning","Move-out"], slots:["Today · 14:00","Today · 18:00","Tomorrow · 09:00"], jobsDone:1280, repeatRate:76),
        .init(name:"CleanPro Dubai", category:"Cleaning", rating:4.7, reviews:215, location:"Dubai Marina", nextSlot:"Tomorrow · 10:00", price:"From AED 90/hour", response:"~8 min", verified:true, image:"https://images.unsplash.com/photo-1527515637462-cff94eecc1ac?auto=format&fit=crop&w=1200&q=90", about:"Apartment and villa cleaning with flexible schedules and optional eco-friendly supplies.", tags:["Apartment Cleaning","Villa Cleaning","Eco Products"], slots:["Tomorrow · 10:00","Tomorrow · 15:00","Sunday · 09:00"], jobsDone:940, repeatRate:71),
        .init(name:"FreshStart Cleaning", category:"Cleaning", rating:4.6, reviews:142, location:"JLT", nextSlot:"Tomorrow · 09:00", price:"From AED 70/hour", response:"~11 min", verified:true, image:"https://images.unsplash.com/photo-1527515862127-a4fc05baf7a5?auto=format&fit=crop&w=1200&q=90", about:"Home cleaning focused on move preparation, upholstery and scheduled recurring visits.", tags:["Sofa & Carpet","Sanitization","Move-in"], slots:["Tomorrow · 09:00","Tomorrow · 13:00","Sunday · 11:00"], jobsDone:685, repeatRate:68),

        .init(name:"MovePro UAE", category:"Moving", rating:4.8, reviews:281, location:"Dubai", nextSlot:"Tomorrow · 08:00", price:"From AED 850", response:"~7 min", verified:true, image:"https://images.unsplash.com/photo-1600518464441-9154a4dea21b?auto=format&fit=crop&w=1200&q=90", about:"Apartment and villa moving with optional packing, boxes and unpacking. Building access requirements can be discussed before booking.", tags:["Packing","Truck","Unpacking"], slots:["Tomorrow · 08:00","Tomorrow · 12:00","Sunday · 08:00"], jobsDone:1540, repeatRate:63),
        .init(name:"UrbanShift Movers", category:"Moving", rating:4.6, reviews:174, location:"Dubai", nextSlot:"Sunday · 10:00", price:"From AED 650", response:"~12 min", verified:true, image:"https://images.unsplash.com/photo-1505693416388-ac5ce068fe85?auto=format&fit=crop&w=1200&q=90", about:"Flexible moving packages for studios through family homes, including optional packing support.", tags:["Budget","Boxes","Dubai-wide"], slots:["Sunday · 10:00","Sunday · 14:00","Monday · 09:00"], jobsDone:910, repeatRate:59),
        .init(name:"Prime Relocations", category:"Moving", rating:4.9, reviews:198, location:"Business Bay", nextSlot:"Monday · 08:00", price:"From AED 1100", response:"~6 min", verified:true, image:"https://images.unsplash.com/photo-1558618666-fcd25c85cd64?auto=format&fit=crop&w=1200&q=90", about:"Premium home relocations with packing coordination, move-day supervision and unpacking options.", tags:["Premium","Packing team","Move manager"], slots:["Monday · 08:00","Monday · 13:00","Tuesday · 08:00"], jobsDone:760, repeatRate:72),

        .init(name:"ColorTop Painting", category:"Painting", rating:4.7, reviews:119, location:"Dubai", nextSlot:"In 2 days", price:"From AED 600", response:"~10 min", verified:true, image:"https://images.unsplash.com/photo-1562259949-e8e7689d7828?auto=format&fit=crop&w=1200&q=90", about:"Interior painting for touch-ups, rooms and full-property repainting before move-out or move-in.", tags:["Touch-ups","Full repaint","Move-out"], slots:["Monday · 08:30","Monday · 13:00","Tuesday · 09:00"], jobsDone:540, repeatRate:61),
        .init(name:"FreshCoat Homes", category:"Painting", rating:4.8, reviews:147, location:"Dubai Hills", nextSlot:"Monday · 09:00", price:"From AED 499/room", response:"~9 min", verified:true, image:"https://images.unsplash.com/photo-1589939705384-5185137a7f0f?auto=format&fit=crop&w=1200&q=90", about:"Interior repaint and touch-up work for apartments and villas, with clear scope before attendance.", tags:["Rooms","Touch-up","Villa"], slots:["Monday · 09:00","Monday · 14:00","Tuesday · 10:00"], jobsDone:610, repeatRate:66),

        .init(name:"FixRight Home Care", category:"Maintenance", rating:4.8, reviews:287, location:"Dubai", nextSlot:"Today · 20:00", price:"From AED 120", response:"~8 min", verified:true, image:"https://images.unsplash.com/photo-1621905251918-48416bd8575a?auto=format&fit=crop&w=1200&q=90", about:"General handyman, AC troubleshooting and common home maintenance jobs.", tags:["Handyman","AC","Minor repairs"], slots:["Today · 20:00","Tomorrow · 10:00","Tomorrow · 16:00"], jobsDone:1720, repeatRate:74),
        .init(name:"HomeCare Technical", category:"Maintenance", rating:4.6, reviews:201, location:"Dubai", nextSlot:"Tomorrow · 08:30", price:"From AED 130", response:"~13 min", verified:true, image:"https://images.unsplash.com/photo-1581141849291-1125c7b692b5?auto=format&fit=crop&w=1200&q=90", about:"Home maintenance visits for mounting, furniture assembly, minor repairs and AC checks.", tags:["Mounting","Assembly","AC check"], slots:["Tomorrow · 08:30","Tomorrow · 14:30","Sunday · 09:00"], jobsDone:960, repeatRate:64),

        .init(name:"BoxSafe Storage", category:"Storage", rating:4.6, reviews:121, location:"Al Quoz", nextSlot:"Pickup tomorrow", price:"From AED 199/month", response:"~18 min", verified:true, image:"https://images.unsplash.com/photo-1600566753190-17f0baa2a6c3?auto=format&fit=crop&w=1200&q=90", about:"Short- and long-term storage with optional pickup. Pricing depends on volume and duration.", tags:["Pickup","Short-term","Long-term"], slots:["Tomorrow · AM","Tomorrow · PM","Sunday · AM"], jobsDone:430, repeatRate:57),
        .init(name:"StoreHub Dubai", category:"Storage", rating:4.7, reviews:95, location:"Dubai Investment Park", nextSlot:"Tomorrow · PM", price:"From AED 240/month", response:"~16 min", verified:true, image:"https://images.unsplash.com/photo-1586528116311-ad8dd3c8310d?auto=format&fit=crop&w=1200&q=90", about:"Flexible storage plans with pickup options and monthly extensions.", tags:["Flexible plans","Pickup","Boxes"], slots:["Tomorrow · PM","Sunday · AM","Sunday · PM"], jobsDone:390, repeatRate:62),

        .init(name:"HomeFlow Technical", category:"Electrical & Plumbing", rating:4.7, reviews:166, location:"Dubai", nextSlot:"Today · 19:00", price:"From AED 150", response:"~9 min", verified:true, image:"https://images.unsplash.com/photo-1504148455328-c376907d081c?auto=format&fit=crop&w=1200&q=90", about:"General electrical and plumbing assistance for common residential jobs. Work and materials are confirmed before attendance.", tags:["Electrical","Plumbing","Home visits"], slots:["Today · 19:00","Tomorrow · 09:30","Tomorrow · 15:00"], jobsDone:1080, repeatRate:69),
        .init(name:"RapidFix Dubai", category:"Electrical & Plumbing", rating:4.6, reviews:132, location:"Dubai", nextSlot:"Tomorrow · 10:30", price:"From AED 140", response:"~12 min", verified:true, image:"https://images.unsplash.com/photo-1607472586893-edb57bdc0e39?auto=format&fit=crop&w=1200&q=90", about:"Home visits for fixtures, leaks, sockets and common electrical or plumbing maintenance.", tags:["Leaks","Fixtures","Sockets"], slots:["Tomorrow · 10:30","Tomorrow · 17:00","Sunday · 11:00"], jobsDone:820, repeatRate:61),

        .init(name:"ApplianceCare Dubai", category:"Appliance Repair", rating:4.5, reviews:132, location:"Dubai", nextSlot:"Tomorrow · 11:00", price:"From AED 130", response:"~14 min", verified:true, image:"https://images.unsplash.com/photo-1626806787461-102c1bfaaea1?auto=format&fit=crop&w=1200&q=90", about:"Diagnostic visits for common household appliances. Parts and final repair cost are quoted after inspection.", tags:["Washer","Dryer","Kitchen appliances"], slots:["Tomorrow · 11:00","Tomorrow · 15:00","Sunday · 12:00"], jobsDone:730, repeatRate:55),
        .init(name:"FixMyAppliance", category:"Appliance Repair", rating:4.7, reviews:101, location:"Dubai", nextSlot:"Tomorrow · 09:30", price:"From AED 150", response:"~10 min", verified:true, image:"https://images.unsplash.com/photo-1556911220-bff31c812dba?auto=format&fit=crop&w=1200&q=90", about:"Diagnostics and common repairs for washing machines, dishwashers, refrigerators and ovens.", tags:["Diagnostics","Fridge","Dishwasher"], slots:["Tomorrow · 09:30","Tomorrow · 13:30","Sunday · 10:00"], jobsDone:620, repeatRate:58),

        .init(name:"SafeHome Pest Control", category:"Pest Control", rating:4.8, reviews:201, location:"Dubai", nextSlot:"Tomorrow · 08:30", price:"From AED 180", response:"~11 min", verified:true, image:"https://images.unsplash.com/photo-1581579185169-7d6a6f78ec82?auto=format&fit=crop&w=1200&q=90", about:"Residential pest-control visits with service scope confirmed before booking. Follow-up timing depends on the selected service.", tags:["Apartment","Villa","Follow-up"], slots:["Tomorrow · 08:30","Tomorrow · 13:30","Sunday · 09:00"], jobsDone:890, repeatRate:67),
        .init(name:"PestAway Dubai", category:"Pest Control", rating:4.6, reviews:153, location:"Dubai", nextSlot:"Tomorrow · 12:00", price:"From AED 160", response:"~15 min", verified:true, image:"https://images.unsplash.com/photo-1632823469850-6a3e9f1da2af?auto=format&fit=crop&w=1200&q=90", about:"Home pest treatment and follow-up services for apartments and villas.", tags:["Inspection","Treatment","Follow-up"], slots:["Tomorrow · 12:00","Tomorrow · 17:00","Sunday · 10:00"], jobsDone:700, repeatRate:60)
    ]
}

private struct V3RemoteImage: View {
    let url: String
    var body: some View {
        AsyncImage(url: URL(string: url)) { phase in
            switch phase {
            case .success(let image): image.resizable().scaledToFill()
            case .empty:
                ZStack { Color(uiColor: .secondarySystemGroupedBackground); ProgressView().tint(DMTheme.green) }
            default:
                ZStack {
                    LinearGradient(colors: [DMTheme.greenDeep, DMTheme.green], startPoint: .topLeading, endPoint: .bottomTrailing)
                    Image(systemName: "photo.fill").font(.largeTitle).foregroundStyle(.white.opacity(0.65))
                }
            }
        }
    }
}

struct ServiceMarketplaceV3View: View {
    @State private var search = ""
    @State private var showFilters = false

    private var categories: [V3Category] {
        let value = search.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !value.isEmpty else { return V3MarketplaceData.categories }
        return V3MarketplaceData.categories.filter { $0.title.localizedCaseInsensitiveContains(value) || $0.subtitle.localizedCaseInsensitiveContains(value) }
    }

    private var popular: [V3Provider] { Array(V3MarketplaceData.providers.sorted { $0.rating > $1.rating }.prefix(6)) }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                header
                searchBar
                categoriesGrid
                popularProviders
                footerNote
            }
            .padding(.horizontal, 16)
            .padding(.top, 8)
            .padding(.bottom, 32)
        }
        .background(Color(uiColor: .systemGroupedBackground).ignoresSafeArea())
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showFilters) { filterSheet }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Services").font(.system(size: 40, weight: .bold, design: .rounded)).tracking(-1.1)
            Text("Professional help for your home and move. Compare providers, availability and price before you book.")
                .font(.subheadline).foregroundStyle(.secondary)
        }
    }

    private var searchBar: some View {
        HStack(spacing: 10) {
            HStack(spacing: 9) {
                Image(systemName: "magnifyingglass").foregroundStyle(.secondary)
                TextField("Search services", text: $search).textInputAutocapitalization(.never)
            }
            .padding(.horizontal, 14).frame(height: 48).background(.white).clipShape(RoundedRectangle(cornerRadius: 16))
            Button { showFilters = true } label: {
                Image(systemName: "slider.horizontal.3").font(.headline).frame(width: 48, height: 48).background(.white).clipShape(RoundedRectangle(cornerRadius: 16))
            }.buttonStyle(.plain).foregroundStyle(DMTheme.ink)
        }
    }

    private var categoriesGrid: some View {
        LazyVGrid(columns: [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)], spacing: 12) {
            ForEach(categories) { category in
                NavigationLink(destination: ServiceCategoryV3View(category: category)) {
                    ZStack(alignment: .bottomLeading) {
                        V3RemoteImage(url: category.hero)
                        LinearGradient(colors: [.clear, .black.opacity(0.76)], startPoint: .center, endPoint: .bottom)
                        VStack(alignment: .leading, spacing: 4) {
                            Image(systemName: category.icon).font(.title2.bold()).foregroundStyle(.white)
                            Text(category.title).font(.headline.bold()).foregroundStyle(.white).lineLimit(2)
                            Text(category.subtitle).font(.caption2).foregroundStyle(.white.opacity(0.84)).lineLimit(2)
                        }.padding(12)
                    }
                    .frame(height: 175)
                    .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
                    .shadow(color: .black.opacity(0.09), radius: 10, y: 5)
                }.buttonStyle(.plain)
            }
        }
    }

    private var popularProviders: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack { Text("Popular providers").font(.title2.bold()); Spacer(); Text("Top rated").font(.subheadline.bold()).foregroundStyle(DMTheme.green) }
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(popular) { provider in
                        NavigationLink(destination: ProviderDetailV3View(provider: provider)) { providerMiniCard(provider) }.buttonStyle(.plain)
                    }
                }
            }
        }
    }

    private func providerMiniCard(_ provider: V3Provider) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            ZStack(alignment: .topTrailing) {
                V3RemoteImage(url: provider.image).frame(width: 210, height: 130).clipped()
                if provider.verified { Label("Verified", systemImage: "checkmark.seal.fill").font(.caption2.bold()).padding(.horizontal, 8).padding(.vertical, 5).background(.ultraThinMaterial).clipShape(Capsule()).padding(8) }
            }
            Text(provider.name).font(.headline).foregroundStyle(DMTheme.ink).lineLimit(1)
            Text(provider.category).font(.caption).foregroundStyle(.secondary)
            HStack(spacing: 4) { Image(systemName: "star.fill").foregroundStyle(DMTheme.green); Text(String(format: "%.1f", provider.rating)).bold(); Text("(\(provider.reviews))").foregroundStyle(.secondary) }.font(.caption)
            Text(provider.price).font(.subheadline.bold()).foregroundStyle(DMTheme.ink)
        }
        .padding(10).frame(width: 230, alignment: .leading).background(.white).clipShape(RoundedRectangle(cornerRadius: 20)).shadow(color: .black.opacity(0.07), radius: 9, y: 4)
    }

    private var footerNote: some View {
        Text("Provider names, prices and slots in backend-free TestFlight mode are sample marketplace data. Live listings will be supplied by verified providers when the provider platform is connected.")
            .font(.caption).foregroundStyle(.secondary).padding(14).background(DMTheme.sand).clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private var filterSheet: some View {
        NavigationStack {
            Form {
                Section("Availability") { Toggle("Available today", isOn: .constant(false)); Toggle("Available tomorrow", isOn: .constant(false)) }
                Section("Provider") { Toggle("Verified only", isOn: .constant(true)); Toggle("4.5+ rating", isOn: .constant(false)) }
                Section("Price") { LabeledContent("Sort", value: "Recommended") }
            }
            .navigationTitle("Filters").toolbar { ToolbarItem(placement: .confirmationAction) { Button("Done") { showFilters = false } } }
        }
    }
}

struct ServiceCategoryV3View: View {
    let category: V3Category
    @State private var search = ""
    @State private var sort = "Recommended"
    @State private var showFilters = false
    @State private var selectedChip: String?

    private var providers: [V3Provider] {
        var list = V3MarketplaceData.providers.filter { $0.category == category.title }
        let query = search.trimmingCharacters(in: .whitespacesAndNewlines)
        if !query.isEmpty { list = list.filter { $0.name.localizedCaseInsensitiveContains(query) || $0.tags.joined(separator: " ").localizedCaseInsensitiveContains(query) } }
        if let selectedChip { list = list.filter { $0.tags.joined(separator: " ").localizedCaseInsensitiveContains(selectedChip.components(separatedBy: " ").first ?? selectedChip) || selectedChip == category.chips.first } }
        if sort == "Rating" { list.sort { $0.rating > $1.rating } }
        if sort == "Price" { list.sort { $0.price < $1.price } }
        return list
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                hero
                chips
                searchAndFilter
                resultHeader
                if providers.isEmpty {
                    ContentUnavailableView("No matching providers", systemImage: "magnifyingglass", description: Text("Try another search or remove a filter."))
                } else {
                    ForEach(providers) { provider in providerCard(provider) }
                }
                sampleNote
            }
            .padding(.bottom, 28)
        }
        .background(Color(uiColor: .systemGroupedBackground).ignoresSafeArea())
        .navigationTitle(category.title)
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showFilters) { filtersSheet }
    }

    private var hero: some View {
        ZStack(alignment: .bottomLeading) {
            V3RemoteImage(url: category.hero).frame(height: 260).clipped()
            LinearGradient(colors: [.clear, .black.opacity(0.78)], startPoint: .center, endPoint: .bottom)
            VStack(alignment: .leading, spacing: 6) {
                Text(category.title).font(.system(size: 38, weight: .bold, design: .rounded)).foregroundStyle(.white)
                Text(category.subtitle).font(.title3).foregroundStyle(.white.opacity(0.9))
            }.padding(20)
        }
    }

    private var chips: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(category.chips, id: \.self) { chip in
                    Button { selectedChip = selectedChip == chip ? nil : chip } label: {
                        VStack(spacing: 8) {
                            Image(systemName: chipIcon(chip)).font(.title3).foregroundStyle(selectedChip == chip ? .white : DMTheme.green)
                            Text(chip).font(.caption).multilineTextAlignment(.center).foregroundStyle(selectedChip == chip ? .white : DMTheme.ink).frame(width: 86)
                        }
                        .padding(.vertical, 12).padding(.horizontal, 8).background(selectedChip == chip ? DMTheme.green : .white).clipShape(RoundedRectangle(cornerRadius: 18))
                    }.buttonStyle(.plain)
                }
            }.padding(.horizontal, 16)
        }
    }

    private var searchAndFilter: some View {
        HStack(spacing: 10) {
            HStack(spacing: 9) { Image(systemName:"magnifyingglass").foregroundStyle(.secondary); TextField("Search \(category.title.lowercased()) providers", text:$search) }
                .padding(.horizontal,14).frame(height:48).background(.white).clipShape(RoundedRectangle(cornerRadius:16))
            Button { showFilters = true } label: { Image(systemName:"slider.horizontal.3").font(.headline).frame(width:48,height:48).background(.white).clipShape(RoundedRectangle(cornerRadius:16)) }.buttonStyle(.plain).foregroundStyle(DMTheme.ink)
        }.padding(.horizontal,16)
    }

    private var resultHeader: some View {
        HStack {
            Text("\(providers.count) providers").font(.subheadline).foregroundStyle(.secondary)
            Spacer()
            Menu {
                Button("Recommended") { sort = "Recommended" }
                Button("Rating") { sort = "Rating" }
                Button("Price") { sort = "Price" }
            } label: { HStack(spacing:4){ Text("Sort by").foregroundStyle(.secondary); Text(sort).bold(); Image(systemName:"chevron.down") }.font(.subheadline).foregroundStyle(DMTheme.ink) }
        }.padding(.horizontal,16)
    }

    private func providerCard(_ provider: V3Provider) -> some View {
        NavigationLink(destination: ProviderDetailV3View(provider: provider)) {
            VStack(alignment: .leading, spacing: 12) {
                ZStack(alignment: .topLeading) {
                    V3RemoteImage(url: provider.image).frame(height: 210).clipped()
                    LinearGradient(colors:[.clear,.black.opacity(0.38)],startPoint:.center,endPoint:.bottom)
                    if provider.verified { Label("Verified", systemImage:"checkmark.seal.fill").font(.caption.bold()).foregroundStyle(.white).padding(.horizontal,9).padding(.vertical,6).background(DMTheme.green).clipShape(Capsule()).padding(12) }
                    HStack { Spacer(); Image(systemName:"heart").font(.title3).foregroundStyle(.white).frame(width:42,height:42).background(.black.opacity(0.26)).clipShape(Circle()).padding(12) }
                }
                .clipShape(RoundedRectangle(cornerRadius:20))

                HStack(alignment:.top) {
                    VStack(alignment:.leading, spacing:5) {
                        Text(provider.name).font(.title3.bold()).foregroundStyle(DMTheme.ink)
                        Text(provider.category).font(.subheadline).foregroundStyle(.secondary)
                        HStack(spacing:5){ Image(systemName:"star.fill").foregroundStyle(DMTheme.green); Text(String(format:"%.1f",provider.rating)).bold(); Text("(\(provider.reviews) reviews)").foregroundStyle(.secondary) }.font(.caption)
                        Label(provider.location, systemImage:"mappin.and.ellipse").font(.caption).foregroundStyle(.secondary)
                        Label("Next available: \(provider.nextSlot)", systemImage:"clock").font(.caption).foregroundStyle(DMTheme.green)
                    }
                    Spacer()
                    VStack(alignment:.trailing,spacing:3){ Text("From").font(.caption).foregroundStyle(.secondary); Text(provider.price.replacingOccurrences(of:"From ",with:"" )).font(.headline.bold()).foregroundStyle(DMTheme.ink) }
                }

                ScrollView(.horizontal, showsIndicators:false){ HStack(spacing:7){ ForEach(provider.tags,id:\.self){ Text($0).font(.caption2.bold()).foregroundStyle(DMTheme.ink).padding(.horizontal,9).padding(.vertical,6).background(Color(uiColor:.secondarySystemGroupedBackground)).clipShape(Capsule()) } } }

                HStack(spacing:10) {
                    Text("View Profile").font(.subheadline.bold()).frame(maxWidth:.infinity).padding(.vertical,12).background(Color.clear).overlay(RoundedRectangle(cornerRadius:14).stroke(DMTheme.green.opacity(0.45),lineWidth:1)).foregroundStyle(DMTheme.green)
                    Text("Book Now").font(.subheadline.bold()).frame(maxWidth:.infinity).padding(.vertical,12).background(DMTheme.green).foregroundStyle(.white).clipShape(RoundedRectangle(cornerRadius:14))
                }
            }
            .padding(12).background(.white).clipShape(RoundedRectangle(cornerRadius:24)).shadow(color:.black.opacity(0.07),radius:10,y:5)
        }
        .buttonStyle(.plain)
        .padding(.horizontal,16)
    }

    private var sampleNote: some View {
        Text("Sample marketplace data is used in backend-free TestFlight mode. Live provider listings, messages and bookings activate when the provider platform is connected.")
            .font(.caption).foregroundStyle(.secondary).padding(14).background(DMTheme.sand).clipShape(RoundedRectangle(cornerRadius:16)).padding(.horizontal,16)
    }

    private var filtersSheet: some View {
        NavigationStack {
            Form {
                Section("Availability") { Toggle("Today", isOn:.constant(false)); Toggle("Tomorrow",isOn:.constant(false)) }
                Section("Provider") { Toggle("Verified only", isOn:.constant(true)); Toggle("4.5+ rating", isOn:.constant(false)) }
            }.navigationTitle("Filters").toolbar { ToolbarItem(placement:.confirmationAction){ Button("Done"){ showFilters = false } } }
        }
    }

    private func chipIcon(_ chip: String) -> String {
        if chip.localizedCaseInsensitiveContains("villa") || chip.localizedCaseInsensitiveContains("apartment") { return "house.fill" }
        if chip.localizedCaseInsensitiveContains("deep") || chip.localizedCaseInsensitiveContains("regular") { return "sparkles" }
        if chip.localizedCaseInsensitiveContains("move") { return "sofa.fill" }
        if chip.localizedCaseInsensitiveContains("AC") { return "snowflake" }
        if chip.localizedCaseInsensitiveContains("plumb") { return "drop.fill" }
        if chip.localizedCaseInsensitiveContains("electric") { return "bolt.fill" }
        if chip.localizedCaseInsensitiveContains("pickup") { return "truck.box.fill" }
        return category.icon
    }
}

struct ProviderDetailV3View: View {
    let provider: V3Provider
    @State private var selectedSlot: String?
    @State private var message = ""
    @State private var sentMessages: [String] = []
    @State private var showBooking = false

    var body: some View {
        ScrollView {
            VStack(alignment:.leading, spacing:18) {
                hero
                stats
                about
                specialties
                availability
                messageCard
                safetyNote
            }
            .padding(.bottom,30)
        }
        .background(Color(uiColor:.systemGroupedBackground).ignoresSafeArea())
        .navigationTitle(provider.name)
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented:$showBooking){ bookingSheet }
    }

    private var hero: some View {
        ZStack(alignment:.bottomLeading) {
            V3RemoteImage(url:provider.image).frame(height:320).clipped()
            LinearGradient(colors:[.clear,.black.opacity(0.8)],startPoint:.center,endPoint:.bottom)
            VStack(alignment:.leading,spacing:6) {
                if provider.verified { Label("Verified provider",systemImage:"checkmark.seal.fill").font(.caption.bold()).foregroundStyle(.white).padding(.horizontal,9).padding(.vertical,6).background(DMTheme.green).clipShape(Capsule()) }
                Text(provider.name).font(.system(size:32,weight:.bold,design:.rounded)).foregroundStyle(.white)
                Text(provider.category).font(.title3).foregroundStyle(.white.opacity(0.9))
                HStack(spacing:5){ Image(systemName:"star.fill").foregroundStyle(.yellow); Text(String(format:"%.1f",provider.rating)).bold(); Text("· \(provider.reviews) reviews"); Text("· \(provider.location)") }.font(.caption).foregroundStyle(.white.opacity(0.92))
            }.padding(18)
        }
    }

    private var stats: some View {
        HStack(spacing:10) {
            metric("Starting", provider.price, "banknote.fill")
            metric("Next slot", provider.nextSlot, "clock.fill")
            metric("Replies", provider.response, "message.fill")
        }.padding(.horizontal,16)
    }

    private func metric(_ title:String,_ value:String,_ icon:String)->some View {
        VStack(alignment:.leading,spacing:6){ Image(systemName:icon).foregroundStyle(DMTheme.green); Text(title).font(.caption2).foregroundStyle(.secondary); Text(value).font(.caption.bold()).foregroundStyle(DMTheme.ink).lineLimit(2) }
            .padding(12).frame(maxWidth:.infinity,minHeight:104,alignment:.topLeading).background(.white).clipShape(RoundedRectangle(cornerRadius:18))
    }

    private var about: some View {
        VStack(alignment:.leading,spacing:8){ Text("About").font(.title3.bold()); Text(provider.about).font(.subheadline).foregroundStyle(.secondary); HStack{ Label("\(provider.jobsDone)+ jobs",systemImage:"checkmark.circle.fill"); Spacer(); Label("\(provider.repeatRate)% repeat",systemImage:"arrow.triangle.2.circlepath") }.font(.caption.bold()).foregroundStyle(DMTheme.green) }
            .padding(16).background(.white).clipShape(RoundedRectangle(cornerRadius:22)).padding(.horizontal,16)
    }

    private var specialties: some View {
        VStack(alignment:.leading,spacing:10){ Text("Services offered").font(.title3.bold()); FlowLayoutV3(items:provider.tags) }
            .padding(16).background(.white).clipShape(RoundedRectangle(cornerRadius:22)).padding(.horizontal,16)
    }

    private var availability: some View {
        VStack(alignment:.leading,spacing:12){
            Text("Available slots").font(.title3.bold())
            ForEach(provider.slots,id:\.self){ slot in
                Button{ selectedSlot = slot }label:{ HStack{ Image(systemName:selectedSlot == slot ? "checkmark.circle.fill":"circle"); Text(slot); Spacer(); Text(selectedSlot == slot ? "Selected":"Choose").font(.caption) }.foregroundStyle(selectedSlot == slot ? DMTheme.green:DMTheme.ink).padding(12).background(selectedSlot == slot ? DMTheme.mint:Color(uiColor:.secondarySystemGroupedBackground)).clipShape(RoundedRectangle(cornerRadius:14)) }.buttonStyle(.plain)
            }
            Button{ showBooking = true }label:{ Label("Continue to booking",systemImage:"calendar.badge.checkmark").frame(maxWidth:.infinity) }.buttonStyle(.borderedProminent).tint(DMTheme.green).disabled(selectedSlot == nil)
        }.padding(16).background(.white).clipShape(RoundedRectangle(cornerRadius:22)).padding(.horizontal,16)
    }

    private var messageCard: some View {
        VStack(alignment:.leading,spacing:10){
            Text("Message provider").font(.title3.bold())
            Text("Ask about scope, materials, access, timing or anything included in the price.").font(.caption).foregroundStyle(.secondary)
            TextField("Write a message",text:$message,axis:.vertical).lineLimit(3...6).padding(12).background(Color(uiColor:.secondarySystemGroupedBackground)).clipShape(RoundedRectangle(cornerRadius:14))
            Button{ let clean=message.trimmingCharacters(in:.whitespacesAndNewlines); guard !clean.isEmpty else{return}; sentMessages.append(clean); message="" }label:{ Label("Send message",systemImage:"paperplane.fill").frame(maxWidth:.infinity) }.buttonStyle(.borderedProminent).tint(DMTheme.green).disabled(message.trimmingCharacters(in:.whitespacesAndNewlines).isEmpty)
            ForEach(Array(sentMessages.enumerated()),id:\.offset){ _,item in HStack{ Spacer(); Text(item).font(.subheadline).padding(10).background(DMTheme.green).foregroundStyle(.white).clipShape(RoundedRectangle(cornerRadius:14)) } }
            Text("Messages remain local in backend-free TestFlight mode.").font(.caption2).foregroundStyle(.secondary)
        }.padding(16).background(.white).clipShape(RoundedRectangle(cornerRadius:22)).padding(.horizontal,16)
    }

    private var safetyNote: some View {
        VStack(alignment:.leading,spacing:7){ Label("Marketplace transparency",systemImage:"checkmark.shield.fill").font(.headline).foregroundStyle(DMTheme.green); Text("Dubai Move helps users discover and communicate with service providers. Final service scope, price and booking confirmation must be explicitly confirmed. Dubai Move does not provide legal advice or make legal determinations.").font(.caption).foregroundStyle(.secondary) }
            .padding(16).background(DMTheme.sand).clipShape(RoundedRectangle(cornerRadius:18)).padding(.horizontal,16)
    }

    private var bookingSheet: some View {
        NavigationStack {
            VStack(alignment:.leading,spacing:18){
                Text(provider.name).font(.title2.bold())
                Text(provider.category).foregroundStyle(.secondary)
                if let selectedSlot { Label(selectedSlot,systemImage:"calendar").font(.headline) }
                Text(provider.price).font(.title3.bold()).foregroundStyle(DMTheme.green)
                Divider()
                Text("This TestFlight screen records your selected slot locally. A real booking will only be created when the provider backend is connected and confirms the request.").font(.subheadline).foregroundStyle(.secondary)
                Spacer()
                Button("Save selected slot"){ showBooking = false }.buttonStyle(.borderedProminent).tint(DMTheme.green).frame(maxWidth:.infinity)
            }.padding(20).navigationTitle("Booking").toolbar{ ToolbarItem(placement:.cancellationAction){ Button("Close"){ showBooking=false } } }
        }
    }
}

private struct FlowLayoutV3: View {
    let items:[String]
    var body: some View {
        VStack(alignment:.leading,spacing:8){
            ForEach(items,id:\.self){ item in Label(item,systemImage:"checkmark.circle.fill").font(.subheadline).foregroundStyle(DMTheme.ink) }
        }
    }
}
