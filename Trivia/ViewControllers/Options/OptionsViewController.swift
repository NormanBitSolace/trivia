import UIKit

protocol OptionsDifficultyDelegate: class {
    func setDifficulty(_ difficulty: String)
}

class OptionsViewController: UITableViewController, OptionsDifficultyDelegate {

    @IBOutlet weak var numQuestions: UITextField!
    @IBOutlet weak var difficultyLabel: UILabel!
    var completion: ((Int, String)->Swift.Void)?

    @IBAction func handleDoneTouch(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }

    @IBAction func handleDifficultyTouched(_ sender: Any) {
        appCoordinator.presentDifficultyChoices(anchor: difficultyLabel, delegate: self)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        guard let completion = completion else { return }
        if let numQuestionsStr = numQuestions?.text,
            let numQuestions = Int(numQuestionsStr),
            let difficulty = difficultyLabel?.text {
            completion(numQuestions, difficulty)
        }
    }
    func setDifficulty(_ difficulty: String) {
        difficultyLabel.text = difficulty
    }
}
