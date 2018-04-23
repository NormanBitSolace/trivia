import UIKit

class AppNavigator: Navigator {

    enum AppViewControllers {
        case start(type: UIViewController.Type, storyboardName: String?)
        case noData
        case game(model: TriviaModel)
        case gameFeedback(container: UIViewController, label: String, title: String?, message: String?, completion: () -> Void)
        case gameComplete(userMessage: String)
        case options(model: OptionsModel, completion: (Int, String) -> Void)
        case difficultyPopover(anchor: Any, delegate: OptionsDifficultyDelegate, choiceHandler: ((String) -> Void))
    }

    func show(_ viewController: AppViewControllers) {
        switch viewController {
        case .start(let type, let storyboardName):
            start(vc: type, storyboardName: storyboardName)
        case .noData:
            showNoData()
        case .game(let model):
            showGame(model: model)
        case .gameFeedback(let container, let label, let title, let message, let completion):
            showGameFeedback(container: container, label: label, title: title, message: message, completion: completion)
        case .gameComplete(let userMessage):
            showGameComplete(userMessage: userMessage)
        case .options(let model, let completion):
            showOptions(model: model, completion: completion)
        case .difficultyPopover(let anchor, let delegate, let choiceHandler):
            showDifficultyPopover(anchor: anchor, delegate: delegate, choiceHandler: choiceHandler)
        }
    }
}

private extension AppNavigator {

    func showNoData() {
        singleButtonAlert(buttonLabel: "OK", title: "Unable to access trivia", message: "Try again later.")
    }

    func showGame(model: TriviaModel) {
        let _: GameViewController = push(storyboardName: "Game") { vc in
            vc.showTrivia(model: model)
        }
    }

    func showGameFeedback(container: UIViewController, label: String, title: String?, message: String?, completion: @escaping () -> Void) {
        let _: GameFeedbackViewController = addChildViewController(storyboardName: "GameFeedback", container: container) { vc in
            vc.view.frame = CGRect(x: 0, y: 0, width: 300, height: 300)
            vc.view.center = container.view.center
            vc.titleLabel.text = title
            vc.messageLabel.text = message
            vc.completion = completion
        }
    }

    func showGameComplete(userMessage: String) {
        let _: UIViewController = presentModal { vc in
            vc.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(self.dismissAndPop as () -> Void))
            vc.view.addEmitterView(imageType: .confetti)
            vc.addMessage(userMessage, toView: vc.view)
        }
    }

    func showOptions(model: OptionsModel, completion: @escaping (Int, String) -> Void) {
        let _: OptionsViewController = presentModal(storyboardName: "Options", wrap: true) { vc in
            vc.tableView.rowHeight = 44
            vc.numQuestions.text = "\(model.numQuestions)"
            vc.difficultyLabel.text = "\(model.difficulty)"
            vc.completion = { numQuestions, difficulty in
                completion(numQuestions, difficulty)
            }
        }
    }

    func showDifficultyPopover(anchor: Any, delegate: OptionsDifficultyDelegate, choiceHandler: @escaping (String) -> Void) {
        let _: MenuPopoverViewController = presentPopover(anchor: anchor) { vc in
            vc.data = ["Mixed", "Easy", "Medium", "Hard"]
            vc.popoverPresentationController?.permittedArrowDirections = .up
            vc.menuChoice = { choice in
                delegate.setDifficulty(choice)
                vc.dismiss(animated: true) {
                    choiceHandler(choice)
                }
            }
        }
    }

    @objc func dismissAndPop() {
        rootNavigationController.topViewController?.dismiss(animated: true) {
            self.rootNavigationController.popViewController(animated: false)
        }
    }
}
