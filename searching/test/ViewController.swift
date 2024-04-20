//
//  ViewController.swift
//  test
//
//  Created by ssyb on 2024/4/18.
//

import UIKit

class ViewController: UIViewController,
                      UITableViewDelegate,
                      UITableViewDataSource,
                      UISearchBarDelegate
{
    //MARK:-tableview，热搜栏和查找结果的相关操作
    
    @IBOutlet weak var hotListResult: UITableView!
    @IBOutlet weak var searchResult: UITableView!
    
    //tag为1表示热搜榜的相关操作，为2是搜索栏结果的操作
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView.tag == 1 {
            if hotlist.taoBaoList == nil {
                return 0
            }else{
                return hotlist.taoBaoList!.count
            }
        }else if tableView.tag == 2 {
            //判断是否有历史记录，如果有先显示历史记录
            var hittoryNum = historylist.count
            if searchlist?.productList == nil {
                return 1+hittoryNum
            }else{
                if searchlist?.productList?.count == 0 {
                    return 1+hittoryNum
                }else{
                    return searchlist!.productList!.count+hittoryNum
                }
            }
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView.tag == 1{
            var cell = tableView.dequeueReusableCell(withIdentifier: "id1", for: indexPath) as? HotListTableViewCell
            if cell == nil {
                cell = HotListTableViewCell(style: .default, reuseIdentifier: "id1")
            }
            if hotlist.taoBaoList == nil {
                
            }else{
                cell!.set(index: hotlist.taoBaoList![indexPath.row].index,
                          content: hotlist.taoBaoList![indexPath.row].title,
                          hot: extractNumber(from: hotlist.taoBaoList![indexPath.row].hot) ?? "unkown")
            }
            return cell!
        }else{
            //判断历史记录数量，先显示历史记录再搜索结果
            if historylist.count>0 {
                if indexPath.row<historylist.count {
                    var cell = tableView.dequeueReusableCell(withIdentifier: "id3", for: indexPath)
                    cell.textLabel?.text = historylist[indexPath.row].name
                    cell.detailTextLabel?.text = ""
                    return cell
                }else{
                    var cell = tableView.dequeueReusableCell(withIdentifier: "id2", for: indexPath)
                    if searchlist?.productList == nil || searchlist?.productList?.count == 0 {
                        cell.textLabel?.text="nothing found"
                    }else{
                        cell.textLabel?.text = searchlist?.productList![indexPath.row - historylist.count].name
                    }
                    return cell
                }
            }else{
                var cell = tableView.dequeueReusableCell(withIdentifier: "id2", for: indexPath)
                if searchlist?.productList == nil || searchlist?.productList?.count == 0 {
                    cell.textLabel?.text = "nothing found"
                }else{
                    cell.textLabel?.text = searchlist?.productList![indexPath.row].name
                }
                return cell
            }
        }
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView.tag == 1 {
            let selectURl = self.hotlist.taoBaoList![indexPath.row].href
            performSegue(withIdentifier: "loadWeb", sender: selectURl)
        }else{
            //判断历史记录数量
            if historylist.count>0 && indexPath.row<historylist.count {
                return
            }else if indexPath.row >= historylist.count {
                var text = self.searchlist!.productList![indexPath.row-historylist.count].name
                for p in historylist{
                    if p.name == text{
                        return
                    }
                }
                historylist.append(Product(name: self.searchlist!.productList![indexPath.row-historylist.count].name,
                                           sales: self.searchlist!.productList![indexPath.row-historylist.count].sales))
                searchResult.reloadData()
            }else{
                var text = self.searchlist!.productList![indexPath.row-historylist.count].name
                for p in historylist{
                    if p.name == text{
                        return
                    }
                }
                historylist.append(Product(name: self.searchlist!.productList![indexPath.row].name,
                                           sales: self.searchlist!.productList![indexPath.row].sales))
                searchResult.reloadData()
            }
        }
        
    }
    //跳转前准备
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "loadWeb" {
            if let destVc = segue.destination as? WebViewController {
                if shouldPerformSegue(withIdentifier: segue.identifier ?? "", sender: sender) {
                    let selectUrl = sender as? String
                    destVc.productURL = selectUrl
                }
            }
        }
    }
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if let selectURL = sender as? String {
            return true
        }
        return false
    }
    //MARK:搜索框相关
    @IBOutlet weak var searchBar: UISearchBar!
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        hotListResult.isHidden = true
        searchResult.isHidden = false
        backButton.isHidden = false
        searchlist = SearchList()
        return true
    }
    //隐藏热搜，显示搜索结果
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        hotListResult.isHidden = true
        searchResult.isHidden = false
        searchlist?.loadData(searchURL: "https://api.oioweb.cn/api/search/taobao_suggest?keyword=".appending(searchText))
        DispatchQueue.main.asyncAfter(deadline: .now()+0.5){
            self.searchResult.reloadData()
        }
    }
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if let searchText = searchBar.text,searchText != "" {
            for p in historylist{
                if p.name == searchText{
                    return
                }
            }
            historylist.append(Product(name: searchText, sales: 3234))
        }
    }
    //MARK:初始化
    var hotlist: HotList
    var searchlist: SearchList?
    var historylist: [Product]
    init(){
        self.hotlist = HotList(hotListURL: "https://api.oioweb.cn/api/common/HotList")
        self.historylist = []
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        self.hotlist = HotList(hotListURL: "https://api.oioweb.cn/api/common/HotList")
        self.historylist = []
        super.init(coder: coder)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        hotListResult.dataSource = self
        hotListResult.delegate = self
        hotListResult.tag = 1
        
        searchResult.dataSource = self
        searchResult.delegate = self
        searchResult.tag = 2
        searchResult.isHidden = true
        
        backButton.isHidden = true
        searchBar.delegate = self
        
        var hotlist = HotList(hotListURL: "https://api.oioweb.cn/api/common/HotList")
        
        DispatchQueue.main.asyncAfter(deadline: .now()+0.5){
            self.hotListResult.reloadData()
        }
    }
    //提取热搜榜的热度
    func extractNumber(from str: String) -> String? {
        let regex = try! NSRegularExpression(pattern: "(\\d+\\.?\\d*|\\d+万)", options: [])
        if let match = regex.firstMatch(in: str, options: [], range: NSRange(location: 0, length: str.utf16.count)) {
            if let range = Range(match.range, in: str) {
                var ans = String(str[range])
                if ans.contains(".") {
                    ans = ans+"w"
                }
                return ans
            }
        }
        return nil
    }
    
    @IBOutlet weak var backButton: UIBarButtonItem!
    
    @IBAction func backToHot(_ sender: Any) {
        self.hotListResult.isHidden = false
        self.hotListResult.reloadData()
        self.searchResult.isHidden = true
        self.backButton.isHidden = true
    }
}

