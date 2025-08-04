//
//  ICloudTypeViewController.swift
//  AllCapabilitiesDemo
//
//  Created by DREAMWORLD on 12/12/24.
//

import UIKit

class ICloudTypeViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    @IBAction func btnCloudkitAction(_ sender: Any) {
        let vc = ICloudViewController()
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func btnCloudDocumentAction(_ sender: Any) {
        let vc = ICloudDocumentsViewController()
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
}
