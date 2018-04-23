import Foundation

struct OptionsModel {
    let numQuestions: Int
    let difficulty: String
}

extension OptionsModel: CustomStringConvertible {
    var description: String {
        return "numQuestions: \(numQuestions), difficulty: \(difficulty)"
    }
}
