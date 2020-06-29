//
//  ViewController.swift
//  Todo_GaganDeep_C0770112
//
//  Created by Mac on 6/27/20.
//  Copyright © 2020 Mac. All rights reserved.
//

import UIKit
import CoreData
import UserNotifications

class ViewController: UITableViewController {
    
    var categories = [Category]()
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var selectedCategory: Category?
    var archivedCategory: Category?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadCategories()
        setupNotification()
    }
    
    func loadCategories() {
        let request: NSFetchRequest<Category> = Category.fetchRequest()
        
        do {
            categories = try context.fetch(request)
        } catch {
            print("Error loading folders \(error.localizedDescription)")
        }
        var cond = true
        for category in categories
        {
            if category.title == "Archived"
            {
                archivedCategory = category
                cond = false
                break
            }
        }
        if cond
        {
            let category = Category(context: context)
            category.title = "Archived"
            archivedCategory = category
            categories.append(category)
            save()
        }
        tableView.reloadData()
    }
    
    func save()
    {
        do {
            try context.save()
            tableView.reloadData()
        } catch {
            print("Error saving folders \(error.localizedDescription)")
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "categoryCell")
        if cell == nil
        {
            cell = UITableViewCell(style: .default, reuseIdentifier: "categoryCell")
        }
        cell?.textLabel?.text = categories[indexPath.row].title
        return cell!
    }
    
    @IBAction func addCategoryClicked(_ sender: Any) {
        var textField = UITextField()
        let alert = UIAlertController(title: "Add New Category", message: "", preferredStyle: .alert)
        let addAction = UIAlertAction(title: "Add", style: .default) { (action) in
            let categoryNames = self.categories.map {$0.title}
            guard !categoryNames.contains(textField.text) else {self.showAlert(); return}
            let newCategory = Category(context: self.context)
            newCategory.title = textField.text!
            self.categories.append(newCategory)
            self.save()
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        cancelAction.setValue(UIColor.orange, forKey: "titleTextColor")
        
        alert.addAction(addAction)
        alert.addAction(cancelAction)
        alert.addTextField { (field) in
            textField = field
            textField.placeholder = "Category Name"
        }
        present(alert, animated: true, completion: nil)
    }
    
    func showAlert() {
        let alert = UIAlertController(title: "Name Taken", message: "Please choose another name", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        okAction.setValue(UIColor.orange, forKey: "titleTextColor")
        alert.addAction(okAction)
        present(alert, animated: true, completion: nil)
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedCategory = categories[indexPath.row]
        performSegue(withIdentifier: "totodolist", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let tlvc = segue.destination as? TodoListViewController
        {
            tlvc.selectedCategory = selectedCategory
            tlvc.archivedCategroy = archivedCategory
        }
    }
    
    func setupNotification()
    {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert]) {
            (granted, error) in
            if granted {
                print("yes")
            } else {
                print("no")
            }
        }
    }
}

