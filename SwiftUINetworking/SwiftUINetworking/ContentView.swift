//
//  ContentView.swift
//  SwiftUINetworking
//
//  Created by Juan Camilo Mendieta Hernández on 17/06/25.
//

import SwiftUI

struct ContentView: View {
    @State private var character: Character?
    
    var body: some View {
        VStack {
            AsyncImage(url: URL(string: character?.image ?? "")) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .clipShape(.circle)
            } placeholder: {
                Circle()
                    .foregroundStyle(.secondary)
            }
            .frame(width: 120, height: 120)
            
            Text(character?.name ?? "name placeholder")
                .bold()
                .font(.title3)
            
            Text(character?.status ?? "status placeholder")
                .padding()
            
            Spacer()
        }
        .padding()
        .task {
            do {
                character = try await getCharacter()
            } catch CustomError.invalidData {
                print("invalid data")
            } catch CustomError.invalidResponse {
                print("invalid response")
            } catch CustomError.invalidURL {
                print("invalid url")
            } catch {
                print("unexpected error")
            }
        }
    }
    
    func getCharacter() async throws -> Character {
        let endpoint = "https://rickandmortyapi.com/api/character/19"
        
        guard let url = URL(string: endpoint) else {
            throw CustomError.invalidURL
        }
        
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
            throw CustomError.invalidResponse
        }
        
        do {
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            return try decoder.decode(Character.self, from: data)
        } catch {
            throw CustomError.invalidData
        }
    }
}

#Preview {
    ContentView()
}

struct Character: Decodable {
    let name: String
    let image: String
    let status: String
}

enum CustomError: Error {
    case invalidURL
    case invalidResponse
    case invalidData
}
