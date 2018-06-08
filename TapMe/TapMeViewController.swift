
import UIKit

class TapMeViewController: UIViewController {
    
    @IBOutlet var timerLabel: UILabel!
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var yourMaxScore: UILabel!
    @IBOutlet weak var gameMaxScore: UILabel!
    
    var player: Player!
    var countdownTimer: Timer!
    var totalTime = 5
    var timerStarted = false
    var score = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getPlayer(Backendless.sharedInstance().userService.currentUser.email as String)
        addEventListeners()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        navigationController?.setToolbarHidden(true, animated: animated)
    }
    
    func startTimer() {
        navigationController?.setToolbarHidden(false, animated:true)
        countdownTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateTime), userInfo: nil, repeats: true)
        timerStarted = true
        score = 0
        DispatchQueue.main.async { self.scoreLabel.text = "0" }
    }
    
    @objc func updateTime() {
        timerLabel.text = "\(timeFormatted(totalTime))"
        if totalTime != 0 {
            totalTime -= 1
        } else {
            endTimer()
        }
    }
    
    func endTimer() {
        countdownTimer.invalidate()
        timerStarted = false
        navigationController?.setToolbarHidden(true, animated: true)
        timerLabel.text = ""
        AlertViewController.sharedInstance.showScoreAlert(score, self)
        totalTime = 5
        if (player.maxScore < score) {
            player.maxScore = score;
            Backendless.sharedInstance().data.of(Player.ofClass()).save(player, response: { updatedPlayer in
                self.player = updatedPlayer as! Player
            }, error: { fault in
                AlertViewController.sharedInstance.showErrorAlert(fault!, self)
            })
        }
    }
    
    func timeFormatted(_ totalSeconds: Int) -> String {
        let seconds: Int = totalSeconds % 60
        let minutes: Int = (totalSeconds / 60) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    func getPlayer(_ email: String) {
        let queryBuilder = DataQueryBuilder()!
        queryBuilder.setWhereClause(String(format: "user.email = '%@'", email))
        Backendless.sharedInstance().data.of(Player.ofClass()).find(queryBuilder, response: { foundPlayers in
            self.player = foundPlayers?.first as! Player
            DispatchQueue.main.async {
                self.navigationItem.title = self.player.name
            }
            self.fillScores(self.player)
        }, error: { fault in
            AlertViewController.sharedInstance.showErrorAlert(fault!, self)
        })
    }
    
    func fillScores(_ player: Player) {
        DispatchQueue.main.async {
            self.yourMaxScore.text = String(format: "Your max score: %i", self.player.maxScore)
            let queryBuilder = DataQueryBuilder()!
            queryBuilder.setProperties(["Max(maxScore) as maxScore"])
            Backendless.sharedInstance().data.of(Player.ofClass()).find(queryBuilder, response: { result in
                self.gameMaxScore.text = String(format: "Game max score: %i", (result?.first as! Player).maxScore)
            }, error: { fault in
                AlertViewController.sharedInstance.showErrorAlert(fault!, self)
            })
        }
    }
    
    func addEventListeners() {
        Backendless.sharedInstance().data.of(Player.ofClass()).rt.addUpdateListener({ updatedPlayer in
            self.fillScores(updatedPlayer as! Player)
        }, error: { fault in
            AlertViewController.sharedInstance.showErrorAlert(fault!, self)
        })
    }
    
    @IBAction func pressedLogout(_ sender: Any) {
        Backendless.sharedInstance().userService.logout()
        self.performSegue(withIdentifier: "unwindToLoginVC", sender: nil)   
    }
    
    @IBAction func pressedTapMe(_ sender: Any) {
        if (!timerStarted) {
            startTimer()
        }
        score += 1;
        DispatchQueue.main.async { self.scoreLabel.text = String(format: "%i", self.score) }
    }
    
    @IBAction func pressedStop(_ sender: Any) {
        endTimer()
    }
}
