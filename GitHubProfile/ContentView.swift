//
//  ContentView.swift
//  GitHubProfile
//
//  Created by Piyush Kachariya on 1/30/25.
//

import SwiftUI

struct ContentView: View {
    
    @State private var gitUser: GitHubUser?
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .center, spacing: 20) {
                if gitUser?.login == nil {
                    Button(gitUser?.login ?? "Please login to see your profile") {
                        Task {
                            do {
                                gitUser = try await getGithubUser()
                            } catch GitUserError.invalidURL {
                                print("invalidURL")
                            } catch GitUserError.invalidResponse {
                                print("invalidResponse")
                            } catch GitUserError.invalidData {
                                print("invalidData")
                            } catch {
                                print("unexpected error")
                            }
                        }
                    }
                } else {
                    AsyncImage(url: URL(string: gitUser?.avatar_url ?? "")) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .clipShape(Circle())
                    } placeholder: {
                        Circle()
                            .foregroundColor(.secondary)
                    }
                    .frame(width: 120, height: 120)
                    
                    
                    Text(gitUser?.login ?? "Please Login")
                    
                    Text(gitUser?.bio ?? "Bio" )
                    
                    Text("Twitter id: \(gitUser?.twitter_username ?? "N/A")")
                    
                    VStack {
                        NavigationLink("No of followers: \(gitUser?.followers ?? 0)") {
                            FollowerListView()
                        }
                    }
                    
                    Text("No of Public Repo: \(gitUser?.public_repos ?? 0)")
                    
                    Spacer()
                    
                    if gitUser?.login != nil {
                        VStack(spacing: 8) {
                            Button("Follow me on GitHub") {
                                if let gitURL = URL(string: "https://www.github.com/piyushkumar111") {
                                    UIApplication.shared.open(gitURL)
                                }
                            }
                            .buttonStyle(.borderedProminent)
                            .tint(.blue)
                            
                            Button("Follow me on Twitter") {
                                if let twitterURL = URL(string: "https://twitter.com/\(gitUser?.twitter_username ?? "")") {
                                    UIApplication.shared.open(twitterURL)
                                }
                            }
                            .buttonStyle(.borderedProminent)
                            .tint(.blue)
                        }
                    }
                }
            }
        }
        .padding()
    }
    
    func getGithubUser() async throws -> GitHubUser {
        let endpointURL = "https://api.github.com/users/piyushkumar111"
        
        guard let url = URL(string: endpointURL) else {
            throw GitUserError.invalidURL
        }
        
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
            throw GitUserError.invalidResponse
        }
        
        do {
            print(String(data: data, encoding: .utf8))
            let decoder = JSONDecoder()
//            decoder.keyDecodingStrategy = .convertFromSnakeCase
            return try decoder.decode(GitHubUser.self, from: data)
        } catch {
            print("Decoding error: \(error)")
            throw GitUserError.invalidData
        }
    }
        
}

struct GitHubUser: Codable {
    let login: String
    let avatar_url: String?
    let name: String
    let bio: String
    let twitter_username: String?
    let followers: Int?
    let public_repos: Int?
}

enum GitUserError : Error {
    case invalidURL
    case invalidResponse
    case invalidData
}

#Preview {
    ContentView()
}

