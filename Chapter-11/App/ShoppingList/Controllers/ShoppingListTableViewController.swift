import UIKit

class ShoppingListTableViewController: BaseTableViewController {
  
  var lists: [ShoppingList] = []
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    title = "Shopping Lists"
    #if TARGET_OS_IOS
    navigationController?.navigationBar.prefersLargeTitles = true
    refreshControl = UIRefreshControl()
    refreshControl?.addTarget(self, action: #selector(didPullDownForRefresh), for: .valueChanged)
    #endif

    navigationItem.rightBarButtonItems?.append(editButtonItem)
    loadData()
  }
  
  @IBAction func didSelectRefreshButton(_ sender: UIBarButtonItem) {
    loadData()
  }
  
  #if TARGET_OS_IOS
  @objc func didPullDownForRefresh(_ sender: UIRefreshControl) {
    loadData()
  }
  #endif
  
  func loadData() {
    ShoppingList.load() { lists in
      self.lists = lists
      self.tableView.reloadData()
      #if TARGET_OS_IOS
      self.refreshControl?.endRefreshing()
      #endif
    }
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
  }
  
  @IBAction func didSelectAdd(_ sender: UIBarButtonItem) {
    requestInput(title: "Shopping list name",
                 message: "Enter name for the new shopping list:",
                 handler: { (listName) in
                  let listCount = self.lists.count;
                  ShoppingList(name: listName).save() { list in
                    self.lists.append(list)
                    self.tableView.insertRows(at: [IndexPath(row: listCount, section: 0)], with: .top)
                  }
    })
  }

  @IBAction func didSelectLogoutButton(_ sender: UIBarButtonItem) {
    UserDefaults.standard.removeObject(forKey: String(describing: Token.self))
    UserDefaults.standard.synchronize()
    #if TARGET_OS_IOS
    self.dismiss(animated: true)
    #else
    self.navigationController?.popViewController(animated: true)
    #endif
  }

  // MARK: - Table view data source
  
  override func numberOfSections(in tableView: UITableView) -> Int {
    return 1
  }
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return lists.count
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "ListCell", for: indexPath)
    
    let list = lists[indexPath.row]
    cell.textLabel?.text = list.name
    
    return cell
  }
  
  override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
    return true
  }
  
  override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
    if editingStyle == .delete {
      let list = lists[indexPath.row]
      list.delete() {
        self.lists.remove(at: indexPath.row)
        tableView.deleteRows(at: [indexPath], with: .fade)
      }
    }
  }
  
  override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
    lists.swapAt(fromIndexPath.row, to.row)
  }
  
  override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
    return true
  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if let destinationViewController = segue.destination as? ItemTableViewController {
      if let indexPath = self.tableView.indexPathForSelectedRow {
        let list = lists[indexPath.row]
        destinationViewController.list = list
      }
    }
  }
}


