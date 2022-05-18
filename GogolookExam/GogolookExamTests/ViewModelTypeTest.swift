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
    
    let animeRequest: PassthroughSubject<ItemRequestType, Error> = .init()
    let mangaRequest: PassthroughSubject<ItemRequestType, Error> = .init()
    
    var subscription: Set<AnyCancellable> = .init()
    
    func testAnimeApiFlow() {
        let (service, _, _, viewModel) = makeSUT()
        
        viewModel.binding(fetchAnime: animeRequest.eraseToAnyPublisher() )
            .sink { completion in
                //
            } receiveValue: { endResponse in
                //
            }
            .store(in: &subscription)

        
        XCTAssertEqual(service.fetchAnimeDataCounter, 0)
        animeRequest.send(ItemReqeustMock())
        XCTAssertEqual(service.fetchAnimeDataCounter, 1)
        
        addTeardownBlock { [weak service, weak viewModel] in
            XCTAssertNil(service, "service should have been deallocated. Potential memory leak", file: #filePath, line: #line)
            XCTAssertNil(viewModel, "viewModel should have been deallocated. Potential memory leak", file: #filePath, line: #line)
        }
    }
    
    func testMangaApiFlow() {
        let (service, _, _, viewModel) = makeSUT()
        
        viewModel.binding(fetchManga: mangaRequest.eraseToAnyPublisher() )
            .sink { completion in
                //
            } receiveValue: { endResponse in
                //
            }
            .store(in: &subscription)

        
        XCTAssertEqual(service.fetchMangaDataCounter, 0)
        mangaRequest.send(ItemReqeustMock())
        XCTAssertEqual(service.fetchMangaDataCounter, 1)
        
        addTeardownBlock { [weak service, weak viewModel] in
            XCTAssertNil(service, "service should have been deallocated. Potential memory leak", file: #filePath, line: #line)
            XCTAssertNil(viewModel, "viewModel should have been deallocated. Potential memory leak", file: #filePath, line: #line)
        }
    }
}


extension ViewModelTypeTest {
    func makeSUT() -> (service: ItemApiServiceSpy,
                       coreDataStoreSpy: CoreDataStoreSpy,
                       itemCacheService: FavoriteItemCacheService,
                       viewModel: ViewModel ) {
        let service = ItemApiServiceSpy()
        let coreDataStoreSpy = CoreDataStoreSpy()
        let itemCacheService = FavoriteItemCacheService(coreDataStore: coreDataStoreSpy)
        let viewMode = ViewModel(service: service, itemCacheService: itemCacheService)
        
        return (service, coreDataStoreSpy, itemCacheService, viewMode)
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

//MARK: ItemReqeustTypeSpy
struct ItemReqeustMock: ItemRequestType {
    var type: String? = "type"
    var filter: String? = "filter"
    var page: Int  = 1
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
class ItemApiServiceSpy: ItemApiServiceType {
    var fetchAnimeDataCounter = 0
    var fetchMangaDataCounter = 0
    
    var animeMonckResponse: AnimeTopResponse?
    var mangaMonckResponse: MangaTopResponse?
    
    init() { }
}

extension ItemApiServiceSpy {
    func fetchTop(param: ItemRequestType) -> AnyPublisher<AnimeTopResponse, Error> {
        return Deferred {
            Future { [unowned self] promise in
                self.fetchAnimeDataCounter += 1
                if let response = self.animeMonckResponse {
                    promise(.success(response))
                } else {
                    promise(.failure(APIError.unknow))
                }
            }
        }.eraseToAnyPublisher()
    }
}

extension ItemApiServiceSpy {
    func fetchTop(param: ItemRequestType) -> AnyPublisher<MangaTopResponse, Error> {
        return Deferred {
            Future { [unowned self] promise in
                self.fetchMangaDataCounter += 1
                if let response = self.mangaMonckResponse {
                    promise(.success(response))
                } else {
                    promise(.failure(APIError.unknow))
                }
            }
        }.eraseToAnyPublisher()
    }
}

//MARK: ServiceErrorTest
enum ServiceErrorTest: Error {
    case animeApiFail
    case mangaApiFail
    case fetchLocalFail
}

//MARK: ViewModelTest
class ViewModelTest: ViewModelType {
    let service: ItemApiService
    var favoriteList: [Int] = []
    var handleItemCacheResult: HandleItemCacheResult
    
    init(service: ItemApiService,
         handleItemCacheResult: HandleItemCacheResult) {
        self.service = service
        self.handleItemCacheResult = handleItemCacheResult
    }
    
    func binding(fetchAnime: AnyPublisher<ItemRequestType, Error>) -> AnyPublisher<AnimeTopResponse, Error> {
        fetchAnime
            .flatMapLatest({ [unowned self]request in
                self.service.fetchTop(param: request)
            })
            .eraseToAnyPublisher()
    }
    
    func binding(fetchManga: AnyPublisher<ItemRequestType, Error>) -> AnyPublisher<MangaTopResponse, Error> {
        fetchManga
            .flatMapLatest({ [unowned self]request in
                self.service.fetchTop(param: request)
            })
            .eraseToAnyPublisher()
    }
    
    func binding(fetchFavorite: AnyPublisher<Void, Error>) -> AnyPublisher<[FavoriteItem], Error> {
        return Deferred {
            Future { promise in
                promise(.failure(ServiceErrorTest.fetchLocalFail))
            }
        }.eraseToAnyPublisher()
    }
    
    func isFavorite(malID: Int) -> Bool {
        favoriteList.contains(malID)
    }
    
    func didTapFavorite(at data: ItemTableViewCellConfigurable, completion: @escaping ((HandleItemCacheResult) -> Void)) throws {
        completion(handleItemCacheResult)
    }
}
