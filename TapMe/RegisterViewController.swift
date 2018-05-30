
import UIKit

class RegisterViewController: UIViewController, UITextFieldDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet var profileImageView: UIImageView!
    @IBOutlet var nameField: UITextField!
    @IBOutlet var emailField: UITextField!
    @IBOutlet var passwordField: UITextField!
    @IBOutlet var signUpButton: UIButton!
    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    
    var imagePicker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        Backendless.sharedInstance().userService.logout()
        let tap = UITapGestureRecognizer(target: self, action: #selector(setProfileImage))
        profileImageView.addGestureRecognizer(tap)
        profileImageView.isUserInteractionEnabled = true
        profileImageView.layer.cornerRadius = self.profileImageView.frame.size.width / 2;
        activityIndicator.isHidden = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setToolbarHidden(true, animated: animated)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name:NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name:NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setToolbarHidden(false, animated: animated)
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func setProfileImage() {
        AlertViewController.sharedInstance.showProfilePicturePicker(profileImageView, self)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        profileImageView.contentMode = .scaleAspectFill
        profileImageView.image = info[UIImagePickerControllerOriginalImage] as? UIImage
        profileImageView.layer.cornerRadius = self.profileImageView.frame.size.width / 2;
        profileImageView.clipsToBounds = true
        dismiss(animated: true, completion: nil)
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
        contentInset.bottom = keyboardFrame.size.height + 20
        scrollView.contentInset = contentInset
    }
    
    @objc func keyboardWillHide(notification:NSNotification){
        let contentInset:UIEdgeInsets = UIEdgeInsets.zero
        scrollView.contentInset = contentInset
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "unwindToLoginVC") {
            let loginVC = segue.destination as! LoginViewController
            loginVC.email = emailField.text
            loginVC.password = passwordField.text
        }
    }
    
    @IBAction func pressedSignUp(_ sender: Any) {
        view.endEditing(true)
        
        self.profileImageView.isUserInteractionEnabled = false
        self.nameField.isEnabled = false
        self.emailField.isEnabled = false
        self.passwordField.isEnabled = false
        self.signUpButton.isEnabled = false
        navigationController?.navigationBar.isUserInteractionEnabled = false
        let color = navigationController?.navigationBar.tintColor
        navigationController?.navigationBar.tintColor = UIColor.lightGray
        
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
        
        let data = UIImagePNGRepresentation(profileImageView.image!)
        let filePathName = String(format: "/profileImages/%@", emailField.text!)
        Backendless.sharedInstance().file.uploadFile(filePathName, content: data, overwriteIfExist: true, response: { userProfileImage in
            let user = BackendlessUser()
            user.setProperty("profileImage", object: userProfileImage?.fileURL)
            user.name = self.nameField.text! as NSString
            user.email = self.emailField.text! as NSString
            user.password = self.passwordField.text! as NSString
            Backendless.sharedInstance().userService.register(user, response: { registeredUser in
                self.performSegue(withIdentifier: "unwindToLoginVC", sender: nil)
                self.profileImageView.image = UIImage(named: "profileImage.png")
                self.nameField.text = ""
                self.emailField.text = ""
                self.passwordField.text = ""
                
                self.activityIndicator.stopAnimating()
                self.activityIndicator.isHidden = true
                self.navigationController?.navigationBar.isUserInteractionEnabled = true
                self.navigationController?.navigationBar.tintColor = color
                
            }, error: { fault in
                AlertViewController.sharedInstance.showErrorAlert(fault!, self)
            })
        }, error: { fault in
            AlertViewController.sharedInstance.showErrorAlert(fault!, self)
        })
    }
}
