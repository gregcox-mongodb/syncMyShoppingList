//
//  tableCell.swift
//  syncMyShoppingList
//
//  Created by Greg Cox on 15/07/2020.
//  Copyright © 2020 Greg Cox. All rights reserved.
//

import UIKit

class tableCell: UITableViewCell {

    @IBOutlet weak var cellImg: UIImageView!
    @IBOutlet weak var cellLbl: UILabel!
    @IBOutlet weak var cellLbl2: UILabel!
    @IBOutlet weak var cellLbl3: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
