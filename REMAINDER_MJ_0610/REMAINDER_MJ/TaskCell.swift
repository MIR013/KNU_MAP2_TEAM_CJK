//
//  TaskCell.swift
//  REMAINDER_MJ
//
//  Created by 구민정 on 30/05/2019.
//  Copyright © 2019 구민정. All rights reserved.
//

import UIKit

protocol ChangeButton {
    func changeButton(checked: Bool, index: Int, sectionIndex: Int)
}

class TaskCell: UITableViewCell {
    
    @IBAction func checkBoxAction(_ sender: Any) {
        //버튼 눌리면 해당 checked정보와 index,sectionIndex정보를 넘겨준다...^.. 어디로..
        if(indexP==0){ //메인일정
            if tasks![indexS!].checked {
                delegate?.changeButton(checked: false, index: indexP!,sectionIndex:indexS!)
            } else {
                delegate?.changeButton(checked: true, index: indexP!,sectionIndex:indexS!)
            }
        }else{ //세부일정
            if tasks![indexS!].sectionChecked[indexP!-1]{
                delegate?.changeButton(checked: false, index: indexP!,sectionIndex:indexS!)
            }else{
                delegate?.changeButton(checked: true, index: indexP!,sectionIndex:indexS!)
            }
        }
    }
    
    @IBOutlet weak var checkBoxOulet: UIButton!
    @IBOutlet weak var taskNameLabel: UILabel!
    @IBOutlet weak var dDayLabel: UILabel!
    
    var delegate: ChangeButton?
    var indexP: Int?
    var indexS: Int?
    var tasks: [Task]?
}
