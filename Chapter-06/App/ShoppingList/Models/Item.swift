import Foundation

class Item: Codable {
  var id: String?
  var name: String
  var isChecked: Bool
  var shoppingListId: String
  var data: Data? {
    get {
      let parameters = [
        "name": name,
        "is_checked": isChecked,
        "shopping_list__id": shoppingListId
        ] as [String : Any]
      do {
        return try JSONSerialization.data(withJSONObject: parameters, options: [])
      } catch {
        return .none
      }
    }
  }
  
  init(name: String, shoppingListId: String, isChecked: Bool = false) {
    self.name = name
    self.shoppingListId = shoppingListId
    self.isChecked = isChecked
  }
  
  func toggleCheck(onCompletion: @escaping (Item) -> Void) {
    self.isChecked = !self.isChecked
    request(url: "/items/\(id!)", httpMethod: "PATCH", httpBody: data) { data, _, _ in
      let decoder = JSONDecoder()
      let item = try decoder.decode(Item.self, from: data!)
      onCompletion(item)
    }
  }

  private enum CodingKeys: String, CodingKey {
    case id
    case name
    case isChecked = "is_checked"
    case shoppingListId = "shopping_list__id"
  }
}

