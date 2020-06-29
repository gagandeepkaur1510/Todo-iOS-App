//
//  TodoDetailViewController.swift
//  Todo_GaganDeep_C0770112
//
//  Created by Mac on 6/28/20.
//  Copyright © 2020 Mac. All rights reserved.
//

import UIKit

class TodoDetailViewController: UIViewController {

    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var remindMeSwitch: UISwitch!
    @IBOutlet weak var dueDateDatePicker: UIDatePicker!
    @IBOutlet weak var descriptionTextField: UITextField!
    var delegate: TodoListViewController!
    
    var selectedTodo: Todo?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if selectedTodo != nil
        {
            titleTextField.text = selectedTodo!.title
            remindMeSwitch.isOn = selectedTodo!.remind
            if let date = selectedTodo!.due
            {
                dueDateDatePicker.date = date
            }
            descriptionTextField.text = selectedTodo!.message
        }
        // Do any additional setup after loading the view.
    }
    
    @IBAction func saveClicked(_ sender: Any) {
        if let title = titleTextField.text
        {
            let desc = descriptionTextField.text
            let remindme = remindMeSwitch.isOn
            let dueDate = dueDateDatePicker.date
            if selectedTodo == nil
            {
                delegate.addTodo(title: title, description: desc, remindme: remindme, due: dueDate)
            }
            else
            {
                selectedTodo?.title = title
                selectedTodo?.message = desc
                selectedTodo?.remind = remindme
                selectedTodo?.due = dueDate
                delegate.updateTodo()
            }
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    @IBAction func completedClicked(_ sender: Any) {
        delegate.completeTodo()
        self.navigationController?.popViewController(animated: true)
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
