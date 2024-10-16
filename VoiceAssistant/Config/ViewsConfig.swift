//
//  File.swift
//  VoiceAssistant
//
//  Created by Osama Hasan on 17/03/2024.
//

import Foundation
import UIKit

// MARK: - Classes
public class GradientSpecs: NSObject
{
    public var colors: [UIColor]
    public var locations: [CGFloat]
    public var start: CGPoint
    public var end: CGPoint
    public var viewBackgroundColor: UIColor?
    
    public init(colors: [UIColor], locations: [CGFloat], start: CGPoint, end: CGPoint , viewBackgroundColor:UIColor? = nil)
    {
        self.colors = colors
        self.locations = locations
        self.start = start
        self.end = end
        self.viewBackgroundColor = viewBackgroundColor
    }
}


public class TextStyle {
    
    public var font:UIFont?
    public var color:  UIColor = .black
    public init(){}
    
    public init(font:UIFont? = nil,color:UIColor = .black) {
        self.font = font
        self.color = color
    }

}

public class ViewStyle{
    public var corners:CACornerMask = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
    public var radius:CGFloat = 25
    public var backgroundColor : UIColor = .white
    public var tintColor:UIColor = .clear
    public var borderColor:UIColor = .clear
    public var borderWidth:CGFloat = 0.0
    
    public init(){}
    
    public init(radius: CGFloat = 0, backgroundColor: UIColor = .black, tintColor: UIColor = .clear,corners:CACornerMask = [.layerMinXMinYCorner, .layerMaxXMinYCorner],borderColor:UIColor = .clear,borderWidth:CGFloat = 0.0) {
        self.radius = radius
        self.backgroundColor = backgroundColor
        self.tintColor = tintColor
        self.corners = corners
        self.borderColor = borderColor
        self.borderWidth = borderWidth
    }
}


public class VoiceAssistantViewTheme{
    public var viewStyle = ViewStyle()
    public var image:UIImage?
    public var waveColors:[UIColor] = [.black]
    public init(){}
}


public class UserChatViewTheme{
    public var viewStyle = ViewStyle()
    public var textStyle = TextStyle()
    public init(){}

}

public class BotChatViewTheme{
    public var viewStyle = ViewStyle()
    public var defualtTextStyle = TextStyle()
    public var scallTextStyle = TextStyle()
    public init(){}

}


public class SheetTheme {
    public init(){}

    public var viewStyle = ViewStyle()
    
}


public class ChipViewTheme {
    public init(){}

    public var viewStyle = ViewStyle()
    public var textStyle = TextStyle()

}


public class ImageViewTheme {
    public init(){}

    public var viewStyle = ViewStyle()
    public var textStyle = TextStyle()

}

public class SuggestionsViewTheme {
    public init(){}

    public var viewStyle = ViewStyle()
    public var textStyle = TextStyle()

}

public class NavigationBarViewTheme {
    public init(){}

    public var textStyle = TextStyle()
    public var backImage : UIImage?
    public var title : String?
    public var backButtonStyle = ViewStyle()
    

}
