import UIKit

class GameViewController: UIViewController {

    @IBOutlet weak var questionLabel: UILabel!
    @IBOutlet weak var button1: UIButton!
    @IBOutlet weak var button2: UIButton!
    @IBOutlet weak var button3: UIButton!
    @IBOutlet weak var button4: UIButton!
    var buttons: [UIButton]!

    override func viewDidLoad() {
        super.viewDidLoad()
        buttons = [button1, button2, button3, button4]
    }

    func showTrivia(model: TriviaModel) {
        title = model.category
        questionLabel.text = model.question
        buttons.forEach { $0.isHidden = true }
        for (index, answer) in model.answers.enumerated() {
            let button = buttons[index]
            button.setTitle(answer, for: .normal)
            button.addTarget(self, action: #selector(handleGuess(_:)), for: .touchUpInside)
            button.isHidden = false // show buttons that display a choice
        }
    }

    @objc private func handleGuess(_ sender: UIButton) {
        guard let title = sender.titleLabel?.text else { return }
        appCoordinator.guess(vc: self, guess: title)
    }
}
