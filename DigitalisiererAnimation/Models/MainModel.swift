//
//  MainModel.swift
//  DigitalisiererAnimation
//
//  Created by Matthias Pochmann on 12.04.18.
//  Copyright © 2018 Matthias Pochmann. All rights reserved.
//

import Foundation
import UIKit

let anzahlEinlagerungsFaecher                       = 8
var mainModel:MainModel = MainModel()
let gehaeuseFarbe                                   = UIColor.init(red: 225/256, green: 166/256, blue: 82/256, alpha: 0.5)


class MainModel{
    //Konstanten
    let kapazitaetEinlagerungsFaecher                   = 25
    let isEditModus                                     = true

    //init
    let positionenUndFrames:PositionenUndFramesModel
    let geraetInAktion:GeraetInAktionModel
    let animationen:AnimationenModel
    init(){
        print("init mainModel")
        positionenUndFrames = PositionenUndFramesModel()
        geraetInAktion      = GeraetInAktionModel()
        animationen         = AnimationenModel(anzahlEinlagerungsFaecher: anzahlEinlagerungsFaecher, geraetInAktion: geraetInAktion)
    }
}
