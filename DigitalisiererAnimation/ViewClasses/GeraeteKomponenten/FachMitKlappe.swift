//
//  FachMitKlappe.swift
//  DigitalisiererAnimation
//
//  Created by Matthias Pochmann on 12.03.18.
//  Copyright © 2018 Matthias Pochmann. All rights reserved.
//

import Foundation
import UIKit
import ReactiveSwift


//MARK: FachMitKlappe (und PapierStapel)
@IBDesignable class FachMitKlappe:NibLoadingView{
    var viewModel:FachMitKlappeUndPapierStapelViewModel!{
        didSet{
            rechteWalze.viewModel   = viewModel.getViewModelForWalze()
            linkeWalze.viewModel    = viewModel.getViewModelForWalze()
            klappe.viewModel        = viewModel.getViewModelForKlappe()
            papierStapel.viewModel  = viewModel.getViewModelForPapierStapel()
            
            //WalzenConstraints
            for width in walzenWidth    { width.reactive.constant <~ viewModel.widthWalze.producer  }
            linkeWalzeTop.reactive.constant         <~ viewModel.linkeWalzePosition.producer.map{$0.y}
            linkeWalzeLeading.reactive.constant     <~ viewModel.linkeWalzePosition.producer.map{$0.x}
            rechteWalzeTrailing.reactive.constant   <~ viewModel.rechteWalzePosition.producer.map{$0.x}
            
            var abstandWalzeBottom:CGFloat { return linkeWalze.frame.origin.y + linkeWalze.frame.height}
            papierStapelWalzeConstraint.reactive.constant <~ viewModel.fachIsGeschlossen.producer.map{  $0 ? -abstandWalzeBottom : mainModel.positionenUndFrames.abstandWalzeZuStapel }
            
            rechteWalze.isHidden    = viewModel.rechtewalzeIsHidden
            linkeWalze.isHidden     = viewModel.linkeWalzeIsHidden
        }
    }

    //IBOutlets
    @IBOutlet private weak var klappe: Klappe!
    @IBOutlet private weak var rechteWalze: Walze!
    @IBOutlet private weak var linkeWalze: Walze!
    @IBOutlet private weak var papierStapel: PapierStapelAnimiert!
    //IBOutlets - Constraints
    @IBOutlet private var walzenWidth: [NSLayoutConstraint]!
    @IBOutlet private weak var hoeheKlappe: NSLayoutConstraint!         {didSet{ hoeheKlappe.constant = mainModel.positionenUndFrames.fachWerte.klappenHoehe } }
    @IBOutlet weak var papierStapelWalzeConstraint: NSLayoutConstraint!
    @IBOutlet private weak var linkeWalzeTop: NSLayoutConstraint!
    @IBOutlet private weak var linkeWalzeLeading: NSLayoutConstraint!
    @IBOutlet private weak var rechteWalzeTrailing: NSLayoutConstraint!
    
    //Gesture Recogizer
    @IBAction func linkeWalzeDoppelTapped(_ sender: UITapGestureRecognizer)     { viewModel.fineTunerFuerWalzeStarten() }
    @IBAction func rechteWalzeDoppelTapped(_ sender: UITapGestureRecognizer)    { viewModel.fineTunerFuerWalzeStarten() }
    
    //layoutSubViews
    override func layoutSubviews() {  viewModel?.fachHoehen.value = frame.width }
}




//MARK: Klappe
@IBDesignable class Klappe:NibLoadingView{
    //ViewModel
    var viewModel:KlappeViewModel!{
        didSet{
            //Farben
            backgroundColor                 = UIColor.clear
            linkeKlappe.backgroundColor     = viewModel.direction == .left ? .darkGray : .clear
            rechteKlappe.backgroundColor    = viewModel.direction == .right ? .darkGray : .clear
            
            viewModel.klappWinkel.producer.startWithValues{ [weak self] winkel in self?.animateKlappe(winkel: winkel)}
        }
    }
    
    //Animation
    private func animateKlappe(winkel:CGFloat){
        let multiplicator:CGFloat = viewModel.direction == .left ? 1 : -1
        let angel = multiplicator * winkel
        UIView.animate(withDuration: 1) { self.transform = CGAffineTransform(rotationAngle: angel) }
    }

    //IBOutlets
    @IBOutlet weak private var linkeKlappe: UIView!
    @IBOutlet weak private var rechteKlappe: UIView!
}


//MARK: Fach
@IBDesignable class Fach:UIView{
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.clear
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        backgroundColor = UIColor.clear
        self.addBorders(edges: [.top, .bottom], color: .darkGray, thickness: 1)
    }
}








//class FachMitKlappeViewModel{
//    var anzahlBlaetter:Int
//
//    //Walzen
//    var rechteWalzeIsSpinning:MutableProperty<Bool>
//    var linkeWalzeIsSpinning:MutableProperty<Bool>
//    var klappeIsOpen:MutableProperty<Bool>
//    var klappeDirection = Direction.left
//    var fachDesStapels:FachDesStapels
//
//    var klappWinkel = MutableProperty<CGFloat>(0)
//
//    //init
//    init(rechteWalzeIsSpinning:MutableProperty<Bool>,
//         linkeWalzeIsSpinning:MutableProperty<Bool>,
//         klappeIsOpen:MutableProperty<Bool>,
//         anzahlBlaetter:Int ,
//         klappeDirection:Direction,
//         fachDesStapels:FachDesStapels
//        ){
//
//        self.rechteWalzeIsSpinning  = rechteWalzeIsSpinning
//        self.linkeWalzeIsSpinning   = linkeWalzeIsSpinning
//        self.klappeIsOpen           = klappeIsOpen
//        self.anzahlBlaetter         = anzahlBlaetter
//        self.klappeDirection        = klappeDirection
//        self.fachDesStapels         = fachDesStapels
//    }
//
//
//
//    var isEingabefach = false //weg
//    //MARK: helper
//    func getViewModelForKlappe()->KlappeViewModel   { return KlappeViewModel(klappWinkel: klappWinkel, direction: klappeDirection, fachDesStapels: fachDesStapels) }
//    func toggleLinkewalzeSpinning()                 { linkeWalzeIsSpinning.value = !linkeWalzeIsSpinning.value}
//    func toggleRechtewalzeSpinning()                { rechteWalzeIsSpinning.value = !rechteWalzeIsSpinning.value}
//    func toggleKlappe()                             { klappeIsOpen.value = !klappeIsOpen.value}
//    func setKlappeDirection(isLeft:Bool,ohne:Bool)  { klappeDirection = ohne ? .stop : isLeft ? .left : .right }
//    func getViewModelForPapierStapel() -> PapierStapelViewModel {
//        return PapierStapelViewModel(anzahlBlaetter: anzahlBlaetter,fachDesStapels:fachDesStapels, blattDicke: model.blattDicke, blattAbstandOffen: model.blattAbstandOffen, blattAbstandGeschlossen: model.blattAbstandGeschlossen)
//    }
//}

//class KlappeViewModel{
//    var farbe:UIColor = .green
//    var direction:Direction
//    var hasBorder = false
//    var fachDesStapels:FachDesStapels
//
//    var klappWinkel:MutableProperty<CGFloat>
//
//    init(klappWinkel:MutableProperty<CGFloat>, direction:Direction,hasBorder:Bool = true,fachDesStapels:FachDesStapels, farbe:UIColor = .black){
//        self.direction      = direction
//        self.hasBorder      = hasBorder
//        self.fachDesStapels = fachDesStapels
//        self.klappWinkel    = klappWinkel
//        self.farbe          = farbe
//    }
//}
