import Foundation

class DataSource {

    func loadOptionsModel() -> OptionsModel {
        let numQuestions = UserDefaults.standard.object(forKey: "numQuestions") as? Int ?? 10
        let difficulty = UserDefaults.standard.object(forKey: "difficulty") as? String ?? "Mixed"
        return OptionsModel.init(numQuestions: numQuestions, difficulty: difficulty)
    }

    func saveOptionsModel(_ model: OptionsModel) {
        UserDefaults.standard.setValue(model.numQuestions, forKey: "numQuestions")
        UserDefaults.standard.setValue(model.difficulty, forKey: "difficulty")
    }

    func fetchTrivia(_ completion: @escaping ([TriviaModel]?) -> Void) {
        let triviaUrl = buildUrl()
        triviaUrl.fetchJson { dict in
            if let dict = dict {
                let models = TriviaModel.parseJson(dict: dict)
                completion(models)
            } else {
                completion(nil)
            }
        }
    }

}

fileprivate extension DataSource {

    //  In the future this will include more options e.g.
    //  https://opentdb.com/api.php?amount=10&category=9&difficulty=medium&type=boolean
    //  type=multiple&
    func buildUrl() -> URL {
        let model = loadOptionsModel()
        var urlStr = "https://opentdb.com/api.php?amount=\(model.numQuestions)"
        if model.difficulty != "Mixed" {
            urlStr += "&difficulty=" + model.difficulty.lowercased()
        }
        if let url = URL(string: urlStr) {
            return url
        }
        fatalError("DataSource.buildUrl() failed: [\(urlStr)].")
    }
}

extension URL {

    func fetchJson(_ completion: @escaping ([String: Any]?) -> Void) {
        URLSession.shared.dataTask(with: self) { data, _, _ in
            if let data = data,
                let jsonObj = try? JSONSerialization.jsonObject(with: data, options: []),
                let json = jsonObj as? [String: Any] {
                completion(json)
            } else { completion(nil) }
            }.resume()
    }
}
