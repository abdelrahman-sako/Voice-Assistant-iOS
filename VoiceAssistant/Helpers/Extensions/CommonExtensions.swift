//
//  Extensions.swift
//  Visit Jordan Bot
//
//  Created by AhmeDroid on 9/21/16.
//  Copyright © 2016 Imagine Technologies. All rights reserved.
//

import UIKit
import QuartzCore
import ImageIO
import NaturalLanguage

extension UIView
{

    func applyGradient(colours: [UIColor], locations: [NSNumber]?)
    {
        let gradient: CAGradientLayer = CAGradientLayer()
        gradient.frame = self.bounds
        gradient.colors = colours.map
        {
            $0.cgColor
        }
        gradient.locations = locations
        self.layer.insertSublayer(gradient, at: 0)
    }
    
    func applyDynamicGradient(colors: [UIColor], locations: [NSNumber]? ,startPoint:CGPoint = CGPoint(x: 0, y: 0) ,endPoint:CGPoint = CGPoint(x: 1, y: 0) )
    {
        let cgColors = colors.map({$0.cgColor})
        let gradientView = DynamicGradientView(colors: cgColors, frame: self.bounds ,locations:locations ,startPoint: startPoint ,endPoint:  endPoint)
        self.insertSubview(gradientView, at: 0)
    }
    
    

    class func loadFromNibNamedFromDefaultBundle(_ nibNamed: String) -> UIView?
    {
        let bundle = Bundle(for: VoiceAssistantViewController.self)
        return UINib(nibName: nibNamed, bundle: bundle).instantiate(withOwner: nil, options: nil)[0] as? UIView
    }

    func applyDarkShadow(opacity: Float, offsetY: CGFloat, radius: CGFloat = 1.0) -> Void
    {

        self.applyDarkShadow(opacity: opacity, offset: CGSize(width: 0, height: offsetY), radius: radius)
    }

    func applyDarkShadow(opacity: Float, offset: CGSize, radius: CGFloat = 1.0) -> Void
    {

        self.applyShadow(color: UIColor.black, opacity: opacity, offset: offset, radius: radius)
    }

    func applyShadow(color: UIColor, opacity: Float, offsetY: CGFloat, radius: CGFloat = 1.0) -> Void
    {

        self.applyShadow(color: color, opacity: opacity, offset: CGSize(width: 0, height: offsetY), radius: radius)
    }

    func applyShadow(color: UIColor, opacity: Float, offset: CGSize, radius: CGFloat = 1.0) -> Void
    {

        self.layer.shadowOpacity = opacity
        self.layer.shadowRadius = radius
        self.layer.shadowOffset = offset
        self.layer.shadowColor = color.cgColor
    }
    
    func applySemanticAccordingToBotLang() {
        let currentLang =   SharedPreference.shared.botLangCode 
        if currentLang == .ar {
            self.semanticContentAttribute = .forceRightToLeft
        }else{
            self.semanticContentAttribute = .forceLeftToRight
        }
    }
    
    func applyReversedSemanticAccordingToBotLang() {
        let currentLang =   SharedPreference.shared.botLangCode
        if currentLang == .ar {
           self.semanticContentAttribute = .forceLeftToRight
        }else{
             self.semanticContentAttribute = .forceRightToLeft
        }
    }
    func applyHierarchicalSemantics(flipImage:Bool = true) {
        self.applySemanticAccordingToBotLang()
        for subview in self.subviews {
            if subview.semanticContentAttribute == .unspecified {
                subview.applyHierarchicalSemantics(flipImage:flipImage)
            }
            if let textFiled = subview as? UITextField {
                if textFiled.textAlignment == .natural {
                    textFiled.applyAlignmentAccordingToOnboardingLang()
                }
            } else if let label = subview as? UILabel {
                if label.textAlignment == .natural {
                    label.applyAlignmentAccordingToOnboardingLang()
                }
            }else if flipImage, let imageView = subview as? UIImageView {
                imageView.transform = CGAffineTransform(scaleX: SharedPreference.shared.botLangCode == .ar ? -1 : 1, y: 1)
            }
        }
    }
    
    func shake()  {
        let animation = CABasicAnimation(keyPath: "position")
        animation.duration = 0.07
        animation.repeatCount = 4
        animation.autoreverses = true
        animation.fromValue = NSValue(cgPoint: CGPoint(x: self.center.x - 10, y: self.center.y))
        animation.toValue = NSValue(cgPoint: CGPoint(x: self.center.x + 10, y: self.center.y))
        self.layer.add(animation, forKey: "position")
    }
    func roundCorners(corners: UIRectCorner, radius: CGFloat) {
        let maskPath = UIBezierPath(
            roundedRect: bounds,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius))

        let shape = CAShapeLayer()
        shape.path = maskPath.cgPath
        layer.mask = shape
    }
    
    func roundCornersByFrame(corners: UIRectCorner, radius: CGFloat) {
        let maskPath = UIBezierPath(
            roundedRect: frame,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius))

        let shape = CAShapeLayer()
        shape.path = maskPath.cgPath
        layer.mask = shape
    }
}
extension UITextField {
    func applyAlignmentAccordingToOnboardingLang() {
        let currentLang =   SharedPreference.shared.botLangCode
        if currentLang == .ar {
            self.textAlignment = .right
        }else{
            self.textAlignment = .left
        }
    }
}
extension UILabel {
    func applyAlignmentAccordingToOnboardingLang() {
        let currentLang =   SharedPreference.shared.botLangCode
        if currentLang == .ar {
            self.textAlignment = .right
        }else{
            self.textAlignment = .left
        }
    }
}

extension CALayer
{
    var borderUIColor: UIColor
    {
        set
        {
            self.borderColor = newValue.cgColor
        }

        get
        {
            return UIColor(cgColor: self.borderColor!)
        }
    }
    var shadowUIColor: UIColor
    {
        set
        {
            self.shadowColor = newValue.cgColor
        }

        get
        {
            return UIColor(cgColor: self.shadowColor!)
        }
    }
}

extension Date
{
    func previousYaers(_ day: Int = -1) -> Date
    {
        return Calendar.current.date(byAdding: .year, value: day, to: self)!
    }

}

let oneYearLater = Date().previousYaers(-1)

extension String
{

    func isvalidinput(vaalidation: String) -> Bool
    {
        do
        {
            let regex = try NSRegularExpression(pattern: vaalidation, options: .caseInsensitive)
            return regex.firstMatch(in: self, options: NSRegularExpression.MatchingOptions(rawValue: 0), range: NSMakeRange(0, self.count)) != nil
        } catch
        {
            return false
        }
    }
    func verifyUrl() -> Bool {
        if let url = URL(string: self) {
            // check if your application can open the NSURL instance
            return UIApplication.shared.canOpenURL(url)
        }
        return false
    }
    
    func height(constraintedWidth width: CGFloat, font: UIFont) -> CGFloat {
        let label =  UILabel(frame: CGRect(x: 0, y: 0, width: width - 20, height: .greatestFiniteMagnitude))
        label.numberOfLines = 0

        label.text = self
        label.font = font
        label.sizeToFit()
        return label.frame.height
//        let textView =  UITextView(frame: CGRect(x: 0, y: 0, width: width, height: 40))
//        textView.font = font
//        textView.text = self
//        let layoutManeger:NSLayoutManager = textView.layoutManager
//        let numberOfGlyphs = layoutManeger.numberOfGlyphs
//        var numberOfLines = 0
//        var index = 0
//        var lineRange:NSRange = NSRange()
//        while (index < numberOfGlyphs) {
//            layoutManeger.lineFragmentRect(forGlyphAt: index, effectiveRange: &lineRange)
//            index = NSMaxRange(lineRange);
//            numberOfLines = numberOfLines + 1
//        }
//        print(textView.contentSize.height)
//        return ((textView.font?.lineHeight)! * CGFloat(numberOfLines))
    }
    
    func size(maxWidth:CGFloat ,font: UIFont?) -> CGSize {
        let label =  UILabel(frame: CGRect(x: 0.0, y: 0.0, width:  .greatestFiniteMagnitude, height: .greatestFiniteMagnitude))
        label.translatesAutoresizingMaskIntoConstraints = false
        label.widthAnchor.constraint(lessThanOrEqualToConstant: 300).isActive = true
        label.frame.origin = CGPoint(x: 0, y: 0)
        label.heightAnchor.constraint(greaterThanOrEqualToConstant: 40).isActive = true
        label.numberOfLines = 0
        
        label.text = self
        label.font = font
        let maxSize = CGSize(width: maxWidth, height: .greatestFiniteMagnitude)
        let size = label.sizeThatFits(maxSize)
        
        return size//CGSize(width: label.frame.width, height: label.frame.height)
    }
    
    

    func detectedLangauge() -> String? {
        var lang = "en"
        if #available(iOS 12.0, *) {
            let recognizer = NLLanguageRecognizer()
            recognizer.processString(self)
            guard let languageCode = recognizer.dominantLanguage?.rawValue else {
                 return self.containsEnglishNumbers ? "en" : "ar"
            }
            lang = languageCode
        } else {
            let tagger = NSLinguisticTagger(tagSchemes: [.language], options: 0)
            tagger.string = self
            lang = tagger.dominantLanguage ?? "en"
        }
       let firstIndex = lang.firstIndex(of: "-") ?? lang.endIndex
       let langCode = String( lang[lang.startIndex..<firstIndex])
     
       return LabibaLanguages(rawValue: langCode)?.rawValue ?? "en"
       
        
        
    }
    
    mutating func addArabicAlignment() {
        self = "\u{202B}\(self)\u{200f}\u{202C}".replacingOccurrences(of: "\n", with: "\u{200f}\n\u{200f}").replacingOccurrences(of: "<br>", with: "\u{200f}<br>\u{200f}")
        //\u{200f} this is right to left unicode (zero width) to handle puncuation marks at the end of the sentences
        //\u{200f} this is right to left
        //\u{202C} POP DIRECTIONAL FORMATTING
    }
    var containsEnglishNumbers: Bool {
          return !isEmpty && range(of: "[^0-9]", options: .regularExpression) != nil
      }
    
    func detectedHyperLinkRange() -> Range<String.Index>?  {
        let detector = try! NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue)
        let matches = detector.matches(in: self, options: [], range: NSRange(location: 0, length: self.utf16.count))
        if matches.count > 0 {
            for match in matches {
                guard let range = Range(match.range, in: self) else { continue }
                return  range
            }
        }
        return nil
    }
    
    mutating func removeArabicDiacritic(){
        if self.detectedLangauge() == "ar" {
            let regex = try! NSRegularExpression(pattern: "[\\u064b-\\u064f\\u0650-\\u0652]", options: NSRegularExpression.Options.caseInsensitive)
            let range = NSMakeRange(0, self.unicodeScalars.count)
            let modString = regex.stringByReplacingMatches(in: self, options: [], range: range, withTemplate: "")
            self = modString
        }
    }
    mutating func removeHiddenCharacters(){
        let regex = try? NSRegularExpression(pattern: "[\\u200f]", options: NSRegularExpression.Options.caseInsensitive)
        let range = NSMakeRange(0, self.unicodeScalars.count)
        let modString = regex?.stringByReplacingMatches(in: self, options: [], range: range, withTemplate: "")
        self = modString ?? self
        
    }
   
    func underLine() -> NSAttributedString  {
        let textRange = NSMakeRange(0, self.count)
        let attributedText = NSMutableAttributedString(string: self)
        attributedText.addAttribute(NSAttributedString.Key.underlineStyle , value: NSUnderlineStyle.single.rawValue, range: textRange)
        // Add other attributes if needed
        return attributedText
    }
    
    mutating func removeHtmlTags()  {
        self = self.replacingOccurrences(of: "<[^>]+>", with: " ", options:
        .regularExpression, range: nil).replacingOccurrences(of: "&[^;]+;", with:
            "", options:.regularExpression, range: nil)
    }

    public func htmlAttributedString(regularFont: UIFont, boldFont: UIFont, color: UIColor) -> NSAttributedString {
        if self.isEmpty {
            return NSAttributedString()
        }
        guard let htmlData = NSString(string: self).data(using: String.Encoding.unicode.rawValue) else {return NSAttributedString()}
        // the follwing code is to check if the text is HTML or ordinary text
        let options : [NSAttributedString.DocumentReadingOptionKey: Any] = [.documentType: NSAttributedString.DocumentType.html]
        
        guard let attributedString = try? NSMutableAttributedString(data: htmlData, options: options, documentAttributes: nil) else {
            return NSAttributedString()
        }
        if attributedString.length < 1 {
            return NSAttributedString()
        }
        let fullRange = NSMakeRange(0, attributedString.length)
        
        var regularRanges: [NSRange] = []
        var boldRanges: [NSRange] = []
        
        attributedString.beginEditing()
        attributedString.enumerateAttribute(NSAttributedString.Key.font, in: fullRange, options: .longestEffectiveRangeNotRequired) { (value, range, stop) in
            guard let font = value as? UIFont else {
                return
            }
            if font.fontDescriptor.symbolicTraits.contains(.traitBold) {
                boldRanges.append(range)
            } else {
                regularRanges.append(range)
            }
        }
        
        for range in regularRanges {
            attributedString.addAttribute(NSAttributedString.Key.font, value: regularFont, range: range)
        }
        
        for range in boldRanges {
            attributedString.addAttribute(NSAttributedString.Key.font, value: boldFont, range: range)
        }
        
        if  let htmlColor = attributedString.attribute(.foregroundColor, at: 0, effectiveRange: nil) as? UIColor {
            var red: CGFloat = 0
            var green: CGFloat = 0
            var blue: CGFloat = 0
            var alpha: CGFloat = 0
            htmlColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
            if green == 0 && blue == 0 && red == 0 {
                attributedString.addAttribute(NSAttributedString.Key.foregroundColor, value: color, range: fullRange)
            }
        }
        
        attributedString.endEditing()
        
        return attributedString
    }
    
//    var htmlToAttributedString: NSAttributedString? {
//        guard let data = data(using: .utf8) else { return NSAttributedString() }
//        do {
//            return try NSAttributedString(data: data, options: [.documentType: NSAttributedString.DocumentType.html, .characterEncoding:String.Encoding.utf8.rawValue], documentAttributes: nil)
//        } catch {
//            return NSAttributedString()
//        }
//    }
//    var htmlToString: String {
//        return htmlToAttributedString?.string ?? ""
//    }

//    func isvalid(vaalidation:String) -> Any {
//        if vaalidation == "N" {
//            return Int()
//        }else if vaalidation == "N_CHAR" {
//            return String() Int()
//        }else if vaalidation == "N_CHAR_AR" {
//
//        }else if vaalidation == "CHAR_AR" {
//
//        }else if vaalidation == "CHAR" {
//
//        }else if vaalidation == "CALENDAR" {
//
//        }else if vaalidation == "user_phone_number" {
//
//        }else if vaalidation == "user_email" {
//
//        }
//        return (Any).self
//    }

    func heightWithConstrainedWidth(_ width: CGFloat, font: UIFont) -> CGFloat
    {

        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: font], context: nil)

        return boundingBox.height
    }

    func compressingWhiteSpaces() -> String
    {

        let nString = self.trimmingCharacters(in: .whitespacesAndNewlines)

        do
        {

            let regEx = try NSRegularExpression(pattern: "\\s+", options: .allowCommentsAndWhitespace)
            return regEx.stringByReplacingMatches(in: nString,
                    options: .reportCompletion,
                    range: NSRange(location: 0, length: nString.count),
                    withTemplate: " ")
        } catch let error
        {

            print("Error compressing white spaces: \(error.localizedDescription)")
            return nString
        }
    }
    func QRcodeToArray() -> String  {
        var returnString = String()
        
        for myChar in self {
            let tmpString: String = String(myChar)
            for myChar in tmpString.unicodeScalars {
                if myChar.value != UInt32(29) {
                    returnString += "\(myChar)"
                }
            }
        }
        return returnString
    }
    
    var withoutSpecialCharacters: String {
       return self.components(separatedBy: CharacterSet.symbols).joined(separator: "")
    }
    var withoutPunctuationCharacters: String {
       return self.components(separatedBy: CharacterSet.punctuationCharacters).joined(separator: "")
    }
    func isValidEmail() -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: self)
    }
    
    
}

extension NSAttributedString
{

    func heightWithConstrainedWidth(_ width: CGFloat) -> CGFloat
    {

        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, context: nil)
        return boundingBox.height
    }
    
    func size(maxWidth:CGFloat , minHeight:CGFloat = 0 ,font: UIFont? = nil) -> CGSize {
           let label =  UILabel(frame: CGRect(x: 0.0, y: 0.0, width:  .greatestFiniteMagnitude, height: .greatestFiniteMagnitude))
           label.translatesAutoresizingMaskIntoConstraints = false
           label.widthAnchor.constraint(lessThanOrEqualToConstant: 300).isActive = true
           label.frame.origin = CGPoint(x: 0, y: 0)
           label.heightAnchor.constraint(greaterThanOrEqualToConstant: 40).isActive = true
           label.numberOfLines = 0
           
           label.attributedText = self
          // label.font = font
           let maxSize = CGSize(width: maxWidth, height: .greatestFiniteMagnitude)
           var size = label.sizeThatFits(maxSize)
           size.height = size.height < minHeight ? minHeight : size.height
           return size//CGSize(width: label.frame.width, height: label.frame.height)
       }
    
}


extension UIImage
{

    func imageWithColor(_ color: UIColor) -> UIImage
    {

        let size = self.size

        UIGraphicsBeginImageContextWithOptions(size, false, self.scale)
        let context = UIGraphicsGetCurrentContext();

        context?.translateBy(x: 0, y: self.size.height)
        context?.scaleBy(x: 1.0, y: -1.0)
        context?.setBlendMode(.normal)

        let rect = CGRect(x: 0.0, y: 0.0, width: size.width, height: size.height);

        context?.clip(to: rect, mask: self.cgImage!)
        context?.setFillColor(color.cgColor)
        context?.fill(rect)

        let image = UIGraphicsGetImageFromCurrentImageContext()!;
        UIGraphicsEndImageContext();

        return image;
    }
    
   
}

extension UIImage
{


    static func animatedImage(withAnimatedGIFData data: Data) -> UIImage?
    {
         
        if let source = CGImageSourceCreateWithData(data as CFData, nil)
        {
            return animatedImage(withAnimatedGIFImageSource: source)
        }

        return nil
    }

    static func animatedImage(withAnimatedGIFURL url: URL) -> UIImage?
    {

        if let source = CGImageSourceCreateWithURL(url as CFURL, nil)
        {
            return animatedImage(withAnimatedGIFImageSource: source)
        }

        return nil
    }


    static func delayCentisecondsForImage(source: CGImageSource, atIndex index: Int) -> Int
    {

        var delayCentiseconds = 3
        if let properties = CGImageSourceCopyProperties(source, nil) as? [String: AnyObject],
           let gifProps = properties[kCGImagePropertyGIFDictionary as String] as? [String: AnyObject]
        {

            var number = gifProps[kCGImagePropertyGIFUnclampedDelayTime as String] as? NSNumber

            if number == nil || number!.doubleValue == 0.0
            {
                number = gifProps[kCGImagePropertyGIFDelayTime as String] as? NSNumber
            }

            if let num = number?.doubleValue, num > 0
            {
                delayCentiseconds = lrint(num * 100)
            }
        }

        return delayCentiseconds
    }

    static func createImages(source: CGImageSource, count: Int) -> [CGImage]
    {

        var imagesOut = [CGImage]()
        for i in 0..<count
        {
            imagesOut.append(CGImageSourceCreateImageAtIndex(source, i, nil)!)
        }

        return imagesOut
    }

    static func createDelays(source: CGImageSource, count: Int) -> [Int]
    {

        var delayCentisecondsOut = [Int]()
        for i in 0..<count
        {
            delayCentisecondsOut.append(delayCentisecondsForImage(source: source, atIndex: i))
        }

        return delayCentisecondsOut
    }

    static func sum(values: [Int]) -> Int
    {

        var _result = 0
        for val in values
        {
            _result += val
        }

        return _result
    }

    static func pairGCD(a: Int, b: Int) -> Int
    {

        if a < b
        {
            return pairGCD(a: b, b: a)
        }

        var _a = a, _b = b
        while true
        {
            let r = _a % _b
            if r == 0
            {
                return _b
            }
            _a = _b
            _b = r
        }
    }

    static func vectorGCD(count: Int, values: [Int]) -> Int
    {

        var gcd = values[0]
        for val in values
        {
            gcd = pairGCD(a: val, b: gcd)
        }

        return gcd
    }

    static func frameArray(count: Int, images: [CGImage], delayCentiseconds: [Int]) -> [UIImage]
    {

        let gcd = vectorGCD(count: count, values: delayCentiseconds)

        var frames = [UIImage](), f = 0
        for i in 0..<images.count
        {

            let frame = UIImage(cgImage: images[i])
            let m = delayCentiseconds[i] / gcd
            for _ in m...1
            {
                //frames[f] = frame
                frames.append(frame)
                f += 1
            }
        }

        return frames
    }

    static func animatedImage(withAnimatedGIFImageSource source: CGImageSource) -> UIImage?
    {

        let count = CGImageSourceGetCount(source)
        let images = createImages(source: source, count: count)
        let delays = createDelays(source: source, count: count)

        let totalDurationCentiseconds = Double(sum(values: delays))
        let frames = frameArray(count: count, images: images, delayCentiseconds: delays)
        
        return UIImage.animatedImage(with: frames, duration: totalDurationCentiseconds / 100.0)
    }
    ///
    
   
    ///
}
extension URL{
    func isImage() -> Bool {
        let imageFormats = ["jpg", "jpeg", "png", "gif"]
        let ext = self.pathExtension
        return imageFormats.contains(ext)
    }
    
}
extension Double
{
    func formatted(_ fractions: Int) -> String?
    {

        let numberFormat = NumberFormatter()
        numberFormat.maximumFractionDigits = fractions
        numberFormat.minimumIntegerDigits = 1
        numberFormat.locale = Locale(identifier: "en")
        return numberFormat.string(from: NSNumber(value: self))
    }
}

public extension UIColor
{
    convenience init(red: Int, green: Int, blue: Int, a: Int = 0xFF) {
        self.init(
            red: CGFloat(red) / 255.0,
            green: CGFloat(green) / 255.0,
            blue: CGFloat(blue) / 255.0,
            alpha: CGFloat(a) / 255.0
        )
    }
    
    // let's suppose alpha is the first component (ARGB)
    convenience init(argb: Int) {
        self.init(
            red: (argb >> 16) & 0xFF,
            green: (argb >> 8) & 0xFF,
            blue: argb & 0xFF,
            a: (argb >> 24) & 0xFF
        )
    }
}

extension UIViewController
{


    var safeAreaInsets: UIEdgeInsets
    {

        if #available(iOS 11.0, *)
        {
            if let insets = UIApplication.shared.keyWindow?.safeAreaInsets
            {
                return insets
            }
        }
        return UIEdgeInsets.zero
    }

    func fillEdgeSpace(withColor color: UIColor, edge: UIRectEdge) -> Void
    {

        guard edge == .top || edge == .bottom
        else
        {
            print("Can't be applied to right or left edges ..")
            return
        }

        if #available(iOS 11.0, *)
        {

            if let insets = UIApplication.shared.keyWindow?.alignmentRectInsets
            {

                if edge == .top, insets.top <= 0
                {
                    return
                }

                if edge == .bottom, insets.bottom <= 0
                {
                    return
                }

                var r = self.view.frame
                r.origin.y = insets.top
                r.size.height -= insets.top + insets.bottom

                let bv = UIView(frame: CGRect(x: 0, y: r.maxY, width: r.width, height: insets.bottom))
                bv.backgroundColor = color
                self.view.addSubview(bv)

                if edge == .top
                {
                    bv.topAnchor.constraint(equalTo: view.topAnchor, constant: 0).isActive = true
                }
                else
                {
                    bv.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0).isActive = true
                }

                bv.heightAnchor.constraint(equalToConstant: insets.bottom).isActive = true
                bv.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 0).isActive = true
                bv.rightAnchor.constraint(equalTo: view.rightAnchor, constant: 0).isActive = true
            }
        }
    }
    
    var topMostViewController : UIViewController {
        
        if let presented = self.presentedViewController {
            return presented.topMostViewController
        }
        
        if let navigation = self as? UINavigationController {
            return navigation.visibleViewController?.topMostViewController ?? navigation
        }
        
        if let tab = self as? UITabBarController {
            return tab.selectedViewController?.topMostViewController ?? tab
        }
        
        return self
    }
}

extension UIApplication {
   // class var statusBarBackgroundColor: UIColor? {
//        get {
//            return (shared.value(forKey: "statusBar") as? UIView)?.backgroundColor
//        } set {
//            (shared.value(forKey: "statusBar") as? UIView)?.backgroundColor = newValue
//        }
//
//    }
    
    func setStatusBarColor(color:UIColor)  {
        if #available(iOS 13.0, *) {
            let tag = 38482458385
          //  if let statusBar = UIApplication.shared.keyWindow?.viewWithTag(tag) {
               // statusBarView = statusBar
           // if (UIApplication.shared.keyWindow?.viewWithTag(tag)) != nil {
                UIApplication.shared.keyWindow?.viewWithTag(tag)?.removeFromSuperview()
         //   }
                
           // } else {
                let statusBar = UIView(frame: UIApplication.shared.statusBarFrame)
                statusBar.tag = tag
                statusBar.backgroundColor = color
                UIApplication.shared.keyWindow?.addSubview(statusBar)
              //  statusBarView = statusBar
            //}
        } else {
            (UIApplication.shared.value(forKey: "statusBar") as? UIView)?.backgroundColor = color
        }
    }

    
    var topMostViewController : UIViewController? {
        return self.keyWindow?.rootViewController?.topMostViewController
    }
}
extension UIImageView {
    ///
    func gif(data:Data, looping:Bool)
    {
        var frames:[UIImage] = []
        var totalDurationCentiseconds:Double = 1
        if let source = CGImageSourceCreateWithData(data as CFData, nil)
        {
            let count = CGImageSourceGetCount(source)
            for i in 0..<count {
                frames.append(UIImage(cgImage: CGImageSourceCreateImageAtIndex(source, i, nil)!))
            }
            let delays = UIImage.createDelays(source: source, count: count)
            totalDurationCentiseconds = Double(UIImage.sum(values: delays))
            
        }
       
        self.animationImages = frames
        self.animationRepeatCount = looping ? 0 : 1
        self.animationDuration = totalDurationCentiseconds / 100.0
        self.image = frames.last
        self.startAnimating()
    }
    
    ///
}

extension UITextView {
    func numberOfLines() -> Int {
        let layoutManager = self.layoutManager
        let numberOfGlyphs = layoutManager.numberOfGlyphs
        var lineRange: NSRange = NSMakeRange(0, 1)
        var index = 0
        var numberOfLines = 0
        
        while index < numberOfGlyphs {
            layoutManager.lineFragmentRect(
                forGlyphAt: index, effectiveRange: &lineRange
            )
            index = NSMaxRange(lineRange)
            numberOfLines += 1
        }
        return numberOfLines
    }
}

extension Data {
    func saveToDocumentDirectory(lastPathComponent:String) -> Bool{
        guard let directory = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false) as NSURL else {
            return false
        }
        do{
            try self.write(to: directory.appendingPathComponent(lastPathComponent)!)
            return true
        } catch {
            return false
        }
    }
}

extension FileManager{
    func pathOnDocumentDirectory(lastPathComponent LPath:String , success:(_ url:URL)->Void ,fauiler:()->Void)  {
        if let directory = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false) as NSURL  {
            do {
                if let url = URL(string: directory.absoluteString! + LPath){
                    let isReachable = try url.checkResourceIsReachable()
                    if isReachable {
                        success(url)
                        return
                    }
                }
            } catch {}
            fauiler()
        }
    }
    
}

extension NSLayoutConstraint {
    func constraintWithMultiplier(_ multiplier: CGFloat) -> NSLayoutConstraint {
        return NSLayoutConstraint(item: self.firstItem!, attribute: self.firstAttribute, relatedBy: self.relation, toItem: self.secondItem, attribute: self.secondAttribute, multiplier: multiplier, constant: self.constant)
    }
}



