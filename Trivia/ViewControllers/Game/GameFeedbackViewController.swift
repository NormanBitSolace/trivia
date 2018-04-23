import UIKit

class GameFeedbackViewController: UIViewController {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    var completion: (() -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func handleContinueTouch(_ sender: Any) {
        guard let completion = completion else { fatalError("Must set completion") }
        completion()
        removeChildViewController()
    }
}
