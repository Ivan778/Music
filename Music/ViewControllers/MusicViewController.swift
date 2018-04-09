//
//  ViewController.swift
//  Music
//
//  Created by Иван on 07.04.2018.
//  Copyright © 2018 Ivan. All rights reserved.
//

import UIKit
import AVFoundation

class MusicViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var tableView: UITableView!
    var content = [String]()
    var player: AVAudioPlayer? = nil
    var currentSong = -1
    
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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if player == nil || currentSong != indexPath.row {
            currentSong = indexPath.row
            do {
                let documentsDirectoryURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
                let url = documentsDirectoryURL.appendingPathComponent(content[indexPath.row])
                
                self.player = try AVAudioPlayer(contentsOf: url)
                player?.prepareToPlay()
                player?.volume = 1.0
                player?.play()
            } catch let error as NSError {
                self.player = nil
                print(error.localizedDescription)
            } catch {
                print("AVAudioPlayer init failed")
            }
        } else {
            if (player?.isPlaying)! {
                player?.pause()
            } else {
                player?.play()
            }
            
        }
        
        
        tableView.deselectRow(at: indexPath, animated: true)
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
    
    override func viewWillAppear(_ animated: Bool) {
        let documentsDirectoryURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        print(documentsDirectoryURL)
        
        do {
            content = try FileManager.default.contentsOfDirectory(atPath: documentsDirectoryURL.path)
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        } catch {
            print("Can't get filelist!")
        }
    }
}

