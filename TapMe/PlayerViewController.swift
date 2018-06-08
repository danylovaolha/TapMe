
import UIKit

class PlayerViewController: UITableViewController {
    
    var players:[Player]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "PlayerCell", for: indexPath)
        let player = players![indexPath.row]
        cell.textLabel?.text = player.name
        cell.detailTextLabel?.text = String(format: "%i", player.maxScore)
        let image = UIImage(named: "my.png")
        cell.imageView?.image = image
        cell.layoutIfNeeded()
        cell.imageView?.layer.cornerRadius = (image?.size.width)!/2
        return cell
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.imageView?.layer.cornerRadius = (cell.imageView?.frame.size.width)! / 2
        cell.imageView?.layer.masksToBounds = true
    }
    
    func setImageFromUrl(_ cell: UITableViewCell, _ url: String) {
        DispatchQueue.global(qos: .default).async(execute: {() -> Void in
            if let urlFromString = URL(string: url) {
                
                if let data = try? Data(contentsOf: urlFromString) {
                    if let image = UIImage(data: data) {
                        DispatchQueue.main.async(execute: {() -> Void in
                            cell.imageView?.image = image
                            cell.layoutIfNeeded()
                            cell.imageView?.layer.cornerRadius = (cell.imageView?.frame.height)!/2
                            cell.imageView?.contentMode = .scaleAspectFit
                        })
                    }
                }
            }
        })
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
}
