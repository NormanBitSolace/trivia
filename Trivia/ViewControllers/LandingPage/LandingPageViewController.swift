import UIKit

class LandingPageViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Trivia"
    }

    @IBAction func handleOptionsTouch(_ sender: Any) {
        appCoordinator.presentOptions()
    }

    @IBAction func handlePlayTouch(_ sender: Any) {
        appCoordinator.play()
    }

}
