//
//  LocationDetailsViewController.swift
//  PhotographyStartup
//
//  Created by Dmitry Lemaykin on 9/11/18.
//  Copyright © 2018 Dmitry Lemaykin. All rights reserved.
//

import UIKit
import MagicalRecord

class LocationDetailsViewController: UIViewController
{
    var location : CustomLocation?

    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var descriptionTextView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let location = self.location else {
            return
        }

        self.nameTextField.text = location.name
        self.descriptionTextView.text = location.notes
    }

    @IBAction func saveTap(_ sender: Any)
    {
        guard let location = self.location else {
            return
        }
        
        location.name = self.nameTextField.text
        location.notes = self.descriptionTextView.text
        
        NSManagedObjectContext.mr_default().mr_saveToPersistentStore { (success, error) in
            
            let message = success ? "Success" : "Could not save"
            
            let ac = UIAlertController(title: "Save compleat", message: message, preferredStyle: .actionSheet)
            let actionOk = UIAlertAction(title: "Ok", style: .default, handler: { action in
                self.navigateBack()
            })
            ac.addAction(actionOk)
            self.present(ac, animated: true)
        }
    }
    
    @IBAction func backTap(_ sender: Any) {
        self.navigateBack()
    }
    
    func navigateBack() {
        self.presentingViewController?.dismiss(animated: true, completion: nil)
    }
}
