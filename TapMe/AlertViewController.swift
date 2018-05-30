
import UIKit

class AlertViewController: UIViewController {
    
    static let sharedInstance = AlertViewController()

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func showErrorAlert(_ fault: Fault, _ target: UIViewController) {
        let alert = UIAlertController(title: String(format: "Error %@", fault.faultCode), message: fault.detail, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
        target.view.endEditing(true)
        target.present(alert, animated: true)
    }
    
    func showProfilePicturePicker (_ imageView: UIImageView, _ target: UIViewController) {
        let alert = UIAlertController(title: "Set profie picture", message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Use camera", style: .default, handler: { alertAction in
            if (!UIImagePickerController.isSourceTypeAvailable(.camera)) {
                self.showErrorAlert(Fault(message: "", detail: "No device found. Camera is not available"), target)
            }
            else {
                let cameraPicker = UIImagePickerController()
                cameraPicker.sourceType = .camera
                cameraPicker.delegate = target as! (UIViewController & UINavigationControllerDelegate & UIImagePickerControllerDelegate)
                target.present(cameraPicker, animated: true, completion: nil)
            }
        }))
        alert.addAction(UIAlertAction(title: "Select from gallery", style: .default, handler: { alertAction in
            if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
                let imagePicker = UIImagePickerController()
                imagePicker.sourceType = .photoLibrary
                imagePicker.delegate = target as! (UIViewController & UINavigationControllerDelegate & UIImagePickerControllerDelegate)
                imagePicker.allowsEditing = false
                target.present(imagePicker, animated: true, completion: nil)
            }
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        target.present(alert, animated: true)
    }
    
    func showScoreAlert(_ scores: Int, _ target: UIViewController) {
        let alert = UIAlertController(title: "Finish", message: String(format: "Your score is %i", scores), preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        target.view.endEditing(true)
        target.present(alert, animated: true)
    }
}
