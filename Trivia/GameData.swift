import Foundation

class GameData {
    var questionIndex: Int
    var numRight: Int
    var numWrong: Int
    let modelList: [TriviaModel]

    var model: TriviaModel {
        return modelList[questionIndex]
    }

    var numQuestions: Int {
        return modelList.count
    }

    init(trivia: [TriviaModel]) {
        modelList = trivia
        questionIndex = 0
        numRight = 0
        numWrong = 0
    }

    func incQuestionIndex() -> Bool {
        questionIndex += 1
        return questionIndex < modelList.count
    }

    func incGuess(isCorrect: Bool) {
        if isCorrect { numRight += 1 } else { numWrong += 1 }
    }

    func isCorrect(_ guess: String) -> Bool {
        return guess == model.correctAnswer
    }

    func userMessage() -> String {
        var message: String
        let percentage = Double(numRight) / Double(numQuestions)
        switch percentage {
        case 0...0.1:
            message = "Perfectly imperfect!\nYou're on a roll - stop it!"
        case 0.1...0.45:
            message = "Don't quit your day job.\nYou answered \(numRight) of \(numQuestions) correctly."
        case 0.99...1:
            message = "Congratulations!\nYou answered all \(numQuestions) correctly."
        default:
            message = "Good job!\nYou answered \(numRight) of \(numQuestions) correctly."
        }
        return message
    }
}
