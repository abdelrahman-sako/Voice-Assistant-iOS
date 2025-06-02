//
//  TextInputCell.swift
//  VoiceAssistant
//
//  Created by Mohammad Khalil on 01/06/2025.
//

import UIKit

class TextInputCell: UITableViewCell,UITextFieldDelegate {
    @IBOutlet weak var MessageTF: UITextField!
   
    
 var onSendTapped: ((String?) -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.setupTextFieldDelegate()

    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
 
       private func setupTextFieldDelegate() {
           MessageTF.delegate = self
           MessageTF.keyboardType = .default
           MessageTF.returnKeyType = .send
       }
       
       // UITextFieldDelegate - Called when the text changes
       func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
           let currentText = textField.text ?? ""
           let updatedText = (currentText as NSString).replacingCharacters(in: range, with: string)
           return true
       }
  
    
    private func handleSend() {
          let message = MessageTF.text
          onSendTapped?(message)
          MessageTF.text = ""
          MessageTF.resignFirstResponder() 
      }
      
      // MARK: - UITextFieldDelegate
      func textFieldShouldReturn(_ textField: UITextField) -> Bool {
          if textField == MessageTF {
              handleSend()
              return false
          }
          return true
      }
      
}
