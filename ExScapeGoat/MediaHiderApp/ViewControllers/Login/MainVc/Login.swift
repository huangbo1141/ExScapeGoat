import UIKit
import LocalAuthentication

class login: baseVc {
    
    //*********************************************
    // MARK: Variables
    //*********************************************
    
    // UI Related
    
    let passwordContainerView = PasswordContainerView.initMe(withDigit: 6)
    
    // Others
    
    //*********************************************
    // MARK: Outlets
    //*********************************************
    
    //*********************************************
    // MARK: Defaults
    //*********************************************
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupView()
    }
    var mode:Int = 1
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        
    }
    func setupView(){
        
        if let view = passwordContainerView.superview {
            passwordContainerView.removeFromSuperview()
        }
        if mode == 0 {
            let delegate = UIApplication.shared.delegate as! QMAppDelegate
            let ac = UIAlertController.init(title: "Choose Method", message: nil, preferredStyle: .actionSheet)
            let ac1 = UIAlertAction.init(title: "Thumbprint", style: .default) { (uiac) in
                delegate.curentPassMode = 1
                self.authenticateUser()
            }
            let ac2 = UIAlertAction.init(title: "Passcode", style: .default) { (uiac) in
                delegate.curentPassMode = 0
                self.setupPasswordContainerView()
            }
            ac.addAction(ac1)
            ac.addAction(ac2)
            
            self.present(ac, animated: true, completion: {
                
            })
        }else{
            self.setupPasswordContainerView()
        }
    }
    
    func authenticateUser() {
        let context = LAContext()
        var error: NSError?
        
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            let reason = "Identify yourself!"
            
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) {
                [unowned self] success, authenticationError in
                
                DispatchQueue.main.async {
                    if success {
                        self.runSecretCode()
                    } else {
                        let ac = UIAlertController(title: "Cannot access ICLOUD. please come back later and check again.", message: "Sorry!", preferredStyle: .alert)
                        ac.addAction(UIAlertAction.init(title: "OK", style: .default, handler: { (uiac1) in
                            self.setupView()
                        }))
                        self.present(ac, animated: true)
                    }
                }
            }
        } else {
            let ac = UIAlertController(title: "Cannot access ICLOUD. please come back later and check again.", message: "Sorry!", preferredStyle: .alert)
            ac.addAction(UIAlertAction.init(title: "OK", style: .default, handler: { (ac1) in
                let delegate = UIApplication.shared.delegate as! QMAppDelegate
                delegate.curentPassMode = 0
                self.setupPasswordContainerView()
            }))
            present(ac, animated: true)
        }
    }
    func runSecretCode(){
        // when login success
        if let vc = G_getVc(ofType: desktopVC(), FromStoryBoard: storyBoards.main , withIdentifier: vcIdentifiers.desktopVC)
        {
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}


//*********************************************
// MARK: Actions
//*********************************************

extension login
{
    /**
     #selectors
     */
    
    
    /**
     @IBActions
     */
}


//*********************************************
// MARK: Custom Methods
//*********************************************

extension login
{
    /**
     Decorate UI
     */
    
    fileprivate func setupPasswordContainerView() {
        passwordContainerView.tintColor = G_colorBlueLight
        passwordContainerView.highlightedColor = G_colorBlueLight
        passwordContainerView.delegate = self
        
        self.view.addSubview(passwordContainerView)
        
        passwordContainerView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addConstraints([NSLayoutConstraint.init(item: passwordContainerView, attribute: .centerX, relatedBy: .equal, toItem: self.view, attribute: .centerX, multiplier: 1.0, constant: 0),
                                  NSLayoutConstraint.init(item: passwordContainerView, attribute: .centerY, relatedBy: .equal, toItem: self.view, attribute: .centerY, multiplier: 1.0, constant: 0),
                                  NSLayoutConstraint.init(item: passwordContainerView, attribute: .width, relatedBy: .equal, toItem: self.view, attribute: .width, multiplier: 0.7, constant: 0),
                                  NSLayoutConstraint.init(item: passwordContainerView, attribute: .height, relatedBy: .equal, toItem: self.view, attribute: .height, multiplier: 0.65, constant: 0)])
    }
}



extension login : PasswordInputCompleteProtocol {
    
    func touchAuthenticationComplete(_ passwordContainerView: PasswordContainerView, success: Bool, error: Error?) {
        
        if success
        {
            let delegate = UIApplication.shared.delegate as! QMAppDelegate
            delegate.curentPassMode = 1
            if let vc = G_getVc(ofType: desktopVC(), FromStoryBoard: storyBoards.main , withIdentifier: vcIdentifiers.desktopVC)
            {
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
    
    func passwordInputComplete(_ passwordContainerView: PasswordContainerView, input: String) {
        
        if PasswordManager.verifyIsValidPassword(enteredPassword: input)
        {
            // when login success
            if let vc = G_getVc(ofType: desktopVC(), FromStoryBoard: storyBoards.main , withIdentifier: vcIdentifiers.desktopVC)
            {
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
        else
        {
            Banner.customBannerShow(title: "Error", subtitle: "Please enter a valid password", colorCase: .error)
            passwordContainerView.wrongPassword()
        }
    }
}
