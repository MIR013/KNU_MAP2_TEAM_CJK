//
//  AddTaskController.swift
//  REMAINDER_MJ
//
//  Created by 구민정 on 30/05/2019.
//  Copyright © 2019 구민정. All rights reserved.
//

import UIKit
import MapKit

protocol AddTask {
    func addTask(name: String, date: String, sectionData: [String])
}
var dateString = ""

class AddTaskController: UIViewController {

    ////////////아울렛///////////////
    @IBOutlet weak var dateTextField: UITextField!
    @IBOutlet weak var detailTableView: UITableView!
    @IBOutlet weak var detailTextField: UITextField!
    
    private var datePicker: UIDatePicker?
    ////////////view가 로드되기 전에 동작될 것들//////////////
    override func viewDidLoad() {
        super.viewDidLoad()
        //////////////datePicker 사용////////////////
        datePicker = UIDatePicker()
        datePicker?.datePickerMode = .date
        datePicker?.addTarget(self, action: #selector(AddTaskController.dateChanged(datePicker:)), for: .valueChanged)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(AddTaskController.viewTapped(gestureRecognizer:)))
        view.addGestureRecognizer(tapGesture)
        
        dateTextField.inputView = datePicker
        
        ////////////지도는 안보이ㅏ는게 디폴트/////////////
        mapKit.isHidden = true
        //////tableView의 일을 이놈(여기 컨트롤러 파일)이 대신하긋다.
        self.detailTableView.delegate = self
        self.detailTableView.dataSource = self
        
        
    }
    
    ////////////////////지도 여닫기////////////////////
    @IBAction func locaSwitch(_ sender: UISwitch) {
        if (sender.isOn) {
            mapKit.isHidden = false
        } else {
            mapKit.isHidden = true
        }
    }
    @IBOutlet weak var mapKit: MKMapView!
    @objc func viewTapped(gestureRecognizer: UITapGestureRecognizer) {
        view.endEditing(true)
    }
    
    ////////////////////상세일정 여닫기//////////////////////////
    @IBAction func taskSwitch(_ sender: UISwitch) {
        if(sender.isOn){
            subTaskView.isHidden = false
            detailTextField.isHidden = false
            subTaskBtn.isHidden = false
        }
        else{
            subTaskView.isHidden = true
            detailTextField.isHidden = true
            subTaskBtn.isHidden = true
        }
    }
    
    @IBOutlet weak var subTaskView: UITableView!
    @IBOutlet weak var subTaskBtn: UIButton!
    @IBOutlet weak var taskNameOulet: UITextField!
    var delegate: AddTask?
    
    ////////////////////일정 추가 버튼 클릭시 이벤트/////////////////////
    @IBAction func addAction(_ sender: Any) {
        if taskNameOulet.text != "" {
            delegate?.addTask(name: taskNameOulet.text!, date: dateString, sectionData: detailText)
            navigationController?.popViewController(animated: true)
        }
    }
    /////////////////////날짜 선택 필드////////////////////
    @objc func dateChanged(datePicker: UIDatePicker) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy년 MM월 dd일"
        dateString = dateFormatter.string(from: datePicker.date)
        dateTextField.text = dateString
        view.endEditing(true)
    }
    ////////////////////지도 디폴트는 서울////////////////////
    override func viewWillAppear(_ animated: Bool) {
        let annotation = MKPointAnnotation()
        annotation.title = "Seoul"
        annotation.coordinate = CLLocationCoordinate2D(latitude: 37.55, longitude: 127.98)
        mapKit.addAnnotation(annotation)
    }
    
    ///////////////////상세일정 테이블에 추가 부분/////////////////////////
    
    var detailText:[String] = []{
        didSet{
            detailTableView.reloadData()
        }
    }
    @IBAction func onClickAddDetailButton(_ sender: Any) {
        guard let text = detailTextField.text else{ return }
        guard text != ""  else { return }
        detailText.append(text)
        detailTextField.text = ""
        
    
        return
    }
    
    
}

//////////상세일정 테이블 관련 이벤트/////////////
extension AddTaskController: UITableViewDelegate,UITableViewDataSource{
    //섹션당 열 수
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return detailText.count
    }
    //값 테이블에 배치
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let subTask = tableView.dequeueReusableCell(withIdentifier: "subTask", for: indexPath)
        subTask.textLabel?.text = detailText[indexPath.row]
        return subTask
    }
    // table 값 삭제버튼 완료
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete{
            let actionSheet = UIAlertController(title: "", message: "일정을 삭제하시겠습니까?", preferredStyle: .actionSheet)
            let deleteButton = UIAlertAction(title: "삭제", style: .default){ action in
                //삭제 이벤트
                self.detailText.remove(at: indexPath.row)
                
            }
            let cancelButton = UIAlertAction(title: "취소", style: .cancel){ action in return
            }
            
            actionSheet.addAction(deleteButton)
            actionSheet.addAction(cancelButton)
            self.present(actionSheet,animated: true,completion: nil)
        }
    }
    
}
