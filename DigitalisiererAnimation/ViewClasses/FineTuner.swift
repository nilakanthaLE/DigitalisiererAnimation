//
//  FineTuner.swift
//  DigitalisiererAnimation
//
//  Created by Matthias Pochmann on 20.04.18.
//  Copyright © 2018 Matthias Pochmann. All rights reserved.
//

import Foundation
import UIKit
import ReactiveSwift

class FineTunerVC:UIViewController{
    var viewModel:FineTunerViewModel!{ didSet{ viewModel.dismissVC.signal.observeValues {[weak self] _ in self?.dismiss(animated: true, completion: nil) } } }
    
    @IBOutlet weak var xSlider: UISlider!{
        didSet{
            xSlider.reactive.isHidden       <~ viewModel.xSliderIsHidden.producer
            xSlider.reactive.value          <~ viewModel.sliderXValues.producer.filter{$0 != nil}.map{$0!.value}
            xSlider.reactive.maximumValue   <~ viewModel.sliderXValues.producer.filter{$0 != nil}.map{$0!.max}
            xSlider.reactive.minimumValue   <~ viewModel.sliderXValues.producer.filter{$0 != nil}.map{$0!.min}
            viewModel.newX                  <~ xSlider.reactive.values
        }
    }
    @IBOutlet weak var ySlider: VerticalSlider!{
        didSet{
            ySlider.reactive.value          <~ viewModel.sliderYValues.producer.map{$0.value}
            ySlider.reactive.maximumValue   <~ viewModel.sliderYValues.producer.map{$0.max}
            ySlider.reactive.minimumValue   <~ viewModel.sliderYValues.producer.map{$0.min}
            viewModel.newY                  <~ ySlider.reactive.values
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super .viewWillAppear(animated)
        ySlider.frame       = CGRect(x: view.frame.size.width - 30, y: 0, width: 30, height: view.frame.size.height)
    }
}

@IBDesignable class VerticalSlider:UISlider{
    override init(frame: CGRect) {
        super.init(frame: frame)
        transform = CGAffineTransform(rotationAngle: CGFloat.pi / 2)
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder:aDecoder)
        transform = CGAffineTransform(rotationAngle: CGFloat.pi / 2)
    }
}
