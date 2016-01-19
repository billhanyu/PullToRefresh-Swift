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

private let refreshViewHeight: CGFloat = 200

func delayBySeconds(seconds: Double, delayCode: () -> ()) {
    let targetTime = dispatch_time(DISPATCH_TIME_NOW, Int64(Double(NSEC_PER_SEC) * seconds))
    dispatch_after(targetTime, dispatch_get_main_queue(), {
        delayCode()
    })
}

class RefreshableTableViewController: UITableViewController {
    
    var refreshView: RefreshView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        refreshView = RefreshView(frame: CGRect(x: 0, y: -refreshViewHeight, width: CGRectGetWidth(view.bounds), height: refreshViewHeight), scrollView: tableView)
        refreshView.delegate = self
        refreshView.translatesAutoresizingMaskIntoConstraints = false
        view.insertSubview(refreshView, atIndex: 0)
    }
    
    override func scrollViewWillEndDragging(scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        refreshView.scrollViewWillEndDragging(scrollView, withVelocity: velocity, targetContentOffset: targetContentOffset)
    }
    
    override func scrollViewDidScroll(scrollView: UIScrollView) {
        refreshView.scrollViewDidScroll(scrollView)
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 20
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as UITableViewCell
        
        cell.textLabel?.text = "Cell \(indexPath.row)"
        
        return cell
    }
}

extension RefreshableTableViewController: RefreshViewDelegate {
    func refreshViewDieRefresh(refreshView: RefreshView) {
        delayBySeconds(3, delayCode: {
            self.refreshView.endRefreshing()
        })
    }
}
