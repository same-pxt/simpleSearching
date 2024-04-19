//
//  HotList.swift
//  TaoBaoSearching
//
//  Created by ssyb on 2024/4/18.
//

import Foundation

struct hotListEntry: Codable {
    let index: Int
    let title: String
    let hot: String
    let href: String
}

struct hotListResponse: Codable {
    let code: Int
    let result: [String: [hotListEntry]]
    let msg: String
}
class HotList{
    private var hotListURL: String
    var taoBaoList: [hotListEntry]?
    var returnCode: Int
    var returnmsg: String
    init(hotListURL: String) {
        self.hotListURL = hotListURL
        self.returnCode = 0
        self.returnmsg = ""
        loadData()
    }
    //load data from the URL
    func loadData()
    {
        // URL
        guard let url = URL(string: hotListURL) else {
            print("Invalid URL")
            exit(1)
        }

        // 发起网络请求
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            // 检查是否有错误
            if let error = error {
                fatalError("Error:\(error)")
                return
            }
            
            // 检查响应是否成功
            guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
                fatalError("Invalid response")
                return
            }
            
            // 检查是否有数据
            guard let jsonData = data else {
                fatalError("No data received")
                return
            }
            
            // 解析 JSON 数据
            do {
                let decoder = JSONDecoder()
                let response = try decoder.decode(hotListResponse.self, from: jsonData)
                if response.code != 200 {
                    print(response.msg)
                    fatalError("get data wrong")
                }else{
                    self.taoBaoList = response.result["淘宝"]
                    self.returnmsg = response.msg
                    self.returnCode = response.code
                }
            } catch {
                print("Error decoding JSON:", error)
            }
        }
        task.resume()
    }
}
