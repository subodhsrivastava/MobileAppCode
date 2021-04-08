//
//  SelectFlavourVC.swift
//  PizzaExpress
//
//  Created by Subcodevs on 23/11/2020.
//  Copyright © 2020 Subodh. All rights reserved.
//

import UIKit


protocol  SelectDressingsDelegate {
    func didSelectId(_ id:String?)
}


class SelectDressingsVC: BaseViewController {
    
    // MARK:- IBOutlets
    @IBOutlet weak var screenTitleLabel:UILabel!
    @IBOutlet weak var tableView:UITableView!
    
    
    // MARK:- variables
    var delegate:SelectDressingsDelegate?
    var screenTitle:String?
    var slectionTitle:String?
    var isSingleSelection:Bool = true
    
    // MARK:- common
    var selectedId:String?
    var ids = [String]()
    var list = [ToppingsModel]()
    
    
}




// MARK:- Life cycle
extension SelectDressingsVC {
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func clickOnSave() {
        delegate?.didSelectId(selectedId)
        super.clickOnBack()
    }
}




// MARK:- UITableViewDelegate
extension SelectDressingsVC:UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedId = list[indexPath.row].id
        tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 56
    }
    
}




// MARK:- UITableViewDataSource
extension SelectDressingsVC:UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return list.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return UITableViewCell()
        /*let cell = tableView.dequeueReusableCell(withIdentifier: "PapatizerFlavorCell") as! PapatizerFlavorCell
        cell.flavor = list[indexPath.row]
        cell.checkButton.isSelected = (list[indexPath.row].id == selectedId)
        return cell*/
    }
    
}

