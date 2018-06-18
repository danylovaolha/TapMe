
import UIKit

class PlayerViewController: UITableViewController {
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    var players:[Player]?
    private let IMAGES_KEY = "tapMeProfileImages"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.tableFooterView = UIView()
        getPlayers()
        addUpdateListener()
    }
    
    func getPlayers() {
        let dataStore = Backendless.sharedInstance().data.of(Player.ofClass())
        let queryBuilder = DataQueryBuilder()!
        queryBuilder.setSortBy(["maxScore DESC", "name"])
        dataStore?.find(queryBuilder, response: { updatedPlayers in
            self.players = updatedPlayers as? [Player]
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }, error: { fault in
            AlertViewController.sharedInstance.showErrorAlert(fault!, self)
        })
    }
    
    func addUpdateListener() {
        let dataStore = Backendless.sharedInstance().data.of(Player.ofClass())
        dataStore?.rt.addUpdateListener({ updatedPlayer in
            self.getPlayers()
        }, error: { fault in
            AlertViewController.sharedInstance.showErrorAlert(fault!, self)
        })
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (players != nil) {
            return (players?.count)!
        }
        return 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        navigationItem.title = "Players"
        let cell = tableView.dequeueReusableCell(withIdentifier: "PlayerCell", for: indexPath)
        let player = players![indexPath.row]
        cell.textLabel?.text = player.name
        cell.detailTextLabel?.text = String(format: "%i scores", player.maxScore)
        let image = UIImage(named: "profileImage.png")
        cell.imageView?.image = image
        cell.layoutIfNeeded()
        cell.imageView?.layer.cornerRadius = (image?.size.width)!/2
        cell.imageView?.contentMode = .scaleAspectFill
        setImageFromUrl(player.profileImageUrl!, cell)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.imageView?.layer.cornerRadius = (cell.imageView?.frame.size.width)! / 2
        cell.imageView?.layer.masksToBounds = true
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60;
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    
    func setImageFromUrl(_ url: String, _ cell: UITableViewCell) {
        if (getImageFromUserDefaults(url) != nil) {
            DispatchQueue.main.async {
                cell.imageView?.image = self.getImageFromUserDefaults(url)
            }
        }
        else {
            DispatchQueue.global(qos: .default).async(execute: {() -> Void in
                if let urlFromString = URL(string: url) {
                    if let data = try? Data(contentsOf: urlFromString) {
                        if let image = UIImage(data: data) {
                            self.saveImageToUserDefaults(image, url)
                            DispatchQueue.main.async(execute: {() -> Void in
                                cell.imageView?.image = image
                            })
                        }
                    }
                }
            })
        }
    }
    
    func getImageFromUserDefaults(_ key: String) -> UIImage? {
        if let data = UserDefaults.standard.object(forKey: IMAGES_KEY) as? Data {
            if let images = NSKeyedUnarchiver.unarchiveObject(with: data) as? [String : UIImage] {
                if (images[key] != nil) {
                    return images[key]!
                }
            }
        }
        return nil
    }
    
    func saveImageToUserDefaults(_ image: UIImage?, _ key: String) {
        if (image != nil) {
            var images = [String : Any]()
            if let data = UserDefaults.standard.object(forKey: IMAGES_KEY) as? Data {
                images = NSKeyedUnarchiver.unarchiveObject(with: data) as! [String : Any]
            }
            else {
                images = [String : UIImage]()
            }
            if (images[key] == nil) {
                images[key] = image;
            }
            let data = NSKeyedArchiver.archivedData(withRootObject: images as Any)
            UserDefaults.standard.set(data, forKey: IMAGES_KEY)
            UserDefaults.standard.synchronize()
        }
    }
}
