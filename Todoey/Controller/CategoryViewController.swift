//
//  CategoryViewController.swift
//  Todoey
//
//  Created by André Vicente Pessanha on 25/02/2018.
//  Copyright © 2018 André Vicente Pessanha. All rights reserved.
//

import UIKit
import RealmSwift
import SwipeCellKit
import ChameleonFramework


class CategoryViewController: UITableViewController {
    
    let realm = try! Realm()
    
    var categoryArray : Results<Category>?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadCategories()
        tableView.rowHeight = 80.0
        tableView.separatorStyle = .none
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        guard let navBar = navigationController?.navigationBar else {fatalError("Navigation Controller não existe")}
        
        let navBarColor = FlatWhite()
        navBar.barTintColor = navBarColor
        navBar.tintColor = ContrastColorOf(navBarColor, returnFlat: true)
        
        navBar.largeTitleTextAttributes = [NSAttributedStringKey.foregroundColor : ContrastColorOf(navBarColor, returnFlat: true)]
        
    }
    
    //MARK: - TableView Data Source Methods

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categoryArray?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell", for: indexPath) as! SwipeTableViewCell
        cell.textLabel?.text = categoryArray?[indexPath.row].name ?? "Sem Categorias"
        cell.delegate = self
        
        //cell.backgroundColor = UIColor.randomFlat
        
        return cell
    }
    
    //MARK: - TableView Delegate Methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "goToItems", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! TodoListViewController
        if let indexPath = tableView.indexPathForSelectedRow {
            destinationVC.selectedCategory = categoryArray?[indexPath.row]
        }
    }
    
    //MARK: - Data Manipulation Methods
    
    func loadCategories (){
        
        categoryArray = realm.objects(Category.self)

        tableView.reloadData()
    }
    
    func save(category : Category){
        
        do{
            try realm.write {
                realm.add(category)
            }
        }
        catch{
            print("Error saving context \(error)")
        }
        tableView.reloadData()
    }
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add New Category", message: "", preferredStyle: .alert)
        
        let addAction = UIAlertAction(title: "Add", style: .default) { (action) in
            
            let newCategory = Category()
            newCategory.name = textField.text!
            self.save(category : newCategory)
        }
        
        alert.addAction(addAction)
        
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Category Name"
            textField = alertTextField
        }
        
        present(alert, animated: true, completion: nil)
        
    }
    
}

extension CategoryViewController : SwipeTableViewCellDelegate {
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        
        guard orientation == .right else { return nil }
        
        let deleteAction = SwipeAction(style: .destructive, title: "Delete") { action, indexPath in
            
            if let categoryForDeletion = self.categoryArray?[indexPath.row] {
                do{
                    try self.realm.write {
                        self.realm.delete(categoryForDeletion)
                    }
                }
                catch{
                    print("Erro ao deletar categoria, \(error)")
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

