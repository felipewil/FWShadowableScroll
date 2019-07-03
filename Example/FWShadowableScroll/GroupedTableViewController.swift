//
//  GroupedTableViewController.swift
//  FWShadowableScroll_Example
//
//  Created by Felipe Leite on 02/07/19.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import UIKit

class GroupedTableViewController : UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.shouldShowScrollShadow = true
        tableView.shadowRadius = 10.0
        tableView.shadowHeight = 10.0
    }
    
}

extension GroupedTableViewController : UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 10
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section.isMultiple(of: 2) ? 3 : 5
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell! = tableView.dequeueReusableCell(withIdentifier: "BasicCell")
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Header"
    }
    
}

extension GroupedTableViewController : UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 28 + (CGFloat(section) * 10)
    }
    
}

