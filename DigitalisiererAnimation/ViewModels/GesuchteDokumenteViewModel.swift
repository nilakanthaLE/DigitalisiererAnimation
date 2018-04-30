//
//  GesuchteDokumenteViewModel.swift
//  DigitalisiererAnimation
//
//  Created by Matthias Pochmann on 27.04.18.
//  Copyright © 2018 Matthias Pochmann. All rights reserved.
//

import Foundation
import UIKit
import ReactiveSwift
//MARK: DokumentView

class DokumenteFindenUndScannenViewModel{
    let gesuchteDokumenteViewModel:GesuchteDokumenteViewModel
    let scanAnzeigeViewModel:ScanAnzeigeDokumentViewModel
    init(model:DokumenteFindenUndScannenModel){
        gesuchteDokumenteViewModel  = GesuchteDokumenteViewModel(model: model.gesuchteDokumenteModel)
        scanAnzeigeViewModel        = ScanAnzeigeDokumentViewModel(scanAnzeigeDokumentModel: model.scanAnzeigeModel)
    }
}

class GesuchteDokumenteViewModel{
    let dokumentenAnzeigeMatrix = MutableProperty<[[ScanAnzeigeDokumentViewModel]]>([[ScanAnzeigeDokumentViewModel]]())
    init(model:GesuchteDokumenteModel){
        dokumentenAnzeigeMatrix <~ model.gesuchteDokumenteModels.map{GesuchteDokumenteViewModel.getMatrix(for: $0)}
    }
    static func getMatrix(for gesuchteDokumenteModels:[ScanAnzeigeDokumentModel]) -> [[ScanAnzeigeDokumentViewModel]]{
        guard gesuchteDokumenteModels.count > 0 else {return [[ScanAnzeigeDokumentViewModel]]()}
        var viewModels  = gesuchteDokumenteModels.map{ScanAnzeigeDokumentViewModel(scanAnzeigeDokumentModel: $0,isGesuchteDokumenteView: true)}
        let spalten:Int = Int(sqrt(Double(viewModels.count))) + 1
        let zeilen:Int  =  spalten * (spalten - 1) - viewModels.count < 0 ? spalten : spalten - 1
        
        var ergebnis = [[ScanAnzeigeDokumentViewModel]]()
        for _ in 0 ..< zeilen{
            let zeile = viewModels.suffix(spalten)
            viewModels.removeLast(zeile.count)
            ergebnis.append(Array(zeile))
        }
        print(ergebnis.map{$0.map{$0.buchstabeUndZahl.value}})
        return ergebnis
        
    }
}

class ScanAnzeigeDokumentViewModel{
    //für View relevant
    let buchstabeUndZahl                                = MutableProperty<BuchstabeUndZahl?>(nil)
    let scanGestartet                                   = MutableProperty(Void())
    let isHidden                                        = MutableProperty(false)
    let matching                                        = MutableProperty(Matching.none)
    
    let isGesuchteDokumenteView:Bool
    var scanBeendet:()->Void
    init(scanAnzeigeDokumentModel:ScanAnzeigeDokumentModel, isGesuchteDokumenteView:Bool = false){
        scanBeendet         = {
            print("scanBeendet")
            scanAnzeigeDokumentModel.scanBeendet.value = ()
            
        }
        self.isGesuchteDokumenteView = isGesuchteDokumenteView
        buchstabeUndZahl    <~ scanAnzeigeDokumentModel.buchstabeUndZahl.producer
        scanGestartet       <~ scanAnzeigeDokumentModel.scanGestartet.producer
        isHidden            <~ scanAnzeigeDokumentModel.isHidden.producer
        matching            <~ scanAnzeigeDokumentModel.matching.producer
    }
    
    func getViewModelForBackGround() -> BackgroundViewModel { return BackgroundViewModel(matching: matching,isGesuchteDokumenteView:isGesuchteDokumenteView) }
}


//BackGroundView (für DokumentView)
class BackgroundViewModel{
    var matching = MutableProperty<Matching>(.none)
    let isGesuchteDokumenteView:Bool
    init(matching: MutableProperty<Matching>, isGesuchteDokumenteView:Bool = false){
        self.isGesuchteDokumenteView = isGesuchteDokumenteView
        self.matching <~ matching.producer
    }
}
