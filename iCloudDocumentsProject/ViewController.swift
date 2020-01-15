//
//  ViewController.swift
//  iCloudDocumentsProject
//
//  Created by Mxionlly on 2019/12/25.
//  Copyright © 2019 Mxionlly. All rights reserved.
//

import UIKit

enum enumErrMessage: String{
    case Oops = "请再试一次!"
}

class ViewController: UIViewController {
    
    @IBOutlet weak var textField: UITextField!
    
    @IBOutlet weak var upButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    
    @IBAction func icloudAction(_ sender: Any) {
        self.view.endEditing(true)
        self.downloadFile("同步文件") { (path, str) in
            guard let localPath = path, str == nil else {
                debugPrint(str ?? enumErrMessage.Oops.rawValue)
                return
            }
            self.exportToiCloud(fileUrl: localPath)
        }
    }
    

    // MARK:- 下载资源
    func downloadFile(_ fileName : String,complection: @escaping(URL?, String?) -> Void ) {
        if self.textField.text?.count == 0 {
            print("----请输入连接----")
            return
        }
        let finaleURL = self.textField.text ?? ""
        
        let string = finaleURL.suffix(5)
        if string.range(of: ".") == nil {
            print("----连接有误----")
            return
        }
        let range: Range = string.range(of: ".")!
        let location: Int = string.distance(from: string.startIndex, to: range.lowerBound)
        let subStr = string.suffix(string.count - location)
        
        let fileNameNew = fileName + subStr
        guard let url = URL(string: finaleURL) else {
            DispatchQueue.main.async {
                complection(nil, enumErrMessage.Oops.rawValue)
            }
            return
        }
        URLSession.shared.dataTask(with: url) { (data, response, err) in
            guard let data = data, err == nil else {
                DispatchQueue.main.async {
                    complection(nil, err?.localizedDescription ?? enumErrMessage.Oops.rawValue)
                }
                return
            }
            let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent(fileNameNew)
            do {
                try data.write(to: tempURL)
            } catch let fileErr {
                DispatchQueue.main.async {
                    complection(nil, fileErr.localizedDescription)
                    return
                }
            }
            DispatchQueue.main.async {
                complection(tempURL, nil)
            }
            }.resume()
    }
    
    
    func exportToiCloud(fileUrl:URL){
        
        let exportMenu = UIDocumentPickerViewController(url: fileUrl , in: .exportToService)
        exportMenu.modalPresentationStyle = .formSheet

        exportMenu.delegate = self
        self.present(exportMenu, animated: true) {

        }
    }
}

// MARK:- UIDocumentPickerDelegates
extension ViewController : UIDocumentPickerDelegate {
    
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        
        if controller.documentPickerMode == .exportToService{
            
            print("----同步成功----")
            
        }
        
    }
    
    
    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        
        print("----取消了----")
        
        if controller.documentPickerMode == .import {
    
            print("如果您在iCloud中没有找到任何文件，请同步您的iCloud或从您的iPhone中添加一些文件到iCloud")

        }
    }
    
}

