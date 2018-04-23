import Foundation

//"category":"Entertainment: Video Games","type":"multiple","difficulty":"easy",
//"question":"Which company did Gabe Newell work at before founding Valve Corporation?",
//"correct_answer":"Microsoft","incorrect_answers":["Apple","Google","Yahoo"]

struct TriviaModel {
    let category: String
    let type: String
    let difficulty: String
    let question: String
    let correctAnswer: String
    let incorrectAnswers: [String]
    let answers: [String]
}

extension TriviaModel {

    init(dict: [String: Any]) {
        func strFromDict(_ key: String, _ dict: [String: Any]) -> String {
            guard let value = dict[key] as? String else { fatalError() }
            return value
        }
        func strsFromDict(_ key: String, _ dict: [String: Any]) -> [String] {
            guard let value = dict[key] as? [String] else { fatalError() }
            return value
        }
        category = strFromDict("category", dict)
        type = strFromDict("type", dict)
        difficulty = strFromDict("difficulty", dict)
        question = strFromDict("question", dict)
        correctAnswer = strFromDict("correct_answer", dict)
        incorrectAnswers = strsFromDict("incorrect_answers", dict)
         if type == "boolean" {
            answers = ["True", "False"]
       } else {
            answers = (incorrectAnswers + [correctAnswer]).sorted()
        }
    }

    func isTrueFalse() -> Bool {
        return type == "boolean"
    }

    static func parseJson(dict: [String: Any]) -> [TriviaModel] {
        guard let triviaDicts = dict["results"] as? [[String: Any]] else { fatalError() }
        let decodedDicts = triviaDicts.map { $0.htmlDecoded() }
        let models = decodedDicts.map { TriviaModel.init(dict: $0) }
        return models
    }
}
