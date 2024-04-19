import Foundation

struct Product {
    let name: String
    let sales: Double
}

struct SearchListResponse: Codable {
    let code: Int
    let result: [[String]]
    let msg: String
}

class SearchList {
    private var searchListURL: String?
    var response: SearchListResponse?
    var productList: [Product]?
    
    init() {
        
    }
    
    // 加载数据方法
    
    func loadData(searchURL: String) {
        guard let url = URL(string: searchURL) else {
            print("Invalid URL")
            return
        }

        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            if let error = error {
                print("Error:", error)
                return
            }

            guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
                print("Invalid response")
                return
            }

            guard let jsonData = data else {
                print("No data received")
                return
            }

            do {
                let decoder = JSONDecoder()
                let response = try decoder.decode(SearchListResponse.self, from: jsonData)
                self.response = response
                if let r = self.response, r.code != 200 {
                    print(r.msg)
                    print("Get data wrong")
                } else {
                    self.productList = response.result.map { Product(name: $0[0], sales: Double($0[1]) ?? 0.0) }
                }
            } catch {
                print("Error decoding JSON:", error)
            }
        }
        task.resume()
    }
}
