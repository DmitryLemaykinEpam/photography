//
//  LocationDetailsViewController.swift
//  PhotographyStartup
//
//  Created by Dmitry Lemaykin on 9/11/18.
//  Copyright © 2018 Dmitry Lemaykin. All rights reserved.
//

import UIKit
import MagicalRecord

protocol LocationDetailsViewControllerDelegate: class
{
    func locationDetailsViewControllerDidBackAction()
    func locationDetailsViewControllerDidSaveViewModel(_ viewModel: LocationViewModel)
}

class LocationDetailsViewController: UIViewController
{
    weak var delegate: LocationDetailsViewControllerDelegate?
    
    var viewModel: LocationViewModel!

    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var descriptionTextView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.nameTextField.text = viewModel.name
        self.descriptionTextView.text = viewModel.notes
    }

    @IBAction func saveTap(_ sender: Any)
    {
        viewModel.updatedName = self.nameTextField.text
        viewModel.updatedNotes = self.descriptionTextView.text
        
        self.delegate?.locationDetailsViewControllerDidSaveViewModel(viewModel)
    }
    
    func showSaveResultAlert(success: Bool, error: Error?)
    {
        let message = success ? "Success" : "Could not save"
        
        let alertController = UIAlertController(title: "Save compleat", message: message, preferredStyle: .actionSheet)
        let confirmAction = UIAlertAction(title: "Ok", style: .default, handler: { action in
            self.navigateBack()
        })
        alertController.addAction(confirmAction)
        
        if let popoverController = alertController.popoverPresentationController
        {
            popoverController.sourceView = view
            popoverController.sourceRect = CGRect(x: view.bounds.midX, y: view.bounds.maxY, width: 0, height: 0)
        }
        
        self.present(alertController, animated: true)
    }
    
    @IBAction func backTap(_ sender: Any)
    {
        navigateBack()
    }
    
    func navigateBack()
    {
        self.delegate?.locationDetailsViewControllerDidBackAction()
    }
    
    @IBAction func allViewTap(_ sender: Any)
    {
        self.view.endEditing(true)
    }
}
