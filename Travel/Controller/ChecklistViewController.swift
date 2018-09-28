//
//  CheckListViewController.swift
//  Travel
//
//  Created by TaiHsinLee on 2018/9/24.
//  Copyright © 2018 TaiHsinLee. All rights reserved.
//

import UIKit

class ChecklistViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    let headerText: [String] = ["Essentials", "Personal Comfort", "Electronics"]

    var cellData = [CellData]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTableView()
        
        cellData = [
            CellData(title: "Essentials",
                     sectionData: ["Passport", "Boarding Pass", "Confirmation Receipts", "Wallet", "Credit Card"]),
            CellData(title: "Personal Clothes",
                     sectionData: ["T - shirts", "Jeans", "Shorts", "Jackets", "Socks", "Sandals"]),
            CellData(title: "Electronics",
                     sectionData: ["Laptop", "iPhone", "Camera", "GoPro", "All Chargers", "Adapters"])
        ]
    }
    
    func setupTableView() {
        
        let xib = UINib(
            nibName: String(describing: ChecklistTableViewCell.self),
            bundle: nil
        )
        
        tableView.register(
            xib,
            forCellReuseIdentifier: String(describing: ChecklistTableViewCell.self)
        )
        
        let headerXib = UINib(
            nibName: String(describing: ChecklistHeader.self),
            bundle: nil
        )
        
        tableView.register(
            headerXib,
            forHeaderFooterViewReuseIdentifier: String(describing: ChecklistHeader.self)
        )
    
        let footerXib = UINib(nibName: String(describing: ChecklistFooter.self), bundle: nil)
        
        tableView.register(footerXib, forHeaderFooterViewReuseIdentifier: String(describing: ChecklistFooter.self))
        
        tableView.delegate = self
        
        tableView.dataSource = self
    }
}

// MARK: - Table View Data Source

extension ChecklistViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        return cellData.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return cellData[section].sectionData.count
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
//        let view = UIView()
//        view.backgroundColor = UIColor.white
//
//        let separatorView = UIView()
//        separatorView.backgroundColor = UIColor.darkGray
//        let screenWidth = UIScreen.main.bounds.width
//        separatorView.frame = CGRect(x: 0, y: 29, width: screenWidth, height: 1)
//        view.addSubview(separatorView)
//
//        let label = UILabel()
//        label.text = cellData[section].title
//        label.frame = CGRect(x: 10, y: 5, width: 200, height: 20)
//        label.textColor = UIColor.darkGray
//        label.font = label.font.withSize(15)
//
//        view.addSubview(label)
//
//        return view
        
        guard let headerView = tableView.dequeueReusableHeaderFooterView(
            withIdentifier: String(describing: ChecklistHeader.self)) as? ChecklistHeader else {
                return UIView()
        }

        headerView.contentLabel.text = cellData[section].title

        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30
    }
    
    func tableView(
        _ tableView: UITableView,
        viewForFooterInSection section: Int
        ) -> UIView? {
        
        guard let footerView = tableView.dequeueReusableHeaderFooterView(
            withIdentifier: String(describing: ChecklistFooter.self)) as? ChecklistFooter else {
                return UIView()
        }
        
        return footerView
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        
        return 35
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(
            withIdentifier: String(describing: ChecklistTableViewCell.self),
            for: indexPath)
        
        guard let checklistCell = cell as? ChecklistTableViewCell else { return cell }
        
        checklistCell.contentLabel.text = cellData[indexPath.section].sectionData[indexPath.row]
        
        return checklistCell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 35
    }
}

// MARK: - Table View Delegate

extension ChecklistViewController: UITableViewDelegate {
    
}
