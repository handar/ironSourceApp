//
//  ViewController.swift
//  ironSourceTestApp
//
//  Created by Hadia Andar on 10/25/19.
//  Copyright © 2019 Hadia Andar. All rights reserved.
//

import UIKit

let USERID = "testapp"
let kAPPKEY = "4ea90fad"

class ViewController: UIViewController, ISRewardedVideoDelegate, ISInterstitialDelegate, ISOfferwallDelegate{
    
    @IBOutlet weak var initButton: UIButton!
    @IBOutlet weak var showRewardedVideoButton: UIButton!
    @IBOutlet weak var loadInterstitialButton: UIButton!
    @IBOutlet weak var showInterstitialButton: UIButton!
    @IBOutlet weak var showOfferwallButton: UIButton!
    
    var rewardVideoPlacementInfo: ISPlacementInfo? //Object that contains the placement's reward name and amount
    var rewardName: String?
    var rewardAmount: Int?
    
    var earnedUserCredits: String?
    
    let dispatchGroup = DispatchGroup()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Button styling
        initButton.layer.cornerRadius = 4
        showRewardedVideoButton.layer.cornerRadius = 4
        loadInterstitialButton.layer.cornerRadius = 4
        showInterstitialButton.layer.cornerRadius = 4
        showOfferwallButton.layer.cornerRadius = 4
        
        //user consent
        IronSource.setConsent(true)
        
        //Verify integration, remove before going live
        ISIntegrationHelper.validateIntegration()
        
        //Client-side callbacks for Offerwall
        ISSupersonicAdsConfiguration.configurations().useClientSideCallbacks = 1 as NSNumber
        
        
        //Set Delegates
        IronSource.setRewardedVideoDelegate(self)
        IronSource.setInterstitialDelegate(self)
        IronSource.setOfferwallDelegate(self)
        
        //UserID
        var userId = IronSource.advertiserId()
        
        if userId.count == 0 {
            //If cannot get advertiser id, use default
            userId = USERID
        }
        
        IronSource.setDynamicUserId(userId)
        
        showInterstitialButton.isEnabled = false
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func initButtonTapped(_ sender: Any) {
        IronSource.initWithAppKey(kAPPKEY)
        IronSource.shouldTrackReachability(true) //listen for changes in network connectivity
    }
    
    @IBAction func showRewardedVideoButtonTapped(_ sender: Any) {
        IronSource.showRewardedVideo(with: self)
    }
    
    @IBAction func loadInterstitialButtonTapped(_ sender: Any) {
        IronSource.loadInterstitial()
    }
    
    @IBAction func showInterstitialButtonTapped(_ sender: Any) {
        IronSource.showInterstitial(with: self)
    }
    
    @IBAction func showOfferwallButtonTapped(_ sender: Any) {
        IronSource.showOfferwall(with: self)
    }
    
    
    //MARK: ISRewardedVideoDelegate Functions
    /**
     Called after a rewarded video has changed its availability.
     
     @param available The new rewarded video availability. YES if available and ready to be shown, NO otherwise.
     */
    public func rewardedVideoHasChangedAvailability(_ available: Bool) {
        //Change the in-app 'Traffic Driver' state according to availability.
        //check if video is available, if it is, enable showRewardedVideoButton
        
        //function happens on background thread and update the main thread when it is finished
        
        //not on main thread so it doesn't block function of app if vidoe is not available, you never want to block main thread
        DispatchQueue.main.async{
            self.showRewardedVideoButton.isEnabled = available
            self.showOfferwallButton.isEnabled = available
        }
    }
    
    /**
     Called after a rewarded video has been dismissed.
     */
    public func rewardedVideoDidClose() {
        //after reward video is closed, check the rewardVideoPlacementInfo. When it is not nil, show alert that tells user how much they earned
        dispatchGroup.notify(queue: .main) {
            if (self.rewardVideoPlacementInfo != nil) {
                let alert = UIAlertController(title: "Video Reward", message: "You have been rewarded \(String(self.rewardAmount ?? 0)) \(String(self.rewardName!)).", preferredStyle: .alert)
                
                alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
                
                self.present(alert, animated: true)
                self.rewardVideoPlacementInfo = nil
            }
        }
        
    }
    
    /**
     Called after a rewarded video has been opened.
     */
    public func rewardedVideoDidOpen() {
    }
    
    /**
     Called after a rewarded video has attempted to show but failed.
     
     @param error The reason for the error
     */
    public func rewardedVideoDidFailToShowWithError(_ error: Error!) {
    }
    
    /**
     Called after a rewarded video has been viewed completely and the user is eligible for reward.
     
     @param placementInfo An object that contains the placement's reward name and amount.
     */
    public func didReceiveReward(forPlacement placementInfo: ISPlacementInfo!) {
        //rvPlacementInfo = the placementInfo parameter, store reward here
        dispatchGroup.enter()
        self.rewardVideoPlacementInfo = placementInfo
        self.rewardName = rewardVideoPlacementInfo?.rewardName
        rewardAmount = rewardVideoPlacementInfo?.rewardAmount as? Int
        dispatchGroup.leave()
    }
    /**Invoked when the end user clicked on the RewardedVideo ad
     */
    public func didClickRewardedVideo(_ placementInfo: ISPlacementInfo!) {
    }
    /**
     Called after a rewarded video has finished playing.
     */
    public func rewardedVideoDidEnd() {
    }
    
    /**
     Called after a rewarded video has started playing.
     */
    public func rewardedVideoDidStart() {
    }
    
    
    
    //MARK: ISInterstitialDelegate Functions
    /**
     Called after an interstitial has been clicked.
     */
    public func didClickInterstitial() {
        
    }
    
    /**
     Called after an interstitial has attempted to show but failed.
     
     @param error The reason for the error
     */
    public func interstitialDidFailToShowWithError(_ error: Error!) {
        
    }
    
    /**
     Called after an interstitial has been displayed on the screen.
     */
    public func interstitialDidShow() {
        
    }
    
    /**
     Called after an interstitial has been dismissed.
     */
    public func interstitialDidClose() {
        
    }
    
    /**
     Called after an interstitial has been opened.
     */
    public func interstitialDidOpen() {
        
    }
    
    /**
     Called after an interstitial has attempted to load but failed.
     
     @param error The reason for the error
     */
    public func interstitialDidFailToLoadWithError(_ error: Error!) {
        
    }
    
    /**
     Called after an interstitial has been loaded
     */
    public func interstitialDidLoad() {
        DispatchQueue.main.async{
            self.showInterstitialButton.isEnabled = true
        }
        
    }
    
    
    
    //MARK: ISOfferwallDelegate Functions
    /**
     Called after the 'offerwallCredits' method has attempted to retrieve user's credits info but failed.
     
     @param error The reason for the error.
     */
    public func didFailToReceiveOfferwallCreditsWithError(_ error: Error!) {
        
    }
    
    /**
     @abstract Called each time the user completes an offer.
     @discussion creditInfo is a dictionary with the following key-value pairs:
     
     "credits" - (int) The number of credits the user has Earned since the last didReceiveOfferwallCredits event that returned YES. Note that the credits may represent multiple completions (see return parameter).
     
     "totalCredits" - (int) The total number of credits ever earned by the user.
     
     "totalCreditsFlag" - (BOOL) In some cases, we won’t be able to provide the exact amount of credits since the last event (specifically if the user clears the app’s data). In this case the ‘credits’ will be equal to the "totalCredits", and this flag will be YES.
     
     @param creditInfo Offerwall credit info.
     
     @return The publisher should return a BOOL stating if he handled this call (notified the user for example). if the return value is NO, the 'credits' value will be added to the next call.
     */
    public func didReceiveOfferwallCredits(_ creditInfo: [AnyHashable : Any]!) -> Bool {
        let storeCreditInfo = creditInfo["credits"]
        
        earnedUserCredits = storeCreditInfo as? String
        
        return true;
    }
    
    /**
     Called after the offerwall has been dismissed.
     */
    public func offerwallDidClose() {
        
        if (earnedUserCredits != nil){
            let alert = UIAlertController(title: "OfferWall Reward", message: "You have been rewarded \(earnedUserCredits ?? "0") credits.", preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
            
            self.present(alert, animated: true)
            earnedUserCredits = nil
        }
        
    }
    
    /**
     Called after the offerwall has attempted to show but failed.
     
     @param error The reason for the error.
     */
    public func offerwallDidFailToShowWithError(_ error: Error!) {
        
        
    }
    
    /**
     Called after the offerwall has been displayed on the screen.
     */
    public func offerwallDidShow() {
        
    }
    
    /**
     Called after the offerwall has changed its availability.
     
     @param available The new offerwall availability. YES if available and ready to be shown, NO otherwise.
     */
    public func offerwallHasChangedAvailability(_ available: Bool) {
        //        DispatchQueue.main.async{
        //            self.showOfferwallButton.isEnabled = available
        //        }
    }
    
    
}


