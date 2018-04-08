//
//  FileDownloader.swift
//  Music
//
//  Created by Иван on 07.04.2018.
//  Copyright © 2018 Ivan. All rights reserved.
//

import Foundation

protocol FileDownloaderDelegate {
    func downloadSuccess()
    func downloadFail()
}

class FileDownloader {
    var delegate: FileDownloaderDelegate!
    
    func downloadFile(url: URL) {
        // Then lets create your document folder url
        let documentsDirectoryURL =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        
        // Lets create your destination file url
        let destinationUrl = documentsDirectoryURL.appendingPathComponent(url.lastPathComponent)
        print(destinationUrl)
        
        // To check if it exists before downloading it
        if FileManager.default.fileExists(atPath: destinationUrl.path) {
            print("The file already exists at path")
        } else {
            URLSession.shared.downloadTask(with: url, completionHandler: { (location, response, error) -> Void in
                guard let location = location, error == nil else { return }
                do {
                    try FileManager.default.moveItem(at: location, to: destinationUrl)
                    print("File moved to documents folder")
                    self.delegate.downloadSuccess()
                } catch let error as NSError {
                    print(error.localizedDescription)
                    self.delegate.downloadFail()
                }
            }).resume()
        }
    }
}
