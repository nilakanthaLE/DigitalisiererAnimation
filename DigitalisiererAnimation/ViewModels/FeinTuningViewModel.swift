//
//  FeinTuningViewModel.swift
//  DigitalisiererAnimation
//
//  Created by Matthias Pochmann on 20.04.18.
//  Copyright © 2018 Matthias Pochmann. All rights reserved.
//

import Foundation
import ReactiveSwift


class FineTunerModel{
    let fineTuningObjekt = mainModel.positionenUndFrames.fineTuningWerte.feinTuningFuerObjekt
    init(){
        xValue  <~ fineTuningObjekt.producer.map{ mainModel.positionenUndFrames.fineTuningWerte.getX(fuer: $0) }
        yValue  <~ fineTuningObjekt.producer.filter{$0 != nil}.map{ mainModel.positionenUndFrames.fineTuningWerte.getY(fuer: $0!) }
    }
    
    var xValue  = MutableProperty<Float?>(0)
    var yValue  = MutableProperty<Float>(0)
    
    func updateX(newValue:Float){ mainModel.positionenUndFrames.fineTuningWerte.setX(fuer: fineTuningObjekt.value ?? .EinzugOben, newValue: newValue) }
    func updateY(newValue:Float){ mainModel.positionenUndFrames.fineTuningWerte.setY(fuer: fineTuningObjekt.value ?? .EinzugOben, newValue: newValue) }
}

class FineTunerViewModel{
    let sliderSpanne:Float    = 100
    
    let sliderXValues   = MutableProperty<SliderValues?>(SliderValues(value: 0, max: 0, min: 0))
    let sliderYValues   = MutableProperty<SliderValues>(SliderValues(value: 0, max: 0, min: 0))
    let dismissVC       = MutableProperty<Void>(Void())
    let xSliderIsHidden = MutableProperty<Bool>(false)
    
    init(){
        let fineTunerModel  = FineTunerModel()
        let halbeSpanne     = sliderSpanne / 2
        
        sliderXValues   <~ fineTunerModel.xValue.producer.filter{$0 != nil}.map{SliderValues(value: $0!, max: $0! + halbeSpanne, min: $0! - halbeSpanne)}
        xSliderIsHidden <~ fineTunerModel.xValue.producer.map{$0 == nil}
        sliderYValues   <~ fineTunerModel.yValue.producer.map{SliderValues(value: $0, max: $0 + halbeSpanne, min: $0 - halbeSpanne)}
        
        sliderXValues.signal.filter{$0 != nil}.observeValues{fineTunerModel.updateX(newValue: $0!.value)}
        sliderYValues.signal.observeValues{fineTunerModel.updateY(newValue: $0.value)}
        
        newX.signal.observeValues{fineTunerModel.updateX(newValue: $0)}
        newY.signal.observeValues{fineTunerModel.updateY(newValue: $0)}
        
        dismissVC       <~ fineTunerModel.fineTuningObjekt.signal.filter{$0 == nil}.map{_ in Void()}
    }
    
    let newX        = MutableProperty<Float>(0)
    let newY        = MutableProperty<Float>(0)
}
    
struct SliderValues{
    let value:Float
    let max:Float
    let min:Float
}
