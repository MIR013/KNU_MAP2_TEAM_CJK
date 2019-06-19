//
//  AddTaskController.swift
//  REMAINDER_MJ
//
//  Created by 구민정 on 30/05/2019.
//  Copyright © 2019 구민정. All rights reserved.
//

import UIKit
import MapKit
import UserNotifications
import CoreLocation

protocol AddTask {
    func addTask(name: String, date: String, sectionData: [String])
}

var dateString = ""
var printDate = ""

class AddTaskController: UIViewController, UISearchBarDelegate {

    ////////////아울렛///////////////
    @IBOutlet weak var dateTextField: UITextField!
    @IBOutlet weak var detailTableView: UITableView!
    @IBOutlet weak var detailTextField: UITextField!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var dateTextHeight: NSLayoutConstraint!
    @IBOutlet weak var searchButtonHeight: NSLayoutConstraint!
    @IBOutlet weak var segmentHeight: NSLayoutConstraint!
    
    let locationManager = CLLocationManager()
    
    ////////////view가 로드되기 전에 동작될 것들//////////////
    override func viewDidLoad() {
        super.viewDidLoad()
        //////////////datePicker 사용////////////////
        datePicker?.datePickerMode = .dateAndTime
        
        ////////////location manager 설정/////////////
        requestLocationAccess()
        
        //////tableView의 일을 이놈(여기 컨트롤러 파일)이 대신하긋다.
        self.detailTableView.delegate = self
        self.detailTableView.dataSource = self
        
        tableHeight.constant = 0
        tableSpace.constant = 0
        detailHeight.constant = 0
        insertHeight.constant = 0
        detailSpace.constant = 0
        mapHeight.constant = 0
        searchButtonHeight.constant = 0
        segmentHeight.constant = 0
        dateHeight.constant = 0
        dateTextHeight.constant = 0
        dateSpace.constant = 0
        segmentButton.isHidden = true
        subTaskBtn.setTitle("", for: UIControl.State.normal)
    }
    
    @IBOutlet weak var dateSpace: NSLayoutConstraint!
    @IBOutlet weak var dateHeight: NSLayoutConstraint!
    @IBAction func dateSwitch(_ sender: UISwitch) {
        if (sender.isOn) {
            dateHeight.constant = 216
            dateTextHeight.constant = 30
            dateSpace.constant = 10
        } else {
            dateHeight.constant = 0
            dateTextHeight.constant = 0
            dateSpace.constant = 0
        }
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
    
    ////////////////////지도 여닫기////////////////////
    @IBOutlet weak var mapHeight: NSLayoutConstraint!
    @IBAction func locaSwitch(_ sender: UISwitch) {
        if (sender.isOn) {
            segmentHeight.constant = 28
            searchButtonHeight.constant = 30
            mapHeight.constant = 330.5
            segmentButton.isHidden = false
        } else {
            segmentHeight.constant = 0
            searchButtonHeight.constant = 0
            mapHeight.constant = 0
            segmentButton.isHidden = true
        }
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
    ///////////////////Mapkit///////////////////////////
    @IBOutlet weak var mapKit: MKMapView!
    @objc func viewTapped(gestureRecognizer: UITapGestureRecognizer) {
        view.endEditing(true)
    }
 
    //https://www.youtube.com/watch?v=GYzNsVFyDrU
    //https://www.appcoda.com/mapkit-beginner-guide/
    func requestLocationAccess() { //권한 체크
        let status = CLLocationManager.authorizationStatus()
        
        switch status {
        case .authorizedAlways, .authorizedWhenInUse:
            print("location access allowed")
            return
            
        case .denied, .restricted:
            print("location access denied")
            
        default:
            locationManager.requestWhenInUseAuthorization()
            //info.plist에 NSLocationWhenInUseUsageDescription를 등록해야 한다.
        }
    }
    
    //위도, 경도
    var laptitude:CLLocationDegrees?
    var longitude:CLLocationDegrees?
    //버튼 클릭 이벤트
    @IBAction func searchButton(_ sender: Any) {
      let searchController = UISearchController(searchResultsController: nil)
        searchController.searchBar.delegate = self
        present(searchController,animated: true,completion: nil)
        
    }
    //서치 버튼 클릭 시 장소 검색 -> 지도에 마커 표시
    //(자동 지도 완성은 애플에서 제한하기 때문에 구현할 수 없다)
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        UIApplication.shared.beginIgnoringInteractionEvents()
        let activityIndicator = UIActivityIndicatorView()
        activityIndicator.style = UIActivityIndicatorView.Style.gray
        activityIndicator.center = self.view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.startAnimating()
        
        self.view.addSubview(activityIndicator)
        
        searchBar.resignFirstResponder()
        dismiss(animated: true, completion: nil)
        
        let searchRequest = MKLocalSearch.Request()
        searchRequest.naturalLanguageQuery = searchBar.text
        
        let activeSearch = MKLocalSearch(request: searchRequest)
        activeSearch.start{ (response, error) in
            activityIndicator.stopAnimating()
            UIApplication.shared.endIgnoringInteractionEvents()
            
            if response == nil {
                print("error")
            }else{
                let annotations = self.mapKit.annotations
                self.mapKit.removeAnnotations(annotations)
                
                
                let lap = response?.boundingRegion.center.latitude
                let log = response?.boundingRegion.center.longitude
                
                let annotation = MKPointAnnotation()
                annotation.title = searchBar.text
                annotation.coordinate = CLLocationCoordinate2DMake(lap!, log!)
                self.mapKit.addAnnotation(annotation)
                
                let coord:CLLocationCoordinate2D = CLLocationCoordinate2DMake(lap!, log!)
                //let span = MKCoordinateSpan(latitudeDelta: 0.1,longitudeDelta: 0.1)
                /////// mapket
                let region = MKCoordinateRegion(center: coord, latitudinalMeters: 200, longitudinalMeters: 200)
                self.mapKit.setRegion(region, animated: true)
                
                // 위도, 경도 저장
                self.laptitude = lap!
                self.longitude = log!
                
                //원 그리기
                self.addAnnotations()
            }
        }
        
    }
    ///////////////////////지도 푸시//////////////////////////////
    //https://github.com/kevinfur/UNLocationNotificationTrigger-Example/blob/master/localNotification/ViewController.swift
    //https://www.thorntech.com/2016/01/how-to-search-for-location-using-apples-mapkit/'
    //지도 알람 푸시 추가
    func addLocationAlarm(){
        if laptitude != nil, longitude != nil{ //값이 존재한다면...
            //중앙
            let center = CLLocationCoordinate2D(latitude: laptitude!, longitude: longitude!)
            //현재 위치에서 원 사이
            let region = CLCircularRegion(center: center, radius: 10.0, identifier: "Headquarters")
            // 발송 완료 안내 메시지
            var messages = "장소 알람이 등록되었습니다. 알람은 (\(String(describing: laptitude)),\(String(describing: longitude)))에"
            
            if segmentButton.selectedSegmentIndex == 1{ //들어올때
                region.notifyOnEntry = true
                region.notifyOnExit = false
                messages += "들어올 때, 발송됩니다."
            }else{ //나갈때
                region.notifyOnEntry = false
                region.notifyOnExit = true
                messages += "나갈 때, 발송됩니다."
            }
            let trigger = UNLocationNotificationTrigger(region: region, repeats: false)
            let noCenter = UNUserNotificationCenter.current()
            let content = UNMutableNotificationContent()
            content.title = "일정 '" + (self.taskNameOulet.text)! + "'을 확인하세요."
            content.body = "REMINDER(장소알람)"
            content.categoryIdentifier = "alarm"
            content.sound = UNNotificationSound.default
            
            let request = UNNotificationRequest(identifier: "Headquarters", content: content, trigger: trigger)
            noCenter.add(request)
            
            // 노티피케이션 센터에 추가
            UNUserNotificationCenter.current().add(request) { (_) in
                DispatchQueue.main.sync {
                    let alert = UIAlertController(title: "알람 등록 완료", message: messages, preferredStyle: .alert)
                    let ok = UIAlertAction(title: "확인", style: .default)
                    alert.addAction(ok)
                    
                    self.present(alert, animated: false)
                }
            }
        }
    }
    
    //https://github.com/appcoda/MapKitDemo/blob/master/MapKit%20Starter/ViewController.swift
    //////지도에 원 그리기///////
    func addAnnotations() {
        let center = CLLocationCoordinate2D(latitude: laptitude!, longitude: longitude!)
        let overlay = MKCircle(center: center, radius: 10) //나중에 알람이랑 반지름 똑같이 만들 것
        mapKit.addOverlay(overlay)
    }
    
    
    //////////// 시간 알람 추가 ///////////////
    func addTimeAlarm(){
        if dateString != "" { //값이 존재한다면
            if #available(iOS 10, *) {
                UNUserNotificationCenter.current().getNotificationSettings { settings in
                    if settings.authorizationStatus == UNAuthorizationStatus.authorized {
                        DispatchQueue.main.async {
                            // 알람 정의
                            let nContent = UNMutableNotificationContent()
                            nContent.body = "일정 '" + (self.taskNameOulet.text)! + "'을 확인하세요."
                            nContent.title = "REMINDER(시간알람)"
                            nContent.sound = UNNotificationSound.default
                            
                            // 발송 시각을 지금으로부터 ~초 형식으로 변환
                            let time = self.datePicker.date.timeIntervalSinceNow
                            if time >= 0 { //과거로는 알람 불가능
                                
                                // 발송 조건 정의
                                let trigger = UNTimeIntervalNotificationTrigger(timeInterval: time, repeats: false)
                                
                                // 발송 요청 객체 정의
                                let request = UNNotificationRequest(identifier: "alarm", content: nContent, trigger: trigger)
                                
                                // 노티피케이션 센터에 추가
                                UNUserNotificationCenter.current().add(request) { (_) in
                                    DispatchQueue.main.sync {
                                        // 발송 완료 안내 메시지
                                        //let date = self.datePicker.date.addingTimeInterval(9*60*60)
                                        let message = "일정 알람이 등록되었습니다. 알람은 " + printDate + "에 발송됩니다"
                                        
                                        let alert = UIAlertController(title: "알람 등록 완료", message: message, preferredStyle: .alert)
                                        let ok = UIAlertAction(title: "확인", style: .default)
                                        alert.addAction(ok)
                                        
                                        self.present(alert, animated: false)
                                    }
                                }
                            }
                        }
                    } else {
                        let alert = UIAlertController(title: "알람 권한 확인", message: "알람이 허용되어 있지 않습니다", preferredStyle: .alert)
                        let ok = UIAlertAction(title: "확인", style: .default)
                        alert.addAction(ok)
                        
                        self.present(alert, animated: false)
                        return
                    }
                }
            } else {
                
            }
        }
    }
    
    
    @IBOutlet weak var tableHeight: NSLayoutConstraint!
    @IBOutlet weak var tableSpace: NSLayoutConstraint!
    @IBOutlet weak var detailHeight: NSLayoutConstraint!
    @IBOutlet weak var insertHeight: NSLayoutConstraint!
    @IBOutlet weak var detailSpace: NSLayoutConstraint!
    
    ////////////////////상세일정 여닫기//////////////////////////
    @IBAction func addSubTaskSwitch(_ sender: UISwitch) {
        if(sender.isOn){
            tableHeight.constant = 150
            tableSpace.constant = 10
            detailHeight.constant = 30
            insertHeight.constant = 30
            detailSpace.constant = 10
            subTaskBtn.setTitle("추가하기", for: UIControl.State.normal)
        }
        else{
            tableHeight.constant = 0
            tableSpace.constant = 0
            detailHeight.constant = 0
            insertHeight.constant = 0
            detailSpace.constant = 0
            subTaskBtn.setTitle("", for: UIControl.State.normal)
        }
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
    
    @IBOutlet weak var subTaskView: UITableView!
    @IBOutlet weak var subTaskBtn: UIButton!
    @IBOutlet weak var taskNameOulet: UITextField!
    @IBOutlet weak var segmentButton: UISegmentedControl!
    var delegate: AddTask?
    
    
    ////////////////////일정 추가 버튼 클릭시 이벤트/////////////////////
    @IBAction func addAction(_ sender: Any) {
        if taskNameOulet.text != "" {
           
            //시간 알람 추가
            addTimeAlarm()
            //위치 추가
            addLocationAlarm()
            ///일 추가
            delegate?.addTask(name: taskNameOulet.text!, date: dateString, sectionData: detailText)
            navigationController?.popViewController(animated: true)
        }
    }
    /////////////////////날짜 선택 필드////////////////////
    @IBAction func changeDatePicker(_ sender: UIDatePicker) {
        let datePickerView = sender
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy/MM/dd HH:mm"
        //dateTextField.text = dateFormatter.string(from: datePickerView.date)
        dateString = dateFormatter.string(from: datePickerView.date)
        
        dateFormatter.dateFormat = "yyyy년 MM월 dd일 HH시 mm분"
        printDate = dateFormatter.string(from: datePickerView.date)
        dateTextField.text = printDate
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
        detailText.append("    "+text)
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

//////지도에 원 그리기///////

extension AddTaskController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKCircleRenderer(overlay: overlay)
        renderer.fillColor = UIColor.black.withAlphaComponent(0.5)
        renderer.strokeColor = UIColor.blue
        renderer.lineWidth = 2
        return renderer
    }
}
