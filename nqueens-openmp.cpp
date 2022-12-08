#include <cassert>
#include <iostream>
#include <vector>
#include <fstream>
#include <string>
#include <chrono>
#include <iomanip>
#include <stack>
#include <thread>
#include <omp.h>
#include <algorithm>
using namespace std;

#define N_MAX 10

// Determine the validity of the board
bool boardIsValid(int lastPlacedRow, const int* gameBoard, const int N)
{
    // Last placed column
    int lastPlacedColumn = gameBoard[lastPlacedRow];

    // Iterating to determine whether the board is valid
    for (int row = 0; row < lastPlacedRow; ++row)
    {
        // If the row is the same as the last column, then the board is not valid
        if (gameBoard[row] == lastPlacedColumn)
            return false;

        // check the 2 diagonals
        const auto col1 = lastPlacedColumn - (lastPlacedRow - row);
        const auto col2 = lastPlacedColumn + (lastPlacedRow - row);

        // If the row is the came as column 1 or 2, the board is not valid
        if (gameBoard[row] == col1 || gameBoard[row] == col2)
            return false;
    }
    // The board is valid if nothing is flagged previously
    return true;
}

// Calculate the solutions
void calculateSolutions(int N, std::vector<std::vector<int>>& solutions)
{
    // For board evaluation
    const long long int O = powl(N, N);

    // Solution array & number of solutions
    int* solutionArr = (int*)malloc(pow(N, 5) * sizeof(int)); // Determining array size 
    int no_of_sols = 0;

#pragma omp parallel for num_threads(std::thread::hardware_concurrency())
    // Columns
    for (long long int i = 0; i < O; i++) {
        bool valid = true;

        // Game Board array
        int gameBoard[N_MAX];
        long long int column = i;

        // Rows
        for (int j = 0; j < N; j++) {
            gameBoard[j] = column % N;

            // If the board is not valid, break
            if (!boardIsValid(j, gameBoard, N)) {
                valid = false;
                break;
            }

            // divide and assign to column
            column /= N;
        }

        // If the board is valid, 
        if (valid) {
            for (int j = 0; j < N; j++)
                solutionArr[N * no_of_sols + j] = gameBoard[j];
            // Increment number of solutions found
            no_of_sols++;
        }
    }

    // Add the solution to the solutions array
    for (int i = 0; i < no_of_sols; i++) {
        std::vector<int> solution = std::vector<int>();
        for (int j = 0; j < N; j++)
            solution.push_back(solutionArr[N * i + j]);
        solutions.push_back(solution);
    }
    // Free memory
    free(solutionArr);
}

// Calculate all solutions given the size of the chessboard
void calculateAllSolutions(int N, bool print)
{
    std::vector<std::vector<int>> solutions;

    // Start timer
    auto startTime = omp_get_wtime();

    // Calculate solutions
    calculateSolutions(N, solutions);

    // End timer
    auto endTime = omp_get_wtime();

    // Calculate time
    auto overallTime = endTime - startTime;

    // Print to console
    std::cout << "N=" << N << " time elapsed: " << overallTime << "s\n";
    printf("N=%d, solutions=%d\n\n", N, int(solutions.size()));

}


int main(int argc, char** argv)
{

    for (int N = 4; N <= N_MAX; ++N)
        calculateAllSolutions(N, false);

    /*
    // Input Specific N for solution
{
    int n;
    char c;

    do
    {
        cout << "-= NQueens Puzzle Solutions\n";
        cout << "-= WARNING: N > 9 will take longer to process \n";
        cout << "-= N = 10 takes around 75 seconds on my PC \n\n";

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