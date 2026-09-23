import SwiftUI
import SQLite
import AppKit

@main
struct GlobeTimeApp: App {
  @State var searchText: String = ""
  @State var places: [Place] = [];
  @State var favorites: [Favorite] = []
  @State var db: Connection? = loadDb()
  @State private var showAbout = false
  
  var body: some Scene {
    MenuBarExtra("GlobeTime", systemImage: "globe") {
      VStack(alignment: .leading, spacing: 10) {
        
        if !favorites.isEmpty {
          Text("Favorites")
            .font(.caption)
            .foregroundStyle(.secondary)

          ForEach(favorites, id: \.id) { favorite in
            HStack {
              Text(favorite.place.flag)
              Text(favorite.place.name)
                .lineLimit(1)
              Spacer()
              TimeField(timezone: favorite.place.timezone)
              Button {
                removeFavorite(db: db, id: favorite.id)
                favorites = fetchFavorites(db: db)
              } label: {
                Image(systemName: "trash")
              }
                .help("Remove from favorites")
                .buttonStyle(.plain)
            }
            .padding(.vertical, 2)
          }
          
          Divider()
        }
        
        if favorites.count < 20 {
          TextField("Search cities", text: $searchText)
            .onChange(of: searchText) { _, val in
              places = fetchPlaces(db: db, searchText: val)
            }
            .onSubmit {
              if let firstPlace = places.first {
                let isFavorite = favorites.contains(where: { $0.place.id == firstPlace.id })
                if !isFavorite {
                  addFavorite(db: db, place: firstPlace)
                  favorites = fetchFavorites(db: db)
                  searchText = ""
                  places = []
                }
              }
            }
          
          
          if searchText != "" {
            Divider()
            
            if places.isEmpty {
              Text("No places found")
            }
          }
          
          if !places.isEmpty {
            ForEach(places, id: \.id) { place in
              let isFavorite = favorites.contains(where: { $0.place.id == place.id })
              
              Button {
                if !isFavorite {
                  addFavorite(db: db, place: place)
                  favorites = fetchFavorites(db: db)
                  searchText = ""
                  places = []
                }
              } label: {
                HStack {
                  Text(place.flag)
                  Text(place.name)
                    .lineLimit(1)
                  Spacer()
                  TimeField(timezone: place.timezone)
                  Image(systemName: isFavorite ? "checkmark" : "plus")
                    .frame(width: 14)
                }
                .padding(.vertical, 2)
                .contentShape(Rectangle())
                .onHover { hovering in
                  if hovering {
                    NSCursor.pointingHand.push()
                  } else {
                    NSCursor.pop()
                  }
                }
              }
              .buttonStyle(.plain)
              .opacity(isFavorite ? 0.5 : 1)
            }
          }
        } else {
          Text("Max. 20 favorites are permitted")
            .onAppear {
              searchText = ""
              places = []
            }
        }
        
        Divider()
        
        HStack {
          Button {} label: {
            Image(systemName: "info.circle")
          }
          .help("About GlobeTime")
          .buttonStyle(.plain)
          .onHover(perform: { hovering in
            showAbout = hovering
          })
          .popover(isPresented: $showAbout, arrowEdge: .bottom) {
            VStack(spacing: 16) {
              Text("GlobeTime is based on Zonic, available under the MIT License. Location data is available under ODbL 1.0.")
                .multilineTextAlignment(.center)
                .font(.caption)
            }
            .padding()
            .frame(minWidth: 300)
          }
          
          Spacer()
          Button("Quit") {
            NSApplication.shared.terminate(self)
          }
          .buttonStyle(.plain)
        }
      }
      .padding()
      .frame(width: 360)
      .onAppear {
        favorites = fetchFavorites(db: db)
      }
      .onDisappear {
        searchText = ""
      }
    }
    .menuBarExtraStyle(.window)
  }
}
