//
//  ViewController.swift
//  Todo_GaganDeep_C0770112
//
//  Created by Mac on 6/27/20.
//  Copyright © 2020 Mac. All rights reserved.
//

import UIKit
import CoreData

class ViewController: UITableViewController {
    
    var categories = [Category]()
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadCategories()
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
                cond = false
                break
            }
        }
        if cond
        {
            let category = Category(context: context)
            category.title = "Archived"
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
}

