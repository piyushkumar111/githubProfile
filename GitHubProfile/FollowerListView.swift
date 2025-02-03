//
//  FollowerListView.swift
//  GitHubProfile
//
//  Created by Piyush Kachariya on 2/1/25.
//

import SwiftUI

struct FollowerListView: View {
    
    @State private var followers: [Follower] = []
    
    var body: some View {
        VStack {
            if followers.count == 0 {
                Text("Loading...")
                ProgressView()
            } else {
                List {
                    ForEach(followers, id: \.login) { follower in
                        HStack {
                            
                            AsyncImage(url: URL(string: follower.avatar_url)) { image in
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .clipShape(Circle())
                            } placeholder: {
                                Circle()
                                    .foregroundColor(.secondary)
                            }
                            .frame(width: 40, height: 40)
                            
                            Text(follower.login)
                            
                            Spacer()
                            
                            Button("Profile") {
                                guard let url = URL(string: "https://www.github.com/\(follower.login)") else { return }
                                UIApplication.shared.open(url)
                            }
                            .buttonStyle(.borderedProminent)
                            .tint(.blue)
                        }
                    }
                }
            }
        }
        .listStyle(.plain)
        .navigationTitle("Followers")
        .navigationBarTitleDisplayMode(.large)
        .task {
            do {
                followers = try await getGithubFollowers()
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
    
    func getGithubFollowers() async throws -> [Follower] {
        let endpointURL = "https://api.github.com/users/piyushkumar111/followers"
        
        guard let url = URL(string: endpointURL) else {
            throw GitUserError.invalidURL
        }
        
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
            throw GitUserError.invalidResponse
        }
        
        do {
            let decoder = JSONDecoder()
            return try decoder.decode([Follower].self, from: data)
        } catch {
            print("Decoding error: \(error)")
            throw GitUserError.invalidData
        }
    }
}

struct Follower: Codable {
    var login: String
    var avatar_url: String
    var url: String
}
