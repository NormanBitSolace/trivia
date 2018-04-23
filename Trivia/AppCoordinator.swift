import UIKit

class AppCoordinator: NSObject {

    let dataSource: DataSource
    let navigator: AppNavigator
    var gameData: GameData!
    var optionsModel: OptionsModel {
        return self.dataSource.loadOptionsModel()
    }

    init(dataSource: DataSource, appNavigator: AppNavigator) {
        self.dataSource = dataSource
        self.navigator = appNavigator
        appNavigator.start(vc: LandingPageViewController.self, storyboardName: "LandingPage")
        super.init()
    }

    func play() {
        dataSource.fetchTrivia { model in
            DispatchQueue.main.async {
                if let model = model {
                    self.gameData = GameData.init(trivia: model)
                    self.navigator.show(.game(model: self.gameData.model))
                } else {
                    self.navigator.show(.noData)
                }
            }
        }
    }

    func guess(vc: GameViewController, guess: String) {
        func buttonHandler() {
            if gameData.incQuestionIndex() {
                vc.showTrivia(model: gameData.model)
            } else {
                self.navigator.show(.gameComplete(userMessage: gameData.userMessage()))
            }
        }
        let isCorrect = gameData.isCorrect(guess)
        let title = isCorrect ? "Correct" : "Incorrect"
        let message = isCorrect ? nil : gameData.model.correctAnswer
        navigator.show(.gameFeedback(container: vc, label: "Continue", title: title, message: message, completion: buttonHandler))
        gameData.incGuess(isCorrect: isCorrect)
    }

    func presentOptions() {
        let optionsCompletion: (Int, String) -> Void = { numQuestions, difficulty in
            let model = OptionsModel.init(numQuestions: numQuestions, difficulty: difficulty)
            self.dataSource.saveOptionsModel(model)
        }
        navigator.show(.options(model: optionsModel, completion: optionsCompletion))
    }

    func presentDifficultyChoices(anchor: Any, delegate: OptionsDifficultyDelegate) {
        navigator.show(.difficultyPopover(anchor: anchor, delegate: delegate) { difficulty in
            let updatedModel = OptionsModel(numQuestions: self.optionsModel.numQuestions, difficulty: difficulty)
            self.dataSource.saveOptionsModel(updatedModel)
            })
    }
}
