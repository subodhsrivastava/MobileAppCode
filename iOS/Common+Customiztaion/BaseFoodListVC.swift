//
//  BaseFoodListVC.swift
//  PizzaExpress
//
//  Created by Subcodevs on 23/11/2020.
//  Copyright © 2020 Subodh. All rights reserved.
//

import UIKit

@IBDesignable class BaseFoodListVC: BaseViewController {

    /// table view outlet
    @IBOutlet weak var tableView: UITableView!
    
    /// array of food items
    var foodList = [PizzaModel](){
        didSet{
            foodList.forEach({$0.updatePrices()})
        }
    }
    
    /// array of search food items
    var searchList = [PizzaModel]()
    
    /// refrence to the ExploreMenuVC for refreshing purpose
    weak var exploreMenu:ExploreMenuVC!
    
    /// list of items in cart
    var cartList = [UserCart]()
    
    var emptyView = NoResultView.view(frame: ExploreMenuVC.noResultFrame)
    
    var openIndex:Int = -1
    var selectedInfos = SelectedPizzaInfo()
    var selectedSaladInfo = SelectSaladInfo()
    var selectedPapatizer = SelectedPapatizerInfo()
    var selectedSubsModel = SelectedSubsInfo()
    var selectedPitaModel = SelectedPitaInfo()
    var selectedDinnerModel = SelectedDinnerModel()
    var selectedSizeId:String?
    
    
    override var preferredStatusBarStyle: UIStatusBarStyle{
        return .lightContent
    }
    
    var isSearchActive : Bool {
        let textCount = exploreMenu?.txtSearch.text?.count ?? 0
        return textCount > 0 ? true : false
    }
    
    @IBInspectable var type:String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.setEstimatedHeights()
        tableView.tableFooterView = listFooterView
        refresh()
    }
    

    func refresh() {
        foodList = foodList.sorted{$0.position! < $1.position!}
        cartList = appDelegate.cartFor(type)
        tableView?.reloadData()
    }
    
    /// clear search data and reload table
    func clearSearch() {
        searchList.removeAll()
        tableView?.reloadData()
    }
    
    @objc func didSelectCell(cell:BaseFoodListCell) {
        
    }

}



// MARK:-UITableViewDataSource
extension BaseFoodListVC:UITableViewDataSource ,UITableViewDelegate{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isSearchActive {
            if searchList.count == 0{
                addEmptyView()
            }else {
                removeEmptyView()
            }
            return searchList.count
        }else {
            removeEmptyView()
            if foodList.count == 0 {addEmptyView()}
            return foodList.count
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ExploreFoodCell") as! ExploreFoodCell
        cell.parentVC = self.exploreMenu
        if isSearchActive {
            cell.pizza = searchList[indexPath.row]
        }else {
            cell.pizza = foodList[indexPath.row]
        }
        cell.updateCart(list: cartList)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return exploreCellHeight
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
    
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        let detail = isSearchActive == true ? searchList[indexPath.row] : foodList[indexPath.row]
        detail.updatePrices()
        return indexPath
    }
    
    func addEmptyView() {
        self.view.addSubview(emptyView)
    }
    
    func removeEmptyView() {
        emptyView.removeFromSuperview()
    }
}
