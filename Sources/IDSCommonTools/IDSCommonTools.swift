//
//  IDSCommonTools.swift
//
//
//  Created by AKorotkov on 29.01.2024.
//

import Foundation

public func IDSCreateUniqueID() -> String {
    let uuid: CFUUID = CFUUIDCreate(nil)
    let cfStr: CFString = CFUUIDCreateString(nil, uuid)
    
    let swiftString: String = cfStr as String
    return swiftString
}
