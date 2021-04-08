//
//  SelectAddonCell.swift
//  PizzaExpress
//
//  Created by Subcodevs on 23/11/2020.
//  Copyright © 2020 Subodh. All rights reserved.
//

import UIKit

class AddonChipsCell: UITableViewCell {
    
    // MARK:- IBOutlets
    @IBOutlet weak var nameLabel:UILabel!
    @IBOutlet weak var quantityLabel:UILabel!
    
    @IBOutlet weak var plusButton:UIButton!
    @IBOutlet weak var minusButton:UIButton!
    
    // MARK:- NSLayoutConstraint
    @IBOutlet weak var minusButtonWidth:NSLayoutConstraint!
    
    
    @IBOutlet weak var addonsView:UIView!
    @IBOutlet weak var checkButton:CheckedButton!
    
    
    //MARK:- Static Variables
    static let nib = UINib.init(nibName: "AddonChipsCell", bundle: nil)
    static let height:CGFloat = 58//37 + 17*widthFactor
    
    var senderVC:SelectAddonsVC!
    var senderCell:SelectAddonCell?
    
    var quantity:Int = 0
    var maxQuantity:Int = 0
    var totalQuantity:Int = 0
    
    var selectedAddons:[String:Int]?
    
    var chips:ToppingsModel? {
        didSet{
            fill()
        }
    }

    var dressingVC:SaladPreferencesVC?
    
    var dressing:ToppingsModel?{
        didSet{
            fillDressingInfo()
        }
    }
}





// MARK:- Life Cycle
extension AddonChipsCell {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
    }
    
    func fill() {
        
        nameLabel.text = chips?.name
        if let addonInfo = selectedAddons {
            let key = chips?.id ?? ""
            let value =  addonInfo[key] ?? 0
            self.quantity = value
            
            if quantity == 0  {
                resetStepper()
            }else{
                quantityLabel.text = "\(quantity)"
                minusButtonWidth.constant = 30
            }
            
            totalQuantity = 0
            addonInfo.forEach({
                totalQuantity += $0.value
            })
            
        }
    }
    
    
    func fillDressingInfo() {
        nameLabel.text = dressing?.name
        if let addonInfo = selectedAddons {
            let key = dressing?.id ?? ""
            let value =  addonInfo[key] ?? 0
            self.quantity = value
            if quantity == 0  {
                resetStepper()
            }else{
                quantityLabel.text = "\(quantity)"
                minusButtonWidth.constant = 30
            }
        }else{
            resetStepper()
        }
    }
    
    
}





// MARK:- IBActions
extension AddonChipsCell {
    
    
    @IBAction func clickOnCheck(_ sender:CheckedButton) {
        
        checkButton.iSelected =  !checkButton.iSelected
        
        let key = senderCell?.addon?.uuid ?? ""
        
        let totalQuantity = senderCell?.selectedAddons?[key] ?? 0
        var selectedQuantity:Int = 0
        
        if let dict = senderCell?.senderVC.selectedAddonModel[key] {
            dict.forEach({
                selectedQuantity += $0.value
            })
        }
    
        if checkButton.iSelected {
            if totalQuantity == 1 {
                senderCell?.selectedChips.removeAll()
            }else {
                if totalQuantity > selectedQuantity {
                    
                }else if totalQuantity == selectedQuantity {
                    
                }
            }
            senderCell?.selectedChips[chips?.id ?? ""] = 1
        }else{
             senderCell?.selectedChips.removeValue(forKey: chips?.id ?? "")
        }
        senderCell?.chipsTable.reloadData()
    }
    
    @IBAction func clickOnPlus(_ sender:UIButton) {
    
        if maxQuantity == 1 {
            totalQuantity = 0
            quantity = 0
            senderCell?.selectedChips.removeAll()
        }
        
        if quantity == 0 {
            minusButtonWidth.constant = 30
        }
        if totalQuantity < maxQuantity{
            quantity += 1
            quantityLabel.text = "\(quantity)"
        }
        updateSelecteAddonInfo()
    }
    
    
    
    @IBAction func clickOnMinus(_ sender:UIButton) {
        
        senderVC.tableView.reloadData()
        
        if quantity > 0 {
            quantity -= 1
            if quantity == 0 {
                quantityLabel.text = "Add"
                minusButtonWidth.constant = 60
                let key = dressing?.id ?? ""
                dressingVC?.selectedDressings.removeValue(forKey: key)
            }else{
                quantityLabel.text = "\(quantity)"
            }
        }
        updateSelecteAddonInfo()
    }
    
    
    func resetStepper() {
        quantity = 0
        quantityLabel.text = "Add"
        minusButtonWidth.constant = 60
    }
    
    
    func updateSelecteAddonInfo() {
        let key = chips?.id ?? ""
        senderCell?.selectedChips[key] = quantity
        if quantity == 0 {
            senderCell?.selectedChips.removeValue(forKey: key)
        }
        
        senderCell?.senderVC.selectedAddonModel[senderCell?.addon?.uuid ?? ""] = senderCell?.selectedChips ?? [:]
        senderCell?.chipsTable.reloadData()
    }
    
}

