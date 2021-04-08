//
//  SelectFlavourVC.swift
//  PizzaExpress
//
//  Created by Subcodevs on 23/11/2020.
//  Copyright © 2020 Subodh. All rights reserved.
//

import UIKit


protocol  SelectFlavourVCDelegate {
     func didSelectId(_ id:String?)
}


class SelectFlavourVC: BaseViewController {

    // MARK:- IBOutlets
    @IBOutlet weak var screenTitleLabel:UILabel!
    @IBOutlet weak var tableView:UITableView!
    
    
    // MARK:- variables
    var delegate:SelectFlavourVCDelegate?
    var screenTitle:String?
    var slectionTitle:String?
    
    
    // MARK:- common
    var selectedId:String?
    var list = [ToppingsModel]()

    override func clickOnBack() {
        clickOnSave()
    }
    
    @objc func handleSwipeBack(gesture:UISwipeGestureRecognizer) {
        delegate?.didSelectId(selectedId)
    }
    
}




// MARK:- Life cycle
extension SelectFlavourVC {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let action = #selector(handleSwipeBack(gesture:))
        navigationController?.interactivePopGestureRecognizer?.addTarget(self, action: action)
        
        list = list.sorted{$0.position! < $1.position!}
        
        if let title = screenTitle {
           screenTitleLabel.text = title
        }
    }
    
    @IBAction func clickOnSave() {
        delegate?.didSelectId(selectedId)
        super.clickOnBackButton()
    }
}




// MARK:- UITableViewDelegate
extension SelectFlavourVC:UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedId = list[indexPath.row].id
        tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 56
    }
    
}




// MARK:- UITableViewDataSource
extension SelectFlavourVC:UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return list.count
    }
        
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PapatizerFlavorCell") as! PapatizerFlavorCell
        cell.flavor = list[indexPath.row]
        cell.checkButton.isSelected = (list[indexPath.row].id == selectedId)
        return cell
    }
    
}
