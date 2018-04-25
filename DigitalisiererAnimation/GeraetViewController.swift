//
//  viewController3.swift
//  DigitalisiererAnimation
//
//  Created by Matthias Pochmann on 12.03.18.
//  Copyright © 2018 Matthias Pochmann. All rights reserved.
//

import UIKit
import ReactiveSwift

//TestZwecke
let angefahrenesFachArray = [BlattBewegungsTyp.Ausgabe,
                             BlattBewegungsTyp.Eingabe,
                             BlattBewegungsTyp.ObenZuEinlagerung(fachID: 0),
                             BlattBewegungsTyp.EinlagerungZuUnten(fachID: 0),
                             BlattBewegungsTyp.EinlagerungZuOben(fachID: 1),
                             BlattBewegungsTyp.EinlagerungZuUnten(fachID: 1),
                             BlattBewegungsTyp.EinlagerungZuOben(fachID: 2),
                             BlattBewegungsTyp.EinlagerungZuUnten(fachID: 2),
                             BlattBewegungsTyp.EinlagerungZuOben(fachID: 3),
                             BlattBewegungsTyp.EinlagerungZuUnten(fachID: 3),
                             BlattBewegungsTyp.EinlagerungZuOben(fachID: 4),
                             BlattBewegungsTyp.EinlagerungZuUnten(fachID: 4),
                             BlattBewegungsTyp.EinlagerungZuOben(fachID: 5),
                             BlattBewegungsTyp.EinlagerungZuUnten(fachID: 5),
                             BlattBewegungsTyp.EinlagerungZuOben(fachID: 6),
                             BlattBewegungsTyp.EinlagerungZuUnten(fachID: 6),
                             BlattBewegungsTyp.EinlagerungZuOben(fachID: 7),
                             BlattBewegungsTyp.EinlagerungZuUnten(fachID: 7)
]

class GeraetViewController:UIViewController{
    //IBOutlets
    @IBOutlet weak var geraet: Geraet!{didSet{ geraet.viewModel = GeraetViewModel(geraetModel: mainModel.geraetInAktion.geraetModel) } }
    @IBOutlet weak var fachPositionAnpassen: UIBarButtonItem!

    //IBActions
    @IBAction func eingabe(_ sender: UIBarButtonItem) { performSegue(withIdentifier: "showDocAuswahl", sender: DokumentenAuswahlViewTyp.Eingabe) }
    @IBAction func ausgabe(_ sender: UIBarButtonItem) { performSegue(withIdentifier: "showDocAuswahl", sender: DokumentenAuswahlViewTyp.Herausfinden) }
    @IBAction func fachPositionAnpassenAction(_ sender: UIBarButtonItem) { }
    @IBAction func stepperValueChanged(_ sender: UIStepper) {
        mainModel.animationen.geraetAnimationen.startAnimation(blattBewegungsTyp: angefahrenesFachArray[Int(sender.value)])
        sender.maximumValue = Double(angefahrenesFachArray.count - 1)
        sender.minimumValue = 0 //Nicht - zu Beginn drücken!
    }
    
    //segues
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        (segue.destination.contentViewController.contentViewController as? FineTunerVC)?.viewModel      = FineTunerViewModel()
        guard let sender =  sender as? DokumentenAuswahlViewTyp else {return}
        (segue.destination.contentViewController as? AusgabeUndEingabeVC)?.viewModel                    = DokumentenAuswahlViewModel(dokumentenAuswahlModel: DokumentenAuswahlModel(typ: sender))
    }
    
    //VC LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        mainModel.positionenUndFrames.fineTuningWerte.feinTuningFuerObjekt.signal.filter{$0 != nil}.observe {[weak self] _ in self?.performSegue(withIdentifier: "showFineTuner", sender: nil) }
        _ = Dokument.createInitSet()
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        mainModel.geraetInAktion.angefahrenesFach.value = AngefahrenesFach(typ: .Initial)
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isToolbarHidden = false
    }
}


class MyCollectionViewCell:UICollectionViewCell{
    override var isSelected: Bool{
        didSet{
            if self.isSelected
            {
                //This block will be executed whenever the cell’s selection state is set to true (i.e For the selected cell)
                self.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
                
                layer.borderColor = UIColor.green.cgColor
                layer.borderWidth = 5.0
            }
            else
            {
                //This block will be executed whenever the cell’s selection state is set to false (i.e For the rest of the cells)
                self.transform = CGAffineTransform.identity
                layer.borderColor = UIColor.green.cgColor
                layer.borderWidth = 0.0
                
            }
        }
    }
    required init?(coder aDecoder: NSCoder) {
        dokumentView = DokumentView(frame: CGRect.zero)
        super.init(coder: aDecoder)
        addSubview(dokumentView)
        dokumentView.translatesAutoresizingMaskIntoConstraints = false
        dokumentView.heightAnchor.constraint(equalTo: heightAnchor).isActive    = true
        dokumentView.leftAnchor.constraint(equalTo: leftAnchor).isActive    = true
        dokumentView.topAnchor.constraint(equalTo: topAnchor).isActive    = true
        dokumentView.heightAnchor.constraint(equalTo: dokumentView.widthAnchor, multiplier: sqrt(2)).isActive    = true
        dokumentView.backgroundColor = .brown
        
    }
    var dokumentView:DokumentView
}



extension UIViewController{
    var contentViewController:UIViewController {
        if let navCon = self as? UINavigationController{ return navCon.visibleViewController ?? navCon
        }else{ return self  }
    }
}









//Tests

class TestVC:UIViewController{
    override func viewDidLoad() {
        
    }
    @IBOutlet weak var stack: UIStackView!
    
    @IBOutlet weak var hoeheConstraint: NSLayoutConstraint!

    @IBOutlet weak var fachMitKlape2: FachMitKlappe!{
        didSet{
//            fachMitKlape2.viewModel = FachMitKlappeViewModel(rechteWalzeIsSpinning: MutableProperty(false), linkeWalzeIsSpinning: MutableProperty(false), klappeIsOpen: MutableProperty(false), anzahlBlaetter: 0, klappeDirection: .left, fachDesStapels: FachDesStapels(stapel: .beweglichesFachOben, idFallsEinlagerungsfach: nil))
        }
    }
    @IBOutlet weak var fachMitKlape: FachMitKlappe!{
        didSet{
//            fachMitKlape.viewModel = FachMitKlappeViewModel(rechteWalzeIsSpinning: MutableProperty(false), linkeWalzeIsSpinning: MutableProperty(false), klappeIsOpen: klappeIsOpen, anzahlBlaetter: 7, klappeDirection: .left, fachDesStapels: FachDesStapels(stapel: .eingabeFach, idFallsEinlagerungsfach: nil))
        }
    }
    var klappeIsOpen = MutableProperty(false)
    
    @IBAction func erscheinenRechtsAction(_ sender: Any) {
        
//        stack.arrangedSubviews.filter{$0 == fachMitKlape}.first?.frame.size.height  =  fachMitKlape.frame.size.height  == 5 ? 200 : 5
        
        hoeheConstraint.constant = 200 //hoeheConstraint.constant == 5 ? 200 : 5
        
        klappeIsOpen.value = true
    }
}
