/// Copyright (c) 2019 Razeware LLC
///
/// Permission is hereby granted, free of charge, to any person obtaining a copy
/// of this software and associated documentation files (the "Software"), to deal
/// in the Software without restriction, including without limitation the rights
/// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
/// copies of the Software, and to permit persons to whom the Software is
/// furnished to do so, subject to the following conditions:
///
/// The above copyright notice and this permission notice shall be included in
/// all copies or substantial portions of the Software.
///
/// Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
/// distribute, sublicense, create a derivative work, and/or sell copies of the
/// Software in any work that is designed, intended, or marketed for pedagogical or
/// instructional purposes related to programming, coding, application development,
/// or information technology.  Permission for such use, copying, modification,
/// merger, publication, distribution, sublicensing, creation of derivative works,
/// or sale is expressly withheld.
///
/// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
/// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
/// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
/// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
/// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
/// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
/// THE SOFTWARE.

import UIKit
import Alamofire

class MainTableViewController: UITableViewController {
  
  // Variables:
  var items: [Displayable] = []
  var selectedItem : Displayable?
  var films : [Film] = []
  
  // IB Properties:
  @IBOutlet weak var searchBar: UISearchBar!
  
  // Overridden Methods:
  override func viewDidLoad() {
    super.viewDidLoad()
    searchBar.delegate = self
    fetchFilms()
  }
  
  // - UITableViewController Methods:
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return items.count
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "dataCell", for: indexPath)    
    let item = items[indexPath.row]
    cell.textLabel?.text = item.titleLabelText
    cell.detailTextLabel?.text = item.subtitleLabelText
    return cell
  }
  
  override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
    selectedItem = items[indexPath.row]
    return indexPath
  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    guard let destinationVC = segue.destination as? DetailViewController else {
      return
    }
    destinationVC.data = selectedItem
  }
}

// MARK: - UISearchBarDelegate
extension MainTableViewController: UISearchBarDelegate {
    
  func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
    guard let shipName = searchBar.text else { return }
    searchStarships(for: shipName)
  }
  
  func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
    searchBar.text = ""
    searchBar.resignFirstResponder()
    items = films
    tableView.reloadData()
  }
  
}

extension MainTableViewController {
  
  // Methods:
  func fetchFilms() {
    // 1: Alamofire uses namespacing, so you need to prefix all calls that you use with AF. request(_:method:parameters:encoding:headers:interceptor:) accepts the endpoint for your data. It can accept more parameters, but for now, you’ll just send the URL as a string and use the default parameter values.
    let request = AF.request("https://swapi.dev/api/films")
    
    // 2: You’ll convert it into your internal data model, Films. For debugging purposes, you print the title of the first film retrieved.
    request.validate().responseDecodable(of: Films.self, completionHandler: { (response) in
      guard let films = response.value else { return }
      self.films = films.all
      self.items = films.all
      self.tableView.reloadData()
    })
  }
  
  func searchStarships(for name : String) {
    // 1: Sets the URL that you’ll use to access the starship data.
    let url = "https://swapi.dev/api/starships"
    // 2: Sets the key-value parameters that you’ll send to the endpoint.
    let parameters : [String : String] = ["search" : name]
    // 3: Here, you’re making a request like before, but this time you’ve added parameters. You’re also performing a validate and decoding the response into Starships.
    AF.request(url, parameters: parameters)
    .validate()
    .responseDecodable(of: Starships.self, completionHandler: { response in
      // 4: Finally, once the request completes, you assign the list of starships as the table view’s data and reload the table view.
      guard let starships = response.value else { return }
      self.items = starships.all
      self.tableView.reloadData()
    })
  }
  
}
