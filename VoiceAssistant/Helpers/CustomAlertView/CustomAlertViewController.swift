//
//  CustomAlertViewController.swift
//  VoiceAssistant
//
//  Created by Yazan Kareem on 27/01/2026.
//

import UIKit

enum AlertViewType: String, CaseIterable {
    case reportForm
}

class CustomAlertViewController: UIViewController {

    @IBOutlet weak var tableViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var tableView: ContentSizedTableView!
    
    var cells: [AlertViewType] = AlertViewType.allCases
    var didSelectCell: ((AlertViewType) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupViews()
    }

    
    private func setupViews() {
        self.enableTapToDismissAnimated()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.isScrollEnabled = false
        let nib = UINib(nibName: "NormalAlertTableViewCell", bundle: Bundle(for: NormalAlertTableViewCell.self))
        tableView.register(nib, forCellReuseIdentifier: "NormalAlertTableViewCell")
        tableView.reloadData()
        tableView.layoutIfNeeded()
        tableViewHeightConstraint.constant = tableView.contentSize.height
    }
}

extension CustomAlertViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cells.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch cells[indexPath.row] {
        case .reportForm:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "NormalAlertTableViewCell", for: indexPath) as? NormalAlertTableViewCell else {
                    fatalError("Cannot dequeue CustomCell")
                }
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let selectedType = cells[indexPath.row]
                
        self.dismissAnimated {
            self.didSelectCell?(selectedType)
        }
    }
    
}
