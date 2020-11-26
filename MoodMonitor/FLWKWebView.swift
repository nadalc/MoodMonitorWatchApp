import UIKit
import WebKit


extension WKWebView {

    // Use associated objects to set and get the request ivar
    func associatedObjectKey() -> String {
        return "kAssociatedObjectKey"
    }
    
    var request: URLRequest? {
        get {
            return objc_getAssociatedObject(self, associatedObjectKey()) as? URLRequest
        }
        set(newValue) {
            objc_setAssociatedObject(self, associatedObjectKey(), newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    

    // A simple convenience initializer, this allows for WKWebView(delegateView:) initialization
    convenience init(delegateView: AnyObject, config:WKWebViewConfiguration) {
        self.init(frame:(delegateView as! UIViewController).view.frame, configuration: config)
        self.uiDelegate = delegateView as? WKUIDelegate
        self.navigationDelegate = delegateView as? WKNavigationDelegate
    }
    // We will need to set both the UIDelegate AND navigationDelegate in the case of WebKit

     func setDelegateViews(_ viewController: UIViewController) {
          self.uiDelegate = viewController as? WKUIDelegate
          self.navigationDelegate = viewController as? WKNavigationDelegate
        let deviceIdentifier: String! = UIDevice.current.identifierForVendor?.uuidString
        let userScript = WKUserScript(
            source: "function i(){webkit.messageHandlers.callbackHandler.postMessage({\"username\":document.getElementById('id_username').value, \"password\":document.getElementById('id_password').value,\"device_id\":\"dessie_device\"});return true;}var dvi = document.createElement(\"input\");dvi.setAttribute(\"type\", \"hidden\");dvi.setAttribute(\"name\", \"device_id\");dvi.setAttribute('value', '" + deviceIdentifier + "');document.getElementById(\"login_form\").appendChild(dvi);document.getElementById('login_form').addEventListener('submit',i,false);",
            injectionTime: WKUserScriptInjectionTime.atDocumentEnd,
            forMainFrameOnly: true
        )
        self.configuration.userContentController.addUserScript(userScript)
        self.configuration.userContentController.add(
          viewController as! WKScriptMessageHandler,
            name: "callbackHandler"
        )
    }

    func clearDelegateViews(){
        self.uiDelegate = nil
        self.navigationDelegate = nil
        self.configuration.userContentController.removeAllUserScripts()
        self.configuration.userContentController.removeScriptMessageHandler(forName: "callbackHandler")
    }

    func currentURL() -> URL? {
        return self.url
    }
    
    func canNavigateBackward() -> Bool {
        return self.canGoBack
    }
    
    func canNavigateForward() -> Bool {
        return self.canGoForward
    }
    
    // A quick method for loading requests based on strings in a URL format
    func loadRequestFromString(_ urlNameAsString: String) {
          if let url = URL(string: urlNameAsString) {
               let request = NSMutableURLRequest(url: url)
               if APIConstants.isNativeNavEnabled {
                    request.setValue(APIConstants.appVersionHeaderValue, forHTTPHeaderField: APIConstants.appVersionHeaderKey)
               }
               self.load(request as URLRequest)
          }
    }
    
    // A quick method for loading requests based on strings in a URL format
    func loadRequestFromStringWithCredentials(_ urlNameAsString: String!, username: String!, password:String!) {
        return;        
    }
    
    // Pass this up the chain and let WebKit handle it
    func evaluateJS(_ javascriptString: String!, completionHandler: (AnyObject, NSError) -> ()) {
        self.evaluateJavaScript(javascriptString, completionHandler: { (AnyObject, NSError) -> Void in
            
        })
    }

}

extension WKScriptMessageHandler {
     
     func setupConfig() -> WKWebViewConfiguration {
             let config = WKWebViewConfiguration()

             let scriptMediaSource = """
             $('.mindf-player__play-btn').each(function(){
                 this.addEventListener("click", function(){
                     var id = $(this).attr('id')
                     var message = {element: id, mediaType: "audio", isPlaying: true};
                     window.webkit.messageHandlers.mediaClickListener.postMessage(message);
                 });
             });

             $('.mindf-player__pause-btn').each(function(){
                 this.addEventListener("click", function(){
                     var id = $(this).attr('id')
                     var message = {element: id, mediaType: "audio", isPlaying: false};
                     window.webkit.messageHandlers.mediaClickListener.postMessage(message);
                 });
             });

             $('.mindf-bking-track').each(function(){
                this.remove();
             });

             $(document).ready(function() {
                 $("video").append('playsinline');
             });

             """
             
             let script = WKUserScript(source: scriptMediaSource, injectionTime: .atDocumentEnd, forMainFrameOnly: false)
             config.allowsInlineMediaPlayback = true
             config.allowsPictureInPictureMediaPlayback = true
             config.userContentController.addUserScript(script)
             config.userContentController.add(self, name: "mediaClickListener")
             return config
         }
}
