//
//  CategoryViewController.swift
//  Up4
//
//  Created by Andres Posada Cortazar on 5/21/19.
//  Copyright © 2019 Andres Posada Cortazar. All rights reserved.
//

import UIKit
import RealmSwift
import ChameleonFramework

class CategoryViewController: SwipeTableViewController {

    let realm = try! Realm()
    var categories: Results<Category>?
    
    
    @IBOutlet weak var SearchBarP: UISearchBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadCategories()
        tableView.separatorStyle = .none
      
    }

    // MARK: - TableView Datasource Methods
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return categories?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        
        if let category = categories?[indexPath.row] {
            
            cell.textLabel?.text = category.name
            
            //todays date until deadLine (predefined when creation)
            let day = daysLeft(iDate: Date(),fDate: category.deadLine!)
            
            guard let categoryColour = UIColor(hexString: cellColour(daysLeft: day, deadLineDays: category.daysLeft)) else {fatalError()}
            
            cell.backgroundColor = categoryColour
            cell.textLabel?.textColor = ContrastColorOf(categoryColour, returnFlat: true)
            
        }
        
        return cell
    }
    
    //MARK: - TableView Delegate Methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "goToItems", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! TodoListViewController
        
        if let indexPath = tableView.indexPathForSelectedRow {
            destinationVC.selectedCategory = categories?[indexPath.row]
        }
    }
    
    // MARK: - Data Manipulation Methods
    
    func save(category: Category) {
        do {
            try realm.write {
                realm.add(category)
            }
        } catch {
            print("Error saving category \(error)")
        }
        
        tableView.reloadData()
        
    }
    
    func loadCategories() {
        
        categories  = realm.objects(Category.self)
        
        tableView.reloadData()
        
    }
    
    //MARK: - Delete Data From Swipe
    
    override func updateModel(at indexPath: IndexPath) {
        
        //super.updateModel(at: indexPath)
        
        if let categoryForDeletion = self.categories?[indexPath.row] {
            do {
                try self.realm.write {
                    self.realm.delete(categoryForDeletion)
                }
            } catch {
                print("Error deleting category, \(error)")
            }
        }
    }
    
    // MARK - Add New Categoies
    
    @IBAction func addButonPressed(_ sender: UIBarButtonItem) {
        
        var textField = UITextField()
        var deadLineField = UITextField()
        
//        var dateInterval: Double = 1.0
        
        let alert = UIAlertController(title: "New Project", message: "Please specify the number of days expected to complete this project", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Add", style: .default) { (action) in
            
            let newCategory = Category()
            
            // must be grater or equal to zero days
            var deadLineDays = Int(deadLineField.text!)!
            if deadLineDays <= 0 {
                deadLineDays = 1
            }
            
            newCategory.name = textField.text!
            newCategory.dateCreated = Date()
            
            // sets future date corresponding to the deadline date by adding the number of days to the date of creation
            newCategory.deadLine = Calendar.current.date(byAdding: .day, value: deadLineDays, to: Date())
            
            // sets the horizon day should be equal to deadLineDays when creation
            let day = daysLeft(iDate: newCategory.dateCreated!,fDate: newCategory.deadLine!)
            newCategory.daysLeft = day
            newCategory.colour = cellColour(daysLeft: day,deadLineDays: deadLineDays)

            self.save(category: newCategory)
            
        }
        
        alert.addAction(action)
        
        alert.addTextField { (field) in
            textField = field
            textField.keyboardType = .default
            textField.placeholder = "New project's title"
        }

        alert.addTextField { (field2) in
            deadLineField = field2
            deadLineField.keyboardType = .numberPad
            deadLineField.placeholder = "Number of days until dead line"
        }
        
        present(alert, animated: true, completion: nil)
    }
    
}

func daysLeft(iDate: Date, fDate: Date)->Int{
    let gregorian = NSCalendar(calendarIdentifier:NSCalendar.Identifier.gregorian)
    let components = gregorian?.components(NSCalendar.Unit.day, from: iDate, to: fDate, options: .matchFirst)
    
    guard let day = components?.day else { return 1 }
    return day
}

func cellColour(daysLeft: Int, deadLineDays: Int)-> String{
    
    var hexString: String = "FFFFFF"
    
    let percent: CGFloat = CGFloat(daysLeft)/CGFloat(deadLineDays)
    
    if percent <= 0.2 {
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

 //MARK: - Searchbar Methods

extension CategoryViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        categories = categories?.filter("name CONTAINS[cd] %@", searchBar.text!).sorted(byKeyPath: "name", ascending: true)
        
        tableView.reloadData()
        
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0 {
            
            loadCategories()
            
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
            
        }
    }
}
