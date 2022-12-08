#include <cassert>
#include <iostream>
#include <vector>
#include <fstream>
#include <string>
#include <chrono>
#include <iomanip>

// Stack for use in backtracking
#include <stack>

using namespace std;
using namespace std::chrono;

// check if the chessboard is valid so far, for row in [0,lastPlacedRow]
bool boardIsValidSoFar(int lastPlacedRow, const std::vector<int>& gameBoard)
{
    const auto N = gameBoard.size(); 
    int lastPlacedColumn = gameBoard[lastPlacedRow];

    // Check against other queens
    for (int row = 0; row < lastPlacedRow; ++row)
    {
        if (gameBoard[row] == lastPlacedColumn) // same column, fail!
            return false;
        // check the 2 diagonals
        const auto col1 = lastPlacedColumn - (lastPlacedRow - row);
        const auto col2 = lastPlacedColumn + (lastPlacedRow - row);
        if (gameBoard[row] == col1 || gameBoard[row] == col2)
            return false;
    }
    return true;
}

// Attempting to Use backtracking to brute force the soluton
// Essentially, the alogorithm will create solition candidates, and if they are deemed invalid, will abandon them while keeping those that are valid
void calculateSolutionsNonRecursive(std::vector<int>& gameBoard, int N, std::vector<std::vector<int>>& solutions)
{
    // Stack to indicate the position of the queens
    std::stack<std::pair<int, int>> queenStack = std::stack<std::pair<int, int>>();

    auto start = high_resolution_clock::now();
    int writeToRow = 0;
    for (int i = 0; i < N; i++)
    {
        gameBoard[writeToRow] = i;
        // If the position is valid, set Queen position and move to the next row
        if (boardIsValidSoFar(writeToRow, gameBoard))
        {
            if (writeToRow < N - 1)
            {
                queenStack.push(std::make_pair(writeToRow, i));
                writeToRow++;
                i = -1;
            }
            else
                solutions.push_back(gameBoard);
        }
        while (i == N - 1)
        {
            // backtrack
            if (!queenStack.empty())
            {
                std::pair<int, int> tempPair = queenStack.top();
                writeToRow = tempPair.first;
                i = tempPair.second;
                queenStack.pop();
            }
            else
                break;
        }
    }
    auto stop = high_resolution_clock::now();
    auto duration = duration_cast<microseconds>(stop - start);

    cout << "Solution found in: "
        << duration.count() / 1000 << "s" << endl;

}

// Calculate all solutions given the size of the chessboard
void calculateAllSolutions(int N, bool print)
{
    std::vector<std::vector<int>> solutions;
    std::vector<int> gameBoard(N, 0);

    calculateSolutionsNonRecursive(gameBoard, N, solutions);

    printf("N=%d, solutions=%d\n\n", N, int(solutions.size()));
    
    if (print)
    {
        std::string text;
        text.resize(N * (N + 1)+1); // we know exactly how many characters we'll need: one for each place at the board, and N newlines (at the end of each row). And one more newline to differentiate from other solutions
        text.back() = '\n'; // add extra line at the end
        for (const auto& solution : solutions)
        {
            for (int i = 0; i < N; ++i)
            {
                auto queenAtRow = solution[i];
                for (int j = 0; j < N; ++j)
                    text[i * (N+1) + j] = queenAtRow == j ? 'X' : '.';
                text[i * (N + 1) + N] = '\n';
            }
            std::cout << text << "\n";
        }
    }
}

int main(int argc, char** argv)
{
    // Get all solutions
    {
        for (int N = 4; N < 11; ++N)
            calculateAllSolutions(N, false);
    }

    /*
    // Input Specific N for solution
    {
        int n;
        char c;

        do
        {
            cout << "-= NQueens Puzzle Solutions\n";

            do
            {
                cout << "\tEnter an between 3 and 15 (not-inclusive) \n";
                cout << "\nN = ";
                cin >> n;
                if (n < 4 || n > 14)
                    cout << "INVALID!\n";
            } while (n < 4 || n > 14);

            calculateAllSolutions(n, false);

            cout << "Solve another N-Queen Puzzle (Y/N) ? ";
            cin >> c;

            cout << "\n\n";
        } while (c != 'N' && c != 'n');

        system("PAUSE");
        return 0;
    }
    */
}