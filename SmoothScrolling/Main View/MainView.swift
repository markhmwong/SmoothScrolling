//
//  MainView.swift
//  SmoothScrolling
//
//  Created by Mark Wong on 8/3/19.
//  Copyright © 2019 Mark Wong. All rights reserved.
//

import UIKit

/// An attempt to separate the view from the view controller itself. I've placed all view's within the Main View beginning with the UITableView.
class MainView: UIView {
    let cellId = "imageCellId"
    var dataSource = [[String : Any]]()
    var delegate: ViewController?
    
    //To be use for dynamic cell height.
    var imageDataSource = [UIImage]()
    var sizeCache: [String : CGSize] = [:]
    
    lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.delegate = self
        tableView.dataSource = self
        return tableView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
        self.setupView()
        self.setupAutoLayout()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupView() {
        addSubview(tableView)
        tableView.register(ImageCell.self, forCellReuseIdentifier: cellId)
        tableView.isHidden = true
        tableView.prefetchDataSource = self
        tableView.estimatedRowHeight = 400.0
        tableView.rowHeight = UITableView.automaticDimension
    }
    
    func setupAutoLayout() {
        tableView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        tableView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        tableView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
    }
    
    func insertDataTo(source: [[String : Any]], pageNumber: Int) {
        self.dataSource = source
        DispatchQueue.main.async {
            if (pageNumber < 1) {
                self.tableView.isHidden = false
                self.tableView.reloadData()
            } else {
                let startIndex = (pageNumber - 1) * 10
                let endIndex = self.dataSource.count - 1
                let arr = (startIndex...endIndex).map { IndexPath(row: $0, section: 0) }
                self.tableView.insertRows(at: arr, with: .none)
            }
        }
    }
    
    func addToSizeCache(url: String, size: CGSize) {
        sizeCache[url] = size
    }
}

/// The main work of the UITableView and it's functions
extension MainView: UITableViewDelegate, UITableViewDataSource, UITableViewDataSourcePrefetching {
    func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        print("\(indexPaths) \(self.dataSource.count)")
        
        //intersect with visible cells
        let fetchMore = indexPaths.contains { (indexPath) -> Bool in
            return indexPath.row >= self.dataSource.count - 1
        }
        
        if fetchMore {
            print("fetch")
            let pageNumber = (dataSource.count / 10) + 1
            delegate?.makeRequest(pageNumber: pageNumber)
        }
    }
    
    
//    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
//        if (indexPath.row == dataSource.count - 1) {
//            let pageNumber = (dataSource.count / 10) + 1
//            delegate?.makeRequest(pageNumber: pageNumber)
//        }
//    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("numberOfRowsInSection \(dataSource.count)")
        return dataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! ImageCell
        
        if (indexPath.row > dataSource.count) {
            cell.configure(withData: nil)
        } else {
            cell.configure(withData: dataSource[indexPath.row])
        }
        
        cell.delegate = self
        return cell
    }

    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 400.0
    }
}

private extension MainView {
    
    func visibleIndexPathsToReload(intersecting indexPaths: [IndexPath]) -> [IndexPath] {
        let indexPathsForVisibleRows = tableView.indexPathsForVisibleRows ?? []
        let indexPathsIntersection = Set(indexPathsForVisibleRows).intersection(indexPaths)
        return Array(indexPathsIntersection)
    }
}
