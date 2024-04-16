//
//  ChoicesCell.swift
//  VoiceAssistant
//
//  Created by Osama Hasan on 13/03/2024.
//

import UIKit

class ChoicesCell: UITableViewCell {

    @IBOutlet weak var collectionView: ContentSizedCollectionView!
    @IBOutlet weak var messageLabel: UILabel!
    
    var choices: [DialogChoice] = []
    var selectItemAt:((DialogChoice)->Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(cellClass: ChipCell.self)
        
        let flowLayout = AlignedCollectionViewFlowLayout(
            horizontalAlignment: .left,
            verticalAlignment: .top
        )
        
       // let flowLayout = LeftAlignedCollectionViewFlowLayout()
        flowLayout.scrollDirection = .vertical
        flowLayout.sectionInset = UIEdgeInsets(top: 12, left: 0, bottom: 0, right: 0)
        flowLayout.minimumInteritemSpacing = 10
        flowLayout.minimumLineSpacing = 15
        flowLayout.estimatedItemSize = CGSize(width: 40, height: UIScreen.main.bounds.width)
        collectionView.collectionViewLayout = flowLayout
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
    func setData(data:ConversationDialog){
        if let replies = data.choices {
            choices = replies
            collectionView.reloadData()
        }
        
        messageLabel.isHidden = !data.hasMessage
        messageLabel.text = data.message
    }
    
}


extension ChoicesCell : UICollectionViewDelegate,UICollectionViewDataSource{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return choices.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let item = choices[indexPath.row]
        let cell = collectionView.dequeueReusableCell(withClass: ChipCell.self, for: indexPath )
        cell.setData(data: item.title)
        return cell
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let item = choices[indexPath.row]
        selectItemAt?(item)
    }
}


