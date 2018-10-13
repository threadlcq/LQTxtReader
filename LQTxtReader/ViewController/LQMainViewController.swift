//
//  LQMainViewController.swift
//  LQTxtReader
//
//  Created by liuchaoqun on 2018/9/30.
//  Copyright © 2018年 liuchaoqun. All rights reserved.
//

import UIKit
private let collectionIdentifier = "DZMCellIdentifier"

class LQMainViewController: LQBaseViewController, UICollectionViewDelegate, UICollectionViewDataSource  {
    private var collectionView: UICollectionView!
    private var bookList: [String] = [String]()
    private var bundleDir:String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollection()
        setupData()
        // 标题
        title = "电子阅读器"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let selectedIndexPath = collectionView.indexPathsForSelectedItems?.first {
            collectionView.deselectItem(at: selectedIndexPath, animated: true)
        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    private func setupCollection() {
        let cellLines: CGFloat = 3
        let spacing: CGFloat = 10
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = spacing
        layout.minimumInteritemSpacing = spacing
        let cellWidth = floor((self.view.width - spacing*4)/cellLines)
        layout.itemSize = CGSize(width: cellWidth, height: cellWidth*1.6)
        layout.sectionInset = UIEdgeInsets(top: spacing, left: spacing, bottom: spacing, right: spacing)
        
        collectionView = UICollectionView(frame: self.view.bounds, collectionViewLayout: layout)
        collectionView.backgroundColor = UIColor.white
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(LQMainCollectionCell.classForCoder(), forCellWithReuseIdentifier: collectionIdentifier)
        self.view.addSubview(collectionView)
        
    }
    
    private func setupData() {
        self.bundleDir = Bundle.main.bundlePath
        if let files = FileManager.default.subpaths(atPath: bundleDir) {
            for file in files {
                if file.hasSuffix(".txt") {
                    bookList.append(file)
                }
            }
        }
    }
    
    //Mark
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return bookList.count
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: LQMainCollectionCell = collectionView.dequeueReusableCell(withReuseIdentifier: collectionIdentifier, for: indexPath) as! LQMainCollectionCell
        let title  = bookList[indexPath.row] as NSString
        cell.setTitle(title: title.deletingPathExtension)
        cell.backgroundColor = UIColor.gray
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let url = URL(fileURLWithPath: self.bundleDir)
        let readViewController = LQReadViewController()
        readViewController.url = url.appendingPathComponent(bookList[indexPath.row])
        navigationController?.pushViewController(readViewController, animated: true)
    }

}
