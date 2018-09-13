//
//  CollectionViewController.swift
//  FWShadowableScroll_Example
//
//  Created by Felipe Leite on 13/09/18.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import UIKit

class CollectionViewController : UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.shouldShowScrollShadow = true
        collectionView.shadowRadius = 30.0
        collectionView.shadowHeight = 30.0
    }
    
}

extension CollectionViewController : UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 200
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: UICollectionViewCell! = collectionView.dequeueReusableCell(withReuseIdentifier: "BasicCell",
                                                                            for: indexPath)
        
        let bgColor: UIColor = arc4random_uniform(2) == 0 ? .gray : .black
        cell.backgroundColor = bgColor.withAlphaComponent(0.3)
        
        return cell
    }
    
}
