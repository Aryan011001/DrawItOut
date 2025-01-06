# DrawItOut

**DrawItOut** is an interactive, real-time multiplayer drawing and guessing game 🎮🖼️ built with Flutter 📱, Node.js 🖥️, Express 🌐, and MongoDB 🗃️. The game offers a fun and engaging way for players to showcase their artistic skills 🎨 while competing with friends or other players online 🌍.


## Features
- **Real-Time Gameplay:** 🌐 Seamlessly connect with players online and enjoy real-time interactions.
- **Interactive Drawing Board:** 🎨 Intuitive and responsive drawing tools to create your masterpieces.
- **Guess the Drawing:** 🖼️ Players take turns drawing, while others guess the word being depicted.
- **Custom Rooms:** 🏠 Create or join private rooms to play with friends.
- **Leaderboard:** 🏆 Track your performance and see how you stack up against other players.
- **Cross-Platform:** 💻📱 Accessible on web, mobile, and desktop platforms.


## Tech Stack

### Frontend:
- **Flutter**: 📱 For building a responsive and cross-platform user interface.

### Backend:
- **Node.js**: 🖥️ For handling server-side logic and real-time communication.
- **Express**: 🌐 For building RESTful APIs.
- **Socket.IO**: 🔌 For enabling real-time communication between clients.
- **MongoDB**: 🗃️ For managing user data, game stats, and more.


## Installation
- [Flutter](https://flutter.dev/docs/get-started/install)
- [Node.js](https://nodejs.org/)
- [MongoDB](https://www.mongodb.com/try/download/community)

### Steps:
1. **Clone the repository:**
   ```bash
   git clone https://github.com/Aryan011001/DrawItOut.git
   cd DrawItOut
    ``` 

2. Backend Setup: 
    - Navigate to the server directory:
        ```cd server ```
    - Install dependencies:
        ```npm install ```
    - Start server 
        ```npm start```

3. Frontend Setup:
    - Navigate to the root directory:
        ```cd ..```
    - Run the Flutter app:
        ```flutter run ```

4. Database Setup: Ensure MongoDB is running locally or connect to a MongoDB Atlas instance.

Update the connection string in ```server/.env:```
    ```MONGO_URI=mongodb+srv://<username>:<password>@cluster.mongodb.net/DrawItOut ```

### Usage
- Open the app or navigate to the web version.
- Create or join a game room.
- Start drawing and guessing to earn points!

### Roadmap

- Add more drawing tools and colors.
- Implement user authentication.
- Enhance the scoring algorithm.
- Add AI-powered hints for challenging words.
- Introduce new game modes.










