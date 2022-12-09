#include <cassert>
#include <iostream>
#include <vector>
#include <fstream>
#include <string>
#include <chrono>
#include <iomanip>
#include <stack>
#include <thread>
#include <algorithm>
#include <sstream>
#include <cmath>

// CUDA Includes
#include <cuda_runtime.h>
#include <device_launch_parameters.h>

// Error check Helper 
#include "gpuErrchk.h"


#define N_MAX 10 // Max size of the board (10X10)
#define THREADPERBLOCK 512 // allocates 2D GPU threads (max 1024, 512 has been chosen as a middleground and it seems the most efficient)

// __device__ to indicate use on the GPU 
__device__ bool boardIsValidSoFar(int lastPlacedRow, const int* gameBoard, const int N)
{
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

//__global__ to indicate use by GPU by multiple threads
__global__ void checkQueenPos(const int N, const long long int O, const long long int offset, int* d_solutions, int* d_no_of_sols)
{
    // Column = threadIdx.x + blockIdx.x * blockDim.x
    long long int column = (long long int)(threadIdx.x + blockIdx.x * blockDim.x);
    if (column >= O)
        return;
    bool valid = true;

    // Game Board Array
    int gameBoard[N_MAX];

    // Checking Queen Positions
    for (int i = 0; i < N; i++) {
        gameBoard[i] = column % N;

        if (!boardIsValidSoFar(i, gameBoard, N)) {
            valid = false;
            break;
        }

        // divide and assign to column
        column /= N;
    }

    // If the board is valid
    if (valid) {
        const int index = atomicAdd(d_no_of_sols, 1);
        for (int i = 0; i < N; i++)
            d_solutions[N * index + i] = gameBoard[i] + 1; // Increment number of device solutions
    }
}

// Calculate the solutions to the problem
void calculateSolutions(const int N, std::vector<std::vector<int>>* solutions, int* h_no_of_sols)
{
    // h for host variables
    *h_no_of_sols = 0;
    // d for device variables
    int* d_solutions = nullptr;
    int* d_no_of_sols = nullptr;

    // For board evaluation
    const long long int O = powl(N, N);

    //Solutions Array and Number of solutions
    size_t solutions_mem = pow(N, 5) * sizeof(int*);
    cudaMalloc((void**)&d_solutions, solutions_mem);
    cudaMalloc((void**)&d_no_of_sols, sizeof(int));

    // copy host host number of solutions to device number of solutions
    cudaMemcpy(d_no_of_sols, h_no_of_sols, sizeof(int), cudaMemcpyHostToDevice);

    // Defining grid and blocks
    long long int grid = (O + THREADPERBLOCK - 1) / THREADPERBLOCK;
    int block = THREADPERBLOCK;

    for (long long int i = 0; i < 1; i++) {
        checkQueenPos << <grid, block >> > (N, O, NULL, d_solutions, d_no_of_sols); //kernel for checking the queen positions
        cudaDeviceSynchronize(); // host device ensures device synchronisation
    }

    // Copy device number of solutions to host number of solutions
    cudaMemcpy(h_no_of_sols, d_no_of_sols, sizeof(int), cudaMemcpyDeviceToHost);
    // Free up memory of device number of solutions
    cudaFree(d_no_of_sols);

    int* h_solutions = (int*)malloc(solutions_mem);
    cudaMemcpy(h_solutions, d_solutions, solutions_mem, cudaMemcpyDeviceToHost);
    cudaFree(d_solutions);

    // Add solutions to the solutions array
    for (int i = 0; i < *h_no_of_sols; i++) {
        if (h_solutions[N * i] != NULL) {
            std::vector<int> solution = std::vector<int>();
            for (int j = 0; j < N; j++)
                solution.push_back(h_solutions[N * i + j]);
            solutions->push_back(solution);
        }
    }

    // Free memory of host solutions
    free(h_solutions);
}

void calculateAllSolutions(const int N, const bool print)
{
    std::vector<std::vector<int>> solutions = std::vector<std::vector<int>>();
    int no_of_sols = 0;

    auto startTime = std::chrono::system_clock::now();
    calculateSolutions(N, &solutions, &no_of_sols);
    auto stopTime = std::chrono::system_clock::now();

    auto timeTaken = std::chrono::duration_cast<std::chrono::microseconds>(stopTime - startTime);
    std::cout << "N=" << N << " Solution found in: " << timeTaken.count() / 1000000.0 << "s\n";
    printf("N=%d, solutions=%d\n\n", N, no_of_sols);

}

int main(int argc, char** argv)
{
    // Helper to exit on first CUDA error
    gpuErrchk(cudaSetDevice(0));

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