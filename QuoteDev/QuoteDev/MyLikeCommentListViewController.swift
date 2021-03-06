//
//  MyLikeCommentListViewController.swift
//  QuoteDev
//
//  Created by leejaesung on 2017. 12. 2..
//  Copyright © 2017년 leejaesung. All rights reserved.
//

import UIKit
import Firebase

class MyLikeCommentListViewController: UIViewController {
    
    @IBOutlet weak var mainTableView: UITableView!
    
    var quotesSeriousData: [[String:String]] = [[:]]
    var quotesJoyfulData: [[String:String]] = [[:]]
    
    var isMyLikeView:Bool = true
    
    
    /*******************************************/
    //MARK:-        LifeCycle                  //
    /*******************************************/
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.mainTableView.delegate = self
        self.mainTableView.dataSource = self
        
        if self.isMyLikeView == true {
            // 나의 좋아요 명언 목록 가져오기 > 명언 데이터 가져오기
            self.getMyQuotesLikesList()
        }else {
            // 나의 댓글 명언 목록 가져오기 > 명언 데이터 가져오기
            self.getMyQuotesCommentsList()
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    /*******************************************/
    //MARK:-         Functions                 //
    /*******************************************/
    // MARK: 나의 좋아요 명언 목록 가져오기
    func getMyQuotesLikesList() {
        // 네트워크 인디케이터
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        
        guard let realUid = Auth.auth().currentUser?.uid else { return }
        let ref = Database.database().reference().child(Constants.firebaseUsersRoot).child(realUid).child("user_quotes_likes")
        ref.queryOrderedByKey().observeSingleEvent(of: DataEventType.value, with: {[unowned self] (snapshot) in
            // 네트워크 인디케이터
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            
            print("///// snapshot.value- 7293: \n", snapshot.value ?? "no data")
            
            var userQuotesLikesKeyList: [String] = []
            
            if snapshot.exists() {
                // 좋아요한 키 값들을 순차적으로 변수에 저장하기
                guard let data = snapshot.value as? [String:Bool] else { return }
                for item in data {
                    if item.value == true { // 좋아요 값이 true인 것만 보여주도록 구현
                        userQuotesLikesKeyList.append(item.key)
                    }
                }
                
            } else {
                print("///// snapshot is not exists()- 8203 \n")
            }
            
            // 실질적인 명언 데이터 가져오기
            self.getQuotesDataOf(keyList: userQuotesLikesKeyList)
            
        }) { (error) in
            print("///// error- 7392: \n", error)
        }
    }
    
    // MARK: 나의 댓글 명언 목록 가져오기
    func getMyQuotesCommentsList() {
        // 네트워크 인디케이터
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        
        guard let realUid = Auth.auth().currentUser?.uid else { return }
        let ref = Database.database().reference().child(Constants.firebaseUsersRoot).child(realUid).child("user_quotes_comments")
        ref.queryOrderedByKey().observeSingleEvent(of: DataEventType.value, with: {[unowned self] (snapshot) in
            // 네트워크 인디케이터
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            
            print("///// snapshot.value- 7293: \n", snapshot.value ?? "no data")
            
            var userQuotesCommentsKeyList: [String] = []
            
            if snapshot.exists() {
                // 좋아요한 키 값들을 순차적으로 변수에 저장하기
                guard let data = snapshot.value as? [String:Bool] else { return }
                for item in data {
                    if item.value == true { // 좋아요 값이 true인 것만 보여주도록 구현
                        userQuotesCommentsKeyList.append(item.key)
                    }
                }
                
            } else {
                print("///// snapshot is not exists()- 8203 \n")
            }
            
            // 실질적인 명언 데이터 가져오기
            self.getQuotesDataOf(keyList: userQuotesCommentsKeyList)
            
        }) { (error) in
            print("///// error- 7392: \n", error)
        }
    }
    
    // MARK: 좋아요한 명언 데이터 가져오기
    func getQuotesDataOf(keyList: [String]) {
        // 네트워크 인디케이터
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        
        for item in keyList {
            // 진지 모드의 명언 데이터 조회하기
            let ref = Database.database().reference().child("quotes_data_kor_serious").child(item)
            ref.observeSingleEvent(of: DataEventType.value, with: {[unowned self] (snapshot) in
                // 네트워크 인디케이터
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                
                if snapshot.exists() {
                    guard let data = snapshot.value as? [String:Any] else { return }
                    
                    let quoteID = data[Constants.firebaseQuoteID] as! String
                    let quoteText = data[Constants.firebaseQuoteText] as! String
                    let quoteAuthor = data[Constants.firebaseQuoteAuthor] as! String
                    
                    DispatchQueue.main.async {
                        self.quotesSeriousData.append(["quoteID":quoteID, "quoteText":quoteText, "quoteAuthor":quoteAuthor])
                        self.mainTableView.reloadData()
                    }
                    
                } else {
                    // 진지 모드에 없으면, 유쾌 모드의 데이터 조회하기
                    // 네트워크 인디케이터
                    UIApplication.shared.isNetworkActivityIndicatorVisible = true
                    
                    print("///// serious snapshot is not exists()- 8203 \n")
                    let ref = Database.database().reference().child("quotes_data_kor_joyful").child(item)
                    ref.observeSingleEvent(of: DataEventType.value, with: {[unowned self] (snapshot) in
                        // 네트워크 인디케이터
                        UIApplication.shared.isNetworkActivityIndicatorVisible = false
                        
                        if snapshot.exists() {
                            guard let data = snapshot.value as? [String:Any] else { return }
                            
                            let quoteID = data[Constants.firebaseQuoteID] as! String
                            let quoteText = data[Constants.firebaseQuoteText] as! String
                            let quoteAuthor = data[Constants.firebaseQuoteAuthor] as! String
                            
                            DispatchQueue.main.async {
                                self.quotesJoyfulData.append(["quoteID":quoteID, "quoteText":quoteText, "quoteAuthor":quoteAuthor])
                                self.mainTableView.reloadData()
                            }
                            
                        } else {
                            print("///// joyful snapshot is not exists()- 8273 \n")
                        }
                    }, withCancel: { (error) in
                        // 유쾌 모드 조회 에러
                        print("///// error- 9378: \n", error)
                    })
                }
                
            }, withCancel: { (error) in
                // 진지 모드 조회 에러
                print("///// error- 8293: \n", error)
            })
        }
        
    }
    
}


/*******************************************/
//MARK:-         extenstion                //
/*******************************************/
extension MyLikeCommentListViewController: UITableViewDelegate, UITableViewDataSource {
    
    // MARK: tableView - Section의 개수
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    // MARK: tableView - Row 개수
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return self.quotesSeriousData.count - 1
        case 1:
            return self.quotesJoyfulData.count - 1
        default:
            return 0
        }
    }
    
    // MARK: tableView - Section의 타이틀
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return "진지 모드"
        case 1:
            return "유쾌 모드"
        default:
            return nil
        }
    }
    
    // MARK: tableView - Cell 그리기
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let resultCell = tableView.dequeueReusableCell(withIdentifier: "MyLikeCommentListTableViewCell", for: indexPath) as! MyLikeCommentListTableViewCell
        
        switch indexPath.section {
        case 0:
            resultCell.quoteID = self.quotesSeriousData[indexPath.row + 1]["quoteID"]
            resultCell.labelQuoteText.text = self.quotesSeriousData[indexPath.row + 1]["quoteText"]
            resultCell.labelQuoteAuthor.text = self.quotesSeriousData[indexPath.row + 1]["quoteAuthor"]
            
            return resultCell
        case 1:
            resultCell.quoteID = self.quotesJoyfulData[indexPath.row + 1]["quoteID"]
            resultCell.labelQuoteText.text = self.quotesJoyfulData[indexPath.row + 1]["quoteText"]
            resultCell.labelQuoteAuthor.text = self.quotesJoyfulData[indexPath.row + 1]["quoteAuthor"]
            
            return resultCell
        default:
            return UITableViewCell()
        }
    }
    
    // MARK: tableView - Cell 선택 액션 정의
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        // 터치한 표시를 제거하는 액션
        tableView.deselectRow(at: indexPath, animated: true)
        
        // 명언 댓글 뷰로 이동
        switch indexPath.section {
        case 0:
            guard let realQuoteID = self.quotesSeriousData[indexPath.row + 1]["quoteID"] else { return }
            guard let realQuoteText = self.quotesSeriousData[indexPath.row + 1]["quoteText"] else { return }
            guard let realQuoteAuthor = self.quotesSeriousData[indexPath.row + 1]["quoteAuthor"] else { return }
            let nextVC = self.storyboard?.instantiateViewController(withIdentifier: Constants.quoteCommentViewController) as! QuoteCommentViewController
            
            nextVC.todayQuoteID = realQuoteID
            nextVC.QuoteText = realQuoteText
            nextVC.QuoteAuthor = realQuoteAuthor
            
            self.navigationController?.pushViewController(nextVC, animated: true)
        case 1:
            guard let realQuoteID = self.quotesSeriousData[indexPath.row + 1]["quoteID"] else { return }
            guard let realQuoteText = self.quotesJoyfulData[indexPath.row + 1]["quoteText"] else { return }
            guard let realQuoteAuthor = self.quotesJoyfulData[indexPath.row + 1]["quoteAuthor"] else { return }
            let nextVC = self.storyboard?.instantiateViewController(withIdentifier: Constants.quoteCommentViewController) as! QuoteCommentViewController
            
            nextVC.todayQuoteID = realQuoteID
            nextVC.QuoteText = realQuoteText
            nextVC.QuoteAuthor = realQuoteAuthor
            
            self.navigationController?.pushViewController(nextVC, animated: true)
        default: break
        }

    }
    
}
