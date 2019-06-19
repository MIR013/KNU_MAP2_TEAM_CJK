//
//  TableViewController.swift
//  REMAINDER_MJ
//
//  Created by 구민정 on 30/05/2019.
//  Copyright © 2019 구민정. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class TableViewController: UITableViewController, AddTask, ChangeButton {

    @IBOutlet var totalTableView: UITableView!
    var tasks: [Task] = []{
        didSet{
            totalTableView.reloadData() //tasks의 값 삭제/변경시 불리게 될 것
        }
    }
    override func viewDidLoad() {
        //화면 켜지자 마자 하는 것 (최초 한번 수행, 여러번 수행하려면 viewWillAppear에서 수행)
        //coredata에서 값을 읽어와 tasks에 저장하기!!
        loadCoreData()
    }
    //////////////////// uiviewtable////////////////////////
    //section 수
    override func numberOfSections(in tableView: UITableView) -> Int {
        return tasks.count
    }
    //section당 row수
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        //return tasks.count
        if tasks[section].opened==true{
            return tasks[section].sectionData.count + 1
        }
        else{
            return 1
        }
    }
    // row 누르면 한번 더 돈다
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let dataIndex = indexPath.row-1
        let cell = tableView.dequeueReusableCell(withIdentifier: "taskCell", for: indexPath) as! TaskCell
   
        if indexPath.row==0{
            cell.taskNameLabel.text = tasks[indexPath.section].name
        }else{
            cell.taskNameLabel.text = tasks[indexPath.section].sectionData[dataIndex]
        }
        
        ////////////////////여기서부터 받아온 taskCell타입 변수에 값을 저장해 준다.////////////////////
        if(indexPath.row == 0){ //메인 일정 처리
            if tasks[indexPath.section].checked {
                cell.checkBoxOulet.setBackgroundImage(#imageLiteral(resourceName: "checked_circle"), for: UIControl.State.normal)
            } else {
                cell.checkBoxOulet.setBackgroundImage(#imageLiteral(resourceName: "unchecked_circle"), for: UIControl.State.normal)
            }
            
        }else{ //상세 일정 처리
            if tasks[indexPath.section].checked == true {
                cell.checkBoxOulet.setBackgroundImage(#imageLiteral(resourceName: "sub_checked_circle"), for: UIControl.State.normal)
            }
            else{
                if tasks[indexPath.section].sectionChecked[indexPath.row-1]{
                    cell.checkBoxOulet.setBackgroundImage(#imageLiteral(resourceName: "sub_checked_circle"), for: UIControl.State.normal)
                } else {
                    //cell.checkBoxOulet.setTitle("ㅁ", for: UIControl.State.normal)
                    cell.checkBoxOulet.setBackgroundImage(#imageLiteral(resourceName: "sub_unchecked_circle"), for: UIControl.State.normal)
                }
            }
        }
        //d-day label 계산
        if(indexPath.row == 0){
            let dDay = tasks[indexPath.section].date
            if dDay != ""{
                cell.dDayLabel.isHidden = false //안보임 해제
                // 데이터 포맷터
                let dateFormatter = DateFormatter()
                // 한국 Locale
                dateFormatter.locale = Locale(identifier: "ko_KR")
                dateFormatter.dateFormat = "yyyy/MM/dd HH:mm"
                // 디데이 파싱
                let endDay = dateFormatter.date(from: dDay)
                let interval = endDay?.timeIntervalSinceNow
                let dDayResult = Int((interval!/86400))
                if(dDayResult < 0){//지난 날
                    cell.dDayLabel.text = "D+" + String(-dDayResult)
                }else if (dDayResult == 0){//당일
                    //당일인데 지금보다 이전 시간일때
                    cell.dDayLabel.text = "D-" + String(-dDayResult)
                    var hour = (interval!/86400) * 24
                    if(hour>0){ // 예약시간 > 현재시간
                        if(hour>1){//시
                            cell.dDayLabel.text = "H-" + String(Int(hour))
                        }else{//분
                            cell.dDayLabel.text = "M-" + String(Int(hour * 60))
                        }
                    }
                    else{// 예약시간 < 현재시간
                        hour = -hour
                        if(hour>1){//시
                            cell.dDayLabel.text = "H+" + String(Int(hour))
                        }else{//분
                            cell.dDayLabel.text = "M+" + String(Int(hour * 60))
                        }
                    }
                }else{//남은 날
                    cell.dDayLabel.text = "D" + String(-dDayResult)
                }
            }
            else{
                cell.dDayLabel.isHidden = true
            }
        }else{
            cell.dDayLabel.isHidden = true
        }
        
        cell.delegate = self
        cell.indexP = indexPath.row
        cell.indexS = indexPath.section
        cell.tasks = tasks
        
        return cell
    }
    //row가 터치 될 경우
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0{
            if tasks[indexPath.section].opened == true{
                tasks[indexPath.section].opened = false
                let sections = IndexSet.init(integer: indexPath.section)
                tableView.reloadSections(sections, with: .none)
            }
            else{
                tasks[indexPath.section].opened = true
                let sections = IndexSet.init(integer: indexPath.section)
                tableView.reloadSections(sections, with: .none)
            }
        }
    }
    //table 값 삭제하기
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete{
            //actionsheet를 이용
            let actionSheet = UIAlertController(title: "", message: "일정을 삭제하시겠습니까?", preferredStyle: .actionSheet)
            let deleteButton = UIAlertAction(title: "삭제", style: .default){ action in
                //삭제 이벤트
                //row == 0 -> main
                //coreData도 연동해야함
                if indexPath.row == 0{ //main
                    self.tasks.remove(at: indexPath.section)
                }
                else{ //section
                    self.tasks[indexPath.section].sectionData.remove(at: indexPath.row-1) //애는 0부터 시작이니 빼줘야지 ^^
                }
                self.changeTaskToCD(row: indexPath.row, section: indexPath.section)
                self.totalTableView.reloadData()
            }
            let cancelButton = UIAlertAction(title: "취소", style: .cancel){ action in return
            }
            
            actionSheet.addAction(deleteButton)
            actionSheet.addAction(cancelButton)
            self.present(actionSheet,animated: true,completion: nil)
        }
    }
    
    
    ////////////////////장면 전환///////////////////////
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let tvc = segue.destination as! AddTaskController
        tvc.delegate = self
    }
    /////이전 장면에서 얘가 불림(?)(해당 프로토콜의 옵셔널 타입 변수를 이용해 부름) 프로토콜을 구현한 부분 (AddTaskController.swift) //////
    func addTask(name: String, date: String, sectionData:[String]) {
        tasks.append(Task(name: name, date: dateString, sectionData: sectionData ))
        dateString = ""
        //data 저장
        addTaskToCD(tasks.count-1) //뒤에 추가하는 거니께 index = count-1 이겠네
        tableView.reloadData()
    }
    ////// check box 액션 (해당 프로토콜의 옵셔널 타입 변수를 이용해 부름) 프로토콜을 구현한 부분 (TaskCell.swift)
    // 체크박스가 눌러지면 해당 정보에 관한 데이터가 흘러들어오는 듯
    func changeButton(checked: Bool, index: Int , sectionIndex: Int) {
        // 대표일정과 세부일정을 나누어서 체크해야 한다.
        if(index==0){
            tasks[sectionIndex].checked = checked
        }else{
            tasks[sectionIndex].sectionChecked[index-1] = checked
        }
        tableView.reloadData()
    }
    
    /////////////////Core Data////////////////////
    //추가한 task를 디비에 저장 (task 추가하기 버튼 후)
    private func addTaskToCD(_ rowIndex:Int){
        let newMain = Main(context: CoreDataStack.context)
        newMain.name = tasks[rowIndex].name
        newMain.date = tasks[rowIndex].date
        newMain.sectionIndex =  Int16(rowIndex) //강제 형변환
        newMain.rowIndex = 0 //저장할 필요 있나...?
        var rIndex:Int16=1
        for subTask in tasks[rowIndex].sectionData{
            let newSub = Sub(context: CoreDataStack.context)
            newSub.sectionData = subTask
            newSub.sectionIndex = Int16(rowIndex)
            newSub.rowIndex = rIndex //필요없어보임
            newSub.main = newMain //입력과 반대로 드가나...?
            rIndex += 1
        }
        CoreDataStack.saveContext() //저장
    }
    
    //시작시 coredata에서 tasks로 값 넣어주기 - viewDidLoad에서 적용
    //sub가 multivalue라 얘를 읽어서 내보내야함
    var subFromCD:[Sub] = []
    var mainFromCD:[Main] = []
    
    func loadCoreData() {
        //deleteFromAllCD() //coreData에 있는 정보 전부 삭제
        guard (UIApplication.shared.delegate as? AppDelegate) != nil else{
            print("load ad failed")
            return
        }
        let mContext = CoreDataStack.persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<Sub> = Sub.fetchRequest()
        let fetchRequest2: NSFetchRequest<Main> = Main.fetchRequest()
        
        //main부터 부르고 그 개수에 맞게 task만들고 - 아니면 sub가 없으면 안만들어짐
        //coredata가 sort를 맞춰주지 않으면 섞인 상태로 반환하기 때문에 sortdescriptors를 이용해 정렬한 후 넣어줘야 한다.
        do{
            //main 별로 소팅
            let sortType = NSSortDescriptor(key: "sectionIndex", ascending: true)
            fetchRequest2.sortDescriptors = [sortType]
            try mainFromCD = mContext.fetch(fetchRequest2)
            
            for mdata in mainFromCD{
                tasks.append(Task(name: mdata.name!, date: mdata.date!, sectionData: []))
            }
        }catch{
            print("fetching to main failed")
        }
        //sub들에 맞게 값 넣어 줘야 할 듯
        do{
            //여긴 두개로 소팅!
            let sortType1 = NSSortDescriptor(key: "sectionIndex", ascending: true)
            let sortType2 = NSSortDescriptor(key: "rowIndex", ascending: true)
            fetchRequest.sortDescriptors = [sortType1,sortType2]
            try subFromCD = mContext.fetch(fetchRequest)
            //데이터 넣기
            for sdata in subFromCD{
                let mainFromSub = sdata.main as Main?
                print(mainFromSub?.sectionIndex ?? "nil" ,",", mainFromSub?.rowIndex ?? "nill")
                let taskIndex = Int(mainFromSub!.sectionIndex) //index는 sectionIndex이기 때문에 0..<count
                tasks[taskIndex].sectionData.append(sdata.sectionData!)
                tasks[taskIndex].sectionChecked.append(false) //얘를 따로 추가해 줘야 한다 아니면 계속 0임
                
            }
        }catch{
            print("fetching to main is fail(sub)")
        }
    }
    //모든 CoreData 정보 삭제
    private func deleteFromAllCD(){
        guard (UIApplication.shared.delegate as? AppDelegate) != nil else{
            print("load ad failed")
            return
        }
        let mContext = CoreDataStack.persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<Sub> = Sub.fetchRequest()
        
        do{
            try subFromCD = mContext.fetch(fetchRequest)
            for data in subFromCD{
                mContext.delete(data)
                CoreDataStack.saveContext()
            }
        }
        catch{
            print("delete fetch error")
        }
        
        let fetchRequest2: NSFetchRequest<Main> = Main.fetchRequest()
        
        do{
            try mainFromCD = mContext.fetch(fetchRequest2)
            for data in mainFromCD{
                mContext.delete(data)
                CoreDataStack.saveContext()
            }
        }
        catch{
            print("delete fetch error")
        }
    }
    //특정 CoreData 정보 삭제/갱신
    private func changeTaskToCD(row:Int, section:Int){
        guard (UIApplication.shared.delegate as? AppDelegate) != nil else{
            print("load ad failed")
            return
        }
        let mContext = CoreDataStack.persistentContainer.viewContext
        //main 삭제면 main 삭제
        if row == 0{
            
            //얘 뒤의 sectionIndex를 다 땡겨와야 한다(main,sub)
            //main 삭제 후 관련 sub들도 삭제해야함
            //main 삭제 및 sectionIndex 땡겨오기
            var m:[Main] = []
            let fetchRequest: NSFetchRequest<Main> = Main.fetchRequest()
            do{
                try m = mContext.fetch(fetchRequest)
                //mContext.delete(m[section])
                for data in m{
                    if(data.sectionIndex == section){
                        //삭제 - 한줄 다 삭제됨!! data를 줬으니까
                        mContext.delete(data)
                        CoreDataStack.saveContext()
                    }else if(data.sectionIndex > section){
                        //수정
                        let newSectionValue = Int16(data.sectionIndex-1)
                        data.setValue(newSectionValue, forKey: "sectionIndex")
                        CoreDataStack.saveContext()
                    }
                }
            }catch{
                print("delete one, fetching fail")
            }
            //관련 sub삭제 및 sectionIndex 땡겨오기
            var s:[Sub] = []
            let fetchRequest2: NSFetchRequest<Sub> = Sub.fetchRequest()
            do{
                try s = mContext.fetch(fetchRequest2)
                for data in s{
                    if(data.sectionIndex == section){
                        //삭제
                        mContext.delete(data)
                        CoreDataStack.saveContext()
                    }
                    else if(data.sectionIndex > section){
                        //수정
                        let newSectionValue = Int16(data.sectionIndex-1)
                        data.setValue(newSectionValue, forKey: "sectionIndex")
                        CoreDataStack.saveContext()
                    }
                }
            }catch{
                print("delete one, fetching fail")
            }
            
            
        }
        else{
            //sub 삭제면 sub만 삭제, main은 삭제x
            //rowindex를 다 땡겨와야 한다.(sub만)
            var s:[Sub] = []
            let fetchRequest: NSFetchRequest<Sub> = Sub.fetchRequest()
            do{
                try s = mContext.fetch(fetchRequest)
                for data in s{
                    if(data.rowIndex == row  && data.sectionIndex == section){
                        //삭제
                        mContext.delete(data)
                        CoreDataStack.saveContext()
                    }else if(data.rowIndex > row && data.sectionIndex == section){
                        //뒤에꺼 땡겨오기
                        let newrowValue = Int16(data.rowIndex-1)
                        data.setValue(newrowValue, forKey: "rowIndex")
                        CoreDataStack.saveContext()
                    }
                }
            }catch{
                print("delete one, fetching fail")
            }
        }
    }

    
    
}
//////데이터 형식/////
class Task {
    var name = ""
    var checked = false
    var date = ""
    
    //group
    var opened: Bool = false
    var sectionData: [String] = []
    var sectionChecked:[Bool]=[] //각 산세일정에 대한 체크 여부 판단
    
    
    convenience init(name: String, date: String, sectionData:[String]) {
        self.init()
        self.date = date
        self.sectionData = sectionData
        self.name = name
        
        for _ in 0...sectionData.count{
            sectionChecked.append(false)
        }
        //중간에 append하게 되면 sectionChecked와 sectionData의 수가 맞지 않음!! (특히 처음에 불러올 때)
    }
}
