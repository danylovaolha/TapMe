
import UIKit

@objcMembers
class Player: NSObject {
    var objectId: String?
    var profileImageUrl: String?
    var name: String?
    var user: BackendlessUser?
    var maxScore: NSInteger = 0
}
