#include <iostream>
#include <algorithm>
#include <vector>
#include <fstream>
#include <string>
#include <chrono>
#include <iomanip>
#include <stack>
#include <thread>
#include <cuda_runtime.h>
#include <device_launch_parameters.h>

#include "gpuErrchk.h"

using namespace std;


#define N_MAX 10

// Determine the validity of the board
bool boardIsValid(const int* gameBoard, const int N)
{
    for (int i = 0; i < N; i++)
        for (int j = i + 1; j < N; j++)
            if (gameBoard[i] - gameBoard[j] == i - j || gameBoard[i] - gameBoard[j] == j - i || gameBoard[i] == gameBoard[j])
                return false;
    return true;
}

// Calculate the solutions
void calculateSolutions(int N, std::vector<std::vector<int>>& solutions)
{
    int O = pow(N, N);

    int** solutionArr = nullptr;
    int no_of_sols = 0;

    auto start = std::chrono::system_clock::now();

    for (int i = 0; i < O; i++) {
        int* gameBoard = (int*)malloc(sizeof(int) * N);

        int column = i;
        for (int j = 0; j < N; j++) {
            gameBoard[j] = column % N;
            column /= N;
        }

        if (boardIsValid(gameBoard, N)) {
            no_of_sols++;
            solutionArr = (int**)realloc(solutionArr, sizeof(int*) * no_of_sols);
            solutionArr[no_of_sols - 1] = gameBoard;
        }
    }

    auto stop = std::chrono::system_clock::now();
    auto time_elapsed = std::chrono::duration_cast<std::chrono::milliseconds>(stop - start);
    std::cout << "N=" << N << " time elapsed: " << time_elapsed.count() / 1000.0 << "s\n";

    // Add the solution to the solutions array
    for (int i = 0; i < no_of_sols; i++) {
        solutions.push_back(std::vector<int>(solutionArr[i], solutionArr[i] + sizeof solutionArr[i] / sizeof solutionArr[i][0]));
        free(solutionArr[i]);
    }
    // Free memory
    free(solutionArr);
}

// Calculate all solutions given the size of the chessboard
void calculateAllSolutions(int N, bool print)
{
    std::vector<std::vector<int>> solutions;

    calculateSolutions(N, solutions);
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