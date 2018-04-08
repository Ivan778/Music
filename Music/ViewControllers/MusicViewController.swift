//
//  ViewController.swift
//  Music
//
//  Created by Иван on 07.04.2018.
//  Copyright © 2018 Ivan. All rights reserved.
//

import UIKit

class MusicViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var tableView: UITableView!
    var content = [String]()
    
    // MARK: - viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setNavigationController()
        setTableView()
    }
    
    // MARK: - TableView delegate methods
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return content.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell")
        (cell?.viewWithTag(100) as! UILabel).text = content[indexPath.row]
        return cell!
    }
    
    // Setting view
    func setNavigationController() {
        self.navigationController?.navigationBar.prefersLargeTitles = true
        self.navigationController?.navigationItem.largeTitleDisplayMode = .never
        
        UINavigationBar.appearance().largeTitleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.black, NSAttributedStringKey.font: UIFont.boldSystemFont(ofSize: 40)]
    }
    
    func setTableView() {
        tableView.delegate = self
        tableView.dataSource = self
    }
}

