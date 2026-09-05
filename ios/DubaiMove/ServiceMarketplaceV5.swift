import SwiftUI
import Foundation

struct PremiumRootTabViewV5: View {
    @EnvironmentObject private var state: AppState

    var body: some View {
        TabView(selection: $state.selectedTab) {
            NavigationStack { PremiumHomeView() }
                .tag(MainTab.home)
                .tabItem { Label("Home", systemImage: "house.fill") }

            NavigationStack { PremiumJourneyView() }
                .tag(MainTab.move)
                .tabItem { Label("My Move", systemImage: "list.number") }

            NavigationStack { ServicesMarketplaceV5View() }
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

struct V5Category: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let subtitle: String
    let imageURL: String
    let fallbackImageURL: String?
    let icon: String
    let iconTint: V5IconTint
    let chips: [String]
}

enum V5IconTint: Hashable {
    case blue, green, red, orange, purple, cyan

    var foreground: Color {
        switch self {
        case .blue: return .blue
        case .green: return DMTheme.green
        case .red: return .red
        case .orange: return .orange
        case .purple: return .purple
        case .cyan: return .cyan
        }
    }

    var background: Color { foreground.opacity(0.14) }
}

struct V5Provider: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let category: String
    let rating: Double
    let reviews: Int
    let location: String
    let price: String
    let nextSlot: String
    let imageURL: String
    let fallbackImageURL: String?
    let about: String
    let tags: [String]
    let slots: [String]
}

enum V5MarketplaceData {
    static let pestPrimary = "https://cdn-khgcn.nitrocdn.com/wDSpGKACrHVHunoymoCMvaxksMNozPTj/assets/images/optimized/rev-9672ef1/thornservices.com/oak/files/images/residential/residential-11.jpg"
    static let pestFallback = "https://lirp.cdn-website.com/d59e4c11/dms3rep/multi/opt/pest%2Bcontrol%2Bredmond%2Bwa%2B4-640w.jpg"

    static let categories: [V5Category] = [
        .init(name: "Cleaning", subtitle: "Homes, apartments, villas", imageURL: "https://images.unsplash.com/photo-1581578731548-c64695cc6952?auto=format&fit=crop&w=1000&q=82", fallbackImageURL: nil, icon: "sparkles", iconTint: .blue, chips: ["Regular", "Deep clean", "Move-out", "Eco-friendly"]),
        .init(name: "Moving", subtitle: "Home & office moving", imageURL: "https://images.unsplash.com/photo-1600518464441-9154a4dea21b?auto=format&fit=crop&w=1000&q=82", fallbackImageURL: nil, icon: "truck.box.fill", iconTint: .green, chips: ["Apartment", "Villa", "Packing", "Boxes"]),
        .init(name: "Painting", subtitle: "Interior & exterior", imageURL: "https://images.unsplash.com/photo-1562259949-e8e7689d7828?auto=format&fit=crop&w=1000&q=82", fallbackImageURL: nil, icon: "paintbrush.fill", iconTint: .red, chips: ["Touch-up", "Single room", "Full repaint", "Move-out"]),
        .init(name: "Maintenance", subtitle: "General repairs & handyman", imageURL: "https://images.unsplash.com/photo-1621905251918-48416bd8575a?auto=format&fit=crop&w=1000&q=82", fallbackImageURL: nil, icon: "wrench.and.screwdriver.fill", iconTint: .orange, chips: ["Handyman", "AC", "Mounting", "Repairs"]),
        .init(name: "Storage", subtitle: "Short & long term", imageURL: "https://images.unsplash.com/photo-1586528116311-ad8dd3c8310d?auto=format&fit=crop&w=1000&q=82", fallbackImageURL: nil, icon: "shippingbox.fill", iconTint: .purple, chips: ["Pickup", "Monthly", "Short-term", "Long-term"]),
        .init(name: "Electrical & Plumbing", subtitle: "Certified professionals", imageURL: "https://images.unsplash.com/photo-1607472586893-edb57bdc0e39?auto=format&fit=crop&w=1000&q=82", fallbackImageURL: "https://images.unsplash.com/photo-1504148455328-c376907d081c?auto=format&fit=crop&w=1000&q=82", icon: "bolt.fill", iconTint: .orange, chips: ["Electrical", "Plumbing", "Leaks", "Fixtures"]),
        .init(name: "Appliance Repair", subtitle: "AC, fridge, washer & more", imageURL: "https://images.unsplash.com/photo-1626806787461-102c1bfaaea1?auto=format&fit=crop&w=1000&q=82", fallbackImageURL: nil, icon: "gearshape.fill", iconTint: .cyan, chips: ["Washer", "Dryer", "Fridge", "Dishwasher"]),
        .init(name: "Pest Control", subtitle: "Safe & effective solutions", imageURL: pestPrimary, fallbackImageURL: pestFallback, icon: "ant.fill", iconTint: .red, chips: ["Apartment", "Villa", "Treatment", "Follow-up"])
    ]

    static let providers: [V5Provider] = [
        provider("Sparkle Home Services", "Cleaning", 4.8, 320, "Dubai", "From AED 80/hour", "Today · 14:00", categories[0].imageURL, nil, "Regular, deep and move-out cleaning for apartments and villas.", ["Deep cleaning", "Move-out", "Supplies included"], ["Today · 14:00", "Today · 18:00", "Tomorrow · 09:00"]),
        provider("CleanPro Dubai", "Cleaning", 4.7, 215, "Dubai Marina", "From AED 90/hour", "Tomorrow · 10:00", "https://images.unsplash.com/photo-1527515637462-cff94eecc1ac?auto=format&fit=crop&w=1000&q=84", nil, "Flexible apartment and villa cleaning with regular and one-off options.", ["Apartment", "Villa", "Eco products"], ["Tomorrow · 10:00", "Tomorrow · 15:00", "Sunday · 09:00"]),
        provider("MovePro UAE", "Moving", 4.8, 281, "Dubai", "From AED 850", "Tomorrow · 08:00", categories[1].imageURL, nil, "Apartment and villa moves with optional packing, boxes and unpacking.", ["Packing", "Truck", "Unpacking"], ["Tomorrow · 08:00", "Tomorrow · 12:00", "Sunday · 08:00"]),
        provider("ColorTop Painting", "Painting", 4.7, 119, "Dubai", "From AED 600", "In 2 days", categories[2].imageURL, nil, "Interior touch-ups, room painting and full-property repainting.", ["Touch-up", "Full repaint", "Move-out"], ["Monday · 08:30", "Monday · 13:00", "Tuesday · 09:00"]),
        provider("FixRight Home Care", "Maintenance", 4.8, 287, "Dubai", "From AED 120", "Today · 20:00", categories[3].imageURL, nil, "General handyman, AC troubleshooting and common home maintenance jobs.", ["Handyman", "AC", "Minor repairs"], ["Today · 20:00", "Tomorrow · 10:00", "Tomorrow · 16:00"]),
        provider("BoxSafe Storage", "Storage", 4.6, 121, "Al Quoz", "From AED 199/month", "Pickup tomorrow", categories[4].imageURL, nil, "Short- and long-term storage with optional pickup.", ["Pickup", "Short-term", "Long-term"], ["Tomorrow · AM", "Tomorrow · PM", "Sunday · AM"]),
        provider("HomeFlow Technical", "Electrical & Plumbing", 4.7, 166, "Dubai", "From AED 150", "Today · 19:00", categories[5].imageURL, categories[5].fallbackImageURL, "Common residential electrical and plumbing visits with scope confirmed before attendance.", ["Electrical", "Plumbing", "Home visits"], ["Today · 19:00", "Tomorrow · 09:30", "Tomorrow · 15:00"]),
        provider("ApplianceCare Dubai", "Appliance Repair", 4.5, 132, "Dubai", "From AED 130", "Tomorrow · 11:00", categories[6].imageURL, nil, "Diagnostics and common home appliance repair visits.", ["Washer", "Dryer", "Kitchen appliances"], ["Tomorrow · 11:00", "Tomorrow · 15:00", "Sunday · 12:00"]),
        provider("SafeHome Pest Control", "Pest Control", 4.8, 201, "Dubai", "From AED 180", "Tomorrow · 08:30", pestPrimary, pestFallback, "Residential pest-control visits with service scope confirmed before booking.", ["Apartment", "Villa", "Follow-up"], ["Tomorrow · 08:30", "Tomorrow · 13:30", "Sunday · 09:00"])
    ]

    private static func provider(_ name: String, _ category: String, _ rating: Double, _ reviews: Int, _ location: String, _ price: String, _ nextSlot: String, _ imageURL: String, _ fallbackImageURL: String?, _ about: String, _ tags: [String], _ slots: [String]) -> V5Provider {
        V5Provider(name: name, category: category, rating: rating, reviews: reviews, location: location, price: price, nextSlot: nextSlot, imageURL: imageURL, fallbackImageURL: fallbackImageURL, about: about, tags: tags, slots: slots)
    }
}

struct V5RemotePhoto: View {
    let url: String
    let fallbackURL: String?

    var body: some View {
        AsyncImage(url: URL(string: url)) { phase in
            switch phase {
            case .success(let image):
                image.resizable().scaledToFill()
            case .empty:
                placeholder
            case .failure:
                if let fallbackURL, let fallback = URL(string: fallbackURL) {
                    AsyncImage(url: fallback) { fallbackPhase in
                        switch fallbackPhase {
                        case .success(let image): image.resizable().scaledToFill()
                        case .empty: placeholder
                        default: fallbackPlaceholder
                        }
                    }
                } else {
                    fallbackPlaceholder
                }
            @unknown default:
                fallbackPlaceholder
            }
        }
        .clipped()
    }

    private var placeholder: some View {
        ZStack {
            DMTheme.cardMuted
            ProgressView().tint(DMTheme.green)
        }
    }

    private var fallbackPlaceholder: some View {
        ZStack {
            LinearGradient(colors: [DMTheme.greenDeep, DMTheme.green], startPoint: .topLeading, endPoint: .bottomTrailing)
            Image(systemName: "photo.fill")
                .font(.title2)
                .foregroundStyle(.white.opacity(0.8))
        }
    }
}

struct ServicesMarketplaceV5View: View {
    @State private var search = ""

    private let columns = [
        GridItem(.flexible(minimum: 0), spacing: 12, alignment: .top),
        GridItem(.flexible(minimum: 0), spacing: 12, alignment: .top)
    ]

    private var categories: [V5Category] {
        guard !search.isEmpty else { return V5MarketplaceData.categories }
        return V5MarketplaceData.categories.filter {
            $0.name.localizedCaseInsensitiveContains(search) || $0.subtitle.localizedCaseInsensitiveContains(search)
        }
    }

    var body: some View {
        ScrollView(.vertical, showsIndicators: true) {
            VStack(alignment: .leading, spacing: 18) {
                header
                searchField

                LazyVGrid(columns: columns, alignment: .center, spacing: 14) {
                    ForEach(categories) { category in
                        NavigationLink(destination: ServiceCategoryV5View(category: category)) {
                            categoryCard(category)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .frame(maxWidth: .infinity)

                ecoBanner
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 16)
            .padding(.top, 8)
            .padding(.bottom, 110)
        }
        .scrollBounceBehavior(.basedOnSize, axes: [.horizontal, .vertical])
        .background(Color(uiColor: .systemGroupedBackground).ignoresSafeArea())
        .navigationBarTitleDisplayMode(.inline)
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Services")
                .font(.system(size: 40, weight: .bold, design: .rounded))
                .foregroundStyle(.primary)
                .lineLimit(1)

            Text("Professional help for your home and move. Compare providers, check availability and book from one place.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .lineLimit(3)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var searchField: some View {
        HStack(spacing: 12) {
            Image(systemName: "magnifyingglass")
                .font(.title3)
                .foregroundStyle(.secondary)
            TextField("Search services or providers…", text: $search)
                .textInputAutocapitalization(.never)
                .lineLimit(1)
        }
        .padding(.horizontal, 16)
        .frame(maxWidth: .infinity)
        .frame(height: 54)
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .shadow(color: .black.opacity(0.04), radius: 8, y: 3)
    }

    private func categoryCard(_ category: V5Category) -> some View {
        VStack(spacing: 0) {
            V5RemotePhoto(url: category.imageURL, fallbackURL: category.fallbackImageURL)
                .frame(maxWidth: .infinity)
                .frame(height: 112)
                .clipped()

            HStack(spacing: 8) {
                ZStack {
                    Circle().fill(category.iconTint.background)
                    Image(systemName: category.icon)
                        .font(.system(size: 17, weight: .bold))
                        .foregroundStyle(category.iconTint.foreground)
                }
                .frame(width: 38, height: 38)

                VStack(alignment: .leading, spacing: 2) {
                    Text(category.name)
                        .font(.system(size: 14.5, weight: .bold))
                        .foregroundStyle(DMTheme.ink)
                        .lineLimit(2)
                        .minimumScaleFactor(0.72)
                        .multilineTextAlignment(.leading)

                    Text(category.subtitle)
                        .font(.system(size: 10.5))
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                        .minimumScaleFactor(0.78)
                        .multilineTextAlignment(.leading)
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                Image(systemName: "chevron.right")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundStyle(DMTheme.ink.opacity(0.62))
                    .frame(width: 22, height: 22)
            }
            .padding(.horizontal, 9)
            .padding(.vertical, 9)
            .frame(maxWidth: .infinity)
            .frame(height: 82)
            .background(.white)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 194)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color.black.opacity(0.04), lineWidth: 1))
        .shadow(color: .black.opacity(0.055), radius: 8, y: 4)
        .clipped()
    }

    private var ecoBanner: some View {
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
        .frame(maxWidth: .infinity)
        .background(DMTheme.mint.opacity(0.62))
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
}

struct ServiceCategoryV5View: View {
    let category: V5Category
    @State private var search = ""
    @State private var selectedChip = "All"

    private var providers: [V5Provider] {
        V5MarketplaceData.providers.filter {
            $0.category == category.name && (search.isEmpty || $0.name.localizedCaseInsensitiveContains(search))
        }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                ZStack(alignment: .bottomLeading) {
                    V5RemotePhoto(url: category.imageURL, fallbackURL: category.fallbackImageURL)
                        .frame(maxWidth: .infinity)
                        .frame(height: 230)
                    LinearGradient(colors: [.clear, .black.opacity(0.72)], startPoint: .center, endPoint: .bottom)
                    VStack(alignment: .leading, spacing: 5) {
                        Text(category.name).font(.largeTitle.bold()).lineLimit(2).minimumScaleFactor(0.8)
                        Text(category.subtitle).font(.subheadline)
                    }
                    .foregroundStyle(.white)
                    .padding(18)
                }
                .clipShape(RoundedRectangle(cornerRadius: 28))

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        chip("All")
                        ForEach(category.chips, id: \.self) { chip($0) }
                    }
                }

                HStack(spacing: 10) {
                    Image(systemName: "magnifyingglass").foregroundStyle(.secondary)
                    TextField("Search providers", text: $search)
                }
                .padding(.horizontal, 14)
                .frame(height: 48)
                .background(.white)
                .clipShape(RoundedRectangle(cornerRadius: 16))

                Text("\(providers.count) providers").font(.headline)

                ForEach(providers) { provider in
                    NavigationLink(destination: ProviderV5DetailView(provider: provider)) {
                        providerCard(provider)
                    }
                    .buttonStyle(.plain)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(16)
            .padding(.bottom, 90)
        }
        .background(Color(uiColor: .systemGroupedBackground).ignoresSafeArea())
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

    private func providerCard(_ provider: V5Provider) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            V5RemotePhoto(url: provider.imageURL, fallbackURL: provider.fallbackImageURL)
                .frame(maxWidth: .infinity)
                .frame(height: 180)
                .clipShape(RoundedRectangle(cornerRadius: 18))

            HStack(alignment: .top, spacing: 6) {
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 5) {
                        Text(provider.name).font(.headline).foregroundStyle(DMTheme.ink).lineLimit(2)
                        Image(systemName: "checkmark.seal.fill").foregroundStyle(DMTheme.green)
                    }
                    Text(provider.category).font(.caption.bold()).foregroundStyle(DMTheme.green)
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                HStack(spacing: 3) {
                    Text(String(format: "%.1f", provider.rating)).bold()
                    Image(systemName: "star.fill").foregroundStyle(.orange)
                }
                .font(.caption)
            }

            HStack {
                Label(provider.location, systemImage: "mappin.and.ellipse")
                Spacer()
                Text("\(provider.reviews) reviews")
            }
            .font(.caption)
            .foregroundStyle(.secondary)

            HStack(alignment: .firstTextBaseline) {
                Text(provider.nextSlot).font(.caption.bold()).foregroundStyle(DMTheme.green).lineLimit(2)
                Spacer(minLength: 8)
                Text(provider.price).font(.headline).foregroundStyle(DMTheme.ink).multilineTextAlignment(.trailing).lineLimit(2)
            }

            HStack(spacing: 10) {
                Text("View Profile")
                    .font(.subheadline.bold())
                    .foregroundStyle(DMTheme.green)
                    .frame(maxWidth: .infinity)
                Text("Book Now")
                    .font(.subheadline.bold())
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(DMTheme.green)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
        }
        .padding(12)
        .frame(maxWidth: .infinity)
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 24))
        .shadow(color: .black.opacity(0.06), radius: 9, y: 4)
    }
}

struct ProviderV5DetailView: View {
    let provider: V5Provider
    @State private var selectedSlot: String?
    @State private var message = ""

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                V5RemotePhoto(url: provider.imageURL, fallbackURL: provider.fallbackImageURL)
                    .frame(maxWidth: .infinity)
                    .frame(height: 270)
                    .clipShape(RoundedRectangle(cornerRadius: 28))

                VStack(alignment: .leading, spacing: 8) {
                    HStack(alignment: .top, spacing: 6) {
                        Text(provider.name).font(.largeTitle.bold()).lineLimit(2).minimumScaleFactor(0.8)
                        Image(systemName: "checkmark.seal.fill").foregroundStyle(DMTheme.green)
                    }
                    Text(provider.category).font(.subheadline.bold()).foregroundStyle(DMTheme.green)
                    HStack {
                        Label(String(format: "%.1f (%d)", provider.rating, provider.reviews), systemImage: "star.fill")
                        Spacer()
                        Label(provider.location, systemImage: "mappin.and.ellipse")
                    }
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    Text(provider.price).font(.title3.bold())
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text("About").font(.headline)
                    Text(provider.about).font(.subheadline).foregroundStyle(.secondary)
                }
                .v5Surface()

                VStack(alignment: .leading, spacing: 10) {
                    Text("Services").font(.headline)
                    ForEach(provider.tags, id: \.self) { Label($0, systemImage: "checkmark.circle.fill").foregroundStyle(DMTheme.green) }
                }
                .v5Surface()

                VStack(alignment: .leading, spacing: 10) {
                    Text("Available slots").font(.headline)
                    ForEach(provider.slots, id: \.self) { slot in
                        Button { selectedSlot = slot } label: {
                            HStack {
                                Image(systemName: selectedSlot == slot ? "checkmark.circle.fill" : "circle")
                                Text(slot)
                                Spacer()
                            }
                            .foregroundStyle(selectedSlot == slot ? DMTheme.green : DMTheme.ink)
                            .padding(12)
                            .background(selectedSlot == slot ? DMTheme.mint : DMTheme.cardMuted)
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                        }
                        .buttonStyle(.plain)
                    }
                    Button("Continue to booking") { }
                        .buttonStyle(.borderedProminent)
                        .tint(DMTheme.green)
                        .disabled(selectedSlot == nil)
                        .frame(maxWidth: .infinity)
                }
                .v5Surface()

                VStack(alignment: .leading, spacing: 10) {
                    Text("Message provider").font(.headline)
                    TextField("Ask about scope, access, timing or equipment", text: $message, axis: .vertical)
                        .padding(12)
                        .background(DMTheme.cardMuted)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                    Button("Send message") { message = "" }
                        .buttonStyle(.borderedProminent)
                        .tint(DMTheme.green)
                        .disabled(message.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
                .v5Surface()

                Text("Provider listings shown in backend-free TestFlight mode are sample marketplace data. Live listings, availability, booking and chat will come from the connected provider platform.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(16)
            .padding(.bottom, 90)
        }
        .background(Color(uiColor: .systemGroupedBackground).ignoresSafeArea())
        .navigationTitle(provider.name)
        .navigationBarTitleDisplayMode(.inline)
    }
}

private extension View {
    func v5Surface() -> some View {
        self
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(DMTheme.card)
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .overlay(RoundedRectangle(cornerRadius: 20).stroke(DMTheme.border, lineWidth: 1))
    }
}
