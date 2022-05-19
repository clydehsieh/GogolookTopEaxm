//
//  ViewModelTypeTest.swift
//  GogolookExamTests
//
//  Created by ClydeHsieh on 2022/5/18.
//

import XCTest
import Combine
@testable import GogolookExam

class ViewModelTypeTest: XCTestCase {
    var subscription: Set<AnyCancellable> = .init()
    
    func testAnimeApiFlow() {
        typealias DataTuple = (NetworkManagerSpy<AnimeTopResponse>,FavoriteItemCacheService, ViewModel)
        let (networkManager, _, viewModel): DataTuple = makeSUT()
        
        var resultItems: [ItemTableViewCellConfigurable] = []
        
        viewModel.updateItemListSubject
            .sink { updateType in
                switch updateType {
                case let .new(items):
                    resultItems = items
                case let .append(items):
                    resultItems.append(contentsOf: items)
                }
            }
            .store(in: &subscription)

        networkManager.mockResponse = makeMocAnimeResponse()
        let baseCount = networkManager.mockResponse?.data.count ?? 0
        
        XCTAssertEqual(resultItems.count, 0)
        viewModel.currentPage.send(1)
        XCTAssertEqual(resultItems.count, baseCount * 1)
        
        addTeardownBlock { [ weak viewModel] in
            XCTAssertNil(viewModel, "viewModel should have been deallocated. Potential memory leak", file: #filePath, line: #line)
        }
    }
    
    func testMangaApiFlow() {
        typealias DataTuple = (NetworkManagerSpy<MangaTopResponse>,FavoriteItemCacheService, ViewModel)
        let (networkManager, _, viewModel): DataTuple = makeSUT()
        
        var resultItems: [ItemTableViewCellConfigurable] = []
        
        viewModel.updateItemListSubject
            .sink { updateType in
                switch updateType {
                case let .new(items):
                    resultItems = items
                case let .append(items):
                    resultItems.append(contentsOf: items)
                }
            }
            .store(in: &subscription)

        networkManager.mockResponse = makeMocMangaResponse()
        let baseCount = networkManager.mockResponse?.data.count ?? 0
        
        XCTAssertEqual(resultItems.count, 0)
        viewModel.currentListType.send(.manga)
        XCTAssertEqual(resultItems.count, baseCount * 1)
        
        addTeardownBlock { [ weak viewModel] in
            XCTAssertNil(viewModel, "viewModel should have been deallocated. Potential memory leak", file: #filePath, line: #line)
        }
    }
    
    func testLoadMareApiFlow() {
        typealias DataTuple = (NetworkManagerSpy<AnimeTopResponse>,FavoriteItemCacheService, ViewModel)
        let (networkManager, _, viewModel): DataTuple = makeSUT()
        
        var resultItems: [ItemTableViewCellConfigurable] = []
        
        viewModel.updateItemListSubject
            .sink { updateType in
                switch updateType {
                case let .new(items):
                    resultItems = items
                case let .append(items):
                    resultItems.append(contentsOf: items)
                }
            }
            .store(in: &subscription)

        networkManager.mockResponse = makeMocAnimeResponse()
        let baseCount = networkManager.mockResponse?.data.count ?? 0
        
        XCTAssertEqual(resultItems.count, 0)
        viewModel.currentPage.send(1)
        XCTAssertEqual(resultItems.count, baseCount * 1)
        viewModel.currentPage.send(2)
        XCTAssertEqual(resultItems.count, baseCount * 2)
        
        
        addTeardownBlock { [ weak viewModel] in
            XCTAssertNil(viewModel, "viewModel should have been deallocated. Potential memory leak", file: #filePath, line: #line)
        }
    }
    
    func testChangeParameterTypeApiFlow() {
        typealias DataTuple = (NetworkManagerSpy<AnimeTopResponse>,FavoriteItemCacheService, ViewModel)
        let (networkManager, _, viewModel): DataTuple = makeSUT()
        
        var resultItems: [ItemTableViewCellConfigurable] = []
        
        viewModel.updateItemListSubject
            .sink { updateType in
                switch updateType {
                case let .new(items):
                    resultItems = items
                case let .append(items):
                    resultItems.append(contentsOf: items)
                }
            }
            .store(in: &subscription)

        networkManager.mockResponse = makeMocAnimeResponse()
        let baseCount = networkManager.mockResponse?.data.count ?? 0
        
        XCTAssertEqual(resultItems.count, 0)
        viewModel.currentPage.send(1)
        XCTAssertEqual(resultItems.count, baseCount * 1)
        viewModel.currentPage.send(2)
        XCTAssertEqual(resultItems.count, baseCount * 2)
        viewModel.currentParamType.send("test")
        XCTAssertEqual(resultItems.count, baseCount * 1)
        
        addTeardownBlock { [ weak viewModel] in
            XCTAssertNil(viewModel, "viewModel should have been deallocated. Potential memory leak", file: #filePath, line: #line)
        }
    }
    
    func testChangeParameterFilterApiFlow() {
        typealias DataTuple = (NetworkManagerSpy<AnimeTopResponse>,FavoriteItemCacheService, ViewModel)
        let (networkManager, _, viewModel): DataTuple = makeSUT()
        
        var resultItems: [ItemTableViewCellConfigurable] = []
        
        viewModel.updateItemListSubject
            .sink { updateType in
                switch updateType {
                case let .new(items):
                    resultItems = items
                case let .append(items):
                    resultItems.append(contentsOf: items)
                }
            }
            .store(in: &subscription)

        networkManager.mockResponse = makeMocAnimeResponse()
        let baseCount = networkManager.mockResponse?.data.count ?? 0
        
        XCTAssertEqual(resultItems.count, 0)
        viewModel.currentPage.send(1)
        XCTAssertEqual(resultItems.count, baseCount * 1)
        viewModel.currentPage.send(2)
        XCTAssertEqual(resultItems.count, baseCount * 2)
        viewModel.currentParamFilter.send("test")
        XCTAssertEqual(resultItems.count, baseCount * 1)
        
        addTeardownBlock { [ weak viewModel] in
            XCTAssertNil(viewModel, "viewModel should have been deallocated. Potential memory leak", file: #filePath, line: #line)
        }
    }
}

extension ViewModelTypeTest {
    func makeSUT<T: Decodable>() -> (networkManager: NetworkManagerSpy<T>,
                       itemCacheService: FavoriteItemCacheService,
                       viewModel: ViewModel ) {
        
        let networkManager: NetworkManagerSpy<T> = .init()
        let coreDataStoreSpy = CoreDataStoreSpy()
        let itemCacheService = FavoriteItemCacheService(coreDataStore: coreDataStoreSpy)
        let viewMode = ViewModel(networkManager: networkManager, itemCacheService: itemCacheService)
        
        return (networkManager, itemCacheService, viewMode)
    }
    
    func makeMocAnimeResponse() -> AnimeTopResponse {
        func mockAired() -> Aired {
            .init(from: .now, to: .now.addingTimeInterval(-50))
        }
        let iamge: Image = .init(imageURL: "", smallImageURL: "", largeImageURL: "")
        
        let data1: AnimeData = .init(malID: 0, title: "title0", url: "url0", images: ["key": iamge], aired: mockAired() , rank: 0)
        let data2: AnimeData = .init(malID: 1, title: "title1", url: "url1", images: ["key": iamge], aired: mockAired() , rank: 0)
        
        let items: Items = .init(count: 10, total: 10, perPage: 10)
        let page: Pagination = .init(lastVisiblePage: 1, hasNextPage: false, currentPage: 1, items: items)
        let mockResponse: AnimeTopResponse = .init(data: [data1, data2], pagination: page)
        
        return mockResponse
    }
    
    func makeMocMangaResponse() -> MangaTopResponse {
        let iamge: Image = .init(imageURL: "", smallImageURL: "", largeImageURL: "")
        
        let data1: MangaData = .init(malID: 0, title: "title0", url: "url0", images: ["key": iamge], published: .init(from: .now, to:.now) , rank: 0)
        let data2: MangaData = .init(malID: 1, title: "title1", url: "url1", images: ["key": iamge], published: .init(from: .now, to:.now) , rank: 0)
        
        let items: Items = .init(count: 10, total: 10, perPage: 10)
        let page: Pagination = .init(lastVisiblePage: 1, hasNextPage: false, currentPage: 1, items: items)
        let mockResponse: MangaTopResponse = .init(data: [data1, data2], pagination: page)
        
        return mockResponse
    }
}


//MARK: -
enum APIError: Error {
    case unknow
}

struct CoreDataStoreSpy: CoreDataStoreType {
    func insertItemEntityData(data: ItemTableViewCellConfigurable) throws {
        
    }
    
    func fetchItem(malID: Int) throws -> [ItemEntity] {
        return []
    }
    
    func fetchItems() throws -> [ItemEntity] {
        return []
    }
    
    func deleteItem(malID: Int) throws {
        
    }
}

//MARK: - ItemApiServiceTest
class NetworkManagerSpy<T>: NetworkManager {
    
    var mockResponse: T?
    
    override func request<T>(endPoint: EndPoint, responseType: T.Type) -> AnyPublisher<T, Error> where T : Decodable {
        Deferred {
            Future { [unowned self] promise in
                if let response = self.mockResponse as? T {
                    promise(.success(response))
                } else {
                    promise(.failure(APIError.unknow))
                }
            }
        }.eraseToAnyPublisher()
    }
}
