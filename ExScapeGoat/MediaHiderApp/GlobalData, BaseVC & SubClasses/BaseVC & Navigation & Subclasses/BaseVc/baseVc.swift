import UIKit

class baseVc: UIViewController {
    
    //*********************************************
    // MARK: Variables
    //*********************************************
    
    //*********************************************
    // MARK: Outlets
    //*********************************************
    
    //*********************************************
    // MARK: Defaults
    //*********************************************
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.plain, target: nil, action: nil)
        
        self.view.backgroundColor = G_colorBackground        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}


//*********************************************
// MARK: Actions
//*********************************************

extension baseVc
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

extension baseVc
{
    
}
