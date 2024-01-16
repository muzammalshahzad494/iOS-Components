//
//  NetworkService.swift
//  CarArt
//
//  Created by Muzammal Shahzad on 6/6/23.
//

import UIKit


extension String {
    var asUrl: URL? {
        return URL(string: self)
    }
}

struct NetworkService {
    
    static let shared = NetworkService()

    private init() {}
    
    private func request<T: Decodable>(route: Route,
                                     method: Method,
                                     parameters: [String: Any]? = nil,
                                     completion: @escaping(Result<T, Error>) -> Void) {
        guard let request = createRequest(route: route, method: method, parameters: parameters) else {
            completion(.failure(AppError.unknownError))
            return
        }
        
        print(route)

        URLSession.shared.dataTask(with: request) { data, response, error in
            var result: Result<Data, Error>?
            if let data = data {
                result = .success(data)
                let responseString = String(data: data, encoding: .utf8) ?? "Could not stringify our data"
                print("The response is:\n\(responseString)")
            } else if let error = error {
                result = .failure(error)
                print("The error is: \(error.localizedDescription)")
            }

            DispatchQueue.main.async {
                self.handleResponse(result: result, completion: completion)
            }
        }.resume()
    }

    private func handleResponse<T: Decodable>(result: Result<Data, Error>?,
                                              completion: (Result<T, Error>) -> Void) {
        guard let result = result else {
            completion(.failure(AppError.unknownError))
            return
        }

        switch result {
        case .success(let data):
            let decoder = JSONDecoder()
            do {
                let model = try decoder.decode(T.self, from: data)
                completion(.success(model))
            } catch {
                completion(.failure(error))
            }
        case .failure(let error):
            completion(.failure(error))
        }
    }


    /// This function helps us to generate a urlRequest
    /// - Parameters:
    ///   - route: the path the the resource in the backend
    ///   - method: type of request to be made
    ///   - parameters: whatever extra information you need to pass to the backend
    /// - Returns: URLRequest
    private func createRequest(route: Route,
                               method: Method,
                               parameters: [String: Any]? = nil) -> URLRequest? {
        let urlString = Route.baseUrl + route.description
        print(urlString)
        guard let url = urlString.asUrl else { return nil }
        var urlRequest = URLRequest(url: url)
        urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.httpMethod = method.rawValue

        if let params = parameters {
            switch method {
            case .get:
                var urlComponent = URLComponents(string: urlString)
                urlComponent?.queryItems = params.map { URLQueryItem(name: $0, value: "\($1)") }
                urlRequest.url = urlComponent?.url
            case .post, .delete, .patch:
                let bodyData = try? JSONSerialization.data(withJSONObject: params, options: [])
                urlRequest.httpBody = bodyData
            }
        }
        return urlRequest
    }
}


extension NetworkService{

    func registerUser(email: String, firstname:String, lastname: String, phone_number: String, password: String , completion: @escaping(Result<RegisterData, Error>) -> Void) {
        let params = ["email": email, "firstname": firstname, "lastname": lastname, "phone_number": phone_number, "password": password]
        request(route: .registerUser, method: .post, parameters: params, completion: completion)
    }
    
    func loginUser(email: String, password: String, completion: @escaping(Result<LoginData, Error>) -> Void) {
        let params = ["email": email,"password": password]
        request(route: .loginUser, method: .post, parameters: params, completion: completion)
    }
    
    func verifyOTP(otp: String, completion: @escaping(Result<LoginData, Error>) -> Void) {
        let params = ["otp": otp]
        request(route: .otp_verification, method: .post, parameters: params, completion: completion)
    }
}
