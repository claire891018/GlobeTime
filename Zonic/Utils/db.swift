import Foundation
import SQLite

func loadDb() -> Connection? {
  // TODO: reduce bundle size by shipping db.sqlite3.gz (5MB) instead of db.sqlite3 (19.6MB)
  do {
    let fileManager = FileManager.default
    let applicationSupport = try fileManager.url(
      for: .applicationSupportDirectory,
      in: .userDomainMask,
      appropriateFor: nil,
      create: true
    )
    let appDirectory = applicationSupport.appendingPathComponent("GlobeTime", isDirectory: true)
    try fileManager.createDirectory(at: appDirectory, withIntermediateDirectories: true)
    let fileURL = appDirectory.appendingPathComponent("db.sqlite3")
    
    if !fileManager.fileExists(atPath: fileURL.path) {
      if let bundleURL = Bundle.main.url(forResource: "db", withExtension: "sqlite3") {
        try fileManager.copyItem(at: bundleURL, to: fileURL)
      }
    }
    
    let db = try Connection(fileURL.path)
    return db
  } catch {
    print(error)
    return nil
  }
}

func fetchPlaces(db: Connection?, searchText: String) -> [Place] {
  do {
    if searchText == "" { return [] }
    guard let db = db else { return [] }
    
    var result: [Place] = []
    let places = SQLite.Table("places")
    let id = SQLite.Expression<Int64>("id")
    let name = SQLite.Expression<String>("name")
    let timezone = SQLite.Expression<String>("timezone")
    let flag = SQLite.Expression<String>("flag")
    let type = SQLite.Expression<String>("type")
    let order_by = Expression<Int>("""
            CASE type 
                WHEN 'country' THEN 1 
                WHEN 'state' THEN 2 
                WHEN 'city' THEN 3 
                ELSE 4 
                END
        """)
    
    let query =
    places
      .select(id, name, timezone, flag, type)
      .filter(name.like("\(searchText.lowercased())%"))
      .order(order_by)
      .limit(10)
    
    for place in try db.prepare(query) {
      let row = Place(
        id: place[id],
        name: place[name],
        timezone: place[timezone],
        flag: place[flag],
        type: place[type]
      )
      result.append(row)
    }
    
    return result
  } catch {
    print(error)
    return []
  }
}

func fetchFavorites(db: Connection?) -> [Favorite] {
  do {
    guard let db = db else { return [] }
    
    var result: [Favorite] = []
    let favorites = SQLite.Table("favorites")
    let places = SQLite.Table("places")
    
    let id = SQLite.Expression<Int64>("id")
    let label = SQLite.Expression<String>("label")
    let place_id = SQLite.Expression<Int64>("place_id")
    let created_at = SQLite.Expression<Date>("created_at")
    let name = SQLite.Expression<String>("name")
    let timezone = SQLite.Expression<String>("timezone")
    let flag = SQLite.Expression<String>("flag")
    let type = SQLite.Expression<String>("type")
    
    let query = favorites
      .join(places, on: favorites[place_id] == places[id])
      .order(favorites[created_at].desc)
    
    for favorite in try db.prepare(query) {
      let row = Favorite(
        id: favorite[favorites[id]],
        label: favorite[favorites[label]],
        //                TODO: need to fix this
        //                created_at: favorite[favorites[created_at]],
        place: Place(
          id: favorite[places[id]],
          name: favorite[places[name]],
          timezone: favorite[places[timezone]],
          flag: favorite[places[flag]],
          type: favorite[places[type]]
        )
      )
      result.append(row)
    }
    
    return result
  } catch {
    print(error)
    return []
  }
}

func addFavorite(db: Connection?, place: Place) {
  do {
    guard let db = db else { return }
    
    let favorites = SQLite.Table("favorites")
    let place_id = SQLite.Expression<Int64>("place_id")
    let label = SQLite.Expression<String>("label")
    
    try db.run(favorites.insert(place_id <- place.id, label <- place.name))
  } catch {
    print(error)
  }
}

func removeFavorite(db: Connection?, id: Int64) {
  do {
    guard let db = db else { return }
    
    let favorites = SQLite.Table("favorites")
    let favoriteId = SQLite.Expression<Int64>("id")
    
    try db.run(favorites.filter(favoriteId == id).delete())
  } catch {
    print(error)
  }
}

func updateFavorite(db: Connection?, id: Int64, to label: String) {
  do {
    guard let db = db else { return }
    
    let favorites = SQLite.Table("favorites")
    let favorite_id = SQLite.Expression<Int64>("id")
    let favorite_label = SQLite.Expression<String>("label")
    
    try db.run(favorites.filter(favorite_id == id).update(favorite_label <- label))
  } catch {
    print(error)
  }
}
