//
//  PositionenUndFramesModel.swift
//  DigitalisiererAnimation
//
//  Created by Matthias Pochmann on 12.04.18.
//  Copyright © 2018 Matthias Pochmann. All rights reserved.
//

import Foundation
import ReactiveSwift

class PositionenUndFramesModel{
    let abstandYzumEingabeFach:CGFloat  = 100
    let abstandZwischenWalzen:CGFloat   = 2 //  Scanmodul und Einzug
    let abstandWalzeZuStapel:CGFloat    = 1
    
    let blattWerte                  = BlattWerte()
    let fachWerte                   = FachWerte()
    let einlagerungsFaecherwerte    = EinlagerungsFaecherWerte()
    let fineTuningWerte             = FineTuningWerte()
    let laufZeitWerte               = LaufZeitWerte()
    
    func getPapierStapelHoehe(anzahlBlaetter:Int, fachGeoeffnet:Bool)->CGFloat{
        guard anzahlBlaetter > 0 else {return 0}
        let anzahlBlaetter = CGFloat(anzahlBlaetter)
        return  anzahlBlaetter * blattWerte.blattDicke +
                anzahlBlaetter * (fachGeoeffnet ? blattWerte.blattAbstandOffen  : blattWerte.blattAbstandGeschlossen)
    }
    
    func getBeweglichesFachTopPosition(angefahrensFach:AngefahrenesFach) -> CGFloat{
        switch angefahrensFach.typ{
        
        case .Eingabe,.Initial:     return -fineTuningWerte.beweglichesFachObererEinzug + abstandYzumEingabeFach + fineTuningWerte.eingabeFachWalzePosition.y
        case .EingabeZuOben:        return -fineTuningWerte.beweglichesFachObererEinzug + abstandYzumEingabeFach + fineTuningWerte.eingabeFachWalzePosition.y
        case .ObenZuEinlagerung:    return laufZeitWerte.abstandZurWalzeInAngefahrenemEinalgerungsFach - laufZeitWerte.abstandTopZurKlappWalzeInVertBeweglFach + einlagerungsFaecherwerte.abstandY
        case .EinlagerungZuOben:    return laufZeitWerte.abstandZurWalzeInAngefahrenemEinalgerungsFach - laufZeitWerte.abstandTopZurKlappWalzeInVertBeweglFach + einlagerungsFaecherwerte.abstandY
        case .EinlagerungZuUnten:   return laufZeitWerte.abstandZurWalzeInAngefahrenemEinalgerungsFach - laufZeitWerte.abstandTopZurKlappWalzeInVertBeweglFach + einlagerungsFaecherwerte.abstandY
        case .Ausgabe:              return abstandYzumEingabeFach - fineTuningWerte.beweglichesFachUnterEinzug - laufZeitWerte.hoeheFaecherInVertBeweglFach + fineTuningWerte.eingabeFachWalzePosition.y
        }
    }
    
    func setKlappWalzeYInGesamtView(fuer position:Position){
        let abstandScanModul = position == .oben ? fineTuningWerte.abstandScanModulOben : fineTuningWerte.abstandScanModulUnten
        laufZeitWerte.abstandTopZurKlappWalzeInVertBeweglFach = abstandScanModul + laufZeitWerte.widthWalze.value + abstandZwischenWalzen + abstandWalzeZuStapel
    }
}

struct BlattWerte{
    let blattDicke:CGFloat                  = 0.5
    let blattAbstandOffen:CGFloat           = 1.5
    let blattAbstandGeschlossen:CGFloat     = 1.0
    
}

struct FachWerte{
    //(Ablage)Faecher
    let klappenHoehe:CGFloat                = 3.0
    let freiraumLeeresAblagefach:CGFloat    = 3.0
    let geoffnetesAblageFachHoehe:CGFloat   = 100.0
}
class LaufZeitWerte{
    
    
    var abstandTopZurKlappWalzeInVertBeweglFach:CGFloat         = 0
    var hoeheFaecherInVertBeweglFach:CGFloat                    = 0
    var abstandZurWalzeInAngefahrenemEinalgerungsFach:CGFloat   = 0
    var blattStueckEinzugWidth:CGFloat                          = 0
    var blattWidth:CGFloat                                      = 0
    var blattStueckScannerWidth:CGFloat                         = 0
    
    let widthWalze                                              = MutableProperty<CGFloat>(10)
    func setWidthWalze(width:CGFloat){ if width != widthWalze.value{ widthWalze.value = width } }
    
}

class FineTuningWerte{
    var feinTuningFuerObjekt                                    = MutableProperty<ObjektFuerFeinTuning?>(nil)
    var fineTuningUpdate = MutableProperty<Void>(Void())
    
    var unteresFachWalzePosition:CGPoint{
        get { return PosFeinTuning.get()?.unteresFachWalzePosition as? CGPoint ?? CGPoint.zero }
        set { PosFeinTuning.get()?.unteresFachWalzePosition = newValue as NSObject }
    }
    var oberesFachWalzePosition:CGPoint{
        get { return PosFeinTuning.get()?.oberesFachwalzePosition as? CGPoint ?? CGPoint.zero }
        set { PosFeinTuning.get()?.oberesFachwalzePosition = newValue as NSObject }
    }
    var eingabeFachWalzePosition:CGPoint{
        get { return PosFeinTuning.get()?.eingabeFachWalzePosition as? CGPoint ?? CGPoint.zero }
        set { PosFeinTuning.get()?.eingabeFachWalzePosition = newValue as NSObject }
    }
    
    var einlagerungsFachWalzePosition:CGPoint{
        get { return PosFeinTuning.get()?.ablageeFachWalzePosition as? CGPoint ?? CGPoint.zero }
        set { PosFeinTuning.get()?.ablageeFachWalzePosition = newValue as NSObject }
    }
    var abstandScanModulOben:CGFloat{
        get { return CGFloat(PosFeinTuning.get()?.abstandScannerOben ?? 0.0)}
        set { PosFeinTuning.get()?.abstandScannerOben = Float(newValue) }
    }
    var abstandScanModulUnten:CGFloat{
        get { return CGFloat(PosFeinTuning.get()?.abstandScannerUnten ?? 0.0)}
        set { PosFeinTuning.get()?.abstandScannerUnten = Float(newValue) }
    }
    var beweglichesFachObererEinzug:CGFloat{
        get { return CGFloat(PosFeinTuning.get()?.einzugFach1 ?? 0.0)}
        set { PosFeinTuning.get()?.einzugFach1 = Float(newValue) }
    }
    var beweglichesFachUnterEinzug:CGFloat{
        get { return CGFloat(PosFeinTuning.get()?.einzugFach2 ?? 0.0)}
        set { PosFeinTuning.get()?.einzugFach2 = Float(newValue) }
    }
    
    func getAbstandScanModul(fuer position:Position) -> CGFloat { return position == .oben ? abstandScanModulOben : abstandScanModulUnten  }
    
    func getX(fuer objekt:ObjektFuerFeinTuning?) -> Float?{
        guard let objekt = objekt else {return nil}
        switch objekt{
            
        case .WalzeEingabeFach:             return Float(eingabeFachWalzePosition.x)
        case .WalzeLinksFachUnten:          return Float(unteresFachWalzePosition.x)
        case .WalzeRechtsFachOben:          return Float(oberesFachWalzePosition.x)
        case .WalzenEinlagerungsFaecher:    return Float(einlagerungsFachWalzePosition.x)
        case .ScanModulOben:                return nil
        case .ScanModulUnten:               return nil
        case .EinzugOben:                   return nil
        case .EinzugUnten:                  return nil
        }
    }
    func getY(fuer objekt:ObjektFuerFeinTuning) -> Float{
        switch objekt{
            
        case .WalzeEingabeFach:             return Float(eingabeFachWalzePosition.y)
        case .WalzeLinksFachUnten:          return Float(unteresFachWalzePosition.y)
        case .WalzeRechtsFachOben:          return Float(oberesFachWalzePosition.y)
        case .WalzenEinlagerungsFaecher:    return Float(einlagerungsFachWalzePosition.y)
        case .ScanModulOben:                return Float(abstandScanModulOben)
        case .ScanModulUnten:               return Float(abstandScanModulUnten)
        case .EinzugOben:                   return Float(beweglichesFachObererEinzug)
        case .EinzugUnten:                  return Float(beweglichesFachUnterEinzug)
        }
    }
    func getWalzenPos(fuer fachTyp:FachTyp) -> CGPoint{
        switch fachTyp{
        case .eingabeFach:                  return eingabeFachWalzePosition
        case .beweglichesFachOben:          return oberesFachWalzePosition
        case .beweglichesFachUnten:         return unteresFachWalzePosition
        case .einlagerungsFach:             return einlagerungsFachWalzePosition
        }
    }
    func setX(fuer objekt:ObjektFuerFeinTuning,newValue:Float){
        switch objekt{
            
        case .WalzeEingabeFach:             eingabeFachWalzePosition.x      = CGFloat(newValue)
        case .WalzeLinksFachUnten:          unteresFachWalzePosition.x      = CGFloat(newValue)
        case .WalzeRechtsFachOben:          oberesFachWalzePosition.x       = CGFloat(newValue)
        case .WalzenEinlagerungsFaecher:    einlagerungsFachWalzePosition.x = CGFloat(newValue)
        case .ScanModulOben:                break
        case .ScanModulUnten:               break
        case .EinzugOben:                   break
        case .EinzugUnten:                  break
        }
        fineTuningUpdate.value = ()
    }
    func setY(fuer objekt:ObjektFuerFeinTuning,newValue:Float){
        switch objekt{
        case .WalzeEingabeFach:             eingabeFachWalzePosition.y      = CGFloat(newValue)
        case .WalzeLinksFachUnten:          unteresFachWalzePosition.y      = CGFloat(newValue)
        case .WalzeRechtsFachOben:          oberesFachWalzePosition.y       = CGFloat(newValue)
        case .WalzenEinlagerungsFaecher:    einlagerungsFachWalzePosition.y =  CGFloat(newValue)
        case .ScanModulOben:                abstandScanModulOben            =  CGFloat(newValue)
        case .ScanModulUnten:               abstandScanModulUnten           =  CGFloat(newValue)
        case .EinzugOben:                   beweglichesFachObererEinzug     =  CGFloat(newValue)
        case .EinzugUnten:                  beweglichesFachUnterEinzug      =  CGFloat(newValue)
        }
        fineTuningUpdate.value = ()
    }
    
}


