/*
* Copyright (c) 2015 Razeware LLC
*
* Permission is hereby granted, free of charge, to any person obtaining a copy
* of this software and associated documentation files (the "Software"), to deal
* in the Software without restriction, including without limitation the rights
* to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
* copies of the Software, and to permit persons to whom the Software is
* furnished to do so, subject to the following conditions:
*
* The above copyright notice and this permission notice shall be included in
* all copies or substantial portions of the Software.
*
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
* AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
* LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
* OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
* THE SOFTWARE.
*/

import UIKit

private let sceneHeight: CGFloat = 120

protocol RefreshViewDelegate: class {
    func refreshViewDieRefresh(refreshView: RefreshView)
}

class RefreshView: UIView {
    
    private unowned var scrollView: UIScrollView
    var progressPercentage: CGFloat = 0
    weak var delegate: RefreshViewDelegate?
    
    var isRefreshing = false
    var refreshItems = [RefreshItem]()
    
    required init(coder aDecoder: NSCoder) {
        scrollView = UIScrollView()
        assert(false, "use init(frame:scrollView:)")
        super.init(coder: aDecoder)!
    }
    
    init(frame: CGRect, scrollView: UIScrollView) {
        self.scrollView = scrollView
        super.init(frame: frame)
        updateBackgroundColor()
        setupRefreshItems()
        print(CGRectGetWidth(bounds))
    }
    
    func setupRefreshItems() {
        let groundImageView = UIImageView(image: UIImage(named: "ground"))
        let buildingsImageView = UIImageView(image: UIImage(named: "buildings"))
        let sunImageView = UIImageView(image: UIImage(named: "sun"))
        let catImageView = UIImageView(image: UIImage(named: "cat"))
        let capeBackImageView = UIImageView(image: UIImage(named: "cape_back"))
        let capeFrontImageView = UIImageView(image: UIImage(named: "cape_front"))
        
        refreshItems = [
            RefreshItem(view: groundImageView,
                centerEnd: CGPoint(x: CGRectGetMidX(bounds), y: CGRectGetHeight(bounds) - CGRectGetHeight(groundImageView.bounds) / 2),
                parallaxRatio: 0.5, sceneHeight: sceneHeight),
            RefreshItem(view: buildingsImageView,
                centerEnd: CGPoint(x: CGRectGetMidX(bounds), y: CGRectGetHeight(bounds) - CGRectGetHeight(groundImageView.bounds) - CGRectGetHeight(buildingsImageView.bounds) / 2.0),
                parallaxRatio: 1.5, sceneHeight: sceneHeight),
            RefreshItem(view: sunImageView,
                centerEnd: CGPoint(x: CGRectGetWidth(bounds) * 0.1, y: CGRectGetHeight(bounds) - CGRectGetHeight(groundImageView.bounds) - CGRectGetHeight(sunImageView.bounds)),
                parallaxRatio: 3, sceneHeight: sceneHeight),
            RefreshItem(view: capeBackImageView,
                centerEnd: CGPoint(x: CGRectGetMidX(bounds), y: CGRectGetHeight(bounds) - CGRectGetHeight(groundImageView.bounds)/2 - CGRectGetHeight(capeBackImageView.bounds)/2),
                parallaxRatio: -1, sceneHeight: sceneHeight),
            RefreshItem(view: catImageView,
                centerEnd: CGPoint(x: CGRectGetMidX(bounds), y: CGRectGetHeight(bounds) - CGRectGetHeight(groundImageView.bounds)/2 - CGRectGetHeight(catImageView.bounds)/2),
                parallaxRatio: 1, sceneHeight: sceneHeight),
            RefreshItem(view: capeFrontImageView,
                centerEnd: CGPoint(x: CGRectGetMidX(bounds), y: CGRectGetHeight(bounds) - CGRectGetHeight(groundImageView.bounds)/2 - CGRectGetHeight(capeFrontImageView.bounds)/2),
                parallaxRatio: -1, sceneHeight: sceneHeight)
        ]
        
        for refreshItem in refreshItems {
            addSubview(refreshItem.view)
        }
    }
    
    func updateBackgroundColor() {
        let value = progressPercentage * 0.7 + 0.2
        backgroundColor = UIColor(red: value, green: value, blue: value, alpha: 1.0)
    }
    
    func updateRefreshItemPositions() {
        for refreshItem in refreshItems {
            refreshItem.updateViewPositionForPercentage(progressPercentage)
        }
    }
    
    func beginRefreshing() {
        isRefreshing = true
        
        UIView.animateWithDuration(0.4, delay: 0, options: .CurveEaseInOut, animations: {
                self.scrollView.contentInset.top += sceneHeight
            }, completion: { _ in
                
        })
    }
    
    func endRefreshing() {
        UIView.animateWithDuration(0.4, delay: 0, options: .CurveEaseInOut, animations: {
                self.scrollView.contentInset.top -= sceneHeight
            }, completion: { _ in
                self.isRefreshing = false
        })
    }
}

extension RefreshView: UIScrollViewDelegate {
    func scrollViewWillEndDragging(scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        if !isRefreshing && progressPercentage == 1 {
            beginRefreshing()
            targetContentOffset.memory.y = -scrollView.contentInset.top
            delegate?.refreshViewDieRefresh(self)
        }
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        if isRefreshing {
            return
        }
        
        let visibleHeight = max(0, -(scrollView.contentOffset.y + scrollView.contentInset.top))
        progressPercentage = min(1, visibleHeight / sceneHeight)
        
        updateBackgroundColor()
        updateRefreshItemPositions()
    }
}
