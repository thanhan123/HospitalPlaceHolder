//
//  LoginViewController.swift
//  HospitalPlaceHolder
//
//  Created by Dinh Thanh An on 6/11/17.
//  Copyright © 2017 Dinh Thanh An. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import NSObject_Rx

class LoginViewController: UIViewController {
    @IBOutlet weak var phoneTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Login"
        
        Observable.combineLatest(phoneTextField.rx.text, passwordTextField.rx.text) {
            ($0?.characters.count)! > 0 && ($1?.characters.count)! > 0
        }
        .bind(to: loginButton.rx.isEnabled)
        .addDisposableTo(rx_disposeBag)
        
        loginButton.rx.tap
        .debug()
        .subscribe(onNext: { [weak self] _ in
            
            APIManager.instance.loginUserWith(username: (self?.phoneTextField.text)!, password: (self?.passwordTextField.text)!)
            .subscribeOn(MainScheduler.instance)
            .subscribe(onNext: { isValid in
                if isValid == true {
                    let mapVC = Utils.storyboard.instantiateViewController(withIdentifier: "MapViewController")
                    self?.navigationController?.pushViewController(mapVC, animated: true)
                } else {
                    print("wrong pass or username")
                }
            }, onError: { error in
                print(error)
            })
            .addDisposableTo((self?.rx_disposeBag)!)
            
        })
        .addDisposableTo(rx_disposeBag)
    }
}
