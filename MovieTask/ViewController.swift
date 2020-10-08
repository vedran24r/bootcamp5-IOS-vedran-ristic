import UIKit

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet var searchBar: UISearchBar!
    @IBOutlet var tableView: UITableView!
    @IBOutlet var suggestionView: UITableView!
    
    var suggestionList:[String] = []
    
    let defaults = UserDefaults.standard
    
    var moviePersist: String = ""
    var movieCurrentPage = 1
    var movieList = Movies(){
        didSet{
            DispatchQueue.main.async {
                self.tableView.reloadData()
                self.suggestionView?.reloadData()
                if self.movieList.total_results! == 0{
                    let alert = UIAlertController(title: "Bad entry", message: "No movies with this name", preferredStyle: UIAlertController.Style.alert)
                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                    
                }
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.delegate = self
        tableView.dataSource = self
        tableView.delegate = self
        tableView.reloadData()
        if let niz = defaults.array(forKey: "SuggestionListPersist") as? [String]{
            suggestionList = niz
        }
        
        suggestionView.delegate = self
        suggestionView.dataSource = self
        suggestionView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView != suggestionView{
            if movieList.results != nil{
                return movieList.results?.count ?? 0
            }else{
                return 0;
            }
        }else{
            if suggestionList.count < 10 {
                return suggestionList.count
            }else {
                return 10
            }
        }
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView != suggestionView{
            let cell = tableView.dequeueReusableCell(withIdentifier: "MovieCell", for: indexPath) as! MovieCell
            let movie = movieList.results![indexPath.row]
            
            cell.lblName?.text = movie.title
            cell.lblDesc?.text = movie.overview
            cell.lblDate?.text = movie.release_date
            
            let defPath = "emptypath"
            let path = movieList.results![indexPath.row].poster_path ?? defPath
            
            let img = "https://image.tmdb.org/t/p/w500/" + path
            
            
            guard let url = URL(string: img) else { return cell}
            cell.ivImage.load(url: url)
            return cell
        }else{
            let cell = suggestionView.dequeueReusableCell(withIdentifier: "SuggestionCell", for: indexPath) as! SuggestionCell
            cell.lblText?.text = suggestionList[indexPath.row]
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row + 1 == movieList.results?.count{
            if movieCurrentPage < movieList.total_pages!{
                movieCurrentPage += 1
                let movieRequest = MovieRequest(title: handleSpecialCharacters(searchText: moviePersist), page: movieCurrentPage)
                
                movieRequest.getMovies{[weak self] result in
                    switch result{
                    case .failure(let error):
                        print(error)
                    case .success(let movies):
                        self?.movieList.results! += movies.results!
                    }
                }
            }else{
                print("no more movies")
                let alert = UIAlertController(title: "No more movies", message: "End of list", preferredStyle: UIAlertController.Style.alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            
            }
            
        }
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView == suggestionView{
            searchBar.text = suggestionList[indexPath.row]
            searchBar.text = handleSpecialCharacters(suggestionText: searchBar.text!)
            searchBarSearchButtonClicked(searchBar)
        }
    }
    
}
class MovieCell: UITableViewCell{
    
    @IBOutlet var ivImage: UIImageView!
    @IBOutlet var lblName: UILabel!
    @IBOutlet var lblDesc: UILabel!
    @IBOutlet var lblDate: UILabel!
    
    
    override func prepareForReuse() {
        clear()
    }
    override func awakeFromNib() {
        clear()
    }
    
    private func clear() {
        lblName.text = String()
        lblDesc.text = String()
        lblDate.text = String()
        ivImage.image = nil
    }
}
class SuggestionCell: UITableViewCell{
    @IBOutlet var lblText: UILabel!
}
extension UIImageView {
    func load(url: URL) {
        DispatchQueue.global().async { [weak self] in
            if let data = try? Data(contentsOf: url) {
                if let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        self?.image = image
                    }
                }
            }
        }
    }
}
extension ViewController : UISearchBarDelegate{
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        suggestionView?.isHidden = false
        tableView?.isHidden = true
    }
    func searchBarSearchButtonClicked(_ searchBar:UISearchBar){
        if searchBar.text != ""{
            suggestionView?.isHidden = true
            tableView?.isHidden = false
            
            guard let searchBarText = searchBar.text else {return}
            var querry = searchBarText
            moviePersist = querry
            querry = handleSpecialCharacters(searchText: querry)
            let movieRequest = MovieRequest(title: querry, page: 1)
            movieRequest.getMovies{[weak self] result in
                switch result{
                case .failure(let error):
                    print(error)
                case .success(let movies):
                    self?.movieList = movies
                    self?.movieCurrentPage = 1
                    self?.suggestionList.insert((self?.moviePersist ?? ""), at: 0)
                    self?.defaults.set(self?.suggestionList, forKey:"SuggestionListPersist")
                    
                }
            }
        }
    }
}
func handleSpecialCharacters(suggestionText: String) -> String {
    let okayChars = Set(" abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLKMNOPQRSTUVWXYZ1234567890+-=().!_")
    var result = suggestionText.replacingOccurrences(of: "%20", with: " ")
    result = result.filter {okayChars.contains($0) }
    let charSet:CharacterSet = [" "]
    result = result.trimmingCharacters(in: charSet)
    return result
}
func handleSpecialCharacters(searchText: String) -> String {
    let okayChars = Set(" abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLKMNOPQRSTUVWXYZ1234567890+-=().!_")
    var result = searchText.filter {okayChars.contains($0) }
    result = result.replacingOccurrences(of: " ", with: "%20")
    let charSet:CharacterSet = [" "]
    result = result.trimmingCharacters(in: charSet)
    
    return result
}


