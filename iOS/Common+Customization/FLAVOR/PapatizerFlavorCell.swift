//
//  PapatizerFlavorCell.swift
//  PizzaExpress
//
//  Created by Subcodevs on 23/11/2020.
//  Copyright © 2020 Subodh. All rights reserved.
//

import UIKit

class PapatizerFlavorCell:UITableViewCell {
    
    @IBOutlet weak var checkButton:UIButton!
    @IBOutlet weak var title:UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
    }
    
    var flavor:ToppingsModel? {
        didSet{
            title.text = flavor?.name
        }
    }
}
