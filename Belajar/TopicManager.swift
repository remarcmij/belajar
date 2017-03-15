//
//  TopicManager.swift
//  Belajar
//
//  Created by Jim Cramer on 28/08/2016.
//  Copyright © 2016 Belajar NL. All rights reserved.
//

import Foundation

private var syncableTopicsDatabasePath: String = {
    let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
    return (documentsPath as NSString).appendingPathComponent("SyncableTopics.sqlite")
}()

class TopicManager {
    
    static let shared = TopicManager()
    
    static let didSyncTopicsNotification = Notification.Name("didSyncTopics")
    static let userInitiatedSync = "userInitiatedSync"
    static let newTopicCount = "newTopicCount"
    static let updatedTopicCount = "updatedTopicCount"
    static let deletedTopicCount = "deletedTopicCount"
    
    var upsertToDoCount = 0
    
    private lazy var preloadedTopicStore: TopicStore = {
        let databasePath = Bundle.main.path(forResource: "Topics", ofType: "sqlite")
        return TopicStore(path: databasePath!)
    }()
    
    private lazy var syncableTopicStore: SyncableTopicStore = SyncableTopicStore(path: syncableTopicsDatabasePath)
    
    var indexTopics: [Topic] {
        var topics = preloadedTopicStore.getCollection()
        topics.append(contentsOf: syncableTopicStore.getCollection())
        return topics
    }
    
    func getCollection() -> [Topic] {
        var topics = preloadedTopicStore.getCollection()
        topics.append(contentsOf: syncableTopicStore.getCollection())
        return topics
    }
    
    func getAllTopics() -> [Topic] {
        var topics = syncableTopicStore.getAllTopics()
        let syncableTopicFileNameSet = Set(topics.map({$0.fileName}))
        let filteredPreloadedTopics = preloadedTopicStore.getAllTopics()
            .filter {!syncableTopicFileNameSet.contains($0.fileName)}
        topics.append(contentsOf: filteredPreloadedTopics)
        return topics
    }
    
    func getPublicationTopics(for publication: String) -> [Topic] {
        var topics = syncableTopicStore.getPublicationTopics(for: publication)
        let syncableTopicFileNameSet = Set(topics.map({$0.fileName}))
        let filteredPreloadedTopics = preloadedTopicStore.getPublicationTopics(for: publication)
            .filter {!syncableTopicFileNameSet.contains($0.fileName)}
        topics.append(contentsOf: filteredPreloadedTopics)

        return topics.sorted() {
            if $0.sortIndex < $1.sortIndex {
                return true
            } else if $0.sortIndex > $1.sortIndex {
                return false
            } else {
                return $0.title < $1.title
            }
        }
    }
    
    func getArticle(withTopicId topicId: Int, preloaded: Bool) -> Article? {
        let topicStore: TopicStore = preloaded ? preloadedTopicStore : syncableTopicStore
        return topicStore.getArticle(withTopicId: topicId)
    }
    
    func syncTopics(isUserInitiated: Bool) {
        
        BackendClient.shared.getHostTopics {[weak self] serverTopics in
            guard let me = self else {
                return
            }
            
            let localTopics = me.getAllTopics()
            let (newTopics, updatedTopics, deletedTopics) = me.compare(localTopics: localTopics, serverTopics: serverTopics!)
            
            func didSyncTopics() {
                DispatchQueue.main.async() {
                    let userInfo = [TopicManager.userInitiatedSync: isUserInitiated,
                                    TopicManager.newTopicCount: newTopics.count,
                                    TopicManager.updatedTopicCount: updatedTopics.count,
                                    TopicManager.deletedTopicCount: deletedTopics.count] as [String : Any]
                    NotificationCenter.default.post(name: TopicManager.didSyncTopicsNotification,
                                                    object: self,
                                                    userInfo: userInfo)
                }
            }
            
            if newTopics.count + updatedTopics.count + deletedTopics.count == 0 {
                didSyncTopics()
                return
            }
            
            var fileNames = newTopics.map({$0.fileName})
            fileNames.append(contentsOf: updatedTopics.map({$0.fileName}))
            
            BackendClient.shared.getHostArticles(withFileNames: fileNames) { articles in
                
                let queue = DispatchQueue(label: "TopicManager", attributes: [])
                queue.sync {
                    
                    let mutatingStore = SyncableTopicStore(path: syncableTopicsDatabasePath)
                    
                    for topic in deletedTopics {
                        mutatingStore.delete(topic: topic)
                    }
                    
                    for topic in newTopics {
                        mutatingStore.upsert(topic: topic, article: articles[topic.fileName]!)
                    }
                    
                    for topic in updatedTopics {
                        mutatingStore.upsert(topic: topic, article: articles[topic.fileName]!)
                    }
                    
                    didSyncTopics()
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
                if localTopic!.topicHash != serverTopic.topicHash {
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
