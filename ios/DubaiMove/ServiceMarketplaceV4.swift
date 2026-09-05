import SwiftUI
import Foundation

struct PremiumRootTabViewV4: View {
    @EnvironmentObject private var state: AppState

    var body: some View {
        TabView(selection: $state.selectedTab) {
            NavigationStack { PremiumHomeView() }
                .tag(MainTab.home)
                .tabItem { Label("Home", systemImage: "house.fill") }
            NavigationStack { PremiumJourneyView() }
                .tag(MainTab.move)
                .tabItem { Label("My Move", systemImage: "list.number") }
            NavigationStack { ServicesMarketplaceV4View() }
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

struct V4Category: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let subtitle: String
    let imageURL: String
    let chips: [String]
}

struct V4Provider: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let category: String
    let rating: Double
    let reviews: Int
    let location: String
    let price: String
    let nextSlot: String
    let imageURL: String
    let about: String
    let tags: [String]
    let slots: [String]
}

enum V4MarketplaceData {
    static let categories: [V4Category] = [
        .init(name: "Cleaning", subtitle: "Homes, apartments, villas", imageURL: "https://images.unsplash.com/photo-1581578731548-c64695cc6952?auto=format&fit=crop&w=1200&q=85", chips: ["Regular", "Deep clean", "Move-out", "Eco-friendly"]),
        .init(name: "Moving", subtitle: "Home & office moving", imageURL: "https://images.unsplash.com/photo-1600518464441-9154a4dea21b?auto=format&fit=crop&w=1200&q=85", chips: ["Apartment", "Villa", "Packing", "Boxes"]),
        .init(name: "Painting", subtitle: "Interior & exterior", imageURL: "https://images.unsplash.com/photo-1562259949-e8e7689d7828?auto=format&fit=crop&w=1200&q=85", chips: ["Touch-up", "Single room", "Full repaint", "Move-out"]),
        .init(name: "Maintenance", subtitle: "General repairs & handyman", imageURL: "https://images.unsplash.com/photo-1621905251918-48416bd8575a?auto=format&fit=crop&w=1200&q=85", chips: ["Handyman", "AC", "Mounting", "Repairs"]),
        .init(name: "Storage", subtitle: "Short & long term", imageURL: "https://images.unsplash.com/photo-1600566753190-17f0baa2a6c3?auto=format&fit=crop&w=1200&q=85", chips: ["Pickup", "Monthly", "Short-term", "Long-term"]),
        .init(name: "Electrical & Plumbing", subtitle: "Home technical services", imageURL: "https://images.unsplash.com/photo-1504148455328-c376907d081c?auto=format&fit=crop&w=1200&q=85", chips: ["Electrical", "Plumbing", "Leaks", "Fixtures"]),
        .init(name: "Appliance Repair", subtitle: "AC, fridge, washer & more", imageURL: "https://images.unsplash.com/photo-1626806787461-102c1bfaaea1?auto=format&fit=crop&w=1200&q=85", chips: ["Washer", "Dryer", "Fridge", "Dishwasher"]),
        .init(name: "Pest Control", subtitle: "Safe home treatments", imageURL: "https://images.unsplash.com/photo-1581579185169-7d6a6f78ec82?auto=format&fit=crop&w=1200&q=85", chips: ["Apartment", "Villa", "Treatment", "Follow-up"])
    ]

    static let providers: [V4Provider] = [
        .init(name: "Sparkle Home Services", category: "Cleaning", rating: 4.8, reviews: 320, location: "Dubai", price: "From AED 80/hour", nextSlot: "Today · 14:00", imageURL: "https://images.unsplash.com/photo-1581578731548-c64695cc6952?auto=format&fit=crop&w=1200&q=90", about: "Regular, deep and move-out cleaning for apartments and villas. Scope and final price are confirmed before booking.", tags: ["Deep cleaning", "Move-out", "Supplies included"], slots: ["Today · 14:00", "Today · 18:00", "Tomorrow · 09:00"]),
        .init(name: "CleanPro Dubai", category: "Cleaning", rating: 4.7, reviews: 215, location: "Dubai Marina", price: "From AED 90/hour", nextSlot: "Tomorrow · 10:00", imageURL: "https://images.unsplash.com/photo-1527515637462-cff94eecc1ac?auto=format&fit=crop&w=1200&q=90", about: "Flexible apartment and villa cleaning with regular and one-off options.", tags: ["Apartment", "Villa", "Eco products"], slots: ["Tomorrow · 10:00", "Tomorrow · 15:00", "Sunday · 09:00"]),
        .init(name: "MovePro UAE", category: "Moving", rating: 4.8, reviews: 281, location: "Dubai", price: "From AED 850", nextSlot: "Tomorrow · 08:00", imageURL: "https://images.unsplash.com/photo-1600518464441-9154a4dea21b?auto=format&fit=crop&w=1200&q=90", about: "Apartment and villa moves with optional packing, boxes and unpacking.", tags: ["Packing", "Truck", "Unpacking"], slots: ["Tomorrow · 08:00", "Tomorrow · 12:00", "Sunday · 08:00"]),
        .init(name: "ColorTop Painting", category: "Painting", rating: 4.7, reviews: 119, location: "Dubai", price: "From AED 600", nextSlot: "In 2 days", imageURL: "https://images.unsplash.com/photo-1562259949-e8e7689d7828?auto=format&fit=crop&w=1200&q=90", about: "Interior touch-ups, room painting and full-property repainting.", tags: ["Touch-up", "Full repaint", "Move-out"], slots: ["Monday · 08:30", "Monday · 13:00", "Tuesday · 09:00"]),
        .init(name: "FixRight Home Care", category: "Maintenance", rating: 4.8, reviews: 287, location: "Dubai", price: "From AED 120", nextSlot: "Today · 20:00", imageURL: "https://images.unsplash.com/photo-1621905251918-48416bd8575a?auto=format&fit=crop&w=1200&q=90", about: "General handyman, AC troubleshooting and common home maintenance jobs.", tags: ["Handyman", "AC", "Minor repairs"], slots: ["Today · 20:00", "Tomorrow · 10:00", "Tomorrow · 16:00"]),
        .init(name: "BoxSafe Storage", category: "Storage", rating: 4.6, reviews: 121, location: "Al Quoz", price: "From AED 199/month", nextSlot: "Pickup tomorrow", imageURL: "https://images.unsplash.com/photo-1600566753190-17f0baa2a6c3?auto=format&fit=crop&w=1200&q=90", about: "Short- and long-term storage with optional pickup.", tags: ["Pickup", "Short-term", "Long-term"], slots: ["Tomorrow · AM", "Tomorrow · PM", "Sunday · AM"]),
        .init(name: "HomeFlow Technical", category: "Electrical & Plumbing", rating: 4.7, reviews: 166, location: "Dubai", price: "From AED 150", nextSlot: "Today · 19:00", imageURL: "https://images.unsplash.com/photo-1504148455328-c376907d081c?auto=format&fit=crop&w=1200&q=90", about: "Common residential electrical and plumbing visits with scope confirmed before attendance.", tags: ["Electrical", "Plumbing", "Home visits"], slots: ["Today · 19:00", "Tomorrow · 09:30", "Tomorrow · 15:00"]),
        .init(name: "ApplianceCare Dubai", category: "Appliance Repair", rating: 4.5, reviews: 132, location: "Dubai", price: "From AED 130", nextSlot: "Tomorrow · 11:00", imageURL: "https://images.unsplash.com/photo-1626806787461-102c1bfaaea1?auto=format&fit=crop&w=1200&q=90", about: "Diagnostics and common home appliance repair visits.", tags: ["Washer", "Dryer", "Kitchen appliances"], slots: ["Tomorrow · 11:00", "Tomorrow · 15:00", "Sunday · 12:00"]),
        .init(name: "SafeHome Pest Control", category: "Pest Control", rating: 4.8, reviews: 201, location: "Dubai", price: "From AED 180", nextSlot: "Tomorrow · 08:30", imageURL: "https://images.unsplash.com/photo-1581579185169-7d6a6f78ec82?auto=format&fit=crop&w=1200&q=90", about: "Residential pest-control visits with service scope confirmed before booking.", tags: ["Apartment", "Villa", "Follow-up"], slots: ["Tomorrow · 08:30", "Tomorrow · 13:30", "Sunday · 09:00"])
    ]
}

struct V4RemotePhoto: View {
    let url: String

    var body: some View {
        AsyncImage(url: URL(string: url)) { phase in
            switch phase {
            case .success(let image): image.resizable().scaledToFill()
            case .empty: ZStack { DMTheme.cardMuted; ProgressView().tint(DMTheme.green) }
            default: LinearGradient(colors: [DMTheme.greenDeep, DMTheme.green], startPoint: .topLeading, endPoint: .bottomTrailing)
            }
        }
    }
}

struct ServicesMarketplaceV4View: View {
    @State private var search = ""

    private let columns = [
        GridItem(.flexible(minimum: 0), spacing: 12),
        GridItem(.flexible(minimum: 0), spacing: 12)
    ]

    private var categories: [V4Category] {
        search.isEmpty ? V4MarketplaceData.categories : V4MarketplaceData.categories.filter {
            $0.name.localizedCaseInsensitiveContains(search) || $0.subtitle.localizedCaseInsensitiveContains(search)
        }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Services")
                        .font(.system(size: 40, weight: .bold, design: .rounded))
                    Text("Professional help for your home and move. Compare providers, check availability and book from one place.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }

                HStack(spacing: 12) {
                    Image(systemName: "magnifyingglass")
                        .font(.title3)
                        .foregroundStyle(.secondary)
                    TextField("Search services or providers…", text: $search)
                        .textInputAutocapitalization(.never)
                }
                .padding(.horizontal, 16)
                .frame(height: 54)
                .background(.white)
                .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                .shadow(color: .black.opacity(0.04), radius: 8, y: 3)

                LazyVGrid(columns: columns, spacing: 14) {
                    ForEach(categories) { category in
                        NavigationLink(destination: ServiceCategoryV4View(category: category)) {
                            categoryCard(category)
                        }
                        .buttonStyle(.plain)
                    }
                }

                ecoFriendlyBanner
            }
            .padding(.horizontal, 16)
            .padding(.top, 8)
            .padding(.bottom, 34)
        }
        .background(Color(uiColor: .systemGroupedBackground).ignoresSafeArea())
        .navigationBarTitleDisplayMode(.inline)
    }

    private func categoryCard(_ category: V4Category) -> some View {
        VStack(spacing: 0) {
            V4RemotePhoto(url: category.imageURL)
                .frame(maxWidth: .infinity)
                .frame(height: 112)
                .clipped()

            HStack(spacing: 8) {
                ZStack {
                    Circle().fill(iconBackground(for: category.name))
                    Image(systemName: iconName(for: category.name))
                        .font(.system(size: 17, weight: .bold))
                        .foregroundStyle(iconColor(for: category.name))
                }
                .frame(width: 38, height: 38)
                .fixedSize()

                VStack(alignment: .leading, spacing: 3) {
                    Text(category.name)
                        .font(.subheadline.bold())
                        .foregroundStyle(DMTheme.ink)
                        .lineLimit(2)
                        .minimumScaleFactor(0.78)
                        .multilineTextAlignment(.leading)
                    Text(category.subtitle)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                        .minimumScaleFactor(0.85)
                        .multilineTextAlignment(.leading)
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                Image(systemName: "chevron.right")
                    .font(.caption.bold())
                    .foregroundStyle(DMTheme.ink.opacity(0.65))
                    .frame(width: 28, height: 28)
                    .background(Color(uiColor: .secondarySystemGroupedBackground))
                    .clipShape(Circle())
                    .fixedSize()
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 10)
            .frame(maxWidth: .infinity, minHeight: 84, alignment: .leading)
            .background(.white)
        }
        .frame(maxWidth: .infinity)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color.black.opacity(0.04), lineWidth: 1))
        .shadow(color: .black.opacity(0.06), radius: 10, y: 5)
    }

    private var ecoFriendlyBanner: some View {
        HStack(spacing: 14) {
            Image(systemName: "leaf.fill")
                .font(.title2)
                .foregroundStyle(DMTheme.green)
                .frame(width: 46, height: 46)
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
            Spacer(minLength: 4)
            Image(systemName: "chevron.right")
                .font(.caption.bold())
                .foregroundStyle(DMTheme.green)
        }
        .padding(16)
        .background(DMTheme.mint.opacity(0.65))
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }

    private func iconName(for category: String) -> String {
        switch category {
        case "Cleaning": return "sparkles"
        case "Moving": return "truck.box.fill"
        case "Painting": return "paintbrush.fill"
        case "Maintenance": return "wrench.and.screwdriver.fill"
        case "Storage": return "shippingbox.fill"
        case "Electrical & Plumbing": return "bolt.fill"
        case "Appliance Repair": return "gearshape.fill"
        case "Pest Control": return "ant.fill"
        default: return "square.grid.2x2.fill"
        }
    }

    private func iconBackground(for category: String) -> Color {
        switch category {
        case "Cleaning": return Color.blue.opacity(0.14)
        case "Moving": return DMTheme.mint
        case "Painting": return Color.red.opacity(0.12)
        case "Maintenance": return Color.yellow.opacity(0.22)
        case "Storage": return Color.purple.opacity(0.14)
        case "Electrical & Plumbing": return Color.orange.opacity(0.16)
        case "Appliance Repair": return Color.cyan.opacity(0.14)
        case "Pest Control": return Color.red.opacity(0.12)
        default: return DMTheme.cardMuted
        }
    }

    private func iconColor(for category: String) -> Color {
        switch category {
        case "Cleaning": return .blue
        case "Moving": return DMTheme.green
        case "Painting": return .red
        case "Maintenance": return .orange
        case "Storage": return .purple
        case "Electrical & Plumbing": return .orange
        case "Appliance Repair": return .cyan
        case "Pest Control": return .red
        default: return DMTheme.green
        }
    }
}

struct ServiceCategoryV4View: View {
    let category: V4Category
    @State private var search = ""
    @State private var selectedChip = "All"

    private var providers: [V4Provider] {
        V4MarketplaceData.providers.filter {
            $0.category == category.name && (search.isEmpty || $0.name.localizedCaseInsensitiveContains(search))
        }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                ZStack(alignment: .bottomLeading) {
                    V4RemotePhoto(url: category.imageURL)
                    LinearGradient(colors: [.clear, .black.opacity(0.72)], startPoint: .center, endPoint: .bottom)
                    VStack(alignment: .leading, spacing: 5) {
                        Text(category.name).font(.largeTitle.bold()).lineLimit(2).minimumScaleFactor(0.8)
                        Text(category.subtitle).font(.subheadline)
                    }
                    .foregroundStyle(.white)
                    .padding(18)
                }
                .frame(height: 230)
                .clipShape(RoundedRectangle(cornerRadius: 28))

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack { chip("All"); ForEach(category.chips, id: \.self) { chip($0) } }
                }

                HStack {
                    Image(systemName: "magnifyingglass").foregroundStyle(.secondary)
                    TextField("Search providers", text: $search)
                }
                .padding(.horizontal, 14)
                .frame(height: 48)
                .background(.white)
                .clipShape(RoundedRectangle(cornerRadius: 16))

                Text("\(providers.count) providers").font(.headline)

                ForEach(providers) { provider in
                    NavigationLink(destination: ProviderV4DetailView(provider: provider)) {
                        providerCard(provider)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(16)
            .padding(.bottom, 24)
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

    private func providerCard(_ p: V4Provider) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            V4RemotePhoto(url: p.imageURL)
                .frame(height: 180)
                .clipped()
                .clipShape(RoundedRectangle(cornerRadius: 18))

            HStack(alignment: .top, spacing: 6) {
                Text(p.name)
                    .font(.title3.bold())
                    .foregroundStyle(DMTheme.ink)
                    .lineLimit(2)
                    .minimumScaleFactor(0.85)
                Image(systemName: "checkmark.seal.fill").foregroundStyle(DMTheme.green)
                Spacer(minLength: 6)
                HStack(spacing: 3) {
                    Text(String(format: "%.1f", p.rating)).bold()
                    Image(systemName: "star.fill").foregroundStyle(.orange)
                }
                .foregroundStyle(DMTheme.ink)
                .fixedSize()
            }

            Text(p.category).font(.caption.bold()).foregroundStyle(DMTheme.green)
            HStack {
                Label(p.location, systemImage: "mappin.and.ellipse")
                Spacer()
                Text("\(p.reviews) reviews")
            }
            .font(.caption)
            .foregroundStyle(.secondary)

            HStack(alignment: .firstTextBaseline, spacing: 8) {
                Text(p.nextSlot).font(.caption.bold()).foregroundStyle(DMTheme.green).lineLimit(2)
                Spacer(minLength: 6)
                Text(p.price).font(.headline).foregroundStyle(DMTheme.ink).multilineTextAlignment(.trailing).lineLimit(2)
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
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 24))
        .shadow(color: .black.opacity(0.07), radius: 10, y: 5)
    }
}

struct ProviderV4DetailView: View {
    let provider: V4Provider
    @State private var selectedSlot: String?
    @State private var message = ""

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                V4RemotePhoto(url: provider.imageURL)
                    .frame(height: 270)
                    .clipped()
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
                .v4Surface()

                VStack(alignment: .leading, spacing: 10) {
                    Text("Services").font(.headline)
                    ForEach(provider.tags, id: \.self) { Label($0, systemImage: "checkmark.circle.fill").foregroundStyle(DMTheme.green) }
                }
                .v4Surface()

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
                .v4Surface()

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
                .v4Surface()

                Text("Provider listings shown in backend-free TestFlight mode are sample marketplace data. Live listings, availability, booking and chat will come from the connected provider platform.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding(16)
            .padding(.bottom, 24)
        }
        .background(Color(uiColor: .systemGroupedBackground).ignoresSafeArea())
        .navigationTitle(provider.name)
        .navigationBarTitleDisplayMode(.inline)
    }
}

private extension View {
    func v4Surface() -> some View {
        self
            .padding(16)
            .background(DMTheme.card)
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .overlay(RoundedRectangle(cornerRadius: 20).stroke(DMTheme.border, lineWidth: 1))
    }
}
