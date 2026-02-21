//
//  Fonts.swift
//  Buky
//
//  Created by Nicolas Bukstein on 28/1/26.
//

import SwiftUI

public extension Font {
    
    private static let fontName = "Quicksand"
    
    private static let boldName = "\(fontName)-Bold"
    private static let lightName = "\(fontName)-Light"
    private static let mediumName = "\(fontName)-Medium"
    private static let regularName = "\(fontName)-Regular"
    private static let semiBoldName = "\(fontName)-SemiBold"
    
    
    
    static var h2Bold: Font {
        .custom(boldName, size: 36, relativeTo: .title2)
    }
    
    static var h3Bold: Font {
        .custom(boldName, size: 20, relativeTo: .title3)
    }
    
    static var h4Bold: Font {
        .custom(boldName, size: 18, relativeTo: .title3)
    }
    
    static var h4SemiBold: Font {
        .custom(semiBoldName, size: 18, relativeTo: .title3)
    }
    
    static var h5Medium: Font {
        .custom(mediumName, size: 16, relativeTo: .subheadline)
    }
    
    static var h5SemiBold: Font {
        .custom(semiBoldName, size: 16, relativeTo: .subheadline)
    }
    
    static var h5Bold: Font {
        .custom(boldName, size: 16, relativeTo: .subheadline)
    }
    
    static var bodyRegular: Font {
        .custom(regularName, size: 14, relativeTo: .body)
    }
    
    static var bodySemiBold: Font {
        .custom(semiBoldName, size: 14, relativeTo: .body)
    }
    
    static var captionRegular: Font {
        .custom(regularName, size: 12, relativeTo: .caption)
    }
}


