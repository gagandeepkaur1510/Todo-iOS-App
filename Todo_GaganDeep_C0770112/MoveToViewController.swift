//
//  MoveToViewController.swift
//  Todo_GaganDeep_C0770112
//
//  Created by Mac on 6/28/20.
//  Copyright © 2020 Mac. All rights reserved.
//

import UIKit
import CoreData

class MoveToViewController: UIViewController {
    
    var delegate: TodoListViewController?
    @IBOutlet weak var tableView: UITableView!
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
    }
    
    @IBAction func cancelClicked(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
}


/// Extension for Table Operations
extension MoveToViewController: UITableViewDelegate, UITableViewDataSource
{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "categoryCell")
        if cell == nil
        {
            cell = UITableViewCell(style: .default, reuseIdentifier: "categoryCell")
        }
        cell?.textLabel?.text = categories[indexPath.row].title
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        delegate?.moveTo(movedToCategory: categories[indexPath.row])
        dismiss(animated: true, completion: nil)
    }
}
