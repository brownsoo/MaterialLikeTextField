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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        view.addSubview(emailMf)
        emailMf.translatesAutoresizingMaskIntoConstraints = false
        emailMf.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        emailMf.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16).isActive = true
        emailMf.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -8).isActive = true
        emailMf.labelText = "이메일"
        emailMf.placeholder = "name@email.com"
        emailMf.nextTextField = passwordMf
        emailMf.delegate = self
        emailMf.returnKeyType = .next
        emailMf.autocapitalizationType = .none
        emailMf.autocorrectionType = .no
        emailMf.spellCheckingType = .no
        emailMf.changeLabelWithPlaceholder = false
        emailMf.underlineTextIsDynamicHeight = true
        emailMf.addTarget(self, action: #selector(emailMfDidChange), for: .editingChanged)

        
        view.addSubview(passwordMf)
        passwordMf.translatesAutoresizingMaskIntoConstraints = false
        passwordMf.topAnchor.constraint(equalTo: emailMf.bottomAnchor, constant: 8).isActive = true
        passwordMf.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16).isActive = true
        passwordMf.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -8).isActive = true
        passwordMf.labelText = "비밀번호"
        passwordMf.placeholder = "please type password"
        passwordMf.isSecureTextEntry = true
        passwordMf.delegate = self
        passwordMf.returnKeyType = .join
        passwordMf.autocapitalizationType = .none
        passwordMf.autocorrectionType = .no
        passwordMf.spellCheckingType = .no
        passwordMf.changeLabelWithPlaceholder = false
        passwordMf.addTarget(self, action: #selector(passwordMfDidChange), for: .editingChanged)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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

