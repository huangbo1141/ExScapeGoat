//
//  ViewController.swift
//  IOSTablayoutWithViewPager
//
//  Created by Sanjeev .Gautam on 03/07/17.
//  Copyright © 2017 SWS. All rights reserved.
//

import UIKit
import PR_utilss

private let PageControlScrollViewTag = 111

class TabBaseViewController: baseVc {
    
    //***********************************
    // MARK: Custom Variables
    //***********************************
    
    /// DropDown Instance
    static var dropdownInstance : DropDown = DropDown()
    
    /// Custom Deligate
    /// Setting it self in Home viewDidLoad.
    weak var deligateCustom : home? = nil
    
    
    
    //***********************************
    // MARK: Custom Funtions
    //***********************************
    
    /**
     Navigation Related
     */
    
    func showAddNavigationButton()  {
        self.PR_AddRightNaviButton(img: #imageLiteral(resourceName: "img_AddIcon"), selector: #selector(clickOnAddIcon(_:)), title: nil, size: CGSize.init(width: 10, height: 10))
    }
    
    func showRestoreNavigationButton()  {
        self.PR_AddRightNaviButton(img: nil, selector: #selector(clickOnRestoreButton(_:)), title: "Restore", size: nil)
    }
    
    
    /**
     Selectors
     */
    
    @objc func clickOnMenuIcon(_ sender : UIButton)  {
        
        DropdownShow(dName: TabBaseViewController.dropdownInstance, toItem: sender, data: ["Back", "Select All","Select None"]) { (index, str) in
            
            var condtion : home.conditionType = .selectNone
            
            switch index
            {
            case 0:
                condtion = .selectBack
            case 1 :
                condtion = .selectAll
            default:
                condtion = .selectNone
            }
            
            self.deligateCustom?.clickOnDropDownButton(condition: condtion)
        }
    }
    @objc func clickOnBackIcon(_ sender : UIButton)  {
        
        if let vc = self.navigationController {
            vc.popViewController(animated: true)
        }
    }
    
    @objc func clickOnAddIcon(_ sender : UIButton) {
        
        deligateCustom?.clickedOnAddButton()
    }
    
    @objc func clickOnRestoreButton(_ sender : UIButton)
    {
        deligateCustom?.clickOnRestoreButton()
    }
    
    
    
    
    
    
    @IBOutlet weak var tabParentView: UIView!
    
    var tabLayoutScrollView:TabLayoutScrollView!
    var pageVC: UIPageViewController!
    var currentChildIndex = -1
    var isDragging = false
    
    var tabsList = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Media"
        
        
        // MARK: PANKAJ
        self.PR_AddLeftNaviButton(img: #imageLiteral(resourceName: "img_menuHome"), selector: #selector(clickOnMenuIcon(_:)) , title: nil, size: CGSize.init(width: 40, height: 40))
        
        self.showAddNavigationButton()
        // TMP HANDLING
        //self.clickOnMenuIcon(UIButton())
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        
        
        self.addTabLayout()
    }
    
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        
        // MARK: PANKAJ
        
        self.deligateCustom = nil
    }
    
    //MARK:- Perform Seque
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "embedToPageVC" {
            pageVC = segue.destination as! UIPageViewController
            
            pageVC.dataSource = self
            pageVC.delegate = self
            
            if let firstViewController = orderedViewControllers.first {
                currentChildIndex = 0
                
                pageVC.setViewControllers(
                    [firstViewController],
                    direction: .forward,
                    animated: true,
                    completion: nil
                )
            }
            
            for view in pageVC.view.subviews {
                if let scrollView = view as? UIScrollView {
                    scrollView.delegate = self
                    scrollView.tag = PageControlScrollViewTag
                }
            }
        }
    }
    
    // MARK:- Button Actions
    func dismissScreenFunc() {
        dismiss(animated: true, completion: nil)
    }
    
    //MARK:- Helper
    fileprivate func addTabLayout() {
        if tabLayoutScrollView == nil {
            
            tabLayoutScrollView = TabLayoutScrollView.init(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.tabParentView.frame.size.height))
            tabLayoutScrollView.delegate = self
            tabLayoutScrollView.dataSource = self
            tabLayoutScrollView.backgroundColor = G_colorBlueLight
            tabLayoutScrollView.drawHeaderView()
            self.tabParentView.addSubview(tabLayoutScrollView)
        }
    }
    
    //MARK:- Page controller
    fileprivate(set) lazy var orderedViewControllers: [UIViewController] = {
        
        var tmp = [UIViewController]()
        
        for i in ["Photos","Videos"]
        {
            if let vc =  G_getVc(ofType: home(), FromStoryBoard: storyBoards.main, withIdentifier: vcIdentifiers.home)
            {
                self.tabsList.append(i)
                
                
                if i == "Photos"
                {
                    vc.enumSourceType = .photos
                }
                else if i == "Videos"
                {
                    vc.enumSourceType = .videos
                }
                
                vc.tabBase = self
                
                tmp.append(vc)
            }
        }
        
        return tmp
    }()
}

// MARK:- UIPageViewController DataSource & Delegate
extension TabBaseViewController: UIPageViewControllerDelegate, UIPageViewControllerDataSource {
    
    func pageViewController(_ pageViewController: UIPageViewController,
                            viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = orderedViewControllers.index(of: viewController) else {
            return nil
        }
        
        let previousIndex = viewControllerIndex - 1
        
        guard previousIndex >= 0 else {
            return nil
        }
        
        guard orderedViewControllers.count > previousIndex else {
            return nil
        }
        
        return orderedViewControllers[previousIndex]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController,
                            viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = orderedViewControllers.index(of: viewController) else {
            return nil
        }
        
        let nextIndex = viewControllerIndex + 1
        let orderedViewControllersCount = orderedViewControllers.count
        
        guard orderedViewControllersCount != nextIndex else {
            return nil
        }
        
        guard orderedViewControllersCount > nextIndex else {
            return nil
        }
        
        return orderedViewControllers[nextIndex]
    }
    
    func setChildViewControllers(_ tag: Int) {
        
        switch tag {
        case 0:
            pageVC.setViewControllers([orderedViewControllers.first!], direction: .reverse, animated: true, completion: nil)
        case tabsList.count-1:
            pageVC.setViewControllers([orderedViewControllers.last!], direction: .forward, animated: true, completion: nil)
            
        default:
            if currentChildIndex < tag {
                pageVC.setViewControllers([orderedViewControllers[tag]], direction: .forward, animated: true, completion: nil)
            }
            else {
                pageVC.setViewControllers([orderedViewControllers[tag]], direction: .reverse, animated: true, completion: nil)
            }
        }
        currentChildIndex = tag
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, willTransitionTo pendingViewControllers: [UIViewController]) {
        
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if (completed && finished)
        {
            let viewControllerIndex11 = orderedViewControllers.index(of: pageViewController.viewControllers!.first!)
            
            currentChildIndex = (viewControllerIndex11?.hashValue)!
        }
        else{
            return
        }
        
        let btn = tabLayoutScrollView.scrollView?.viewWithTag(currentChildIndex)
        if btn != nil {
            tabLayoutScrollView.moveLineWithOutAnimation(btn as! customButton)
        }
    }
}

//MARK:- UIScrollview of UIPageControl
extension TabBaseViewController : UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        if scrollView.tag == PageControlScrollViewTag {
            if tabLayoutScrollView != nil && isDragging {
                tabLayoutScrollView.moveLineWithPageDragging(scrollView)
            }
        }
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        
        if scrollView.tag == PageControlScrollViewTag {
            isDragging = true
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        
        if scrollView.tag == PageControlScrollViewTag {
            isDragging = false
            if tabLayoutScrollView.nextSelectedHeaderButton != nil {
                let btn = tabLayoutScrollView.scrollView?.viewWithTag(currentChildIndex)
                if btn != nil {
                    tabLayoutScrollView.autoScrollToScrollView(btn as! customButton)
                }
            }
        }
    }
}

//MARK:- JukeboxScrollableItemsView Delegate & DataSource
extension TabBaseViewController: TabLayoutScrollViewDataSource {
    
    func numberOfTabsInLayout() -> Int {
        return tabsList.count
    }
    
    func tabLayoutScrollView(titleForTabAtIndex index: Int) -> String {
        return tabsList[index]
    }
    
    func styleOfTabLine() -> (height: CGFloat, color: UIColor) {
        return (1.5, .white)
    }
    
    func styleOfSelectedTab() -> (font: UIFont, color: UIColor) {
        return (UIFont.boldSystemFont(ofSize: helperSubclasses.fontSize(14)), UIColor.white)
    }
    
    func styleOfNonSelectedTab() -> (font: UIFont, color: UIColor) {
        return (UIFont.systemFont(ofSize: helperSubclasses.fontSize(13)), UIColor.white)
    }
    
    func marginBetweenTabs() -> CGFloat {
        return 0
    }
}

extension TabBaseViewController: TabLayoutScrollViewDelegate {
    
    func tabLayoutScrollView(tabLayoutView: TabLayoutScrollView, didSelectedTabInView item: Int) {
        print("Selected Tab: \(item)")
        self.setChildViewControllers(item)
    }
}
























