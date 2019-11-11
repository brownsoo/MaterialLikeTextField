//
//  ViewController.swift
//  MaterialLikeTextField
//
//  Created by brownsoo on 10/05/2018.
//  Copyright (c) 2018 brownsoo. All rights reserved.
//

import UIKit
import MaterialLikeTextField

class ViewController: UIViewController, UITextFieldDelegate {
    
    typealias Mtf = MaterialLikeTextField

    private lazy var emailMf = Mtf()
    private lazy var passwordMf = Mtf()
    private lazy var autosizeMf = Mtf()
    private lazy var searchMf = Mtf()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

        view.addSubview(emailMf)
        emailMf.translatesAutoresizingMaskIntoConstraints = false
        emailMf.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        emailMf.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16).isActive = true
        emailMf.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -8).isActive = true
        emailMf.labelText = "이메일 (underlineTextIsDynamicHeight = false)"
        emailMf.placeholder = "name@email.com"
        emailMf.nextTextField = passwordMf
        emailMf.delegate = self
        emailMf.returnKeyType = .next
        emailMf.autocapitalizationType = .none
        emailMf.autocorrectionType = .no
        emailMf.spellCheckingType = .no
        emailMf.changeLabelWithPlaceholder = false
        emailMf.underlineTextIsDynamicHeight = false
        emailMf.addTarget(self, action: #selector(emailMfDidChange), for: .editingChanged)
        emailMf.debugging = true

        
        view.addSubview(passwordMf)
        passwordMf.translatesAutoresizingMaskIntoConstraints = false
        passwordMf.topAnchor.constraint(equalTo: emailMf.bottomAnchor, constant: 8).isActive = true
        passwordMf.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16).isActive = true
        passwordMf.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -8).isActive = true
        passwordMf.labelText = "비밀번호 (underlineTextIsDynamicHeight = true)"
        passwordMf.placeholder = "please type password"
        passwordMf.isSecureTextEntry = true
        passwordMf.delegate = self
        passwordMf.returnKeyType = .join
        passwordMf.autocapitalizationType = .none
        passwordMf.autocorrectionType = .no
        passwordMf.spellCheckingType = .no
        passwordMf.clearButtonMode = .always
        passwordMf.changeLabelWithPlaceholder = false
        passwordMf.addTarget(self, action: #selector(passwordMfDidChange), for: .editingChanged)
        passwordMf.debugging = true


        view.addSubview(autosizeMf)
        autosizeMf.translatesAutoresizingMaskIntoConstraints = false
        autosizeMf.topAnchor.constraint(equalTo: passwordMf.bottomAnchor, constant: 8).isActive = true
        autosizeMf.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16).isActive = true
        autosizeMf.widthAnchor.constraint(equalToConstant: 200).isActive = true
        autosizeMf.labelText = "자동폰트크기 (adjustsFontSizeToFitWidth = true)"
        autosizeMf.placeholder = "please Anything"
        autosizeMf.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        autosizeMf.underlineTextIsDynamicHeight = false
        autosizeMf.changeLabelWithPlaceholder = false
        autosizeMf.textAlignment = .right
        autosizeMf.clearButtonMode = .whileEditing
        autosizeMf.adjustsFontSizeToFitWidth = true
        autosizeMf.minimumFontSize = 12
        autosizeMf.textPadding = UIEdgeInsets(top: 12, left: 10, bottom: 12, right: 10)
        autosizeMf.debugging = true
        
        
        let tf = UITextField()
        view.addSubview(tf)
        tf.translatesAutoresizingMaskIntoConstraints = false
        tf.topAnchor.constraint(equalTo: autosizeMf.bottomAnchor, constant: 8).isActive = true
        tf.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16).isActive = true
        tf.widthAnchor.constraint(equalToConstant: 200).isActive = true
        tf.placeholder = "UITextField (adjustsFontSizeToFitWidth = true)"
        tf.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        tf.textAlignment = .right
        tf.clearButtonMode = .whileEditing
        tf.adjustsFontSizeToFitWidth = true
        tf.minimumFontSize = 12
        tf.layer.borderColor = UIColor.magenta.withAlphaComponent(0.5).cgColor
        tf.layer.borderWidth = 1
        
        view.addSubview(searchMf)
        searchMf.translatesAutoresizingMaskIntoConstraints = false
        searchMf.topAnchor.constraint(equalTo: tf.bottomAnchor, constant: 8).isActive = true
        searchMf.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16).isActive = true
        searchMf.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -8).isActive = true
        searchMf.labelText = "Left View"
        searchMf.placeholder = "please Anything"
        searchMf.underlineTextIsDynamicHeight = false
        searchMf.changeLabelWithPlaceholder = false
        let iv = UIImageView(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
        iv.contentMode = UIView.ContentMode.scaleAspectFit
        iv.image = UIImage(named: "icSearch")
        searchMf.leftView = iv
        searchMf.leftViewMode = .always
        searchMf.clearButtonMode = .whileEditing
        searchMf.textPadding = UIEdgeInsets(top: 12, left: 10, bottom: 12, right: 10)
        searchMf.debugging = true
        
        
    }
    
    @objc
    private func emailMfDidChange() {
        if let t = emailMf.text, t.isEmpty == false, t.isEmailFormat == false {
            emailMf.errorText = "Wrong email format"
        } else {
            emailMf.errorText = nil
        }
    }
    
    @objc
    private func passwordMfDidChange() {
        if let t = passwordMf.text, t.isEmpty == false, t.count < 8 {
            passwordMf.errorText = "Too short password"
        } else {
            passwordMf.errorText = nil
        }
    }

    // MARK: UITextFieldDelegate
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField.returnKeyType {
        case .next:
            DispatchQueue.main.async {
                (textField as? Mtf)?.nextTextField?.becomeFirstResponder()
            }
            return true
        case .join:
            view.endEditing(true)
            return true
        default:
            return false
        }
    }
    
}

extension String {
    var isEmailFormat: Bool {
        if self.isEmpty {
            return false
        }
        do {
            let pattern = "^(([^<>()\\[\\]\\\\.,;:\\s@\"]" +
                "+(\\.[^<>()\\[\\]\\\\.,;:\\s@\"]+)*)|(\".+\"))" +
                "@" +
                "((\\[[0-9]{1,3}\\.[0-9]{1,3}\\.[0-9]{1,3}\\.[0-9]{1,3}])" +
            "|(([a-zA-Z-0-9]+\\.)+[a-zA-Z]{2,}))$"
            let regex = try NSRegularExpression(pattern: pattern, options: [.caseInsensitive])
            return regex.matches(in: self, options: [], range: NSRange(location: 0, length: self.count)).count > 0
        } catch {
            return false
        }
    }
}

