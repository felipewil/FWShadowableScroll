//
//  ViewController.swift
//  FWShadowableScroll
//
//  Created by Felipe Leite on 09/13/2018.
//  Copyright (c) 2018 Felipe Leite. All rights reserved.
//

import UIKit
import FWShadowableScroll

class ViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        tableView.shouldShowScrollShadow = true
        tableView.shadowRadius = 4.0
        tableView.shadowHeight = 4.0
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

extension ViewController : UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let identifier: String
        
        switch indexPath.row {
        case 0: identifier = "ScrollViewCell"
        case 1: identifier = "CollectionViewCell"
        case 2: identifier = "GroupedTableViewCell"
        default: identifier = ""
        }
        
        return tableView.dequeueReusableCell(withIdentifier: identifier)!
    }
    
}

extension ViewController : UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
    }
    
}
