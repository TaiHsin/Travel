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

enum Edit {
    case add
    case delete
}

class ChecklistViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    // Refactor
    let decoder = JSONDecoder()
    var ref: DatabaseReference!
    
    var checklists: [Checklist] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ref = Database.database().reference()
        
        fetchChecklist(
            success: { (datas) in
                
                self.checklists = datas
                print(self.checklists)
                print(self.checklists.count)
//                print(self.checklists[0].items[0].number)
                
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
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        return checklists.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return checklists[section].items.count + 1
//        return cellData[section].numberOfData()
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

        headerView.contentLabel.text = checklists[section].category
        
        return headerView
    }

    func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
        ) -> UITableViewCell {
        
        // Create another custom cell at the end of section
        
        // Use switch to refactor
        if indexPath.row >= checklists[indexPath.section].items.count {
            
            let cell = tableView.dequeueReusableCell(
                withIdentifier: String(describing: ChecklistFooter.self),
                for: indexPath
            )
            
            guard let createCell = cell as? ChecklistFooter else { return cell }
            
            createCell.addItemButton.addTarget(self, action: #selector(addNewItem(sender:)), for: .touchUpInside)
            
            return createCell
        }
        
        let cell = tableView.dequeueReusableCell(
            withIdentifier: String(describing: ChecklistTableViewCell.self),
            for: indexPath)
        
        guard let checklistCell = cell as? ChecklistTableViewCell else { return cell }
    
        checklistCell.contentLabel.text = checklists[indexPath.section].items[indexPath.row].name
    
        handleCellColor(cell: cell, indexPath: indexPath)
        
        return checklistCell
    }
    
    @objc func addNewItem(sender: UIButton) {
    
        // Use UIButton.superview to find its parents view (UITableView)
        
        guard let cell = sender.superview?.superview as? ChecklistFooter else { return }
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        guard let text = cell.contentTextField.text else { return }
        
        let newItem = Items.init(name: text, number: 1, order: 1, isSelected: false)
        checklists[indexPath.section].items.append(newItem)
        
        let index = checklists[indexPath.section].items.count - 1
        let newPath = IndexPath(row: index, section: indexPath.section)

        tableView.insertRows(at: [newPath], with: .left)
//        updateChecklistData(item: newItem, section: indexPath.section, index: index)
        updateChecklistData(item: newItem, section: indexPath.section, index: index, type: .add)
        
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
    }
    
    func tableView(
        _ tableView: UITableView,
        commit editingStyle: UITableViewCell.EditingStyle,
        forRowAt indexPath: IndexPath) {

        if editingStyle == .delete {
            
            checklists[indexPath.section].items.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
            
            let item = Items.init(name: "", number: 0, order: 0, isSelected: false)
            updateChecklistData(item: item, section: indexPath.section, index: indexPath.row, type: .delete)
            
        }
    }
}

// extension for data fetch functions (temporary)

extension ChecklistViewController {
    
    func fetchChecklist(
        success: @escaping ([Checklist]) -> Void,
        failure: @escaping (TripsError) -> Void
        ) {
        
        ref.child("checklist").observeSingleEvent(of: .value) { (snapshot) in
            
            guard let value = snapshot.value as? NSArray else { return }
            
            print(value)
            
            guard let jsonData = try? JSONSerialization.data(withJSONObject: value) else { return }
            
            do {
                let data = try self.decoder.decode([Checklist].self, from: jsonData)
                
                print(data)
                
                success(data)
                
            } catch {
                // Error handling
                print(error)
            }

        }
    }
    
    func updateChecklistData(item: Items, section: Int, index: Int, type: Edit) {
        
        switch type {
            
        case .add:
            
            let post = ["name": item.name,
                        "number": item.number,
                        "order": item.order,
                        "isSelected": item.isSelected
                ] as [String: Any]
            
            let postUpdate = ["/checklist/\(section)/items/\(index)": post]
            
            ref.updateChildValues(postUpdate)
            
        case .delete:
            
            ref.child("/checklist/\(section)/items/\(index)").removeValue()
        }

    }
    
    func handleCellSelected(indexPath: IndexPath) {
        
        guard let checklistCell = tableView.cellForRow(at: indexPath) as? ChecklistTableViewCell else { return }
        
        if checklists[indexPath.section].items[indexPath.row].isSelected {
            
            checklists[indexPath.section].items[indexPath.row].isSelected = false
            checklistCell.checkButton.isSelected = false
            checklistCell.checkButton.tintColor = UIColor.darkGray
            checklistCell.contentLabel.textColor = UIColor.darkGray
        } else {
            
            checklists[indexPath.section].items[indexPath.row].isSelected = true
            checklistCell.checkButton.isSelected = true
            checklistCell.checkButton.tintColor = UIColor.lightGray
            checklistCell.contentLabel.textColor = UIColor.lightGray
        }
    }
    
    // MARK: - For cellForRoll cell check (sync with Firebase data)
    func handleCellColor(cell: UITableViewCell, indexPath: IndexPath) {
        
        guard let checklistCell = cell as? ChecklistTableViewCell else { return }
        
        if checklists[indexPath.section].items[indexPath.row].isSelected {
            
            checklistCell.checkButton.isSelected = true
            checklistCell.checkButton.tintColor = UIColor.lightGray
            checklistCell.contentLabel.textColor = UIColor.lightGray
        } else {
            
            checklistCell.checkButton.isSelected = false
            checklistCell.checkButton.tintColor = UIColor.darkGray
            checklistCell.contentLabel.textColor = UIColor.darkGray
        }
    }
}
