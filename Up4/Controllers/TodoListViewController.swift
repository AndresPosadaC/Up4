//
//  ViewController.swift
//  Up4
//
//  Created by Andres Posada Cortazar on 5/3/19.
//  Copyright © 2019 Andres Posada Cortazar. All rights reserved.
//

import UIKit
import RealmSwift
import ChameleonFramework

class TodoListViewController: SwipeTableViewController {

    var todoItems: Results<Item>?
    let realm = try! Realm()
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    var selectedCategory : Category? {
        didSet{
            loadItems()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.separatorStyle = .none
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        title = selectedCategory?.name
        
        guard let colourHex = selectedCategory?.colour else { fatalError() }
        
        updateNavBar(withHexCode: colourHex)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        updateNavBar(withHexCode: "28AAC0")
        
    }
    
    //MARK: - Nav Bar Setup Methods
    
    func updateNavBar(withHexCode colourHexCode: String){
        
        guard let navBar = navigationController?.navigationBar else {fatalError("Navigation controller does not exist.")}
        
        guard let navBarColour = UIColor(hexString: colourHexCode) else { fatalError()}
        
        navBar.barTintColor = navBarColour
        
        navBar.tintColor = ContrastColorOf(navBarColour, returnFlat: true)
        
        navBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor : ContrastColorOf(navBarColour, returnFlat: true)]
        
        searchBar.barTintColor = navBarColour
        
    }

    //MARK: - Tableview Datasource Methods
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return todoItems?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        
        if let item = todoItems?[indexPath.row] {
            
            cell.textLabel?.text = item.title
            let titulo = item.title
            
            //Ternary operator ==>
            // value = condition ? valueIfTrue : valueIfFalse
            cell.accessoryType = item.done ? .checkmark : .none
            
            let day = daysLeft(iDate: Date(),fDate: item.itemDeadLine!)

//            print("item \(titulo)")
            
            guard let itemColour = UIColor(hexString: cellColour(checkMark: item.done, daysLeft: day, deadLineDays: item.deadLineDays)) else {fatalError()}
            cell.backgroundColor = itemColour
            
        } else {
            cell.textLabel?.text = "No Items Added"
        }
        
        return cell
        
    }
    
    
    //MARK: - TableView Delegate Methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if let item = todoItems?[indexPath.row] {
            do {
                try realm.write {
                    item.done = !item.done
                }
            } catch {
                print("Error saving done status, \(error)")
            }
        }
        
        tableView.reloadData()
        
        tableView.deselectRow(at: indexPath, animated: true)
        
    }
    
    
    // MARK: - Add new items    
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        var textField = UITextField()
        var deadLineField = UITextField()
        
        let alert = UIAlertController(title: "Add New Item", message: "", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Add Item", style: .default) { (action) in
            
            if let currentCategory = self.selectedCategory {
                do {
                    try self.realm.write {
                        let newItem = Item()
                        var deadLineDays = Int(deadLineField.text!)!
                        if deadLineDays <= 0 {
                            deadLineDays = 1
                        }
                        newItem.title = textField.text!
                        newItem.deadLineDays = deadLineDays
                        newItem.dateItemCreated = Date()
                        newItem.itemDeadLine = Calendar.current.date(byAdding: .day, value: deadLineDays, to: Date())
                        
                        let day = self.daysLeft(iDate: newItem.dateItemCreated!,fDate: newItem.itemDeadLine!)

                        newItem.cellColour = self.cellColour(checkMark: newItem.done, daysLeft: day,deadLineDays: deadLineDays)
                        
                        currentCategory.items.append(newItem)
                    }
                } catch {
                    print("Error saving new items, \(error)")
                }
            }
            
            self.tableView.reloadData()
            
        }
        
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Create new item"
            textField = alertTextField
        }
        
        let maxDays = self.selectedCategory?.daysLeft
        
        alert.addTextField { (field2) in
            deadLineField = field2
            deadLineField.keyboardType = .numberPad
            deadLineField.placeholder = "<= \(maxDays ?? 1) days"
        }
        
        alert.addAction(action)
        
        present(alert, animated: true, completion: nil)
        
    }
    
    func daysLeft(iDate: Date, fDate: Date)->Int{
        let gregorian = NSCalendar(calendarIdentifier:NSCalendar.Identifier.gregorian)
        let components = gregorian?.components(NSCalendar.Unit.day, from: iDate, to: fDate, options: .matchFirst)
        
        guard let day = components?.day else { return 0 }
        return day
    }
    
    func cellColour(checkMark: Bool, daysLeft: Int, deadLineDays: Int)-> String{
        
        var hexString: String = "FFFFFF"
        
        let percent: CGFloat = CGFloat(daysLeft)/CGFloat(deadLineDays)
        
//        print("daysLeft/deadLineDays: \(daysLeft) / \(deadLineDays) = percent \(percent)")
        
        if checkMark == true {
            hexString = (UIColor.flatBlue.lighten(byPercentage: 0.8)?.hexValue())!
        } else if percent <= 0.2 {
            hexString = (UIColor.flatRed.lighten(byPercentage: 0.6)?.hexValue())!
        } else if percent <= 0.4 {
            hexString = (UIColor.flatYellow.lighten(byPercentage: 0.6)?.hexValue())!
        } else if percent <= 0.7 {
            hexString = (UIColor.flatMint.lighten(byPercentage: 0.7)?.hexValue())!
        } else {
            hexString = (UIColor.flatWhite.hexValue())
        }
        return hexString
    }
    
        //MARK - Model Manupulation Methods
    
    func loadItems() {
        
        todoItems = selectedCategory?.items.sorted(byKeyPath: "dateItemCreated", ascending: true)
        
        tableView.reloadData()
        
    }

    //MARK: - Delete Data From Swipe
    
    override func updateModel(at indexPath: IndexPath) {
        
        //super.updateModel(at: indexPath)
        
        if let itemForDeletion = todoItems?[indexPath.row] {
            do {
                try realm.write {
                    realm.delete(itemForDeletion)
                }
            } catch {
                print("Error deleting item, \(error)")
            }
        }
    }
    
}

// MARK: - Searchbar Methods

extension TodoListViewController: UISearchBarDelegate {

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {

        todoItems = todoItems?.filter("title CONTAINS[cd] %@", searchBar.text!).sorted(byKeyPath: "dateItemCreated", ascending: true)

        tableView.reloadData()

    }


    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0 {
            loadItems()

            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }

        }
    }
}
