//
//  ConversationModel.swift
//  Voice Assistant
//
//  Created by Osama Hasan on 15/01/2024.
//

import Foundation
import UIKit
import CoreLocation

enum ConversationParty
{
    case user
    case bot
}

enum DialogCardPresentation: String
{
    case carousel = "carousel"
    case menu = "menu"
    case vmnue = "vmenu"
}

class ConversationDialog
{

    private(set) var party: ConversationParty

    private(set) var isTyping = false
    init(by party: ConversationParty, time: Date? = nil, isTyping:Bool = false)
    {
        self.party = party
        self.timestamp = time
        self.isTyping = isTyping
    }

    var hasMessage: Bool
    {
        let message = self.message ?? ""
        return message.isEmpty == false
    }

    var hasBotMessage: Bool
    {
        return self.party == .bot && self.hasMessage
    }

    var message: String?
    var SSML:String?
    var attributedMessage: NSAttributedString?
    var alignment:NSTextAlignment?
    var link:URL?
    var timestamp: Date?
    var timestampString: String?
    //
    var frame:CGRect?
    var langCode:String?
    var enableTTS:Bool = true // added for natHealth
    var requestLocation:Bool = false
    //
    var choices: [DialogChoice]?
    var cards: DialogCards?
    var media: DialogMedia?
    var map: DialogMap?
    var guide:DialogGuide?
    var attachment:AttachmentCard?
    var content_type: String?
    var inAnimations:[CABasicAnimation]?
    var outAnimations:[CABasicAnimation]?
    var voiceUrl:String?
}

class DialogCards
{

    var presentation: DialogCardPresentation
    var items = [DialogCard]()

    init(presentation: DialogCardPresentation = .carousel)
    {
        self.presentation = presentation
    }
}
class  AttachmentCard
{
    
    var link:String?
    
    init(link:String)
    {
        self.link = link
    }
}

enum MediaType
{

    case Photo
    case Audio
    case Video
    
    static func type(for string: String?) -> MediaType?
    {

        if let str = string
        {

            switch str.lowercased()
            {
            case "photo":
                return .Photo
            case "audio":
                return .Audio
            case "video":
                return .Video
            default:
                return nil
            }
        }

        return nil
    }
}

class DialogMap
{

    var snapshot: UIImage?
    var address: String?
    var distance: String?
    var coordinates: CLLocationCoordinate2D

    init(coordinate: CLLocationCoordinate2D, address: String, distance: String)
    {
        self.coordinates = coordinate
        self.address = address
        self.distance = distance
    }

    static func parse(_ object: [String: AnyObject]) -> DialogMap?
    {
        return nil
    }
}

class DialogMedia
{

    var image: UIImage?
    var localUrl: URL?

    var type: MediaType
    var url: String?

    init(type: MediaType)
    {
        self.type = type
    }

    static func parse(_ object: [String: AnyObject]) -> DialogMedia?
    {

        if let _media = object["media"] as? [String: AnyObject],
           let type = MediaType.type(for: _media["type"] as? String)
        {

            let media = DialogMedia(type: type)

            if let url = _media["url"] as? String
            {
                media.url = url.trimmingCharacters(in: .whitespacesAndNewlines)
            }

            return media
        }

        return nil
    }
}

struct DialogCardButton
{

    var title: String
    var url: String?
    var payload: String?
    var type:AttachmentElementButtonType = .postback

    init(title: String, payload: String? , type:AttachmentElementButtonType)
    {
        self.title = title
        self.payload = payload
        self.type = type
    }

    init(title: String, url: String?)
    {
        self.title = title
        self.url = url
    }
}
enum CardType{
   case square
   case horizontal
    
    var imageSize:(width:CGFloat, hight:CGFloat) {
        switch self {
        case .square:
            return (180,180)
        case .horizontal:
            return (245,130)
       
        }
    }
}

class DialogCard
{

    var title: String
    var subtitle: String?
    var imageUrl: String?
    var image: UIImage?
    var type:CardType = .horizontal // must changed depend payload content , waiting for nour response
    var buttons = [DialogCardButton]()

    init(title: String)
    {
        self.title = title
    }
}

enum DialogChoiceAction: String
{
    case date = "DATE"
    case time = "TIME"
    case location = "LOCATION"
    case distance = "LOCATION_RADIUS"
    case dateRange = "DATE_RANGE"
    case calendar = "CALENDAR"
    case camera = "CAMERA"
    case gallery = "GALLERY"
    case menu = "MENU"
    case QRCode = "QR_CODE"
    

}

class DialogChoice
{

    var title: String
    var action: DialogChoiceAction?

    init(title: String)
    {
        self.title = title
    }
}

class DialogGuide{
    var title:String?
    var questions:[String]?
}
