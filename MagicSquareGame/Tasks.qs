// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT license.

namespace Quantum.Kata.MagicSquareGame {

    open Microsoft.Quantum.Canon;
    open Microsoft.Quantum.Math;
    open Microsoft.Quantum.Intrinsic;
    open Microsoft.Quantum.Arrays;
    open Microsoft.Quantum.Measurement;
    open Microsoft.Quantum.Convert;

    //////////////////////////////////////////////////////////////////
    // Welcome!
    //////////////////////////////////////////////////////////////////

    // The "Magic Square Game" quantum kata is a series of exercises
    // designed to get you familiar with the Mermin-Peres magic square game.

    // In it two players (Alice and Bob) try to win the game in which they
    // have to fill one row and one column of a 3x3 table with plus and minus signs.
    
    // Alice is given an index of a _row_ and has to fill that row 
    // so that it has an _even_ number of minus signs.
    // Bob is given an index of a _column_ and has to fill that column 
    // so that it has an _odd_ number of minus signs.
    // The sign in the cell that belongs to the intersection of Alice's row and Bob's column
    // has to match in both Alice's and Bob's answers.
    // The trick is, the players can not communicate during the game.

    // Each task is wrapped in one operation preceded by the
    // description of the task. Each task has a unit test associated
    // with it, which initially fails. Your goal is to fill in the
    // blank (marked with // ... comment) with some Q# code to make
    // the failing test pass.


    //////////////////////////////////////////////////////////////////
    // Part I. Classical Magic Square Game
    //////////////////////////////////////////////////////////////////

    // Task 1.1. Validate Alice and Bob's moves
    // In this task you have to implement two functions, one for validating Alice's move and one for validating Bob's move.
    // Note that they are covered by one test, so you have to implement both before attempting the test.

    // Input: The signs Alice chose for each cell in her row,
    //        represented as an Int array of length 3.
    // Output: True if Alice's move is valid (every cell is either +1 or -1 and 
    //         the array has an even number of minus signs), and false otherwise.
    function ValidAliceMove (cells : Int[]) : Bool {
        return All(CheckPlusOrMinusOne, cells) and Fold(Multiply, 1, cells)==1;
    }

    // Input: The signs Bob chose for each cell in his column,
    //        represented as an Int array of length 3.
    // Output: True if Bob's move is valid (every cell is either +1 or -1 and
    //         the array has an odd number of minus signs), and false otherwise.
    function ValidBobMove (cells : Int[]) : Bool {
        return All(CheckPlusOrMinusOne, cells) and Fold(Multiply, 1, cells)==-1;
    }

    function CheckPlusOrMinusOne(number : Int) : Bool {
        return AbsI(number) == 1;
    }

    function Multiply(state: Int, number : Int) : Int {
        return state * number;
    }


    // Task 1.2. Win condition
    // Inputs:
    //     1) The row and column indices Alice and Bob were assigned. Each index will be between 0 and 2, inclusive.
    //     2) Alice and Bob's moves, represented as Int arrays of length 3.
    // Output:
    //     True if Alice and Bob won the game (that is, if both their moves are valid and
    //     they chose the same sign in the cell on the intersection of Alice's row and Bob's column),
    //     and false otherwise.
    function WinCondition (rowIndex : Int, columnIndex : Int, row : Int[], column : Int[]) : Bool {
        
        return ValidAliceMove(row) and ValidBobMove(column) and (row[columnIndex] == column[rowIndex]);
    }


    // Task 1.3. Alice and Bob's classical strategy
    // In this task you have to implement two functions, one for Alice's classical strategy and one for Bob's.
    // Note that they are covered by one test, so you have to implement both before attempting the test.
    // The classical strategy should win about 89% of the time.

    // Input:  The index of Alice's row.
    // Output: The signs Alice should place in her row (as an Int array of length 3).
    //         +1 indicates plus sign, -1 - minus sign.
    function AliceClassical (rowIndex : Int) : Int[] {
        let rows =  [[1, 1, 1], 
                     [1, -1, -1], 
                     [-1, 1, -1]];
        return rows[rowIndex];
    }

    // Input:  The index of Bob's column.
    // Output: The signs Bob should place in his column (as an Int array of length 3).
    //         +1 indicates plus sign, -1 - minus sign.
    function BobClassical (columnIndex : Int) : Int[] {
        let columns =  [[1, 1, -1], 
                        [1, -1, 1], 
                        [1, -1, 1]];
        return columns[columnIndex];
    }


    //////////////////////////////////////////////////////////////////
    // Part II. Quantum Magic Square Game
    //////////////////////////////////////////////////////////////////

    // In the quantum version of the game, the players still can not
    // communicate during the game, but they are allowed to share 
    // qubits from two entangled pairs before the start of the game.

    // Task 2.1. Entangled state
    // Input: An array of 4 qubits in the |0000⟩ state.
    // Goal:
    //     Create the entangled state
    //     |ψ⟩ = ((|+⟩₀ ⊗ |+⟩₂ + |-⟩₀ ⊗ |-⟩₂) / sqrt(2)) ⊗ ((|+⟩₁ ⊗ |+⟩₃ + |-⟩₁ ⊗ |-⟩₃) / sqrt(2)),
    //     where |ψ⟩₀ and |ψ⟩₁ are Alice's qubits and |ψ⟩₂ and |ψ⟩₃ are Bob's qubits.
    operation CreateEntangledState (qs : Qubit[]) : Unit {
        // Hint: Can you represent this state as a combination of Bell pairs?

        for ( i in 0..1) {
            H(qs[i]);
            CNOT(qs[i], qs[i+2]);
        }

    }


    // Task 2.2. Magic square observables
    // Input:  A row and column indices corresponding to a cell in a magic square.
    // Output: A tuple that represents the given cell of a magic square.
    //         The first element of the tuple is an Int denoting the sign of the observable (+1 for plus, -1 for minus),
    //         the second - an array of 2 observables of type Pauli.
    // The square should satisfy the following properties:
    //  1) The observables in each row and column mutually commute,
    //  2) The product of observables in each row is I,
    //  3) The product of observables in each column is -I.
    //
    // Note that different sources that describe Mermin-Peres game give different magic squares.
    // We recommend you to pick one source and follow it throughout the rest of the tasks in this kata.
    function GetMagicObservables (rowIndex : Int, columnIndex : Int) : (Int, Pauli[]) {
        let magicSquare = [[(+1, [PauliX, PauliX]), (+1, [PauliX, PauliI]), (+1, [PauliI, PauliX])], 
                           [(+1, [PauliY, PauliY]), (-1, [PauliX, PauliZ]), (-1, [PauliZ, PauliX])], 
                           [(+1, [PauliZ, PauliZ]), (+1, [PauliI, PauliZ]), (+1, [PauliZ, PauliI])] ];
        
        return magicSquare[rowIndex][columnIndex];
    }


    // Task 2.3. Apply magic square observables
    // Inputs:
    //      1) A tuple representing an observable in a cell of a magic square, in the same format as in task 2.2.
    //      2) An array of 2 qubits.
    // Goal:   Apply the observable described by this tuple to the given array of qubits.
    //
    // For example, if the given tuple is (-1, [PauliX, PauliY]), you have to 
    // apply X to the first qubit, Y to the second qubit, and a global phase of -1 to the two-qubit state.
    operation ApplyMagicObservables (observable : (Int, Pauli[]), qs : Qubit[]) : Unit is Adj+Ctl {
        let (sign, paulis) = observable;
        ApplyPauli(paulis, qs);

        if ( sign < 0 ) {
            R(PauliI, 2.*PI(), qs[0]);
        }
    }


    // Task 2.4. Measure observables using joint measurement
    // Inputs:
    //      1) A tuple representing an observable in a cell of a magic square, in the same format as in task 2.2.
    //      2) A 2-qubit register to measure the observable on.
    //         The register is guaranteed to be in one of the eigenstates of the observable.
    // Output: The result of measuring the observable on the given register:
    //         Zero if eigenvalue +1 has been measured, One if eigenvalue -1 has been measured.
    // The state of the qubits at the end of the operation does not matter.
    operation MeasureObservable (observable : (Int, Pauli[]), target : Qubit[]) : Result {
        // Hint: Use Measure operation to perform a joint measurement.
        let (sign, paulis) = observable;
    
        // joint measurement on the observables and convert to eigenvalue, multiply with sign, convert back to Result
        return ((Measure(paulis, target) == Zero ? +1 | -1) * sign) == +1 ? Zero | One;
    }


    // Task 2.5. Measure an operator
    // Inputs:
    //      1) An operator which acts on 2 qubits, has eigenvalues +1 and -1 and has a controlled variant.
    //      2) A 2-qubit register to measure the operator on. 
    //         The register is guaranteed to be in one of the eigenstates of the operator.
    // Output: The result of measuring the operator on the given register: 
    //         Zero if eigenvalue +1 has been measured, One if eigenvalue -1 has been measured.
    // The state of the qubits at the end of the operation does not matter.
    operation MeasureOperator (op : (Qubit[] => Unit is Ctl), target : Qubit[]) : Result {
        // Hint: Applying the operator to an eigenstate will introduce a global phase equal to the eigenvalue.
        //       Is there a way to convert this global phase into a relative phase?

        // Hint: Remember that you can allocate extra qubits.

        using (anc = Qubit()) {
            H(anc);
            Controlled op([anc], target);
            H(anc);

            return MResetZ(anc);
        }
    }


    // Task 2.6. Alice and Bob's quantum strategy
    // In this task you have to implement two functions, one for Alice's quantum strategy and one for Bob's.
    // Note that they are covered by one test, so you have to implement both before attempting the test.
    // The best quantum strategy can win every time.

    // Inputs:
    //      1) The index of Alice's row.
    //      2) Alice's share of the entangled qubits, stored as an array of length 2.
    // Output: The signs Alice should place in her row (as an Int array of length 3).
    //         +1 indicates plus sign, -1 - minus sign.
    operation AliceQuantum (rowIndex : Int, qs : Qubit[]) : Int[] {
        // Hint: Use GetMagicObservables from task 2.2.
        
        // Hint: You can use either MeasureObservable from task 2.4, or ApplyMagicObservables and
        // MeasureOperator from tasks 2.3 and 2.5.

        mutable cells = new Int[3];

        for ( c in 0..2) {
            let observable = GetMagicObservables(rowIndex, c);
            let res = MeasureObservable(observable, qs);
            set cells w/= c <- res == Zero ? +1 | -1;
        }

        return cells;
    }

    // Input:
    //     1) The index of Bob's column.
    //     2) Bob's share of the entangled qubits, stored as an array of length 2.
    // Output: The signs Bob should place in his column (as an Int array of length 3).
    //         +1 indicates plus sign, -1 - minus sign.
    operation BobQuantum (columnIndex : Int, qs : Qubit[]) : Int[] {
        // Hint: Use GetMagicObservables from task 2.2.
        
        // Hint: You can use either MeasureObservable from task 2.4, or ApplyMagicObservables and
        // MeasureOperator from tasks 2.3 and 2.5.

        mutable cells = new Int[3];

        for ( r in 0..2) {
            let observable = GetMagicObservables(r, columnIndex);
            let op = ApplyMagicObservables(observable, _);
            let res = MeasureOperator(op, qs);
            set cells w/= r <- res == Zero ? +1 | -1;
        }

        return cells;
    }


    // Task 2.7. Play the magic square game using the quantum strategy
    // Input: Operations that return Alice and Bob's moves based on their quantum
    //        strategies and given their respective qubits from the entangled state.
    //        Alice and Bob have already been told their row and column indices.
    // Goal:  Return Alice and Bob's moves.
    //
    // Note that this task uses strategies AliceQuantum and BobQuantum 
    // which you've implemented in task 2.6.
    operation PlayQuantumMagicSquare (askAlice : (Qubit[] => Int[]), askBob : (Qubit[] => Int[])) : (Int[], Int[]) {
        // Hint: Use CreateEntangledState from task 2.1.

        using (state = Qubit[4]) {
            CreateEntangledState(state);
            let a = askAlice([state[0], state[1]]);
            let b = askBob([state[2], state[3]]);

            ResetAll(state);
            return (a, b);
        }
    }


    //////////////////////////////////////////////////////////////////
    // Part III. Experimenting with the Magic Square
    //////////////////////////////////////////////////////////////////

    // Task 3.1. Testing magic square strategies
    // Goal:
    //    Use your classical and quantum magic square strategies from tasks 1.3 and 2.6 to
    //    verify their probabilities of winning. Can you make the classical strategy lose?
    operation MagicSquare_Test () : Unit {

        // Classical strategies
        mutable wins = 0;
        for (i in 1..100) {
            let rowIndex = RandomInt(3);
            let columnIndex = RandomInt(3);
            let (alice, bob) = (AliceClassical(rowIndex), BobClassical(columnIndex));
            if (WinCondition(rowIndex, columnIndex, alice, bob)) {
                set wins += 1;
            }
        }
        Message($"classical strategy wins in {wins}% cases");


        let (a, b) = (AliceClassical(2), BobClassical(2));
        Message($"classical strategy wins on row/col = 2/2: " + BoolAsString(WinCondition(2, 2, a, b)));


        set wins = 0;
        for (i in 1..10) {
            let rowIndex = RandomInt(3);
            let columnIndex = RandomInt(3);

            // Hint: You will need to use partial application to use your quantum strategies from task
            // 2.6 with PlayQuantumMagicSquare from task 2.7.

            let (aq, bq) = PlayQuantumMagicSquare(AliceQuantum(rowIndex, _), BobQuantum(columnIndex, _));

            // Hint: Use WinCondition function from task 1.2 to check that Alice and Bob won the game.
            if (WinCondition(rowIndex, columnIndex, aq, bq)) {
                set wins += 1;
                Message($"quantum strategy wins on row/col = {rowIndex}/{columnIndex}:");
            }
            else {
                Message($"quantum strategy looses on row/col = {rowIndex}/{columnIndex}:");
            }

            // Hint: Use the DrawMagicSquare function in Tests.qs to see what the magic square looks
            // like after Alice and Bob make their moves.
            DrawMagicSquare(aq, rowIndex, bq, columnIndex);
            Message("------------------------------------------------------------------------------");

        }
        Message($"quantum strategy wins in {wins/10*100}% cases");
    }

}