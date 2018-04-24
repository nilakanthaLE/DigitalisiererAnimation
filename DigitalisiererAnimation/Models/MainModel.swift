//
//  MainModel.swift
//  DigitalisiererAnimation
//
//  Created by Matthias Pochmann on 12.04.18.
//  Copyright © 2018 Matthias Pochmann. All rights reserved.
//

import Foundation

let anzahlEinlagerungsFaecher                       = 8
var mainModel:MainModel = MainModel()



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
