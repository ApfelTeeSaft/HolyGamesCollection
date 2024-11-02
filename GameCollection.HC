// TempleOS Classic Games: Pong, Tetris, and Snake

#include "std/Kernel.h"

const int WIDTH = 10, HEIGHT = 20;
int score = 0;

void MainMenu();

void PongGame() {
    const int xMax = 80, yMax = 25;
    int ballX = xMax / 2, ballY = yMax / 2;
    int ballDX = 1, ballDY = 1;
    int leftPaddleY = yMax / 2, rightPaddleY = yMax / 2;
    const int paddleHeight = 3;
    int leftScore = 0, rightScore = 0;
    bool gameRunning = TRUE;

    void Draw() {
        ClrScr();
        for (int i = -paddleHeight; i <= paddleHeight; ++i) {
            if (leftPaddleY + i >= 0 && leftPaddleY + i < yMax)
                PlotChar(2, leftPaddleY + i, '|', WHITE);
            if (rightPaddleY + i >= 0 && rightPaddleY + i < yMax)
                PlotChar(xMax - 3, rightPaddleY + i, '|', WHITE);
        }
        PlotChar(ballX, ballY, 'O', YELLOW);
        PrintAt(2, leftPaddleY - paddleHeight - 1, "P1: %d", leftScore);
        PrintAt(xMax - 10, rightPaddleY - paddleHeight - 1, "P2: %d", rightScore);
        DispFlush();
    }

    void UpdateBall() {
        ballX += ballDX;
        ballY += ballDY;
        if (ballY <= 0 || ballY >= yMax - 1) ballDY = -ballDY;
        if (ballX == 3 && ballY >= leftPaddleY - paddleHeight && ballY <= leftPaddleY + paddleHeight) ballDX = -ballDX;
        if (ballX == xMax - 4 && ballY >= rightPaddleY - paddleHeight && ballY <= rightPaddleY + paddleHeight) ballDX = -ballDX;
        if (ballX <= 0) { ++rightScore; ballX = xMax / 2; }
        if (ballX >= xMax - 1) { ++leftScore; ballX = xMax / 2; }
    }

    void UpdatePaddles() {
        if (KeyPeek() == 'W' && leftPaddleY > 1) --leftPaddleY;
        if (KeyPeek() == 'S' && leftPaddleY < yMax - 2) ++leftPaddleY;
        if (KeyPeek() == KEY_UP && rightPaddleY > 1) --rightPaddleY;
        if (KeyPeek() == KEY_DOWN && rightPaddleY < yMax - 2) ++rightPaddleY;
    }

    while (gameRunning) {
        if (KeyPeek() == 'Q') { MainMenu(); return; }
        UpdatePaddles();
        UpdateBall();
        Draw();
        Wait(5);
    }
}

void TetrisGame() {
    int board[WIDTH][HEIGHT];
    int tetrominoes[7][4][4][4] = {
        {{ {1,1,1,1} }, { {1}, {1}, {1}, {1} }},
        {{ {1,1,1}, {0,0,1} }, { {1,1}, {1}, {1} }},
        {{ {1,1,1}, {1} }, { {1,1}, {0,1}, {0,1} }},
        {{ {1,1}, {1,1} }},
        {{ {0,1,1}, {1,1} }, { {1}, {1,1}, {0,1} }},
        {{ {1,1,1}, {0,1} }, { {0,1}, {1,1}, {0,1} }},
        {{ {1,1,0}, {0,1,1} }, { {0,1}, {1,1}, {1} }}};
    int pieceType, pieceRotation, pieceX, pieceY;
    void InitBoard() { for (int x = 0; x < WIDTH; ++x) for (int y = 0; y < HEIGHT; ++y) board[x][y] = 0; }
    void DrawBoard() {
        ClrScr();
        for (int x = 0; x < WIDTH; ++x) for (int y = 0; y < HEIGHT; ++y) PlotChar(x + 10, y + 2, board[x][y] ? '#' : '.', GRAY);
        PrintAt(0, 0, "Score: %d", score);
        DispFlush();
    }
    bool IsValidPosition(int newX, int newY, int newRotation) { for (int i = 0; i < 4; ++i) for (int j = 0; j < 4; ++j) if (tetrominoes[pieceType][newRotation][i][j] && (newX + i < 0 || newX + i >= WIDTH || newY + j >= HEIGHT || board[newX + i][newY + j])) return FALSE; return TRUE; }
    void PlacePiece() { for (int i = 0; i < 4; ++i) for (int j = 0; j < 4; ++j) if (tetrominoes[pieceType][pieceRotation][i][j]) board[pieceX + i][pieceY + j] = 1; }
    void ClearLines() { for (int y = 0; y < HEIGHT; ++y) { bool fullLine = TRUE; for (int x = 0; x < WIDTH; ++x) if (!board[x][y]) { fullLine = FALSE; break; } if (fullLine) for (int newY = y; newY > 0; --newY) for (int x = 0; x < WIDTH; ++x) board[x][newY] = board[x][newY - 1]; score += 10; } }
    void NewPiece() { pieceType = Rand() % 7; pieceRotation = 0; pieceX = WIDTH / 2 - 2; pieceY = 0; if (!IsValidPosition(pieceX, pieceY, pieceRotation)) { PrintAt(0, 2, "Game Over!"); Wait(100); MainMenu(); return; } }
    InitBoard(); NewPiece(); int speed = 20; int dropCounter = 0;
    while (TRUE) {
        if (KeyPeek() == 'Q') { MainMenu(); return; }
        if (++dropCounter >= speed) {
            dropCounter = 0;
            if (IsValidPosition(pieceX, pieceY + 1, pieceRotation)) pieceY++; else { PlacePiece(); ClearLines(); NewPiece(); }
        }
        DrawBoard();
        Wait(1);
    }
}

void SnakeGame() {
    int snakeX[400], snakeY[400], snakeLength = 5, dirX = 1, dirY = 0;
    int foodX = Rand() % WIDTH, foodY = Rand() % HEIGHT;
    bool gameRunning = TRUE;

    void InitGame() { for (int i = 0; i < snakeLength; ++i) { snakeX[i] = WIDTH / 2 - i; snakeY[i] = HEIGHT / 2; } }
    void DrawGame() {
        ClrScr(); for (int x = 0; x <= WIDTH; ++x) { PlotChar(x + 10, 1, '#', WHITE); PlotChar(x + 10, HEIGHT + 2, '#', WHITE); }
        for (int y = 0; y <= HEIGHT; ++y) { PlotChar(10, y + 2, '#', WHITE); PlotChar(WIDTH + 11, y + 2, '#', WHITE); }
        for (int i = 0; i < snakeLength; ++i) PlotChar(snakeX[i] + 10, snakeY[i] + 2, 'O', GREEN);
        PlotChar(foodX + 10, foodY + 2, '*', RED);
        PrintAt(0, 0, "Score: %d", score); DispFlush();
    }
    void MoveSnake() { for (int i = snakeLength - 1; i > 0; --i) { snakeX[i] = snakeX[i - 1]; snakeY[i] = snakeY[i - 1]; } snakeX[0] += dirX; snakeY[0] += dirY; }
    bool CheckCollision() { if (snakeX[0] < 0 || snakeX[0] >= WIDTH || snakeY[0] < 0 || snakeY[0] >= HEIGHT) return TRUE; for (int i = 1; i < snakeLength; ++i) if (snakeX[0] == snakeX[i] && snakeY[0] == snakeY[i]) return TRUE; return FALSE; }
    InitGame();
    while (gameRunning) {
        if (KeyPeek() == 'Q') { MainMenu(); return; }
        if (CheckCollision()) { PrintAt(0, 2, "Game Over! Final Score: %d", score); gameRunning = FALSE; Wait(100); }
        DrawGame(); Wait(5);
    }
}

void MainMenu() {
    ClrScr();
    Print("TempleOS Classic Games:\n");
    Print("1. Pong\n2. Tetris\n3. Snake\nPress the corresponding number to select a game, or 'Q' to quit.\n");
    while (TRUE) {
        int choice = KeyGet();
        switch (choice) {
            case '1': PongGame(); return;
            case '2': TetrisGame(); return;
            case '3': SnakeGame(); return;
            case 'Q': Print("Goodbye!\n"); exit();
        }
    }
}

// entry
void ClassicGames() { MainMenu(); }