import SwiftUI

@main
struct PetPalsApp: App {
    @StateObject private var game = PetGame()
    var body: some Scene {
        WindowGroup { PetPalsRoot().environmentObject(game) }
    }
}

// MARK: - Model

struct Pet: Identifiable, Codable, Hashable {
    var id = UUID()
    var name: String
    var species: String
    var color: String
    var gender: String
    var level = 5
    var hp = 345
    var maxHP = 534
    var strength = 53
    var agility = 23
    var defense = 53
    var intelligence = 13
}

@MainActor
final class PetGame: ObservableObject {
    @Published var pets: [Pet] = [] { didSet { persist() } }
    @Published var selectedID: UUID? { didSet { UserDefaults.standard.set(selectedID?.uuidString, forKey: "petpals.selected") } }
    @Published var pebbles = 204_871
    @Published var sparks = 1_460
    private let key = "petpals.roster"

    init() {
        if let data = UserDefaults.standard.data(forKey: key),
           let decoded = try? JSONDecoder().decode([Pet].self, from: data), !decoded.isEmpty {
            pets = decoded
        } else {
            pets = [
                Pet(name: "Cooper", species: "Glimmoo", color: "Sky", gender: "Male"),
                Pet(name: "Riley", species: "Bunnoo", color: "Berry", gender: "Female"),
                Pet(name: "Tucker", species: "Snorbit", color: "Mint", gender: "Male"),
                Pet(name: "Bella", species: "Fluffet", color: "Sunny", gender: "Female"),
                Pet(name: "Cookie", species: "Wingle", color: "Sky", gender: "Female"),
                Pet(name: "Abby", species: "Toadle", color: "Mint", gender: "Female")
            ]
        }
        if let s = UserDefaults.standard.string(forKey: "petpals.selected"),
           let id = UUID(uuidString: s), pets.contains(where: { $0.id == id }) {
            selectedID = id
        } else { selectedID = pets.first?.id }
    }

    var selected: Pet? { pets.first(where: { $0.id == selectedID }) ?? pets.first }
    func choose(_ pet: Pet) { selectedID = pet.id }
    func create(name: String, species: String, color: String, gender: String) {
        let pet = Pet(name: name, species: species, color: color, gender: gender)
        pets.insert(pet, at: 0); selectedID = pet.id
    }
    private func persist() {
        if let data = try? JSONEncoder().encode(pets) { UserDefaults.standard.set(data, forKey: key) }
    }
}

// MARK: - Navigation and theme

enum Screen: String, CaseIterable {
    case home = "Home", create = "Create", pets = "My Pets", profile = "Profile"
    var icon: String {
        switch self {
        case .home: "house.fill"
        case .create: "plus.square.fill"
        case .pets: "pawprint.fill"
        case .profile: "person.crop.circle.fill"
        }
    }
}

struct Palette {
    static let yellow = Color(red: 1.0, green: 0.78, blue: 0.10)
    static let paleYellow = Color(red: 1.0, green: 0.93, blue: 0.62)
    static let ink = Color(red: 0.12, green: 0.16, blue: 0.27)
    static let page = Color(red: 0.93, green: 0.95, blue: 1.0)
    static let paper = Color.white
    static let gold = Color(red: 0.76, green: 0.55, blue: 0.12)
    static let bar = Color(red: 0.36, green: 0.31, blue: 0.81)
    static let sky = Color(red: 0.74, green: 0.91, blue: 0.96)
}

struct PetPalsRoot: View {
    @EnvironmentObject private var game: PetGame
    @State private var screen: Screen = .home
    var body: some View {
        VStack(spacing: 0) {
            topBar
            Group {
                switch screen {
                case .home: DashboardView { screen = .create }
                case .create: CreatePetView { screen = .home }
                case .pets: RosterView()
                case .profile: ProfileView()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            bottomBar
        }
        .background(Palette.page)
        .preferredColorScheme(.light)
    }
    private var topBar: some View {
        VStack(spacing: 0) {
            HStack(spacing: 8) {
                Text("✦").font(.system(size: 19, weight: .black))
                Text("PETPALS").font(.system(size: 22, weight: .black, design: .rounded))
                Spacer()
                HStack(spacing: 4) {
                    Image(systemName: "circle.hexagongrid.fill")
                    Text("\(game.pebbles.formatted())")
                }
                .font(.system(size: 10, weight: .heavy, design: .rounded))
                .padding(.horizontal, 8).padding(.vertical, 6)
                .background(.white.opacity(0.86), in: Capsule())
                HStack(spacing: 4) {
                    Image(systemName: "sparkle")
                    Text("\(game.sparks.formatted())")
                }
                .font(.system(size: 10, weight: .heavy, design: .rounded))
                .padding(.horizontal, 8).padding(.vertical, 6)
                .background(.white.opacity(0.86), in: Capsule())
            }
            .foregroundStyle(Palette.ink)
            .padding(.horizontal, 14).padding(.vertical, 11)
            Text("YOUR LITTLE WORLD  •  ADVENTURE AWAITS")
                .font(.system(size: 8, weight: .black, design: .rounded))
                .tracking(2).frame(maxWidth: .infinity).padding(.vertical, 4)
                .background(Palette.ink.opacity(0.08))
        }
        .background(Palette.yellow)
        .overlay(alignment: .bottom) { Rectangle().fill(Palette.gold.opacity(0.6)).frame(height: 2) }
    }
    private var bottomBar: some View {
        HStack(spacing: 0) {
            ForEach(Screen.allCases, id: \.self) { item in
                Button { screen = item } label: {
                    VStack(spacing: 4) {
                        Image(systemName: item.icon).font(.system(size: 18, weight: .bold))
                        Text(item.rawValue).font(.system(size: 10, weight: .heavy, design: .rounded))
                    }
                    .foregroundStyle(screen == item ? Palette.ink : .gray)
                    .frame(maxWidth: .infinity).padding(.vertical, 9)
                    .background(screen == item ? Palette.yellow.opacity(0.32) : .white)
                }.buttonStyle(.plain)
            }
        }
        .background(.white)
        .overlay(alignment: .top) { Rectangle().fill(.black.opacity(0.16)).frame(height: 1) }
    }
}

struct Panel<Content: View>: View {
    let title: String
    @ViewBuilder var content: Content
    var body: some View {
        VStack(spacing: 0) {
            Text(title.uppercased())
                .font(.system(size: 11, weight: .black, design: .rounded))
                .tracking(1)
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 12).padding(.vertical, 9)
                .background(Palette.bar)
            content
        }
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Palette.ink.opacity(0.25), lineWidth: 1.5))
        .shadow(color: Palette.ink.opacity(0.10), radius: 0, y: 2)
    }
}

// MARK: - Dashboard

struct DashboardView: View {
    @EnvironmentObject private var game: PetGame
    let onCreate: () -> Void
    var body: some View {
        ScrollView {
            VStack(spacing: 12) {
                if let pet = game.selected {
                    Panel(title: "Pet Info  •  \(pet.name)") {
                        VStack(spacing: 12) {
                            HStack(alignment: .top, spacing: 14) {
                                VStack(spacing: 5) {
                                    ZStack {
                                        RoundedRectangle(cornerRadius: 10).fill(Palette.sky)
                                        CreatureView(species: pet.species, color: pet.color).padding(6)
                                    }.frame(width: 116, height: 110)
                                    Text("\(pet.level) months").font(.system(size: 12, weight: .black, design: .rounded))
                                }
                                VStack(alignment: .leading, spacing: 8) {
                                    InfoLine(label: "Name", value: pet.name)
                                    InfoLine(label: "Gender", value: pet.gender)
                                    InfoLine(label: "Species", value: pet.species)
                                    InfoLine(label: "Color", value: pet.color)
                                    InfoLine(label: "Last spotted", value: "Just now")
                                    Spacer(minLength: 0)
                                }.padding(.top, 3)
                                Spacer(minLength: 0)
                            }
                            HStack(spacing: 0) {
                                QuickAction(icon: "flag.fill", title: "Trades")
                                QuickAction(icon: "hammer.fill", title: "Auctions")
                                QuickAction(icon: "scroll.fill", title: "Wishlist")
                                QuickAction(icon: "envelope.fill", title: "Mail")
                                QuickAction(icon: "face.smiling.fill", title: "Friends")
                            }
                        }.padding(12)
                    }
                    Panel(title: "Pet stats") {
                        VStack(spacing: 9) {
                            HStack {
                                Text("HEALTH").font(.system(size: 10, weight: .black))
                                Spacer()
                                Text("\(pet.hp)/\(pet.maxHP) HP").font(.system(size: 10, weight: .black))
                            }
                            GeometryReader { geo in
                                ZStack(alignment: .leading) {
                                    Capsule().fill(.gray.opacity(0.2))
                                    Capsule().fill(Color(red: 0.20, green: 0.59, blue: 0.34))
                                        .frame(width: geo.size.width * CGFloat(pet.hp) / CGFloat(pet.maxHP))
                                }
                            }.frame(height: 9)
                            HStack(spacing: 7) {
                                StatBadge(label: "STR", value: pet.strength, color: .red)
                                StatBadge(label: "AGI", value: pet.agility, color: .blue)
                                StatBadge(label: "DEF", value: pet.defense, color: .orange)
                                StatBadge(label: "INT", value: pet.intelligence, color: .green)
                            }
                        }.padding(12)
                    }
                }
                Panel(title: "Your pets") {
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 8) {
                        ForEach(game.pets) { pet in
                            Button { game.choose(pet) } label: {
                                VStack(spacing: 4) {
                                    CreatureView(species: pet.species, color: pet.color).frame(height: 52)
                                    Text(pet.name).font(.system(size: 11, weight: .bold, design: .rounded)).lineLimit(1)
                                }
                                .frame(maxWidth: .infinity).padding(.vertical, 7)
                                .background(game.selectedID == pet.id ? Palette.paleYellow.opacity(0.65) : .white)
                                .clipShape(RoundedRectangle(cornerRadius: 7))
                                .overlay(RoundedRectangle(cornerRadius: 7).stroke(.black.opacity(game.selectedID == pet.id ? 0.22 : 0.05)))
                            }.buttonStyle(.plain).foregroundStyle(Palette.ink)
                        }
                    }.padding(9)
                }
                Panel(title: "Collections") {
                    HStack(spacing: 0) {
                        CollectionItem(icon: "seal.fill", title: "Badges", count: "11")
                        CollectionItem(icon: "rosette", title: "Stickers", count: "0")
                        CollectionItem(icon: "star.fill", title: "Themes", count: "1")
                        CollectionItem(icon: "key.fill", title: "Keys", count: "1")
                    }.padding(.vertical, 12)
                }
                Button(action: onCreate) {
                    Label("CREATE A PET", systemImage: "plus.circle.fill")
                        .font(.system(size: 14, weight: .black, design: .rounded))
                        .frame(maxWidth: .infinity).padding(14)
                        .background(Palette.yellow, in: RoundedRectangle(cornerRadius: 12))
                        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Palette.ink.opacity(0.25), lineWidth: 1.5))
                }.buttonStyle(.plain).foregroundStyle(Palette.ink)
            }.padding(12)
        }
    }
}

struct InfoLine: View {
    let label: String
    let value: String
    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 4) {
            Text(label + ":").font(.system(size: 11, weight: .bold))
            Text(value).font(.system(size: 11, weight: .medium))
                .lineLimit(1).minimumScaleFactor(0.75)
        }.foregroundStyle(Palette.ink)
    }
}

struct QuickAction: View {
    let icon: String
    let title: String
    var body: some View {
        VStack(spacing: 5) {
            Image(systemName: icon).font(.system(size: 18, weight: .semibold)).foregroundStyle(Palette.gold)
            Text(title).font(.system(size: 8, weight: .bold)).lineLimit(1).minimumScaleFactor(0.7)
        }.frame(maxWidth: .infinity)
    }
}

struct StatBadge: View {
    let label: String
    let value: Int
    let color: Color
    var body: some View {
        VStack(spacing: 3) {
            Text(label).font(.system(size: 9, weight: .black))
            Text("\(value)").font(.system(size: 16, weight: .black, design: .rounded))
        }
        .foregroundStyle(Palette.ink)
        .frame(maxWidth: .infinity).padding(.vertical, 7)
        .background(color.opacity(0.18), in: RoundedRectangle(cornerRadius: 6))
        .overlay(RoundedRectangle(cornerRadius: 6).stroke(color.opacity(0.65), lineWidth: 1))
    }
}

struct CollectionItem: View {
    let icon: String
    let title: String
    let count: String
    var body: some View {
        VStack(spacing: 5) {
            Image(systemName: icon).font(.system(size: 22, weight: .bold)).foregroundStyle(Palette.gold)
                .frame(height: 28)
            Text(title).font(.system(size: 8, weight: .bold)).multilineTextAlignment(.center).lineLimit(2).frame(height: 22)
            Text(count).font(.system(size: 10, weight: .black))
        }.frame(maxWidth: .infinity)
    }
}

// MARK: - Create a pet

struct CreatePetView: View {
    @EnvironmentObject private var game: PetGame
    let onDone: () -> Void
    @State private var species = SpeciesInfo.all[0].name
    @State private var color = PetColor.sky
    @State private var name = ""
    @State private var gender = "Male"
    @State private var showError = false

    var body: some View {
        ScrollView {
            VStack(spacing: 12) {
                Panel(title: "Create-a-pet") {
                    VStack(spacing: 11) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 9).fill(Palette.sky)
                            ForEach(0..<5, id: \.self) { i in
                                Capsule().fill(.white.opacity(0.75))
                                    .frame(width: CGFloat(44 + (i % 3) * 16), height: 14)
                                    .offset(x: CGFloat((i * 71) % 220 - 110), y: CGFloat((i * 37) % 120 - 60))
                            }
                            VStack(spacing: 2) {
                                CreatureView(species: species, color: color.rawValue).frame(width: 120, height: 120)
                                Text("\(color.rawValue.uppercased()) \(species.uppercased())")
                                    .font(.system(size: 11, weight: .black, design: .rounded))
                                    .foregroundStyle(Palette.ink)
                            }
                        }.frame(height: 190)
                        Text("SELECT SPECIES").font(.system(size: 10, weight: .black, design: .rounded)).frame(maxWidth: .infinity, alignment: .leading)
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 4), spacing: 7) {
                            ForEach(SpeciesInfo.all) { item in
                                Button { species = item.name } label: {
                                    VStack(spacing: 4) {
                                        CreatureView(species: item.name, color: color.rawValue).frame(height: 46)
                                        Text(item.name.uppercased()).font(.system(size: 8, weight: .black, design: .rounded)).lineLimit(1).minimumScaleFactor(0.7)
                                    }.frame(maxWidth: .infinity).padding(.vertical, 8)
                                        .background(species == item.name ? Palette.yellow : .white)
                                        .clipShape(RoundedRectangle(cornerRadius: 7))
                                        .overlay(RoundedRectangle(cornerRadius: 7).stroke(.black.opacity(species == item.name ? 0.35 : 0.10)))
                                }.buttonStyle(.plain).foregroundStyle(Palette.ink)
                            }
                        }
                        Text("COLOR").font(.system(size: 10, weight: .black, design: .rounded)).frame(maxWidth: .infinity, alignment: .leading)
                        HStack(spacing: 5) {
                            ForEach(PetColor.allCases, id: \.self) { item in
                                Button { color = item } label: {
                                    VStack(spacing: 4) {
                                        RoundedRectangle(cornerRadius: 3).fill(item.base).frame(height: 15)
                                            .overlay(RoundedRectangle(cornerRadius: 3).stroke(.black.opacity(0.2)))
                                        Text(item.rawValue.uppercased()).font(.system(size: 8, weight: .black))
                                    }.padding(5).frame(maxWidth: .infinity)
                                        .background(color == item ? Palette.paleYellow : .white, in: RoundedRectangle(cornerRadius: 6))
                                }.buttonStyle(.plain).foregroundStyle(Palette.ink)
                            }
                        }
                        VStack(alignment: .leading, spacing: 5) {
                            Text("PET NAME").font(.system(size: 10, weight: .black, design: .rounded))
                            TextField("Enter a name", text: $name)
                                .textInputAutocapitalization(.words)
                                .padding(11).background(.white, in: RoundedRectangle(cornerRadius: 5))
                                .overlay(RoundedRectangle(cornerRadius: 5).stroke(.black.opacity(0.2)))
                        }
                        VStack(alignment: .leading, spacing: 5) {
                            Text("GENDER").font(.system(size: 10, weight: .black, design: .rounded))
                            Picker("Gender", selection: $gender) {
                                Text("Male").tag("Male")
                                Text("Female").tag("Female")
                            }.pickerStyle(.segmented)
                        }
                        if showError {
                            Text("Enter a name between 2 and 16 characters.")
                                .font(.system(size: 11, weight: .semibold)).foregroundStyle(.red)
                        }
                        Button {
                            let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
                            guard (2...16).contains(trimmed.count) else { showError = true; return }
                            game.create(name: trimmed, species: species, color: color.rawValue, gender: gender)
                            onDone()
                        } label: {
                            Text("CREATE MY PET")
                                .font(.system(size: 14, weight: .black, design: .rounded))
                                .frame(maxWidth: .infinity).padding(13)
                                .background(Palette.yellow, in: RoundedRectangle(cornerRadius: 7))
                        }.buttonStyle(.plain).foregroundStyle(Palette.ink)
                    }.padding(11).background(Color(red: 1.0, green: 0.95, blue: 0.75))
                }
            }.padding(12)
        }
    }
}

// MARK: - Roster and profile

struct RosterView: View {
    @EnvironmentObject private var game: PetGame
    var body: some View {
        ScrollView {
            Panel(title: "Your pets") {
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 8) {
                    ForEach(game.pets) { pet in
                        Button { game.choose(pet) } label: {
                            VStack(spacing: 6) {
                                CreatureView(species: pet.species, color: pet.color).frame(height: 64)
                                Text(pet.name).font(.system(size: 13, weight: .black, design: .rounded))
                                Text("Lv \(pet.level) • \(pet.color) \(pet.species)").font(.system(size: 9, weight: .medium)).foregroundStyle(.secondary)
                            }.frame(maxWidth: .infinity).padding(12).background(game.selectedID == pet.id ? Palette.paleYellow : .white)
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                                .overlay(RoundedRectangle(cornerRadius: 8).stroke(.black.opacity(0.12)))
                        }.buttonStyle(.plain).foregroundStyle(Palette.ink)
                    }
                }.padding(10)
            }.padding(12)
        }
    }
}

struct ProfileView: View {
    @EnvironmentObject private var game: PetGame
    var body: some View {
        ScrollView {
            Panel(title: "Player profile") {
                VStack(spacing: 12) {
                    Image(systemName: "star.fill").font(.system(size: 54)).foregroundStyle(Palette.yellow)
                    Text("PetPals Player").font(.system(size: 22, weight: .black, design: .rounded))
                    Text("Virtual pet collector").font(.system(size: 12, weight: .medium)).foregroundStyle(.secondary)
                    Divider()
                    HStack {
                        ProfileMetric(value: "\(game.pets.count)", label: "PETS")
                        ProfileMetric(value: game.pebbles.formatted(), label: "PEBBLES")
                        ProfileMetric(value: "11", label: "BADGES")
                    }
                    Text("Your progress is saved on this iPhone.")
                        .font(.system(size: 11, weight: .medium)).foregroundStyle(.secondary)
                }.padding(18).frame(maxWidth: .infinity).background(.white)
            }.padding(12)
        }
    }
}

struct ProfileMetric: View {
    let value: String
    let label: String
    var body: some View {
        VStack(spacing: 5) {
            Text(value).font(.system(size: 17, weight: .black, design: .rounded))
            Text(label).font(.system(size: 9, weight: .heavy)).foregroundStyle(.secondary)
        }.frame(maxWidth: .infinity)
    }
}
