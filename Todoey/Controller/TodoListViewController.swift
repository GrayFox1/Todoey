//
//  ViewController.swift
//  Todoey
//
//  Created by André Vicente Pessanha on 21/02/2018.
//  Copyright © 2018 André Vicente Pessanha. All rights reserved.
//

import UIKit
import RealmSwift
import SwipeCellKit
import ChameleonFramework

class TodoListViewController: UITableViewController{
    
    let realm = try! Realm()
    
    var itemArray : Results<Item>?
    var selectedCategory : Category? {
        didSet{
            loadItems()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.rowHeight = 80.0
        tableView.separatorStyle = .none
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        title = selectedCategory?.name
        let colorHex = FlatSkyBlue().hexValue()
        
        updateNavBar(withHexCode: colorHex)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        updateNavBar(withHexCode: "1D9BF6")
    }
    
    func updateNavBar(withHexCode colorHexCode : String){
        
        guard let navBar = navigationController?.navigationBar else {fatalError("Navigation Controller não existe")}
        guard let navBarColor = UIColor(hexString : colorHexCode) else {fatalError()}
        
        navBar.barTintColor = navBarColor
        navBar.tintColor = ContrastColorOf(navBarColor, returnFlat: true)
        
        navBar.largeTitleTextAttributes = [NSAttributedStringKey.foregroundColor : ContrastColorOf(navBarColor, returnFlat: true)]
        
    }
    
    
    
    //MARK - Table View Datasource Methods
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemArray?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: "ToDoItemCell", for: indexPath) as! SwipeTableViewCell
        cell.textLabel?.text = itemArray?[indexPath.row].title ?? "Sem item"
        
        cell.accessoryType = (itemArray?[indexPath.row].state)! ? .checkmark : .none
        cell.delegate = self
        
        if let color = FlatSkyBlue().darken(byPercentage: CGFloat(indexPath.row) / CGFloat(itemArray!.count)){
            cell.backgroundColor = color
            cell.textLabel?.textColor = ContrastColorOf(color, returnFlat: true)
        }
        
        
        return cell
    }
    
    //MARK - TableView Delegate Methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if let item = itemArray?[indexPath.row] {
            do{
                try realm.write{
                    item.state = !item.state
                }
            }
            catch{
                print(error)
            }
        }
        
        tableView.deselectRow(at: indexPath , animated: true)
        tableView.reloadData()
    }
    
    //MARK - Add new itens
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add New Item", message: "", preferredStyle: .alert)
        let action = UIAlertAction(title: "Add Item", style: .default) { (action) in
            
            if let currentCategory = self.selectedCategory {
                do{
                    try self.realm.write{
                        let newItem = Item()
                        newItem.title = textField.text!
                        newItem.dateCreated = Date()
                        currentCategory.items.append(newItem)
                    }
                }
                catch{
                    print("Error saving, \(error)")
                }
            }
            self.tableView.reloadData()
        }
        
        
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Item Name"
            textField = alertTextField
        }
        
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
    //MARK - Model Manipulation Methods
    
    func loadItems (){
        
        itemArray = selectedCategory?.items.sorted(byKeyPath: "title", ascending: true)
        tableView.reloadData()
    }
    
}

//MARK: - Search bar methods

extension TodoListViewController : UISearchBarDelegate {

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {

        itemArray = itemArray?.filter("title CONTAINS[cd] %@", searchBar.text!).sorted(byKeyPath: "dateCreated", ascending: true)
        
        tableView.reloadData()
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if(searchBar.text?.count == 0) {
            loadItems()

            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
        }
    }

}

extension TodoListViewController : SwipeTableViewCellDelegate {
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        
        guard orientation == .right else { return nil }
        
        let deleteAction = SwipeAction(style: .destructive, title: "Delete") { action, indexPath in
            
            if let itemForDeletion = self.itemArray?[indexPath.row] {
                do{
                    try self.realm.write {
                        self.realm.delete(itemForDeletion)
                    }
                }
                catch{
                    print("Erro ao deletar o item, \(error)")
                }
                
            }
        }
        
        // customize the action appearance
        deleteAction.image = UIImage(named: "trash")
        
        return [deleteAction]
    }
    
    func tableView(_ tableView: UITableView, editActionsOptionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> SwipeTableOptions {
        var options = SwipeTableOptions()
        options.expansionStyle = .destructive
        
        return options
    }
    
}

