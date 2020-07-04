//
//  GenericViewController.swift
//  Toy AWS Authentication App
//
//  Created by Syd Polk on 2/23/20.
//  Copyright © 2020 Earbug, Inc. All rights reserved.
//

import UIKit
import AWSMobileClient

class GenericViewController: UIViewController, UINavigationControllerDelegate {

    @IBOutlet weak var signInStateLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        AWSMobileClient.default().initialize { (userState, error) in
            if let userState = userState {
                switch(userState){
                case .signedIn:
                        DispatchQueue.main.async {
                            self.signInStateLabel.text = "Logged In"
                    }
                case .signedOut:
                    AWSMobileClient.default().showSignIn(navigationController: self.navigationController!, { (userState, error) in
                            if(error == nil){       //Successful signin
                                DispatchQueue.main.async {
                                    self.signInStateLabel.text = "Logged In"
                                }
                            }
                        })
                default:
                    AWSMobileClient.default().signOut()
                }
                
            } else if let error = error {
                print(error.localizedDescription)
            }
        }
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
