
import UIKit

class TapMeViewController: UIViewController {

    @IBOutlet var timerLabel: UILabel!
    
    var countdownTimer: Timer!
    var totalTime = 5
    var timerStarted = false
    var score = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
    }
    
    func timeFormatted(_ totalSeconds: Int) -> String {
        let seconds: Int = totalSeconds % 60
        let minutes: Int = (totalSeconds / 60) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }

    
    @IBAction func pressedLogout(_ sender: Any) {
        Backendless.sharedInstance().userService.logout({
           self.performSegue(withIdentifier: "unwindToLoginVC", sender: nil)
        }, error: { fault in
            AlertViewController.sharedInstance.showErrorAlert(fault!, self)
        })
    }
    
    @IBAction func pressedTapMe(_ sender: Any) {
        if (!timerStarted) {
            startTimer()
        }
        score += 1;
    }
    
    @IBAction func pressedStop(_ sender: Any) {
        endTimer()
    }
}
