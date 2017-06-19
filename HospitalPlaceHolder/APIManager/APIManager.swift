//
//  APIManager.swift
//  HospitalPlaceHolder
//
//  Created by Dinh Thanh An on 6/11/17.
//  Copyright © 2017 Dinh Thanh An. All rights reserved.
//

import Foundation
import Apollo
import RxSwift
import RxCocoa

let graphQLEndpoint = "https://api.graph.cool/simple/v1/cj3bpd484nnm20185dmf2tqm6"
let apollo = ApolloClient(url: URL(string: graphQLEndpoint)!)

class APIManager {
    static var instance = APIManager()
    
    func createDisease(name: String, lat: Double, long: Double, symptoms: String, address: String? = nil, labsValue: String? = nil, treatments: String? = nil, outcome: String? = nil) -> Observable<String> {
        return Observable.create{ observer in
            let createDiseaseMutation = CreateDiseaseMutation(name: name, lat: lat, long: long, symptoms: symptoms, address: address, labsValue: labsValue, treatments: treatments, outcome: outcome)
            apollo.perform(mutation: createDiseaseMutation) { result, error in
            
                if let error = error {
                    print(error.localizedDescription)
                    observer.onError(error)
                } else {
                    let diseaseID = result?.data?.createDisease?.id
                    observer.onNext(diseaseID!)
                    observer.onCompleted()
                }
            }
            
            return Disposables.create()
        }
    }
    
    func getDiseaseBy(name: String) -> Observable<[DiseaseDetails]> {
        return Observable.create{ observer in
            let allDiseaseQuery = DiseasesByQuery(name: name)
            apollo.fetch(query: allDiseaseQuery) { result, error in
                if let error = error {
                    print(error.localizedDescription)
                    observer.onError(error)
                } else {
                    if let diseases = result?.data?.allDiseases {
                        let diseaseArray = diseases.map{ $0.fragments.diseaseDetails }
                        observer.onNext(diseaseArray)
                        observer.onCompleted()
                    } else {
                        observer.onCompleted()
                    }
                }
            }
                
            return Disposables.create()
        }
    }
    
    func loginUserWith(username: String, password: String) -> Observable<Bool> {
        return Observable.create{ observer in
            let loginUser = LoginUserQuery(username: username, password: password)
            apollo.fetch(query: loginUser) { result, error in
                if let error = error {
                    print(error.localizedDescription)
                    observer.onError(error)
                } else {
                    if (result?.data?.allUsers.count)! > 0 {
                        observer.onNext(true)
                        observer.onCompleted()
                    } else {
                        observer.onNext(false)
                        observer.onCompleted()
                    }
                }
            }
            
            return Disposables.create()
        }
    }
}
