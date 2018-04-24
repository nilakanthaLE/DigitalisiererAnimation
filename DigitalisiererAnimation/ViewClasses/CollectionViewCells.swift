//
//  CollectionViewCells.swift
//  DigitalisiererAnimation
//
//  Created by Matthias Pochmann on 18.04.18.
//  Copyright © 2018 Matthias Pochmann. All rights reserved.
//

import Foundation
import UIKit

class DokumentCollectionCell: UICollectionViewCell {
    //ViewModel
    var viewModel:DokumentCollectionCellViewModel!{
        didSet{
            dokumentView.viewModel = viewModel.getViewModelForDokumentView()
            layer.borderColor       = UIColor.darkGray.cgColor
            layer.borderWidth       = 0.5
            layer.cornerRadius      = 5.0
            
            for subview in tagStack.arrangedSubviews{ if let subview = subview as? UILabel { subview.removeFromSuperview() } }
            for tag in viewModel.tags{
                let label           = UILabel()
                label.text          = tag.title
                label.textAlignment = .center
                tagStack.insertArrangedSubview(label, at: 0)
            }
        }
    }
    
    //IBOutlets
    @IBOutlet weak var dokumentView: DokumentView!
    @IBOutlet weak var tagStack: UIStackView!
    
    //isSelected
    override var isSelected: Bool{
        didSet{
            super.isSelected = isSelected
            if self.isSelected
            {
                self.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
                layer.borderColor = UIColor.green.cgColor
                layer.borderWidth = 5.0
            }
            else
            {
                self.transform = CGAffineTransform.identity
                layer.borderColor = UIColor.darkGray.cgColor
                layer.borderWidth = 0.5
            }
        }
    }
}

class TagCollectionViewCell: UICollectionViewCell {
    var viewModel:TagCollectionCellViewModel!{
        didSet{
            tagLabel.text   = viewModel.tag.title
        }
    }
    
    @IBOutlet weak var tagLabel: UILabel!
    
    override var isSelected: Bool{
        didSet{
            if self.isSelected
            {
                self.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
                layer.borderColor = UIColor.green.cgColor
                layer.borderWidth = 5.0
            }
            else
            {
                self.transform = CGAffineTransform.identity
                layer.borderColor = UIColor.darkGray.cgColor
                layer.borderWidth = 0.5
                
            }
        }
    }
}
