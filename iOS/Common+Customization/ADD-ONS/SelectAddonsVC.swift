//
//  SelectAddonsVC.swift
//  PizzaExpress
//
//  Created by Subcodevs on 23/11/2020.
//  Copyright © 2020 Subodh. All rights reserved.
//

import UIKit

protocol AddonDelegate {
    func didSelectAddon(addon:[String:Int])
    func didSelectAddonChips(addon:[String:[String:Int]])
}

class SelectAddonsVC: BaseViewController{

    @IBOutlet weak var tableView:UITableView!
    @IBOutlet weak var titleLable:UILabel!
    @IBOutlet weak var descrptionLabel:UILabel!
    @IBOutlet weak var imageLayer:UIImageView!
    
    // MARK:- NSLayoutConstraint
    @IBOutlet weak var descrptionLabelTop:NSLayoutConstraint!
    @IBOutlet weak var tableViewTop:NSLayoutConstraint!
    
    var delegate:AddonDelegate?
    
    var list = [ToppingsModel]()
    var maxQuantity:Int = 1
    var selectedAddons:[String:Int] = [:]
    var descriptionStr: String?
    var openIndex:Int = -1
    var selectedAddonModel:[String:[String:Int]] = [:]
    
    var isToDecreseAddon = false
    
    var chips = [ToppingsModel]()
    
    
    override func clickOnBack() {
        
        for object in selectedAddons {
            
            let insideDict = selectedAddonModel[object.key]
            var insideQuantity:Int = 0
            
            insideDict?.forEach({
                insideQuantity += $0.value
            })
            
            if object.value != insideQuantity {
                showAlert(msg: "Please select a chip type.", title: "Message", sender: self)
                return
            }
            
        }
        
        clickOnSave(UIButton())
    }
    
    @objc func handleSwipeBack(gesture:UISwipeGestureRecognizer) {
        if gesture.state == .ended {
            delegate?.didSelectAddon(addon: selectedAddons)
            delegate?.didSelectAddonChips(addon: selectedAddonModel)
        }
    }
    
}




// MARK:- Life Cycle
extension SelectAddonsVC {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        chips = customizationFor(type: Food.addons)?.chip ?? []
        chips = chips.sort()
        
        let action = #selector(handleSwipeBack(gesture:))
        navigationController?.interactivePopGestureRecognizer?.addTarget(self, action: action)
        
        tableView.register(SelectAddonCell.nib, forCellReuseIdentifier: "SelectAddonCell")
        
        if let str = descriptionStr {
           descrptionLabel.text = str
           descrptionLabelTop.constant  = 16
           tableViewTop.constant  = 16
           imageLayer.alpha = 1
        }
        
        titleLable.text = "MAKE IT A MEAL"
    }
    
    @IBAction func clickOnSave(_ sender:UIButton) {
        selectedAddons.removeValue(forKey: "")
        delegate?.didSelectAddon(addon: selectedAddons)
        delegate?.didSelectAddonChips(addon: selectedAddonModel)
        super.clickOnBackButton()
    }
    
}




// MARK:- UITableViewDataSource
extension SelectAddonsVC :UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return list.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SelectAddonCell") as! SelectAddonCell
        cell.senderVC = self
        cell.selectedAddons = selectedAddons
        cell.selectedChips = selectedAddonModel[list[indexPath.row].uuid ?? ""] ?? [:]
        cell.addon = list[indexPath.row]
        return cell
    }
}




// MARK:- UITableViewDataSource
extension SelectAddonsVC :UITableViewDelegate{
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let key = list[indexPath.row].uuid ?? ""
        
        if selectedAddons[key] != nil && (selectedAddons[key] ?? 0) > 0{
            let tableHeight = CGFloat( 56 + 56 + 50*(chips.count))
            return tableHeight  - CGFloat(10)
        }else{
           return SelectAddonCell.height
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        openIndex = indexPath.row == openIndex ? -1 : indexPath.row
        tableView.reloadData()
    }
    
}
