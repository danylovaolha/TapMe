
import UIKit

class TapMeViewController: UIViewController {
    
    @IBOutlet var timerLabel: UILabel!
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var yourMaxScore: UILabel!
    @IBOutlet weak var gameMaxScore: UILabel!
    
    var player: Player!
    var channel: Channel?
    var score = 0
    var worldRecordScore = 0
    var countdownTimer: Timer!
    var totalTime = 0
    var timerStarted = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        renewTotalTime()
        getPlayer(Backendless.sharedInstance().userService.currentUser.email as String)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        navigationController?.setToolbarHidden(true, animated: animated)
        self.addDataEventListeners()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        removeDataEventListeners()
        removeMessageListeners()
    }
    
    func renewTotalTime() {
        totalTime = 10
    }
    
    func startTimer() {
        navigationController?.setToolbarHidden(false, animated:true)
        countdownTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateTime), userInfo: nil, repeats: true)
        timerStarted = true
        score = 0
        self.scoreLabel.text = "0"
    }
    
    @IBAction func updateTime() {
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
        renewTotalTime()
        if player.maxScore < score {
            player.maxScore = score;
            Backendless.sharedInstance().data.of(Player.ofClass()).save(player, response: { updatedPlayer in
            }, error: { fault in
                AlertViewController.sharedInstance.showErrorAlert(fault!, self)
            })
        }        
        if worldRecordScore < player.maxScore {
            let publishOptions = PublishOptions()
            publishOptions.addHeader("bestPlayerEmail", value: player.user?.email)
            Backendless.sharedInstance().messaging.publish("TapMeChannel", message: "You have set a new record!", publishOptions: publishOptions, response: { messageStatus in
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
        queryBuilder.setRelationsDepth(1)
        queryBuilder.setWhereClause(String(format: "user.email = '%@'", email))
        Backendless.sharedInstance().data.of(Player.ofClass()).find(queryBuilder, response: { foundPlayers in
            self.player = foundPlayers?.first as! Player
            self.fillScores(self.player)
            self.addMessageListeners()
            self.navigationItem.title = self.player.name
        }, error: { fault in
            AlertViewController.sharedInstance.showErrorAlert(fault!, self)
        })
    }
    
    func fillScores(_ player: Player) {
        self.yourMaxScore.text = String(format: "⭐️ Your max score: %i", self.player.maxScore)
        let queryBuilder = DataQueryBuilder()!
        queryBuilder.setProperties(["Max(maxScore) as maxScore"])
        Backendless.sharedInstance().data.of(Player.ofClass()).find(queryBuilder, response: { result in
            let bestPlayer = (result?.first as! Player)
            self.worldRecordScore = bestPlayer.maxScore
            self.gameMaxScore.text = String(format: "🏆 World record: %i", self.worldRecordScore)
        }, error: { fault in
            AlertViewController.sharedInstance.showErrorAlert(fault!, self)
        })
    }
    
    func addDataEventListeners() {
        Backendless.sharedInstance().data.of(Player.ofClass()).rt.addUpdateListener({ updatedPlayer in
            self.fillScores(updatedPlayer as! Player)
        }, error: { fault in
            AlertViewController.sharedInstance.showErrorAlert(fault!, self)
        })
    }
    
    func removeDataEventListeners() {
        Backendless.sharedInstance().data.of(Player.ofClass()).rt.removeAllListeners()
    }
    
    func addMessageListeners() {
        channel = Backendless.sharedInstance().messaging.subscribe("TapMeChannel")
        channel?.addMessageListenerString(String(format: "bestPlayerEmail = '%@''", (player.user?.email)!), response: { message in
            AlertViewController.sharedInstance.showCongratulationsAlert(message!, self)
        }, error: { fault in
            AlertViewController.sharedInstance.showErrorAlert(fault!, self)
        })
    }
    
    func removeMessageListeners() {
        channel?.removeAllListeners()
    }
    
    @IBAction func pressedLogout(_ sender: Any) {        
        Backendless.sharedInstance().userService.logout({
            self.performSegue(withIdentifier: "unwindToLoginVC", sender: nil)
        }, error: { fault in
            AlertViewController.sharedInstance.showErrorAlert(fault!, self)
        })
    }
    
    @IBAction func pressedTapMe(_ sender: Any) {
        if !timerStarted {
            startTimer()
        }
        score += 1;
        self.scoreLabel.text = String(format: "%i", self.score)
    }
    
    @IBAction func pressedStop(_ sender: Any) {
        endTimer()
    }
    
    @IBAction func pressedPlayers(_ sender: Any) {
        performSegue(withIdentifier: "segueToPlayers", sender: nil)
    }
}
