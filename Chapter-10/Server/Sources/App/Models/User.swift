import FluentProvider
import HTTP
import Fluent
import AuthProvider

final class User: Model, SessionPersistable, TokenAuthenticatable {
  let storage = Storage()
  struct Keys {
    static let id = "id"
    static let name = "name"
    static let email = "email"
    static let password = "password"
  }

  var name: String
  var email: String
  var password: String
  public typealias TokenType = Token
  
  init(name: String, email: String, password: String) {
    self.name = name
    self.email = email
    self.password = password
  }

  init(row: Row) throws {
    name = try row.get(Keys.name)
    email = try row.get(Keys.email)
    password = try row.get(Keys.password)
  }

  func makeRow() throws -> Row {
    var row = Row()
    try row.set(Keys.name, name)
    try row.set(Keys.email, email)
    try row.set(Keys.password, password)
    return row
  }
}

extension User: PasswordAuthenticatable {
  var hashedPassword: String? {
    return password
  }
  
  public static var passwordVerifier: PasswordVerifier? {
    get { return _userPasswordVerifier }
    set { _userPasswordVerifier = newValue }
  }
}

private var _userPasswordVerifier: PasswordVerifier? = nil

extension Request {
  func user() throws -> User {
    return try auth.assertAuthenticated()
  }
}

extension User: Preparation {
  /// Prepares a table/collection in the database
  /// for storing Player
  static func prepare(_ database: Database) throws {
    try database.create(self) { builder in
      builder.id()
      builder.string(Keys.name)
      builder.string(Keys.email)
      builder.string(Keys.password)
    }
  }
  /// Undoes what was done in `prepare`
  static func revert(_ database: Database) throws {
    try database.delete(self)
  }
}

// MARK: JSON

// How the model converts from / to JSON.
// For example when:
//     - Creating a new Player
//     - Fetching a Player
//
extension User: JSONConvertible {
  convenience init(json: JSON) throws {
    try self.init(
      name: json.get(Keys.name),
      email: json.get(Keys.email),
      password: json.get(Keys.password)
    )
  }
  
  func makeJSON() throws -> JSON {
    var json = JSON()
    try json.set(Keys.id, id)
    try json.set(Keys.name, name)
    try json.set(Keys.email, email)
    return json
  }
}

// MARK: HTTP

// This allows Player models to be returned
// directly in route closures
extension User: ResponseRepresentable { }
