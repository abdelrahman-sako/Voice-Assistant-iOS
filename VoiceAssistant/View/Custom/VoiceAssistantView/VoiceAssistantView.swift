//
//  VoiceAssistantView.swift
//  LabibaBotFramwork
//
//  Created by Abdulrahman on 7/31/19.
//  Copyright © 2019 Abdul Rahman. All rights reserved.
//

import UIKit
import Speech
import MobileCoreServices

//import MediaPlayer


protocol VoiceRecognitionProtocol {
    func didStartSpeechToText()
    func finishRecognitionWithText(text:String)
    func didRecognizeText(text:String)
    func didStopRecording()
    func changeFromVoiceToKeyboardType()
}

class VoiceAssistantView: UIView {
    
    class func create() -> VoiceAssistantView
    {
        return bundle.loadNibNamed(String(describing: VoiceAssistantView.self), owner: nil, options: nil)![0] as! VoiceAssistantView
    }
    
    @IBOutlet weak var swiftyWavesView: SwiftyWaveView!
    @IBOutlet weak var micButton: UIButton!
    @IBOutlet weak var keyboardButton: UIButton!
    @IBOutlet weak var attchmentButton: UIButton!
    @IBOutlet weak var backgroundView: UIView!
    
    var delegate:VoiceRecognitionProtocol?
    let speechToTextManager = SpeechToTextManager.shared
    var isAnimating:Bool = false
    
    static var HEIGHT: CGFloat = {
        switch UIScreen.current {
        case .iPhone5_8 ,.iPhone6_1 , .iPhone6_5:
            return 120
        case .iPhone5_5 :
            return 110
        case  .iPad9_7, .iPad10_5 ,.iPad12_9,.ipad:
            return 120
        default:
            return 100
        }
    }()
    
    override func awakeFromNib() {
        self.layoutIfNeeded()
        swiftyWavesView.isHidden = true
        swiftyWavesView.colors = AssistantConfig.micViewTheme.waveColors
        
        if let image = AssistantConfig.micViewTheme.image {
            micButton.setImage(image, for: .normal)
        }
//        micButton.tintColor = Labiba._MicButtonTintColor
//        keyboardButton.tintColor = Labiba._KeyboardIconTintColor
//        attchmentButton.tintColor = Labiba._KeyboardIconTintColor
//        micButton.backgroundColor = Labiba._MicButtonBackGroundColor
//        micButton.alpha = Labiba._MicButtonAlpha
        
        micButton.tintColor = AssistantConfig.micViewTheme.viewStyle.tintColor
//        keyboardButton.tintColor = Labiba.VoiceAssistantView.keyboardButton.tintColor
//        attchmentButton.tintColor = Labiba.VoiceAssistantView.attachmentButton.tintColor
        micButton.backgroundColor = AssistantConfig.micViewTheme.viewStyle.backgroundColor
      //  micButton.alpha = Labiba.VoiceAssistantView.micButton.alpha
        
        micButton.imageView?.contentMode = .scaleAspectFit
//        micButton.setImage(Labiba._MicButtonIcon, for: .normal)
//        keyboardButton.setImage(Labiba._KeyboardButtonIcon, for: .normal)
//        attchmentButton.setImage(Labiba._AttachmentButtonIcon, for: .normal)
//        attchmentButton.isHidden = Labiba.isAttachmentButtonHidden
        
       // micButton.setImage(Labiba.VoiceAssistantView.micButton.icon, for: .normal)
//        keyboardButton.setImage(Labiba.VoiceAssistantView.keyboardButton.icon, for: .normal)
//        attchmentButton.setImage(Labiba.VoiceAssistantView.attachmentButton.icon, for: .normal)
//        attchmentButton.isHidden = Labiba.VoiceAssistantView.attachmentButton.isHidden
        
        backgroundView.applySemanticAccordingToBotLang()
//        if Labiba.Bot_Type == .voiceAndKeyboard || Labiba.Bot_Type == .voiceToVoice{
//            keyboardButton.isHidden = false
//            
//        }
        
//        if let colors = Labiba._bottomBackgroundGradient {
//            self.applyGradient(colours: colors.colors, locations: nil)
//        }
//        switch Labiba.VoiceAssistantView.background {
//        case .solid(color: let color):
//            self.backgroundView.backgroundColor = color
//        case .gradient(gradientSpecs: let grad):
//            self.applyGradient(colours:grad.colors, locations: nil)
//        case .image(image: _):break
//        }
        
        
        
        speechToTextManager.delegate = self
        setNeedsDisplay()
           // activateHeadPhonesStatus()
        }
    override func draw(_ rect: CGRect) {
        micButton.layer.cornerRadius = 35 + ipadFactor*5//micButton.frame.height/2
    }
    
    
    
//    func activateHeadPhonesStatus(){
//        NotificationCenter.default.addObserver(self, selector: #selector(audioRouteChangeListener(_:)), name: AVAudioSession.routeChangeNotification, object: nil)
//    }
//
//    @objc func audioRouteChangeListener(_ notification:Notification) {
//        guard let userInfo = notification.userInfo,
//            let reasonValue = userInfo[AVAudioSessionRouteChangeReasonKey] as? UInt,
//            let reason = AVAudioSession.RouteChangeReason(rawValue:reasonValue) else {
//                return
//        }
//        switch reason {
//        case .unknown:
//            if isListening{
//                 self.finishRecording(submitTextIfExist:false)
//            }else{
//               self.startRecording(_ :UIButton())
//            }
//
//        default:
//            break
//        }
//
//    }
    

    
    func popUp(on view: UIView) -> Void
    {
        let root = view
        let r = root.frame
        let w = r.size.width
        let y = r.size.height
        self.frame = CGRect(x: 0, y: 0 , width: w, height: VoiceAssistantView.HEIGHT )
        let views = UIView(frame: CGRect(x: 0, y: 0 , width: w, height: 200 ))
        views.backgroundColor = .red
        root.addSubview(self)
        //root.addSubview(views)
        let ty = root.frame.height - self.frame.size.height - 20
        self.reconfigure(y: ty)
    }
    
   
    
    func dismiss() -> Void
    {
        self.removeFromSuperview()
    }
    
   
    
    private let topViewC = getTheMostTopViewController()
    
    
    func reconfigure(y: CGFloat) -> Void
    {
        let insets = topViewC?.additionalSafeAreaInsets
       
        var f = self.frame
        f.origin.y = y - (insets?.bottom ?? 0.0)
        self.frame = f
    }
    
    func startRecordingAnimation()  {
        swiftyWavesView?.stop()
        micButton.isEnabled = false // app could crash if user press the micButton while it's animating because it will start speechToText on the same bus again
        DispatchQueue.main.asyncAfter(deadline: .now() + (isAnimating ? 0.2 : 0)) {
            UIView.animate(withDuration: 0.2, animations: {
                self.micButton.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
            }) { (result) in
                self.swiftyWavesView.isHidden = false
                self.micButton.isHidden = true
                self.keyboardButton.isHidden = true
//                if !Labiba.VoiceAssistantView.attachmentButton.isHidden {
//                    self.attchmentButton.isHidden = true
//                }
                self.isAnimating = false
                self.micButton.isEnabled = true
            }
        }
        
        isAnimating = true
        swiftyWavesView.start()
    }
    
    @IBAction func startRecording(_ sender: UIButton) {
        startRecordingAnimation()
        speechToTextManager.start()
    }
    
    @IBAction func keybordTypeAction(_ sender: Any) {
//        delegate?.changeFromVoiceToKeyboardType()
//        if Labiba.Bot_Type == .voiceToVoice {
//            Labiba.setEnableTextToSpeech(enable: false)
//        }
    }
    @IBAction func attachmentAction(_ sender: UIButton) {
//        let topVC = getTheMostTopViewController()
//        let documentPicker = UIDocumentPickerViewController(documentTypes:  Labiba.VoiceAssistantView.attachmentTypes.map({ $0 as String }), in: .import)
//        documentPicker.delegate = self
//        topVC?.present(documentPicker, animated: true, completion: nil)
    }
}

extension VoiceAssistantView : SpeechToTextDelegate {
    func speechToTextDidStartRecognition() {
        startRecordingAnimation()
    }
    func speechToText(didRecognizeText text: String) {
        
    }
    
    func speechToText(didFinishWithText text: String) {
        delegate?.finishRecognitionWithText(text: text)
        self.swiftyWavesView?.stop()
    }
    
    func speechToText(updateVoicePowerInDB dbPower: Float) {
        self.swiftyWavesView?.voicePower = CGFloat(dbPower)
    }
    
    func speechToTextFinishRecording() {
        DispatchQueue.main.asyncAfter(deadline: .now() + (isAnimating ? 0.2 : 0)) {
            self.swiftyWavesView.isHidden = true
//            if Labiba.Bot_Type == .voiceAndKeyboard || Labiba.Bot_Type == .voiceToVoice {
//                self.keyboardButton.isHidden = false
//                if !Labiba.VoiceAssistantView.attachmentButton.isHidden {
//                    self.attchmentButton.isHidden = false
//                }
//            }
            UIView.animate(withDuration: 0.3, animations: {
                self.micButton.isHidden = false
                self.micButton.transform = CGAffineTransform(scaleX: 1, y:1)
            }) { (result) in
                self.isAnimating = false
            }
        }
        isAnimating = true
        self.swiftyWavesView?.stop()
        delegate?.didStopRecording()
    }
    
    
}
//
//extension VoiceAssistantView: UIDocumentPickerDelegate{
//    
//    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
//        if urls.count > 0 {
//            delegate?.voiceAssistantKeyboard(self, didSubmitFile: urls[0])
//        }
//        controller.dismiss(animated: true, completion: nil)
//    }
//    
//}
