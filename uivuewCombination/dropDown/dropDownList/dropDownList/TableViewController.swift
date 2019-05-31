//
//  TableViewController.swift
//  dropDownList
//
//  Created by knuprime089 on 30/05/2019.
//  Copyright © 2019 COMP420. All rights reserved.
//

import UIKit

//data format
struct cellData{
    var opened : Bool
    var title :String
    var sectionData : [String]
}


class TableViewController: UITableViewController {
    
    @IBOutlet var tableList: UITableView!
    
    var testValue = ["abc","bcd","def","efg","awfw","fwqqwf","fqwfqw"]
    var tableViewData : [cellData] = []
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableViewData = [cellData(opened: false, title: "title1", sectionData: ["cell1","cell2","cell3"]),
                         cellData(opened: false, title: "title2", sectionData: ["cell2","cell3"]),
                         cellData(opened: false, title: "title3", sectionData: ["cell1","cell3"]),
                         cellData(opened: false, title: "title4", sectionData: ["cell1","cell2","cell3"]),
                         cellData(opened: false, title: "title5", sectionData: [])
        ]
    }

}

//table data setting
extension TableViewController{
    //초기(?) row의 개수 결정
    override func numberOfSections(in tableView: UITableView) -> Int {
        return tableViewData.count
    }
    //tabel view의 갯수를 결정(indexPath개수인듯?!
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //return testValue.count
        if tableViewData[section].opened == true{
            return tableViewData[section].sectionData.count + 1
        }else{
            return 1
        }
    }
    //table view의 각 cell에 적힐 내용 결정
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        /*
        let schedule = tableView.dequeueReusableCell(withIdentifier: "schedule", for: indexPath)
        schedule.textLabel?.text = testValue[indexPath.row]
        return schedule
 */
        let dataIndex = indexPath.row - 1
        if indexPath.row == 0{
            guard let schedule = tableView.dequeueReusableCell(withIdentifier: "schedule") else{ return UITableViewCell()}
            schedule.textLabel?.text = tableViewData[indexPath.section].title
            return schedule
        }
        else{
            guard let schedule = tableView.dequeueReusableCell(withIdentifier: "schedule") else{ return UITableViewCell()}
            schedule.textLabel?.text = tableViewData[indexPath.section].sectionData[dataIndex]
            return schedule
        }
    }
    
    //열이 선택되었을때 일어날 일?!
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0{
            if tableViewData[indexPath.section].opened == true {
                tableViewData[indexPath.section].opened = false
                let sections = IndexSet.init(integer: indexPath.section)
                tableView.reloadSections(sections, with: .none)
            }
            else{
                tableViewData[indexPath.section].opened = true
                let sections = IndexSet.init(integer: indexPath.section)
                tableView.reloadSections(sections, with: .none)
            }
        }
    }
    
    
}




/*
 
 @IBOutlet weak var editBtn: UIBarButtonItem!
 @IBOutlet weak var selectBtn: UIBarButtonItem!
 
 //in viewDidLoad()
 selectBtn.isEnabled = false
 
 @IBAction func onClickEditButton(_ sender: Any) {
 selectBtn.isEnabled = true
 tableList.allowsMultipleSelectionDuringEditing = true
 tableList.setEditing(true, animated: false)
 editBtn.isEnabled = false
 }
 @IBAction func onClickSelectButton(_ sender: Any) {
 //init
 
 
 if let selectedList = tableList.indexPathsForSelectedRows{
 for item in selectedList{
 //insert representative message by alert
 //remove list
 
 //combine list to drop down list
 print(item)
 }
 //이게 alert입력하는 것 보다 느림;;
 let msg = addReprMsg()
 while(msg=="default"){}
 print("here", msg)
 
 
 }else{
 //nothing happen
 print("there is no selected")
 }
 
 //end editing
 tableList.setEditing(false, animated: false)
 selectBtn.isEnabled = false
 editBtn.isEnabled = true
 
 }
 
 //functions
 func addReprMsg()->String{
 var msg:String = "defualt"
 
 let alert = UIAlertController(title: nil, message: "대표 메세지를 입력해 주세요", preferredStyle: .alert)
 alert.addTextField()
 let ok = UIAlertAction(title: "ok", style: .default){ (ok) in
 msg = alert.textFields?[0].text ?? "noting"
 print("ok")
 }
 let cancel = UIAlertAction(title: "cancle", style: .cancel){ (cancel) in
 
 }
 alert.addAction(cancel)
 alert.addAction(ok)
 
 self.present(alert,animated:true,completion:nil)
 
 return msg
 }
 */

