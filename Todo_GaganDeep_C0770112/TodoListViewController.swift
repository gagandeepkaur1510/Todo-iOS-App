//
//  TodoListViewController.swift
//  Todo_GaganDeep_C0770112
//
//  Created by Mac on 6/27/20.
//  Copyright © 2020 Mac. All rights reserved.
//

import UIKit
import CoreData
import UserNotifications

class TodoListViewController: UIViewController {
    
    var selectedCategory: Category?
    var todos = [Todo]()
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    @IBOutlet weak var tableView: UITableView!
    let TODAY = Date()
    let ONE_DAY = 24*60*60
    var archivedCategroy: Category?
    var selectedTodo: Todo?
    @IBOutlet weak var editButton: UIBarButtonItem!
    let searchController = UISearchController(searchResultsController: nil)
    var editingRows: Bool = false
    @IBOutlet weak var moveToButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        showSearchBar()
        title = selectedCategory?.title
        loadTodos()
    }
    
    func loadTodos() {
        let request: NSFetchRequest<Todo> = Todo.fetchRequest()
        let predicate = NSPredicate(format: "category.title = %@", selectedCategory!.title!)
        request.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
        request.predicate = predicate
        do {
            todos = try context.fetch(request)
        } catch {
            print("Error loading folders \(error.localizedDescription)")
        }
        tableView.reloadData()
    }
    
    func loadTodos(with request: NSFetchRequest<Todo> = Todo.fetchRequest(), predicate: NSCompoundPredicate? = nil) {
    //        let request: NSFetchRequest<Note> = Note.fetchRequest()
            let categoryPredicate = NSPredicate(format: "category.title=%@", selectedCategory!.title!)
            request.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
            if let addtionalPredicate = predicate
            {
                request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [categoryPredicate, addtionalPredicate])
            } else {
                request.predicate = categoryPredicate
            }
            
            do {
                todos = try context.fetch(request)
            } catch {
                print("Error loading notes \(error.localizedDescription)")
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
    
    
    @IBAction func segmentedControlValueChanged(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0
        {
            todos.sort { (todo1, todo2) -> Bool in
                if todo1.title! < todo2.title!
                {
                    return true
                }
                return false
            }
        }
        else if sender.selectedSegmentIndex == 1
        {
            todos.sort { (todo1, todo2) -> Bool in
                if todo1.title! > todo2.title!
                {
                    return true
                }
                return false
            }
        }
        else if sender.selectedSegmentIndex == 2
        {
            todos.sort { (todo1, todo2) -> Bool in
                if todo1.created! < todo2.created!
                {
                    return true
                }
                return false
            }
        }
        else if sender.selectedSegmentIndex == 3
        {
            todos.sort { (todo1, todo2) -> Bool in
                if todo1.created! > todo2.created!
                {
                    return true
                }
                return false
            }
        }
        tableView.reloadData()
    }
    // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let tdvc = segue.destination as? TodoDetailViewController
        {
            tdvc.delegate = self
            tdvc.selectedTodo = selectedTodo
        }
        if let mtvc = segue.destination as? MoveToViewController
        {
            mtvc.delegate = self
        }
     }
    
    @IBAction func addTodoClicked(_ sender: Any) {
        performSegue(withIdentifier: "tododetail", sender: self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        selectedTodo = nil
    }
    
    func showSearchBar() {
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search Todo"
        navigationItem.searchController = searchController
        searchController.searchBar.delegate = self
        definesPresentationContext = true
    }
    
    
    @IBAction func moveToClicked(_ sender: Any) {
        performSegue(withIdentifier: "moveTo", sender: self)
    }
    
    @IBAction func editClicked(_ sender: Any) {
        editingRows = !editingRows
        if editingRows
        {
            editButton.title = "Done"
            moveToButton.isHidden = false
        }
        else
        {
            editButton.title = "Edit"
            moveToButton.isHidden = true
        }
        tableView.setEditing(editingRows, animated: true)
    }
    
    func addNotification(title: String, description: String?, date: Date)
    {
        let content = UNMutableNotificationContent()
        content.title = "Todo"
        content.subtitle = title
        if let desc = description
        {
            content.body = desc
        }
        else
        {
            content.body = "Due tomrrow"
        }
        let imageName = "applelogo"
        guard let imageURL = Bundle.main.url(forResource: imageName, withExtension: "png") else {return }
        let attachment = try! UNNotificationAttachment(identifier: imageName, url: imageURL, options: .none)
        content.attachments = [attachment]
        let triggerDate = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: date.addingTimeInterval(TimeInterval(-ONE_DAY)))
        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: false)
        let request = UNNotificationRequest(identifier: "notification.id.01", content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
    }
}

extension TodoListViewController: UITableViewDataSource, UITableViewDelegate
{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return todos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "todoCell")
        if cell == nil
        {
            cell = UITableViewCell(style: .default, reuseIdentifier: "todoCell")
        }
        cell?.textLabel?.text = todos[indexPath.row].title
        setCellColor(due: todos[indexPath.row].due, cell: cell!)
        return cell!
    }
    
    func setCellColor(due: Date?, cell: UITableViewCell)
    {
        if let date = due
        {
            if date <= TODAY
            {
                cell.backgroundColor = .red
            }
            else if Calendar.current.isDate(TODAY.addingTimeInterval(TimeInterval(ONE_DAY)), equalTo: date, toGranularity: .day)
            {
                cell.backgroundColor = .green
            }
            else
            {
                cell.backgroundColor = .white
            }
        }
        return
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if !editingRows
        {
            selectedTodo = todos[indexPath.row]
            performSegue(withIdentifier: "tododetail", sender: self)
        }
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let todo = todos.remove(at: indexPath.row)
            context.delete(todo)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
    
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let addDate = UIContextualAction(style: .normal, title: "Add One Day") { (action, view, completion) in
                self.todos[indexPath.row].due = self.todos[indexPath.row].due?.addingTimeInterval(TimeInterval(self.ONE_DAY))
            self.save()
            self.setCellColor(due: self.todos[indexPath.row].due, cell: tableView.cellForRow(at: indexPath)!)
            completion(true)
        }
        addDate.backgroundColor = .brown
        return UISwipeActionsConfiguration(actions: [addDate])
    }
}

// Extension for Delegate Operations
extension TodoListViewController
{
    func addTodo(title: String, description: String?, remindme: Bool, due: Date?)
    {
        let todo = Todo(context: context)
        todo.title = title
        todo.message = description
        todo.remind = remindme
        todo.due = due
        todo.created = TODAY
        todo.category = selectedCategory
        if let date = due, remindme
        {
            addNotification(title: title, description: description, date: date)
        }
        todos.append(todo)
        save()
    }
    
    func updateTodo()
    {
        save()
        tableView.reloadData()
    }
    
    func completeTodo()
    {
        todos.removeAll { (todo) -> Bool in
            return todo == selectedTodo
        }
        selectedTodo?.category = archivedCategroy
        save()
        tableView.reloadData()
    }
    
    func moveTo(movedToCategory: Category)
    {
        if let indexPaths = tableView.indexPathsForSelectedRows
        {
            for indexpath in indexPaths
            {
                let todo = todos.remove(at: indexpath.row)
                todo.category = movedToCategory
            }
            save()
            tableView.reloadData()
        }
    }
}

/// Extension for search Bar Delegate
extension TodoListViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        let predicate1 = NSPredicate(format: "title CONTAINS[cd] %@", searchBar.text!)
        let predicate2 = NSPredicate(format: "message CONTAINS[cd] %@", searchBar.text!)
        let compoundPredicate = NSCompoundPredicate(orPredicateWithSubpredicates: [predicate1,predicate2])
        loadTodos(predicate: compoundPredicate)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0
        {
            loadTodos()
            
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
            tableView.reloadData()
        }
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        loadTodos()
        tableView.reloadData()
    }
}
