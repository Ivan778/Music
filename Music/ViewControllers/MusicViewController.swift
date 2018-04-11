//
//  ViewController.swift
//  Music
//
//  Created by Иван on 07.04.2018.
//  Copyright © 2018 Ivan. All rights reserved.
//

import UIKit
import AVFoundation
import MediaPlayer
import SafariServices

class MusicViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, AVAudioPlayerDelegate {
    @IBOutlet weak var tableView: UITableView!
    var content = [String]()
    var player: AVPlayer? = nil
    var playerItem: AVPlayerItem? = nil
    var currentSong = -1
    var currentTime: Double = 0
    var isPlaying = false
    var songArtist = "Artist"
    var songTitle = "Title"
    
    // MARK: - viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setNavigationController()
        setTableView()
        
        UIApplication.shared.beginReceivingRemoteControlEvents()
        let commandCenter = MPRemoteCommandCenter.shared()
        commandCenter.nextTrackCommand.isEnabled = true
        commandCenter.pauseCommand.isEnabled = true
        commandCenter.playCommand.isEnabled = true
        
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Audio session error")
        }
        
        setupNowPlaying()
        setupNowPlayingInfoCenter()
    }
    
//    override func remoteControlReceived(with event: UIEvent?) {
//        if (event?.type == .remoteControl) {
//            let subtype = (event?.subtype)!
//
//            switch subtype {
//            case .remoteControlPlay:
//                self.player?.play()
//                self.setupNowPlaying()
//            case .remoteControlPause:
//                self.player?.pause()
//            case .remoteControlTogglePlayPause:
//                self.player?.pause()
//            default:
//                break
//            }
//        }
//    }
    
    func setupNowPlaying() {
        // Define Now Playing Info
        var nowPlayingInfo = [String : Any]()
        nowPlayingInfo[MPMediaItemPropertyArtist] = songArtist
        nowPlayingInfo[MPMediaItemPropertyTitle] = songTitle
        nowPlayingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = playerItem?.currentTime().seconds
        nowPlayingInfo[MPMediaItemPropertyPlaybackDuration] = playerItem?.asset.duration.seconds
        nowPlayingInfo[MPNowPlayingInfoPropertyPlaybackRate] = player?.rate
        
        // Set the metadata
        MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
    }
    
    func setupNowPlayingInfoCenter() {
        UIApplication.shared.beginReceivingRemoteControlEvents()
        
        MPRemoteCommandCenter.shared().playCommand.isEnabled = true
        MPRemoteCommandCenter.shared().playCommand.addTarget {event in
            self.player?.play()
            self.setupNowPlaying()
            self.isPlaying = true
            
            return .success
        }
        MPRemoteCommandCenter.shared().pauseCommand.isEnabled = true
        MPRemoteCommandCenter.shared().pauseCommand.addTarget {event in
            self.player?.pause()
            self.setupNowPlaying()
            self.isPlaying = false
            
            return .success
        }
        
        MPRemoteCommandCenter.shared().togglePlayPauseCommand.isEnabled = true
        MPRemoteCommandCenter.shared().togglePlayPauseCommand.addTarget {event in
            if self.isPlaying {
                self.player?.pause()
                self.setupNowPlaying()
                self.isPlaying = false
            } else {
                self.player?.play()
                self.setupNowPlaying()
                self.isPlaying = true
            }
            
            return .success
        }
        
        MPRemoteCommandCenter.shared().changePlaybackPositionCommand.isEnabled = true
        MPRemoteCommandCenter.shared().changePlaybackPositionCommand.addTarget(handler: {event in
            let time = (event as! MPChangePlaybackPositionCommandEvent).positionTime
            self.playerItem?.seek(to: CMTimeMakeWithSeconds(time, 1000000), completionHandler: nil)
            self.setupNowPlaying()
            
            return .success
        })
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
            
            let documentsDirectoryURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            let url = documentsDirectoryURL.appendingPathComponent(content[indexPath.row])
            
            let asset = AVURLAsset(url: url)
            if asset.commonMetadata.count > 0 {
                print(asset.commonMetadata.count)
                let metas = asset.commonMetadata
                print("\(metas[metas.count - 1].stringValue!) - \(metas[0].stringValue!)")
                songArtist = metas[metas.count - 1].stringValue!
                songTitle = metas[0].stringValue!
            }
            
            playerItem = AVPlayerItem(url: url)
            player = AVPlayer(playerItem: playerItem)
            player?.play()
            setupNowPlaying()
            self.isPlaying = true
        } else {
            if player?.rate == 0.0  {
                player?.play()
                setupNowPlaying()
                self.isPlaying = true
            } else {
                player?.pause()
                self.setupNowPlaying()
                self.isPlaying = false
            }
        }
        
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == UITableViewCellEditingStyle.delete) {
            do {
                let documentsDirectoryURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
                let url = documentsDirectoryURL.appendingPathComponent(content[indexPath.row])
                
                try FileManager.default.removeItem(at: url)
                content.remove(at: indexPath.row)
                tableView.reloadData()
            } catch {
                print("Can't remove file!")
            }
        }
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

