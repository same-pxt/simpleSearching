//
//  HotListTableViewCell.swift
//  test
//
//  Created by ssyb on 2024/4/18.
//

import UIKit

class HotListTableViewCell: UITableViewCell {
    //MARK:-自定义的tableviewcell，热搜榜的格式设置
    @IBOutlet weak var index: UILabel!
    @IBOutlet weak var content: UILabel!
    @IBOutlet weak var hot: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func set(index: Int,content: String,hot: String)
    {
        self.index.text = String(index)
        self.content.text = content
        self.hot.text = hot
    }
    
}
