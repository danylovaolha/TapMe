
import UIKit

class LoginViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet var emailField: UITextField!
    @IBOutlet var passwordField: UITextField!
    
    var activeTextField: UITextField?
    var email: String?
    var password: String?
    
    private var timer: Timer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        guard Backendless.sharedInstance().userService.currentUser == nil else {
            timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(startGame), userInfo: nil, repeats: false)
            return
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
        navigationController?.setToolbarHidden(true, animated: animated)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name:NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name:NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
        navigationController?.setToolbarHidden(false, animated: animated)
        NotificationCenter.default.removeObserver(self)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        view.endEditing(true)
        return true
    }
    
    @objc func keyboardWillShow(notification:NSNotification){
        var userInfo = notification.userInfo!
        var keyboardFrame:CGRect = (userInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        keyboardFrame = self.view.convert(keyboardFrame, from: nil)
        var contentInset:UIEdgeInsets = scrollView.contentInset
        contentInset.bottom = keyboardFrame.size.height
        scrollView.contentInset = contentInset
    }
    
    @objc func keyboardWillHide(notification:NSNotification){
        let contentInset:UIEdgeInsets = UIEdgeInsets.zero
        scrollView.contentInset = contentInset
    }
    
    @objc func startGame() {
        self.performSegue(withIdentifier: "segueToTapMe", sender: nil)
    }
    
    func login(_ userEmail: String, _ userPassword: String) {
        Backendless.sharedInstance().userService.setStayLoggedIn(true)
        Backendless.sharedInstance().userService.login(userEmail, password: userPassword, response: { loggedUser in
            self.startGame()
        }, error: { fault in
            AlertViewController.sharedInstance.showErrorAlert(fault!, self)
        })
    }
    
    @IBAction func unwindToLoginVC(_ segue: UIStoryboardSegue) {
        if (segue.source .isKind(of: RegisterViewController.ofClass())) {
            login(email!, password!)
        }
    }
    
    @IBAction func pressedSignIn(_ sender: Any) {
        login(emailField.text!, passwordField.text!)
        emailField.text = ""
        passwordField.text = ""
    }
}
