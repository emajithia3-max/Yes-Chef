import SwiftUI
import Foundation
import Firebase

struct LeaderboardView: View {
    @StateObject private var data: LeaderboardData = LeaderboardData()
    @State private var reloadTrigger: Bool = false
    @State private var weeklyPrompt: String = "Loading prompt..."
    @State private var showHistory: Bool = false


    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Fixed header with history button
                HStack {
                    Spacer()
                    NavigationLink(destination: HistoryTab()) {
                        Image(systemName: "clock.fill")
                            .font(.title2)
                            .foregroundColor(.blue)
                    }
                }
                .padding(.horizontal)
                .padding(.top, 10)
                .padding(.bottom, 5)

                // Everything else in a scrollable view
                ScrollView {
                    VStack(spacing: 20) {
                        Text("Leaderboard")
                            .font(.largeTitle)
                            .bold()

                        VStack(spacing: 4) {
                            Text("This Week")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                            Text(weeklyPrompt)
                                .font(.subheadline)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.gray.opacity(0.3))
                        .cornerRadius(10)
                        .padding(.horizontal)

                        // Podium for top 3
                        HStack {
                            Spacer()

                            HStack(alignment: .bottom, spacing: 40) {
                                VStack {
                                    Text("2nd")
                                        .font(.caption)
                                    AsyncImage(url: URL(string: data.currentLeaderboard.entries.count >= 2 ? data.currentLeaderboard.entries[1].user.profileImageURL ?? "" : "")) { phase in
                                        if let image = phase.image {
                                            image
                                                .resizable()
                                                .scaledToFit()
                                                .frame(width: 60, height: 60)
                                                .clipShape(Circle())
                                        } else {
                                            Image(systemName: "person.circle.fill")
                                                .resizable()
                                                .scaledToFit()
                                                .frame(width: 60, height: 60)
                                                .foregroundColor(.blue)
                                        }
                                    }
                                    Text(data.currentLeaderboard.entries.count >= 2 ? data.currentLeaderboard.entries[1].user.username : "Chef #2")
                                        .font(.caption2)
                                    Text(data.currentLeaderboard.entries.count >= 2 ? data.currentLeaderboard.entries[1].recipeName : "Recipe")
                                        .font(.caption2)
                                        .foregroundColor(.gray)
                                }
                                .offset(y: 20)

                                VStack {
                                    ZStack(alignment: .top) {
                                        AsyncImage(url: URL(string: data.currentLeaderboard.entries.count >= 1 ? data.currentLeaderboard.entries[0].user.profileImageURL ?? "" : "")) { phase in
                                            if let image = phase.image {
                                                image
                                                    .resizable()
                                                    .scaledToFit()
                                                    .frame(width: 100, height: 100)
                                                    .clipShape(Circle())
                                            } else {
                                                Image(systemName: "person.circle.fill")
                                                    .resizable()
                                                    .scaledToFit()
                                                    .frame(width: 100, height: 100)
                                                    .foregroundColor(.blue)
                                            }
                                        }
                                        Image("ChefHat")
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 40, height: 40)
                                            .offset(y: -25)
                                            .foregroundColor(.gray)
                                    }
                                    Text(data.currentLeaderboard.entries.count >= 1 ? data.currentLeaderboard.entries[0].user.username : "Chef #1")
                                        .font(.caption2)
                                    Text(data.currentLeaderboard.entries.count >= 1 ? data.currentLeaderboard.entries[0].recipeName : "Recipe")
                                        .font(.caption2)
                                        .foregroundColor(.gray)
                                }
                                .offset(y: -10)

                                VStack {
                                    Text("3rd")
                                        .font(.caption)
                                    AsyncImage(url: URL(string: data.currentLeaderboard.entries.count >= 3 ? data.currentLeaderboard.entries[2].user.profileImageURL ?? "" : "")) { phase in
                                        if let image = phase.image {
                                            image
                                                .resizable()
                                                .scaledToFit()
                                                .frame(width: 60, height: 60)
                                                .clipShape(Circle())
                                        } else {
                                            Image(systemName: "person.circle.fill")
                                                .resizable()
                                                .scaledToFit()
                                                .frame(width: 60, height: 60)
                                                .foregroundColor(.blue)
                                        }
                                    }
                                    Text(data.currentLeaderboard.entries.count >= 3 ? data.currentLeaderboard.entries[2].user.username : "Chef #3")
                                        .font(.caption2)
                                    Text(data.currentLeaderboard.entries.count >= 3 ? data.currentLeaderboard.entries[2].recipeName : "Recipe")
                                        .font(.caption2)
                                        .foregroundColor(.gray)
                                }
                                .offset(y: 20)
                            }

                            Spacer()
                        }
                        .padding(.top)

                        // Top 5 Leaderboard (excluding top 3 shown in podium)
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                ForEach(data.currentLeaderboard.entries.dropFirst(3).prefix(2)) { entry in
                                    LeaderboardRow(entry: entry)
                                }
                            }
                            .padding(.horizontal)
                        }
                        .frame(height: 100)

                        Text("All Submissions")
                            .font(.title2)
                            .bold()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal)
                            .padding(.top, 10)

                        // Grid view of all submissions - directly in main ScrollView
                        let columns = [
                            GridItem(.flexible()),
                            GridItem(.flexible())
                        ]
                        LazyVGrid(columns: columns, spacing: 15) {
                            ForEach(data.currentLeaderboard.entries) { entry in
                                NavigationLink(destination: RecipeDetailView(recipeId: entry.id)) {
                                    ChallengeRecipeCard(entry: entry)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                        .padding(.horizontal)
                        .padding(.bottom, 20)

                        HStack(spacing: 20) {
                            Button(action: {
                                data.recalibrateEntries()
                            }) {
                                Text("Clear Leaderboard")
                                    .font(.headline)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.red.opacity(0.8))
                                    .foregroundColor(.white)
                                    .cornerRadius(10)
                            }

                            Button(action: {
                                data.recalibrateEntries()
                            }) {
                                Text("Load New Sample Entries")
                                    .font(.headline)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.blue.opacity(0.8))
                                    .foregroundColor(.white)
                                    .cornerRadius(10)
                            }
                        }
                        .padding(.horizontal)
                        .padding(.bottom, 20)
                    } // Close VStack inside ScrollView
                } // Close ScrollView
            } // Close outer VStack
        .task {
            data.fetchUserRecipes()
            await fetchWeeklyPrompt()
        }
        } // Close NavigationStack
    } // Close body

    // Fetch the current weekly challenge prompt
    private func fetchWeeklyPrompt() async {
        let db = Firestore.firestore()
        do {
            let document = try await db.collection("weeklyChallenge").document("current").getDocument()
            if document.exists, let data = document.data(), let prompt = data["prompt"] as? String {
                await MainActor.run {
                    self.weeklyPrompt = prompt
                }
            } else {
                // Document doesn't exist, initialize it
                print("⚠️ Weekly challenge not initialized. Initializing now...")
                await initializeWeeklyChallenge()
            }
        } catch {
            print("Error fetching weekly prompt: \(error.localizedDescription)")
            await MainActor.run {
                self.weeklyPrompt = "Could not load challenge prompt"
            }
        }
    }

    // Initialize weekly challenge if it doesn't exist
    private func initializeWeeklyChallenge() async {
        await MainActor.run {
            self.weeklyPrompt = "Initializing challenge..."
        }

        await WeeklyChallengeManager.initializeWeeklyChallenge()

        // Try fetching again after initialization
        let db = Firestore.firestore()
        do {
            let document = try await db.collection("weeklyChallenge").document("current").getDocument()
            if let data = document.data(), let prompt = data["prompt"] as? String {
                await MainActor.run {
                    self.weeklyPrompt = prompt
                }
            } else {
                await MainActor.run {
                    self.weeklyPrompt = "Create your best dish this week!"
                }
            }
        } catch {
            await MainActor.run {
                self.weeklyPrompt = "Create your best dish this week!"
            }
        }
    }
}

struct LeaderboardRow: View {
    let entry: LeaderboardData.LeaderboardEntry

    var body: some View {
        HStack {
            Text("\(entry.rank)")
                .font(.headline)
                .frame(width: 30)
            
            AsyncImage(url: URL(string: entry.user.profileImageURL ?? "")) { phase in
                if let image = phase.image {
                    image
                        .resizable()
                        .scaledToFit()
                        .frame(width: 50, height: 50)
                        .clipShape(Circle())
                } else {
                    Image(systemName: "person.circle.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 50, height: 50)
                        .foregroundColor(.blue)
                }
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(entry.user.username)
                    .font(.headline)
                    .foregroundColor(.blue)
                Text(entry.recipeName)
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            HStack(spacing: 4) {
                Image(systemName: "heart.fill")
                    .foregroundColor(.red)
                Text("\(entry.likes)")
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemGray6))
                .shadow(radius: 2)
        )
        .padding(.horizontal)
    }
}

struct ChallengeRecipeCard: View {
    let entry: LeaderboardData.LeaderboardEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Recipe image placeholder or first media
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemGray5))
                .frame(height: 120)
                .overlay(
                    VStack {
                        Image(systemName: "fork.knife")
                            .font(.largeTitle)
                            .foregroundColor(.gray)
                    }
                )

            VStack(alignment: .leading, spacing: 4) {
                Text(entry.recipeName)
                    .font(.headline)
                    .lineLimit(2)

                HStack {
                    AsyncImage(url: URL(string: entry.user.profileImageURL ?? "")) { phase in
                        if let image = phase.image {
                            image
                                .resizable()
                                .scaledToFit()
                                .frame(width: 20, height: 20)
                                .clipShape(Circle())
                        } else {
                            Image(systemName: "person.circle.fill")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 20, height: 20)
                                .foregroundColor(.gray)
                        }
                    }
                    Text(entry.user.username)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                HStack {
                    Image(systemName: "heart.fill")
                        .foregroundColor(.red)
                        .font(.caption)
                    Text("\(entry.likes)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .padding(.horizontal, 8)
            .padding(.bottom, 8)
        }
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

// Helper view to fetch recipe and navigate to PostView
struct RecipeDetailView: View {
    let recipeId: String
    @State private var recipe: Recipe? = nil
    @State private var isLoading: Bool = true

    var body: some View {
        Group {
            if isLoading {
                VStack {
                    ProgressView()
                    Text("Loading recipe...")
                        .foregroundColor(.gray)
                        .padding(.top)
                }
            } else if let recipe = recipe {
                PostView(recipe: recipe)
            } else {
                VStack {
                    Image(systemName: "exclamationmark.triangle")
                        .font(.largeTitle)
                        .foregroundColor(.red)
                    Text("Recipe not found")
                        .font(.headline)
                        .padding()
                }
            }
        }
        .task {
            recipe = await Recipe.fetchById(recipeId)
            isLoading = false
        }
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    LeaderboardView()
}
