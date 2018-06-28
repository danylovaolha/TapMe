
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
        Types.tryblock({
            Backendless.sharedInstance().userService.logout()
        }, catchblock: { fault in
            AlertViewController.sharedInstance.showErrorAlertWithExit(Fault(message: "Error", detail: "Make sure to configure the app with your APP ID and API KEY before running the app. \nApplication will be closed"), self)
        })
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
        let data = UIImagePNGRepresentation(cropToBounds(image: profileImageView.image!, width: 256, height: 256) )
        let filePathName = String(format: "/tapMeProfileImages/%@.png", emailField.text!)
        
        DispatchQueue.main.async {
            let emailFieldText = self.emailField.text as NSString?
            let passwordFieldText = self.passwordField.text as NSString?
            
            Backendless.sharedInstance().file.uploadFile(filePathName, content: data, overwriteIfExist: true, response: { profileImage in
                let queryBuilder = DataQueryBuilder()!
                queryBuilder.setWhereClause((String(format: "email = '%@'", emailFieldText!)))
                Backendless.sharedInstance().data.of(BackendlessUser.ofClass()).find(queryBuilder, response: { registeredUsers in
                    if (registeredUsers?.first != nil) {
                        self.createNewPlayer(registeredUsers?.first as? BackendlessUser, profileImage, color)
                    }
                    else {
                        let user = BackendlessUser()
                        user.email = emailFieldText
                        user.password =  passwordFieldText!
                        Backendless.sharedInstance().userService.register(user, response: { registeredUser in
                            self.createNewPlayer(registeredUser, profileImage, color)
                        }, error: { fault in
                            AlertViewController.sharedInstance.showErrorAlert(fault!, self)
                            self.returnToSignUp(color!)
                        })
                    }
                }, error: {  fault in
                    AlertViewController.sharedInstance.showErrorAlert(fault!, self)
                })
            }, error: { fault in
                AlertViewController.sharedInstance.showErrorAlert(fault!, self)
                self.returnToSignUp(color!)
            })
        }
    }
    
    func createNewPlayer(_ registeredUser: BackendlessUser?, _ profileImage: BackendlessFile?, _ color: UIColor?) {
        DispatchQueue.main.async {
            let newPlayer = Player()
            newPlayer.profileImageUrl = profileImage?.fileURL
            newPlayer.maxScore = 0
            newPlayer.name = self.nameField.text
            Backendless.sharedInstance().data.of(Player.ofClass()).save(newPlayer, response: { player in
                let userId: String = registeredUser!.objectId! as String
                Backendless.sharedInstance().data.of(Player.ofClass()).setRelation("user:Users:1", parentObjectId: (player as! Player).objectId, childObjects: [userId], response: { relationSet in
                    DispatchQueue.main.async {
                        self.profileImageView.image = UIImage(named: "profileImage.png")
                        self.activityIndicator.stopAnimating()
                        self.activityIndicator.isHidden = true
                        self.performSegue(withIdentifier: "unwindToLoginVC", sender: nil)
                        self.nameField.text = ""
                        self.emailField.text = ""
                        self.passwordField.text = ""
                        self.navigationController?.navigationBar.isUserInteractionEnabled = true
                        self.navigationController?.navigationBar.tintColor = color
                    }
                }, error: { fault in
                    AlertViewController.sharedInstance.showErrorAlert(fault!, self)
                    self.returnToSignUp(color!)
                })
            }, error: { fault in
                AlertViewController.sharedInstance.showErrorAlert(fault!, self)
                self.returnToSignUp(color!)
            })
        }
    }
    
    func cropToBounds(image: UIImage, width: Double, height: Double) -> UIImage {
        let cgimage = image.cgImage!
        let contextImage: UIImage = UIImage(cgImage: cgimage)
        let contextSize: CGSize = contextImage.size
        var posX: CGFloat = 0.0
        var posY: CGFloat = 0.0
        var cgwidth: CGFloat = CGFloat(width)
        var cgheight: CGFloat = CGFloat(height)
        if contextSize.width > contextSize.height {
            posX = ((contextSize.width - contextSize.height) / 2)
            posY = 0
            cgwidth = contextSize.height
            cgheight = contextSize.height
        } else {
            posX = 0
            posY = ((contextSize.height - contextSize.width) / 2)
            cgwidth = contextSize.width
            cgheight = contextSize.width
        }
        let rect: CGRect = CGRect(x: posX, y: posY, width: cgwidth, height: cgheight)
        let imageRef: CGImage = cgimage.cropping(to: rect)!
        let image: UIImage = UIImage(cgImage: imageRef, scale: image.scale, orientation: image.imageOrientation)
        return image
    }
    
    func returnToSignUp(_ color: UIColor) {
        self.activityIndicator.stopAnimating()
        self.activityIndicator.isHidden = true
        self.navigationController?.navigationBar.isUserInteractionEnabled = true
        self.navigationController?.navigationBar.tintColor = color
        profileImageView.isUserInteractionEnabled = true
        self.nameField.isEnabled = true
        self.emailField.isEnabled = true
        self.passwordField.isEnabled = true
        self.signUpButton.isEnabled = true
        navigationController?.navigationBar.isUserInteractionEnabled = true
    }
}
