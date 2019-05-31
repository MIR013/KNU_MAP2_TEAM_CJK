//
//  ViewController.swift
//  dropDownList
//
//  Created by knuprime089 on 30/05/2019.
//  Copyright © 2019 COMP420. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var btnDrops: UIButton!
    @IBOutlet weak var tblView: UITableView!
    @IBOutlet weak var btnTest: UIButton!
    
    var fruitsList = ["a123","b214","c143","d432","e467","f4657"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tblView.isHidden = true
    }

    @IBAction func onClickDropButton(_ sender: Any) {
        if tblView.isHidden{
            animate(toogle: true, type: btnDrops)
        }else{
            animate(toogle: false, type: btnDrops)
        }
    }
    func animate(toogle: Bool,type: UIButton){
        if type == btnDrops{
            if toogle{
                UIView.animate(withDuration: 0.3){
                    self.tblView.isHidden=false
                }
            }else{
                UIView.animate(withDuration: 0.3){
                    self.tblView.isHidden=true
                }
            }
        }
        else{
            //other buttons
        }
    }
}

extension ViewController: UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return  fruitsList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = fruitsList[indexPath.row]
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        btnDrops.setTitle("\(fruitsList[indexPath.row])", for: .normal)
        animate(toogle: false,type: btnDrops)
    }
    
}
