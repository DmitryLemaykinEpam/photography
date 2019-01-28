//
//  ClosestPlaceTableViewCell.swift
//  PhotographyStartup
//
//  Created by Dmitry Lemaykin on 9/11/18.
//  Copyright © 2018 Dmitry Lemaykin. All rights reserved.
//

import UIKit
import MapKit

import RxSwift
import RxCocoa

class ClosestPlaceTableViewCell: UITableViewCell
{
    private var disposeBag = DisposeBag()
    private var viewModel: ClosestPlaceCellViewModel?
    // TODO: move to model
    private lazy var distanceFormatter: MKDistanceFormatter = {
        let distanceFormatter = MKDistanceFormatter()
        distanceFormatter.units = .metric
        distanceFormatter.unitStyle = .full
        
        return distanceFormatter
    }()
    
    let globalScheduler = ConcurrentDispatchQueueScheduler(queue:
        DispatchQueue.global())
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!

    func bindTo(viewModel: ClosestPlaceCellViewModel?)
    {
        guard let viewModel = viewModel else {
            return
        }
        disposeBag = DisposeBag()
        self.viewModel = viewModel
        
        viewModel.distance.asObservable()
            .subscribeOn(globalScheduler)
            .map({ (distance) -> String in
                self.distanceFormatter.string(fromDistance: distance)
            })
            .bind(to: self.distanceLabel.rx.text)
            .disposed(by: disposeBag)
        
        viewModel.name.asObservable()
            .subscribeOn(globalScheduler)
            .map({ (name) -> NSAttributedString in
                if let name = name {
                    return NSAttributedString(string: name, attributes:
                        [NSAttributedString.Key.foregroundColor: UIColor.black,
                         NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14)])
                } else {
                    return NSAttributedString(string: "Not yet set", attributes:
                        [NSAttributedString.Key.foregroundColor: UIColor.gray,
                         NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14)])
                }
            })
            .bind(to: self.nameLabel.rx.attributedText)
            .disposed(by: disposeBag)
    }
}
