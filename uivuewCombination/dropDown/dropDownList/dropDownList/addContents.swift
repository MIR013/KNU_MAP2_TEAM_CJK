//
//  addContents.swift
//  dropDownList
//
//  Created by knuprime089 on 31/05/2019.
//  Copyright © 2019 COMP420. All rights reserved.
//

import UIKit

class addContents: UIViewController {

    @IBOutlet weak var inputField: UITextField!
    @IBOutlet weak var addList: UIButton!
    @IBOutlet weak var tableView: UITableView!
    
    var detailText:[String] = []{
        didSet{
            tableView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.delegate = self
        self.tableView.dataSource = self
        detailText = ["test1","test2"]
    }
    
    @IBAction func onClickAddListButton(_ sender: Any) {
        guard let text = inputField.text else {
            // nothing happend
            return
        }
        guard text != "" else {
            print("nothing!!!")
            return
        }
        detailText.append(text) //add list!
        inputField.text = ""
        return
    }
    
}

extension addContents: UITableViewDelegate,UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return detailText.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let todo = tableView.dequeueReusableCell(withIdentifier: "todo", for: indexPath)
        todo.textLabel?.text = detailText[indexPath.row]
        return todo
    }
    

}
