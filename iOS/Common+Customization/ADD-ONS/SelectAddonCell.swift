//
//  SelectAddonCell.swift
//  PizzaExpress
//
//  Created by Subcodevs on 23/11/2020.
//  Copyright © 2020 Subodh. All rights reserved.
//

import UIKit

class SelectAddonCell: UITableViewCell {

    // MARK:- IBOutlets
    @IBOutlet weak var nameLabel:UILabel!
    @IBOutlet weak var quantityLabel:UILabel!
    
    @IBOutlet weak var plusButton:UIButton!
    @IBOutlet weak var minusButton:UIButton!
    
    // MARK:- NSLayoutConstraint
    @IBOutlet weak var minusButtonWidth:NSLayoutConstraint!
    
    
    @IBOutlet weak var addonsView:UIView!
    @IBOutlet weak var checkButton:CheckedButton!
    
    
    
    @IBOutlet weak var chipsView:UIView!
    @IBOutlet weak var chipsTable:UITableView!
    
    
    //MARK:- Static Variables
    static let nib = UINib.init(nibName: "SelectAddonCell", bundle: nil)
    static let height:CGFloat = 58//37 + 17*widthFactor
    
    var senderVC:SelectAddonsVC!
    
    var quantity:Int = 0
    var totalQuantity:Int = 0
    
    var selectedAddons:[String:Int]?
    var selectedChips:[String:Int] = [:]
    
    var addon:ToppingsModel? {
        didSet{
            fill()
        }
    }
    
    var isNotAddon = false
    var dressingVC:SaladPreferencesVC?
    
    var dressing:ToppingsModel?{
        didSet{
            fillDressingInfo()
        }
    }
}





// MARK:- Life Cycle
extension SelectAddonCell {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
        chipsTable.register(AddonChipsCell.nib, forCellReuseIdentifier: "AddonChipsCell")
    }
    
    func fill() {
        nameLabel.text = addon?.name
        if let addonInfo = selectedAddons {
            let key = addon?.uuid ?? ""
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
extension SelectAddonCell {
   
    
    @IBAction func clickOnCheck(_ sender:CheckedButton) {
        checkButton.iSelected =  !checkButton.iSelected
        if checkButton.iSelected  {
           dressingVC?.selecteNoDressing()
        }else{
            let key = dressing?.id ?? ""
            dressingVC?.selectedDressings.removeValue(forKey: key)
            dressingVC?.tableView.reloadData()
        }
    }
    
    @IBAction func clickOnPlus(_ sender:UIButton) {
        if isNotAddon {
            handlePlus()
            return
        }
        
        for object in senderVC.selectedAddons {
            
            let insideDict = senderVC.selectedAddonModel[object.key]
            
            var insideQuantity:Int = 0
            insideDict?.forEach({
                insideQuantity += $0.value
            })
            
            if object.value != insideQuantity && object.key != addon?.uuid{
                if let index = senderVC.list.firstIndex(where: {$0.uuid == object.key}) {
                   let indexPath = IndexPath.init(row: index, section: 0)
                   let cell = senderVC.tableView.cellForRow(at: indexPath) as? SelectAddonCell
                   cell?.chipsTable.shake()
                   vibrate()
                }
                return
            }
            
        }
        
        
        if quantity == 0 {
            minusButtonWidth.constant = 30
        }
        
        if totalQuantity < senderVC.maxQuantity{
           quantity += 1
           quantityLabel.text = "\(quantity)"
        }
        senderVC.selectedAddonModel[addon?.uuid ?? ""] = selectedChips
        updateSelecteAddonInfo()
        
    }
    
    
    
    @IBAction func clickOnMinus(_ sender:UIButton) {
        if isNotAddon {
            handleMinus()
            return
        }
        
        senderVC.tableView.reloadData()
        if quantity > 0 {
            quantity -= 1
            if quantity == 0 {
               quantityLabel.text = "Add"
               minusButtonWidth.constant = 65
               let key = dressing?.id ?? ""
               dressingVC?.selectedDressings.removeValue(forKey: key)
            }else{
               quantityLabel.text = "\(quantity)"
            }
        }
        
        var chipsQuantity = 0
        
        selectedChips.forEach({
            chipsQuantity += $0.value
        })
        
        if chipsQuantity > quantity {
           let key = selectedChips.first?.key ?? ""
            if let value = selectedChips[key] , value > 1 {
               selectedChips[key] = value - 1
            }else{
              selectedChips.removeValue(forKey: key)
            }
           chipsTable.reloadData()
        }
        
        senderVC.selectedAddonModel[addon?.uuid ?? ""] = selectedChips
        chipsTable.reloadData()
        updateSelecteAddonInfo()
    }
    
    
    func resetStepper() {
        quantity = 0
        quantityLabel.text = "Add"
        minusButtonWidth.constant = 65
    }
    
    
    func updateSelecteAddonInfo() {
        
        let key = addon?.uuid ?? ""
        if quantity != 0 {
            if key != "" {
               senderVC?.selectedAddons[key] = quantity
            }
        }
        
        if quantity == 0 {
            senderVC.openIndex = -1
            senderVC?.selectedAddons.removeValue(forKey: key)
        }else{
            if let index = senderVC.tableView.indexPath(for: self) {
                senderVC.openIndex = index.row
            }
        }
        senderVC?.tableView.reloadData()
    }
    
    
    func handlePlus() {
        if quantity == 0 {
            minusButtonWidth.constant = 35
        }
        quantity += 1
        quantityLabel.text = "\(quantity)"
        let key = dressingVC?.noDressingId ?? ""
        dressingVC?.selectedDressings.removeAll()
        dressingVC?.selectedDressings[key] = nil
        updateSelectedDressing()
    }
    
    
    func handleMinus() {
        if quantity > 0 {
            quantity -= 1
            if quantity == 0 {
                quantityLabel.text = "Add"
                minusButtonWidth.constant = 65
            }else{
                quantityLabel.text = "\(quantity)"
            }
        }
        updateSelectedDressing()
    }
    
    
    func updateSelectedDressing() {
        let id = dressing?.id ?? ""
        dressingVC?.selectedDressings[id] = quantity
        dressingVC?.tableView.reloadData()
        
    }
    
    
}










extension SelectAddonCell:UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isNotAddon {return 0}
        return senderVC.chips.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "AddonChipsCell") as! AddonChipsCell
        
        cell.senderVC = senderVC
        cell.senderCell = self
        
        cell.selectedAddons = selectedChips
        cell.maxQuantity = quantity
        cell.chips = senderVC.chips[indexPath.row]
        
        let name = senderVC.chips[indexPath.row].name ?? ""
        let id = senderVC.chips[indexPath.row].id ?? ""
        
        if name.lowercased() == "no chips" {
            cell.addonsView.isHidden = true
            cell.checkButton.isHidden = false
            cell.checkButton.iSelected = selectedChips[id] != nil
        }else{
            cell.addonsView.isHidden = false
            cell.checkButton.isHidden = true
        }
        
        return cell
    }
    
}







extension SelectAddonCell:UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
}
