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
}

class LocationDetailsViewController: UITableViewController
{
    weak var delegate: LocationDetailsViewControllerDelegate?
    
    var viewModel: LocationViewModel!

    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var descriptionTextView: UITextView!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        let saveBarButtonItem = UIBarButtonItem(title: "Save", style: .done, target: self, action: .save)
        self.navigationItem.rightBarButtonItem = saveBarButtonItem
        
        self.nameTextField.text = viewModel.name
        self.descriptionTextView.text = viewModel.notes
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        
        navigationController?.navigationBar.isHidden = false
    }
    
    override func viewDidDisappear(_ animated: Bool)
    {
        super.viewDidDisappear(animated)
        
        if isMovingFromParent
        {
            delegate?.locationDetailsViewControllerDidBackAction()
        }
    }

    @objc func save()
    {
        viewModel.updatedName = nameTextField.text
        viewModel.updatedNotes = descriptionTextView.text
        
        guard let errorMessage = viewModel.saveUpdates() else {
            self.navigateBack()
            return
        }
        
        showSaveResultErrorAlert(errorMessage)
    }
    
    func showSaveResultErrorAlert(_ errorMessage: String)
    {
        let alertController = UIAlertController(title: "Could not save", message: errorMessage, preferredStyle: .actionSheet)
        let confirmAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
        alertController.addAction(confirmAction)
        
        if let popoverController = alertController.popoverPresentationController
        {
            popoverController.sourceView = view
            popoverController.sourceRect = CGRect(x: view.bounds.midX, y: view.bounds.maxY, width: 0, height: 0)
        }
        
        self.present(alertController, animated: true)
    }
    
    func navigateBack()
    {
        self.delegate?.locationDetailsViewControllerDidBackAction()
        
        _ = self.navigationController?.popViewController(animated: true)
    }
}

fileprivate extension Selector
{
    static let save = #selector(LocationDetailsViewController.save)
}
