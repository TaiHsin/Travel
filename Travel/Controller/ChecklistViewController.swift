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
import KeychainAccess

enum Status {
    case add
    case edit
    case delete
}

class ChecklistViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    let decoder = JSONDecoder()
    
    var ref: DatabaseReference!
    
    let keychain = Keychain(service: "com.TaiHsinLee.Travel")
    
    var checklists: [Checklist] = []
    
    let uncheckColor = UIColor.battleshipGrey
    
    let checkedColor = UIColor.cloudyBlue
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ref = Database.database().reference()
        
        fetchChecklist(
            success: { (datas) in
                
                self.checklists = datas
                
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

        guard let headerView = tableView.dequeueReusableHeaderFooterView(
            withIdentifier: String(describing: ChecklistHeader.self)
            ) as? ChecklistHeader else {
                
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
        
        // Use switch to refactor
        // Create another custom cell at the end of section
        
        if indexPath.row >= checklists[indexPath.section].items.count {
            
            let cell = tableView.dequeueReusableCell(
                withIdentifier: String(describing: ChecklistFooter.self),
                for: indexPath
            )
            
            guard let createCell = cell as? ChecklistFooter else {
                
                return cell
            }
            
            // Refactor
            createCell.addItemButton.addTarget(
                self,
                action: #selector(addNewItem(sender:)),
                for: .touchUpInside
            )
            
            createCell.selectionStyle = .none
            
            return createCell
        }
        
        let cell = tableView.dequeueReusableCell(
            withIdentifier: String(describing: ChecklistTableViewCell.self),
            for: indexPath
        )
        
        guard let checklistCell = cell as? ChecklistTableViewCell else {
            
            return cell
        }
        
        checklistCell.contentLabel.text = checklists[indexPath.section].items[indexPath.row].name
        
        handleCellColor(cell: cell, indexPath: indexPath)
        
        updateHeaderNumber(section: indexPath.section)
        
        checklistCell.selectionStyle = .none
        
        checklistCell.layoutIfNeeded()
        
        return checklistCell
    }
    
    @objc func addNewItem(sender: UIButton) {
        
        // Use UIButton.superview to find its parents view (UITableView)
        // Better way is use delegate to get whole cell (more maintainable and encapsulatalbe for cell)
        
        guard let cell = sender.superview?.superview as? ChecklistFooter else {
            
            return
        }
        
        guard let indexPath = tableView.indexPath(for: cell) else {
            
            return
        }
        
        guard let text = cell.contentTextField.text, text != Constants.emptyString else {
            
            return
        }
        
        let newItem = Items.init(name: text, number: 1, order: 1, isSelected: false)
        
        checklists[indexPath.section].items.append(newItem)
        
        let index = checklists[indexPath.section].items.count - 1
        
        let newPath = IndexPath(row: index, section: indexPath.section)
        
        tableView.insertRows(at: [newPath], with: .left)
        
        updateChecklistData(item: newItem, indexPath: indexPath, type: .add)
        
        cell.contentTextField.text = Constants.emptyString
        
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

        updateHeaderNumber(section: indexPath.section)
        
        guard let uid = keychain["userId"] else { return }
        
        ref.child("/checklist/\(uid)/\(indexPath.section)/items/")
            .queryOrdered(byChild: "order")
            .queryEqual(toValue: 0)
            .observeSingleEvent(of: .value) { (snapshot) in
                
                guard let value = snapshot.value as? NSArray else {
                    
                    return
                }

                let index = value.index(of: "null")
        }
    }
    
    func tableView(
        _ tableView: UITableView,
        editingStyleForRowAt indexPath: IndexPath
        ) -> UITableViewCell.EditingStyle {
        
        let total = tableView.numberOfRows(inSection: indexPath.section)
        
        guard total > 2, indexPath.row != total - 1 else {
            
            return UITableViewCell.EditingStyle.none
        }
        
        return UITableViewCell.EditingStyle.delete
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

// extension for data fetch functions (temporary)

extension ChecklistViewController {
    
    func fetchChecklist(
        success: @escaping ([Checklist]) -> Void,
        failure: @escaping (TripsError) -> Void
        ) {

        guard let uid = keychain["userId"] else { return }
        
        ref.child("/checklist/\(uid)").observeSingleEvent(of: .value) { [weak self] (snapshot) in
            
            guard let self = self else {
                
                return
            }
            
            guard let value = snapshot.value as? NSArray else {
                
                self.fetchDefaultData(success: { [weak self]  (data) in
                    
                    success(data)
                    
                    let numbers = data.count
                    
                    for number in 0 ... numbers - 1 {
                        
                        let post = [ "category": data[number].category,
                                     "id": data[number].id,
                                     "total": data[number].total
                            ] as [String: Any]
                        
                        let postUpdate = ["/checklist/\(uid)/\(number)": post]
                        
                        self?.ref.updateChildValues(postUpdate)
                        
                        let totals = data[number].items.count
                        
                        for index in 0 ... totals - 1 {
                            
                            let item = data[number].items[index]
                            
                            let post = ["name": item.name,
                                        "number": item.number,
                                        "order": item.order,
                                        "isSelected": item.isSelected
                                ] as [String: Any]
                            
                            let postUpdate = ["/checklist/\(uid)/\(number)/items/\(index)": post]
                            
                            self?.ref.updateChildValues(postUpdate)
                        }
                    }
                    
                }, failure: { (error) in
                    
                    print(error)
                })
                
                return
            }
            
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
    
    func fetchDefaultData(
        success: @escaping ([Checklist]) -> Void,
        failure: @escaping (TripsError) -> Void
        ) {
        
        ref.child("/checklist/examplechecklist").observeSingleEvent(of: .value) { [weak self] (snapshot) in
            
            guard let self = self else {
                
                return
            }
            
            guard let value = snapshot.value as? NSArray else {
                
                return
            }
            
            guard let jsonData = try? JSONSerialization.data(withJSONObject: value) else {
                
                return
            }
            
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
        
        guard let uid = keychain["userId"] else {
            
            return
        }
        
        switch type {
            
        case .add:
            
            let post = ["name": item.name,
                        "number": item.number,
                        "order": item.order,
                        "isSelected": item.isSelected
                ] as [String: Any]
            
            let postUpdate = ["/checklist/\(uid)/\(indexPath.section)/items/\(indexPath.row)": post]
            
            ref.updateChildValues(postUpdate)
            
        case .edit:
            
            let postUpdate = [
                "/checklist/\(uid)/\(indexPath.section)/items/\(indexPath.row)/isSelected": item.isSelected
            ]
            
            ref.updateChildValues(postUpdate)
            
        case .delete:
            
            ref.child("/checklist/\(uid)/\(indexPath.section)/items/\(indexPath.row)").removeValue()
            
            let totalRows = tableView.numberOfRows(inSection: indexPath.section)
            
            // Array item shift 1 index forward
            
            guard indexPath.row < totalRows - 1 else {
                
                return
            }
            
            if indexPath.row != totalRows - 2 {
                
                for index in indexPath.row + 1 ... totalRows - 1 {
                    
                    let item = checklists[indexPath.section].items[index - 1]
                    
                    let newIndexPath = IndexPath(row: index - 1, section: indexPath.section)
                    
                    updateChecklistData(item: item, indexPath: newIndexPath, type: .add)
                }
            }
            ref.child("/checklist/\(uid)/\(indexPath.section)/items/\(totalRows - 1)").removeValue()
        }
    }
    
    func handleCellSelected(indexPath: IndexPath) {
        
        guard let checklistCell = tableView.cellForRow(
            at: indexPath
            ) as? ChecklistTableViewCell else {
            
            return
        }
        
        if checklists[indexPath.section].items[indexPath.row].isSelected {
            
            checklists[indexPath.section].items[indexPath.row].isSelected = false
            
            checklistCell.checkImage.image = UIImage(named: "icon_uncheck")
            
            checklistCell.checkImage.tintColor = uncheckColor
            
            checklistCell.contentLabel.textColor = uncheckColor
            
            let item = Items.init(name: Constants.emptyString, number: 1, order: 1, isSelected: false)
            
            updateChecklistData(item: item, indexPath: indexPath, type: .edit)
        } else {
            
            checklists[indexPath.section].items[indexPath.row].isSelected = true
            
            checklistCell.checkImage.image = UIImage(named: "check_enable")
            
            checklistCell.checkImage.tintColor = checkedColor
            
            checklistCell.contentLabel.textColor = checkedColor
            
            let item = Items.init(name: Constants.emptyString, number: 1, order: 1, isSelected: true)
            
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
        
        guard let header = tableView.headerView(
            forSection: section
            ) as? ChecklistHeader else {
                
                return
        }
        
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
    
        header.layoutIfNeeded()
    }
}
