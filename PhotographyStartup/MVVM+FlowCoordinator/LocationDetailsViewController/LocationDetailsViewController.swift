//
//  LocationDetailsViewController.swift
//  PhotographyStartup
//
//  Created by Dmitry Lemaykin on 9/11/18.
//  Copyright © 2018 Dmitry Lemaykin. All rights reserved.
//

import UIKit

import RxSwift


protocol LocationDetailsViewControllerDelegate: class
{
    func locationDetailsViewControllerDidBackAction()
}

class LocationDetailsViewController: UITableViewController
{
    private var disposeBag = DisposeBag()
    
    weak var delegate: LocationDetailsViewControllerDelegate?
    
    private var _viewModel: PlaceViewModel!
    var viewModel: PlaceViewModel!
    {
        get {
            return _viewModel
        }
        set {
            _viewModel = newValue
        }
    }

    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var descriptionTextView: UITextView!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        let saveBarButtonItem = UIBarButtonItem(title: "Save", style: .done, target: self, action: .save)
        navigationItem.rightBarButtonItem = saveBarButtonItem
        
        viewModel.name.asObservable()
            .bind(to: nameTextField.rx.text)
            .disposed(by: disposeBag)
        descriptionTextView.text = viewModel.notes
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
        viewModel.name.value = nameTextField.text ?? ""
        viewModel.notes = descriptionTextView.text
        
        viewModel.save()
        navigateBack()
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
        
        present(alertController, animated: true)
    }
    
    func navigateBack()
    {
        delegate?.locationDetailsViewControllerDidBackAction()
        
        _ = navigationController?.popViewController(animated: true)
    }
}

fileprivate extension Selector
{
    static let save = #selector(LocationDetailsViewController.save)
}
