//
//  DokumentenAuswahlVC.swift
//  DigitalisiererAnimation
//
//  Created by Matthias Pochmann on 23.04.18.
//  Copyright © 2018 Matthias Pochmann. All rights reserved.
//

import Foundation
import UIKit
import ReactiveSwift

class DokumentenWahlVC:UIViewController{
    
}

class AusgabeUndEingabeVC:UIViewController{
    //ViewModel
    var viewModel:DokumentenAuswahlViewModel!
    
    //IBOutlets
    @IBOutlet weak var filterViewHeight: NSLayoutConstraint!
    @IBOutlet weak var tagWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var dokumenteEinOderAusgabenBarButton: UIBarButtonItem!
    
    //IBActions
    @IBAction func abbrechenPressed(_ sender: UIBarButtonItem) { dismiss(animated: true, completion: nil) }
    @IBAction func dokumenteEinOderAusgabenBarButtonPressed(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
        viewModel.model.dokumenteEinOderAusgeben()
    }

    //VC LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        tagWidthConstraint.priority = UILayoutPriority(rawValue: UILayoutPriority.RawValue(viewModel.tagViewsAreHidden.value ? 1000 : 500))
        if viewModel.tagViewsAreHidden.value{ filterViewHeight.constant = 0  }
        dokumenteEinOderAusgabenBarButton.reactive.isEnabled    <~ viewModel.einUndAusgabeBarButtonIsEnabled.producer
        dokumenteEinOderAusgabenBarButton.reactive.title        <~ viewModel.einUndAusgabeBarButtonTitle.producer
    }
    
    //Segues
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        (segue.destination.contentViewController as? DokumentenAuswahlCollectionVC)?.viewModel  = viewModel.getViewModelFuerDokumentenAuswahlCollectionView()
        (segue.destination.contentViewController as? TaggingCollectionVC)?.viewModel            = viewModel.getViewModelFuerTagAuswahlAuswahlCollectionView()
        (segue.destination.contentViewController as? TagsSuchenUndErstellenVC)?.viewModel       = viewModel.getViewModelFuerTagsSuchenUndErstellen()
        (segue.destination.contentViewController as? FilterDokumentsWithTags)?.viewModel        = viewModel.getViewModelFuerTagsAlsFilter()
    }
}

//MARK: Dokumentenauswahl
class DokumentenAuswahlCollectionVC: UICollectionViewController {
    //ViewModel
    var viewModel: DokumentenAuswahlCollectionViewModel!{
        didSet{
            collectionView?.allowsMultipleSelection = true
            viewModel.collectionViewUpdate.producer.start()  {[weak self] _ in  self?.collectionView?.reloadData() }
        }
    }
    
    //CollectionView DataSource und Delegate
    override func numberOfSections(in collectionView: UICollectionView) -> Int                                      { return 1 }
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int    { return viewModel.angezeigteDokumente.value.count }
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell        = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! DokumentCollectionCell
        cell.viewModel  = viewModel.getViewModelForCell(indexPath: indexPath)
        if viewModel.cellIsSelected(indexPath: indexPath){
            cell.isSelected = true
            collectionView.selectItem(at: indexPath, animated: false, scrollPosition: [])
        }
        else{ cell.isSelected = false }
        
        cell.setNeedsLayout()
        cell.layoutIfNeeded()
        return cell
    }
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath)      { viewModel.didSelect(indexPath: indexPath) }
    override func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath)    { viewModel.didSelect(indexPath: indexPath) }
    
    //VC LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView?.register(UINib(nibName: "DokumentCollectionCell", bundle: nil), forCellWithReuseIdentifier: "cell")
    }
}


//MARK: Tags wählen
class TaggingCollectionVC: UICollectionViewController {
    //ViewModel
    var viewModel:TagAuswahlCollectionViewModel!{
        didSet{
            collectionView?.allowsMultipleSelection = true
            viewModel.collectionViewUpdate.producer.start()  {[weak self] _ in  self?.collectionView?.reloadData() }
        }
    }

    //IBOutlets
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
    
    //CollectionView DataSource und Delegate
    override func numberOfSections(in collectionView: UICollectionView) -> Int                                      { return 1 }
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int    { return viewModel.angezeigteTags.value.count }
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell        = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! TagCollectionViewCell
        cell.viewModel  = viewModel.getViewModelForCell(indexPath: indexPath)
        if viewModel.cellIsSelected(indexPath: indexPath){
            cell.isSelected = true
            collectionView.selectItem(at: indexPath, animated: false, scrollPosition: [])
        }
        else { cell.isSelected = false}
        cell.setNeedsLayout()
        cell.layoutIfNeeded()
        return cell
    }
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath)          { viewModel.didSelect(indexPath: indexPath) }
    override func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath)        { viewModel.didSelect(indexPath: indexPath) }
    
    //VC LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        flowLayout.estimatedItemSize            = CGSize(width: 100, height: 100)
        collectionView?.register(UINib(nibName: "TagCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "cell")
    }
}

//MARK: Tags suchen und erstellen
class TagsSuchenUndErstellenVC:UIViewController{
    //ViewModel
    var viewModel:TagsSuchenUndErstellenViewModel!
    
    //IBOutlets
    @IBOutlet weak var textFeld: UITextField!
    @IBOutlet weak var addButton: UIButton!
    
    //IBActions
    @IBAction func addButtonAction(_ sender: UIButton)  { viewModel.addButtonAction() }
    
    //VC LifeCycle
    override func viewDidLoad() {
        addButton.reactive.isEnabled        <~ viewModel.addButtonIsEnabled.producer
        viewModel.suchString                <~ textFeld.reactive.continuousTextValues
    }
}

class FilterDokumentsWithTags:UIViewController{
    //ViewModel
    var viewModel:TagsAlsFilterViewModel!{
        didSet{
            viewModel.tags.signal.observeValues {[weak self] tags in self?.setStack(for: tags) }
            viewModel.tagVerwendung.signal.observeValues{[weak self] verwendung in self?.setBorder(tagVerwendung: verwendung) }
        }
    }
    
    //IBActions & IBOutlets
    @IBOutlet weak var tagStack: UIStackView!
    @IBAction func tapGestureAction(_ sender: UITapGestureRecognizer) { viewModel.switchTagVerwendung() }
    

    //helper
    private func setStack(for tags:[Tag]){
        for subView in tagStack.arrangedSubviews {if let subView = subView as? UILabel { subView.removeFromSuperview()} }
        for tag in tags{
            let label:UILabel = {
                let label = UILabel()
                label.text = tag.title
                return label
            }()
            tagStack.insertArrangedSubview(label, at: 0)
        }
    }
    private func setBorder(tagVerwendung:TagVerwendung){
        switch tagVerwendung{
        case .Filter:
            view.layer.borderColor  = UIColor.green.cgColor
            view.layer.borderWidth  = 3.0
        case .TagDokumente:
            view.layer.borderColor  = UIColor.darkGray.cgColor
            view.layer.borderWidth  = 1.0
        }
    }
}
