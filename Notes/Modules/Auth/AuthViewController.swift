//
//  AuthViewController.swift
//  Notes
//
//  Copyright © 2019 VIS Apps. All rights reserved.
//

import UIKit

class AuthViewController: UIViewController {

    @IBOutlet weak var loginField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var errorLabel: UILabel!
    
    @IBAction func loginButtonPressed() {
        authenticate()
    }
    
    override func viewDidLoad() {
        navigationItem.hidesBackButton = true
        tabBarController?.tabBar.isHidden = true
        loginField.delegate = self
        passwordField.delegate = self
    }
    
    func authenticate() {
        guard let login = loginField.text, let password = passwordField.text,
            login.count > 0, password.count > 0 else {return}
        let loginString = String(format: "%@:%@", login, password)
        guard let loginData = loginString.data(using: String.Encoding.utf8) else {return}
        let base64Token = loginData.base64EncodedString()
        guard let url = URL(string: "https://api.github.com/authorizations") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Basic \(base64Token)", forHTTPHeaderField: "Authorization")
        request.httpBody = AuthorizationRequest.createAuthorizationRequest(client_id: client_id, client_secret: client_secret)
        let task = URLSession.shared.dataTask(with: request) { [weak self] (data, response, error) in
            guard let self = self else {return}
            if let response = response as? HTTPURLResponse,
                response.statusCode == 201,
                let data = data,
                let authResponse = AuthorizationResponse.parseAuthorizationResponse(with: data) {
                //в случае успешной авторизации сохраняем полученный токен в UserDefaults
                UserDefaults.standard.set(authResponse.token, forKey: tokenKey)
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return }
                    self.navigationController?.popViewController(animated: true)
                }
            }
            else {
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return }
                    self.errorLabel.isHidden = false
                    self.loginButton.isEnabled = true
                }
            }
        }
        self.loginButton.isEnabled = false
        self.errorLabel.isHidden = true
        task.resume()
    }
    
}

extension AuthViewController: UITextFieldDelegate {
    
    internal func textFieldDidEndEditing(_ textField: UITextField) {
        self.errorLabel.isHidden = true
    }
    
    internal func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        authenticate()
        return true
    }
    
}
