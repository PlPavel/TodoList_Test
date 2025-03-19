import Foundation

class APICaller {
    
    static let shared = APICaller()
    
    private init() {}
    
    enum ErrorHandler: Error {
        case failedToGetData
    }
    
    func getTodoList(completion: @escaping (Result<TodoTasks, Error>) -> Void) {
        guard let url = URL(string: "https://dummyjson.com/todos") else {
            return
        }
        
        DispatchQueue.global(qos: .background).async {
            URLSession.shared.dataTask(with: url) { data, _, error in
                guard let data = data, error == nil else {
                    completion(.failure(ErrorHandler.failedToGetData))
                    return
                }

                do {
                    let result = try JSONDecoder().decode(TodoTasks.self, from: data)
                    completion(.success(result))
                }
                catch {
                    print(error.localizedDescription)
                    completion(.failure(error))
                }
            }.resume()
        }
    }
}
