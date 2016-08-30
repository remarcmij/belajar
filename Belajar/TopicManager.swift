//
//  TopicManager.swift
//  Belajar
//
//  Created by Jim Cramer on 28/08/2016.
//  Copyright © 2016 Belajar NL. All rights reserved.
//

import Foundation

class TopicManager {
    
    static let shared = TopicManager()
    
    static let didSyncTopicsNotification = Notification.Name("didSyncTopics")
    static let userInitiatedSync = "userInitiatedSync"
    static let newTopicCount = "newTopicCount"
    static let updatedTopicCount = "updatedTopicCount"
    static let deletedTopicCount = "deletedTopicCount"
    
    var upsertToDoCount = 0
    
    private lazy var preloadedTopicStore: TopicStore! = {
        let databasePath = Bundle.main.path(forResource: "Topics", ofType: "sqlite")
        return TopicStore(path: databasePath!)
    }()
    
    private lazy var syncableTopicStore: SyncableTopicStore? = {
        let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        let databasePath = (documentsPath as NSString).appendingPathComponent("SyncableTopics.sqlite")
        let topicStore = SyncableTopicStore(path: databasePath)
        guard topicStore.createTables() else {
            #if DEBUG
                print("Could not create tables in writable topic store")
            #endif
            return nil
        }
        return topicStore
    }()
    
    var allTopics: [Topic] {
        var topics = preloadedTopicStore.allTopics
        if let topicStore = syncableTopicStore {
            topics.append(contentsOf: topicStore.allTopics)
        }
        return topics
    }
    
    var indexTopics: [Topic] {
        var topics = preloadedTopicStore.getCollection()
        if syncableTopicStore != nil {
            topics.append(contentsOf: syncableTopicStore!.getCollection())
        }
        return topics
    }
    
    func getCollection() -> [Topic] {
        var topics = preloadedTopicStore.getCollection()
        if syncableTopicStore != nil {
            topics.append(contentsOf: syncableTopicStore!.getCollection())
        }
        return topics
    }
    
    func getPublicationTopics(for publication: String, preloaded: Bool) -> [Topic] {
        let topicStore: TopicStore = preloaded ? preloadedTopicStore : syncableTopicStore!
        return topicStore.getPublicationTopics(for: publication)
    }
    
    func getArticle(withTopicId topicId: Int, preloaded: Bool) -> Article? {
        let topicStore: TopicStore = preloaded ? preloadedTopicStore : syncableTopicStore!
        return topicStore.getArticle(withTopicId: topicId)
    }
    
    func syncTopics(isUserInitiated: Bool) {
        BackendService.shared.getHostTopics {[weak self] serverTopics in
            guard let localTopics = self?.allTopics else {
                return
            }
            if let (newTopics, updatedTopics, deletedTopics) = self?.compare(localTopics: localTopics, serverTopics: serverTopics!) {
                guard let me = self else { return }
                
                let userInfo = [TopicManager.userInitiatedSync: isUserInitiated,
                                TopicManager.newTopicCount: newTopics.count,
                                TopicManager.updatedTopicCount: updatedTopics.count,
                                TopicManager.deletedTopicCount: deletedTopics.count] as [String : Any]
                
                let notifier: () -> Void = {_ in
                    DispatchQueue.main.async() { _ in
                        NotificationCenter.default.post(name: TopicManager.didSyncTopicsNotification,
                                                        object: self,
                                                        userInfo: userInfo)
                    }
                }
                
                for topic in deletedTopics {
                    me.syncableTopicStore?.delete(topic: topic)
                }
                
                me.upsertToDoCount = newTopics.count + updatedTopics.count
                if me.upsertToDoCount == 0 {
                    notifier()
                }
                
                for topic in newTopics {
                    me.upsertAsync(topic: topic, notifier: notifier)
                }
                
                for topic in updatedTopics {
                    me.upsertAsync(topic: topic, notifier: notifier)
                }
            }
        }
    }
    
    private func upsertAsync(topic: Topic, notifier: @escaping () -> Void) {
        BackendService.shared.getHostArticle(fileName: topic.fileName) { [weak self] article in
            guard let me = self else { return }
            DispatchQueue.main.async() { _ in
                me.syncableTopicStore?.upsert(topic: topic, article: article)
                me.upsertToDoCount -= 1
                if me.upsertToDoCount <= 0 {
                    notifier()
                }
            }
        }
    }
    
    private func compare(localTopics: [Topic], serverTopics: [Topic]) -> ([Topic], [Topic], [Topic]) {
        var newTopics = [Topic]()
        var updatedTopics = [Topic]()
        var deletedTopics = [Topic]()
        var referencedLocalTopicIds = Set<Int>()
        
        for serverTopic in serverTopics {
            var localTopic: Topic?
            for topic in localTopics {
                if topic.fileName == serverTopic.fileName {
                    localTopic = topic
                    break
                }
            }
            if localTopic == nil {
                newTopics.append(serverTopic)
            } else {
                referencedLocalTopicIds.insert(localTopic!.id)
                if localTopic!.lastModified != nil && localTopic!.lastModified! != serverTopic.lastModified! {
                    referencedLocalTopicIds.insert(localTopic!.id)
                    serverTopic.id = localTopic!.id
                    updatedTopics.append(serverTopic)
                }
            }
        }
        
        for localTopic in localTopics {
            if localTopic.lastModified != nil && !referencedLocalTopicIds.contains(localTopic.id) {
                deletedTopics.append(localTopic)
            }
        }
        
        #if DEBUG
            print("Topics to synchronize: new: \(newTopics.count), updated: \(updatedTopics.count), deleted: \(deletedTopics.count)")
        #endif
        
        return (newTopics, updatedTopics, deletedTopics)
    }
}
