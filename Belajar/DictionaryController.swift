//
//  DictionaryController.swift
//  Belajar
//
//  Created by Jim Cramer on 19/06/16.
//  Copyright © 2016 Belajar NL. All rights reserved.
//

import UIKit
import TTTAttributedLabel

extension UIColor {
    convenience init(red: Int, green: Int, blue: Int) {
        assert(red >= 0 && red <= 255, "Invalid red component")
        assert(green >= 0 && green <= 255, "Invalid green component")
        assert(blue >= 0 && blue <= 255, "Invalid blue component")
        
        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
    }
    
    convenience init(netHex: Int) {
        self.init(red:(netHex >> 16) & 0xff, green:(netHex >> 8) & 0xff, blue:netHex & 0xff)
    }
}

private let linkColor = UIColor(netHex: 0x303F9F)
private let linkAttributes = [
    NSUnderlineStyleAttributeName: NSNumber(value: NSUnderlineStyle.styleNone.rawValue),
    NSForegroundColorAttributeName: linkColor
]

class DictionaryController : UITableViewController, TTTAttributedLabelDelegate {
    
    var aggregates: [LemmaAggregate]!
    var attributedStringCache = [Int: AttributedString]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.estimatedRowHeight = 97.0
        self.tableView.separatorStyle = .none
        self.tableView.rowHeight = UITableViewAutomaticDimension
        
        NotificationCenter.default().addObserver(self, selector: #selector(receiveLookupNotification), name: lookupNotification, object: nil)
        lookup(word: "lari", lang: "id")
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return aggregates?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let row = indexPath.row
        let aggregate = aggregates[row]
        
        if (row == 0 || aggregates[row-1].base != aggregate.base) {
            return getHeaderCell(aggregate: aggregate, cellForRowAt: indexPath)
        } else {
            return getBodyCell(aggregate: aggregate, cellForRowAt: indexPath)
        }
    }

    private func getHeaderCell(aggregate: LemmaAggregate, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "HeaderCell", for: indexPath)
        if cell.viewWithTag(1) == nil {
            let headerLabel = TTTAttributedLabel(frame: CGRect.zero)
            headerLabel.tag = 1
            headerLabel.isUserInteractionEnabled = true
            headerLabel.delegate = self
            headerLabel.linkAttributes = linkAttributes
            cell.contentView.addSubview(headerLabel)
            
            let bodyLabel = makeBodyLabel();
            bodyLabel.tag = 2
            cell.contentView.addSubview(bodyLabel)
            
            let viewsDict = ["headerLabel": headerLabel, "bodyLabel": bodyLabel]
            headerLabel.translatesAutoresizingMaskIntoConstraints = false
            bodyLabel.translatesAutoresizingMaskIntoConstraints = false
            
            var constraints = [NSLayoutConstraint]()
            constraints.append(contentsOf: NSLayoutConstraint.constraints(withVisualFormat: "H:|-16-[headerLabel]-16-|", options: [], metrics: nil, views: viewsDict))
            constraints.append(contentsOf: NSLayoutConstraint.constraints(withVisualFormat: "H:|-16-[bodyLabel]-16-|", options: [], metrics: nil, views: viewsDict))
            constraints.append(contentsOf: NSLayoutConstraint.constraints(withVisualFormat: "V:|-24-[headerLabel]-8-[bodyLabel]-4-|", options: [], metrics: nil, views: viewsDict))
            NSLayoutConstraint.activate(constraints)
        }
        
        let headerLabel = cell.viewWithTag(1) as! TTTAttributedLabel
        var headerText = "**\(aggregate.base.uppercased())**"
        if aggregate.base != aggregate.word {
            headerText = "▷ " + headerText
        }
        headerLabel.setText(Util.makeAttributedText(from: headerText, useSmallFont: true))
        
        let bodyLabel = cell.viewWithTag(2) as! TTTAttributedLabel
        bodyLabel.setText(getAttributedString(for: aggregate.body, index: indexPath.row))
        return cell
    }
    
    private func getBodyCell(aggregate: LemmaAggregate, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "BodyCell", for: indexPath)
        if cell.viewWithTag(1) == nil {
            let bodyLabel = makeBodyLabel()
            bodyLabel.tag = 1
            cell.contentView.addSubview(bodyLabel)
            
            let viewsDict = ["bodyLabel": bodyLabel]
            bodyLabel.translatesAutoresizingMaskIntoConstraints = false
            
            var constraints = [NSLayoutConstraint]()
            constraints.append(contentsOf: NSLayoutConstraint.constraints(withVisualFormat: "H:|-16-[bodyLabel]-16-|", options: [], metrics: nil, views: viewsDict))
            constraints.append(contentsOf: NSLayoutConstraint.constraints(withVisualFormat: "V:|-8-[bodyLabel]-4-|", options: [], metrics: nil, views: viewsDict))
            NSLayoutConstraint.activate(constraints)
        }
        
        let bodyLabel = cell.viewWithTag(1) as! TTTAttributedLabel
        bodyLabel.setText(getAttributedString(for: aggregate.body, index: indexPath.row))
        return cell
    }
    
    private func makeBodyLabel() -> TTTAttributedLabel {
        let bodyLabel = TTTAttributedLabel(frame: CGRect.zero)
        bodyLabel.isUserInteractionEnabled = true
        bodyLabel.delegate = self
        bodyLabel.numberOfLines = 0
        bodyLabel.linkAttributes = linkAttributes
        return bodyLabel
    }
    
    func attributedLabel(_ label: TTTAttributedLabel!, didSelectLinkWith url: URL!) {
        let word = url.query!.components(separatedBy: "=")[1];
        if let decoded = word.removingPercentEncoding {
            NotificationCenter.default().post(name: lookupNotification, object: nil, userInfo: ["word": decoded])
        }
    }
    
    private func getAttributedString(for text: String, index: Int) -> AttributedString {
        if let attributedString = attributedStringCache[index] {
            return attributedString
        }
        let attributedString = Util.makeAttributedText(from: text)
        attributedStringCache[index] = attributedString
        return attributedString
    }
    
    func receiveLookupNotification(notification: Notification) {
        if let word = notification.userInfo?["word"] as? String {
            print("received notification \(word)")
            lookup(word: word, lang: "id")
        }
    }
    
    func lookup(word: String, lang: String) {
        let startTime = Date()
        
        let normalisedWord = word.folding(.diacriticInsensitiveSearch, locale: Locale.current()).lowercased()
        aggregates = DictionaryStore.sharedInstance.aggregateSearch(word: normalisedWord, lang: lang)

        attributedStringCache.removeAll()
        self.tableView.reloadData()
        self.tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: false)

        let endTime = Date()
        let elapsed = endTime.timeIntervalSince(startTime) * 1000
        print("lookup \(word) took \(elapsed) ms")
    }
    
}
