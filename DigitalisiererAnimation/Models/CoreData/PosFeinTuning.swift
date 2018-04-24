//
//  PosFeinTuning.swift
//  DigitalisiererAnimation
//
//  Created by Matthias Pochmann on 15.03.18.
//  Copyright © 2018 Matthias Pochmann. All rights reserved.
//

import Foundation
import CoreData

extension PosFeinTuning{
    class func get() -> PosFeinTuning?{
        let request = NSFetchRequest<PosFeinTuning>.init(entityName: "PosFeinTuning")
        if let posFeinTuning = (try? managedContext.fetch(request))?.first{
            return posFeinTuning
        }
        let posFeinTuning = NSEntityDescription.insertNewObject(forEntityName: "PosFeinTuning", into: managedContext) as? PosFeinTuning
        return posFeinTuning
    }
}
