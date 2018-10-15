//
//  CheckListViewController.swift
//  Travel
//
//  Created by TaiHsinLee on 2018/9/24.
//  Copyright © 2018 TaiHsinLee. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase

enum Status {
    case add
    case edit
    case delete
}

class ChecklistViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    #warning ("Refactor")
    
    let decoder = JSONDecoder()
    var ref: DatabaseReference!
    
    var checklists: [Checklist] = []
    
    let uncheckColor = #colorLiteral(red: 0.4862745098, green: 0.5294117647, blue: 0.631372549, alpha: 1)
    
    let checkedColor = #colorLiteral(red: 0.8823529412, green: 0.8941176471, blue: 0.9058823529, alpha: 1)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ref = Database.database().reference()
        
        fetchChecklist(
            success: { (datas) in
                
                self.checklists = datas
                
                print(self.checklists)
                print(self.checklists.count)
                self.tableView.reloadData()
        },
            failure: { (_) in
                //TODO:
        })
        
        setupTableView()
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
    
        let footerXib = UINib(
            nibName: String(describing: ChecklistFooter.self),
            bundle: nil
        )
        
        tableView.register(
            footerXib,
            forCellReuseIdentifier: String(describing: ChecklistFooter.self)
        )
        
        tableView.delegate = self
        
        tableView.dataSource = self
    }
}

// MARK: - Table View Data Source

extension ChecklistViewController: UITableViewDataSource, UITextFieldDelegate {
    
    func numberOfSections(
        in tableView: UITableView
        ) -> Int {
        
        return checklists.count
    }
    
    func tableView(
        _ tableView: UITableView,
        numberOfRowsInSection section: Int
        ) -> Int {
        
        return checklists[section].items.count + 1
    }
    
    func tableView(
        _ tableView: UITableView,
        viewForHeaderInSection section: Int
        ) -> UIView? {
        
        /// Create header view by code
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

        headerView.contentLabel.text = checklists[section].category
        updateHeaderNumber(section: section)
        
        return headerView
    }

    func tableView(
        _ tableView: UITableView,
        willDisplay cell: UITableViewCell,
        forRowAt indexPath: IndexPath
        ) {
        
        updateHeaderNumber(section: indexPath.section)
    }
    
    func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
        ) -> UITableViewCell {
        
        #warning ("Refactor")
        // Use switch to refactor
        
        // Create another custom cell at the end of section
    
        if indexPath.row >= checklists[indexPath.section].items.count {
            
            let cell = tableView.dequeueReusableCell(
                withIdentifier: String(describing: ChecklistFooter.self),
                for: indexPath
            )
            
            guard let createCell = cell as? ChecklistFooter else { return cell }
            
            createCell.addItemButton.addTarget(self, action: #selector(addNewItem(sender:)), for: .touchUpInside)
            createCell.selectionStyle = .none
            return createCell
        }
        
        let cell = tableView.dequeueReusableCell(
            withIdentifier: String(describing: ChecklistTableViewCell.self),
            for: indexPath)
        
        guard let checklistCell = cell as? ChecklistTableViewCell else { return cell }
    
//        sortItems(indexPath: indexPath)
        
        checklistCell.contentLabel.text = checklists[indexPath.section].items[indexPath.row].name
    
        handleCellColor(cell: cell, indexPath: indexPath)
        updateHeaderNumber(section: indexPath.section)
        
        checklistCell.selectionStyle = .none
        checklistCell.layoutIfNeeded()
        
        return checklistCell
    }
    
    @objc func addNewItem(sender: UIButton) {
    
        /// Use UIButton.superview to find its parents view (UITableView)
        
        guard let cell = sender.superview?.superview as? ChecklistFooter else { return }
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        guard let text = cell.contentTextField.text else { return }
        
        let newItem = Items.init(name: text, number: 1, order: 1, isSelected: false)
        checklists[indexPath.section].items.append(newItem)
        
        let index = checklists[indexPath.section].items.count - 1
        let newPath = IndexPath(row: index, section: indexPath.section)

        tableView.insertRows(at: [newPath], with: .left)
        updateChecklistData(item: newItem, indexPath: indexPath, type: .add)
        
        cell.contentTextField.text = ""
        cell.contentTextField.endEditing(true)
    }
}

// MARK: - Table View Delegate

extension ChecklistViewController: UITableViewDelegate {
    
    func tableView(
        _ tableView: UITableView,
        heightForHeaderInSection section: Int
        ) -> CGFloat {
        
        return 30
    }
    
    func tableView(
        _ tableView: UITableView,
        heightForRowAt indexPath: IndexPath
        ) -> CGFloat {
        
        return 35
    }
    
    func tableView(
        _ tableView: UITableView,
        didSelectRowAt indexPath: IndexPath
        ) {
        
        handleCellSelected(indexPath: indexPath)
        
        /// Move cell index position (but can't sync with Firebase)
//        if checklists[indexPath.section].items[indexPath.row].isSelected {
//
//            let totalRows = tableView.numberOfRows(inSection: indexPath.section)
//            let lastIndexPath = IndexPath(row: totalRows - 2, section: indexPath.section)
//            tableView.moveRow(at: indexPath, to: lastIndexPath)
//        } else {
//
//            let firstIndexPath = IndexPath(row: 0, section: indexPath.section)
//            tableView.moveRow(at: indexPath, to: firstIndexPath)
//        }
//        tableView.reloadSections([indexPath.section], with: .automatic)
        
        updateHeaderNumber(section: indexPath.section)
        
        ref.child("/checklist/\(indexPath.section)/items/")
            .queryOrdered(byChild: "order")
            .queryEqual(toValue: 0)
            .observeSingleEvent(of: .value) { (snapshot) in
  
            guard let value = snapshot.value as? NSArray else { return }

            print(value.count)
            print(value)

            let index = value.index(of:"null")
            print(index)

//            for index in 0 ... value.count - 1 {
//
//                guard let test = value[index] as? String, test != "null" else { return }
//                print(value[index])
//                print(index)
//            }
        }
    }
    
    func tableView(
        _ tableView: UITableView,
        commit editingStyle: UITableViewCell.EditingStyle,
        forRowAt indexPath: IndexPath) {

        if editingStyle == .delete {
            
            checklists[indexPath.section].items.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
            
            let item = Items.init(name: "", number: 0, order: 0, isSelected: false)
            updateChecklistData(item: item, indexPath: indexPath, type: .delete)
            updateHeaderNumber(section: indexPath.section)
        }
    }
}

#warning ("Refactor")
// extension for data fetch functions (temporary)

extension ChecklistViewController {
    
    func fetchChecklist(
        success: @escaping ([Checklist]) -> Void,
        failure: @escaping (TripsError) -> Void
        ) {
        
        ref.child("checklist").observeSingleEvent(of: .value) { (snapshot) in
            
            guard let value = snapshot.value as? NSArray else { return }
            guard let jsonData = try? JSONSerialization.data(withJSONObject: value) else { return }
            
            do {
                let data = try self.decoder.decode([Checklist].self, from: jsonData)
                
                success(data)
                
            } catch {
                // TODO: Error handling
                print(error)
            }

        }
    }
    
    func updateChecklistData(item: Items, indexPath: IndexPath, type: Status) {
        
        switch type {
            
        case .add:
            
            let post = ["name": item.name,
                        "number": item.number,
                        "order": item.order,
                        "isSelected": item.isSelected
                ] as [String: Any]
            
            let postUpdate = ["/checklist/\(indexPath.section)/items/\(indexPath.row)": post]
            
            ref.updateChildValues(postUpdate)
            
        case .edit:
            
            let postUpdate = ["/checklist/\(indexPath.section)/items/\(indexPath.row)/isSelected": item.isSelected]
            
            ref.updateChildValues(postUpdate)
            
        case .delete:
            
            ref.child("/checklist/\(indexPath.section)/items/\(indexPath.row)").removeValue()
            
            let totalRows = tableView.numberOfRows(inSection: indexPath.section)
            
            print(indexPath.row)
            print(totalRows)
            
            /// Array item shift 1 index forward
            for index in indexPath.row + 1 ... totalRows - 1 {
                
                let item = checklists[indexPath.section].items[index - 1]
                
                let newIndexPath = IndexPath(row: index - 1, section: indexPath.section)
                
                updateChecklistData(item: item, indexPath: newIndexPath, type: .add)
            }
            
            ref.child("/checklist/\(indexPath.section)/items/\(totalRows - 1)").removeValue()
        }
    }
    
    func handleCellSelected(indexPath: IndexPath) {
        
        guard let checklistCell = tableView.cellForRow(at: indexPath) as? ChecklistTableViewCell else { return }
        
        if checklists[indexPath.section].items[indexPath.row].isSelected {
            
            checklists[indexPath.section].items[indexPath.row].isSelected = false
            
            checklistCell.checkImage.image = UIImage(named: "icon_uncheck")
            checklistCell.checkImage.tintColor = uncheckColor
            checklistCell.contentLabel.textColor = uncheckColor
            let item = Items.init(name: "", number: 1, order: 1, isSelected: false)
            updateChecklistData(item: item, indexPath: indexPath, type: .edit)
        } else {
            
            checklists[indexPath.section].items[indexPath.row].isSelected = true
            
            checklistCell.checkImage.image = UIImage(named: "check_enable")
            checklistCell.checkImage.tintColor = checkedColor
            checklistCell.contentLabel.textColor = checkedColor
            
            let item = Items.init(name: "", number: 1, order: 1, isSelected: true)
            updateChecklistData(item: item, indexPath: indexPath, type: .edit)
        }
    }
    
    // MARK: - For cellForRoll cell check (sync with Firebase data)
    func handleCellColor(cell: UITableViewCell, indexPath: IndexPath) {
        
        guard let checklistCell = cell as? ChecklistTableViewCell else { return }
        
        if checklists[indexPath.section].items[indexPath.row].isSelected {
        
            checklistCell.checkImage.image = UIImage(named: "check_enable")
            checklistCell.checkImage.tintColor = checkedColor
            checklistCell.contentLabel.textColor = checkedColor
        } else {
        
            checklistCell.checkImage.image = UIImage(named: "icon_uncheck")
            checklistCell.checkImage.tintColor = uncheckColor
            checklistCell.contentLabel.textColor = uncheckColor
        }
    }
    
    func updateHeaderNumber(section: Int) {
        
        guard let header = tableView.headerView(forSection: section) as? ChecklistHeader else { return }

        var totalNumber = 0
        var selectedNumber = 0
        let items = checklists[section].items
        
        for item in items {
            
            totalNumber += item.number
            
            if item.isSelected {
                
                selectedNumber += item.number
            }
        }

        header.numberLabel.text = "\(selectedNumber)" + "/" + "\(totalNumber)"
//        tableView.reloadSections([section], with: .automatic)
        header.layoutIfNeeded()
    }
    
    /// Sort item with "isSelected = true/ false" (Can't sync with Firebase due to array type)
//    func sortItems(indexPath: IndexPath) {
//
//        checklists[indexPath.section].items.sort { !$0.isSelected && $1.isSelected}
//
//        print(checklists[indexPath.section].items)
//    }
}
