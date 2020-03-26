// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT license.

namespace Quantum.Kata.RippleCarryAdder {
    
    open Microsoft.Quantum.Intrinsic;
    open Microsoft.Quantum.Canon;
    open Microsoft.Quantum.Diagnostics;
    open Microsoft.Quantum.Convert;
    open Microsoft.Quantum.Math;
    
    
    //////////////////////////////////////////////////////////////////
    // Welcome!
    //////////////////////////////////////////////////////////////////
    
    // The "Ripple Carry Adder" quantum kata is a series of exercises designed
    // to get you familiar with ripple-carry addition on a quantum computer,
    // walking you through the steps to build two different adders.
    // It covers the following topics:
    //  - Adapting a classical adder to a quantum environment
    //  - Modifying the adder to re-use input qubits
    //  - An alternate, simplified quantum adder
    //  - A simple subtractor

    // Each task is wrapped in one operation preceded by the description of the task.
    // Each task (except tasks in which you have to write a test) has a unit test associated with it,
    // which initially fails. Your goal is to fill in the blank (marked with // ... comment)
    // with some Q# code to make the failing test pass.
    
    // Within each section, tasks are given in approximate order of increasing difficulty;
    // harder ones are marked with asterisks.
    
    
    //////////////////////////////////////////////////////////////////
    // Part I. Simple adder outputting to empty qubits
    //////////////////////////////////////////////////////////////////
    
    // This section adapts the classical binary adder to a quantum computer.
    // It starts with simple sum and carry gates, and works up to an N-bit full adder.

    // Task 1.1. Summation of two bits
    // Inputs:
    //      1) qubit "a" in an arbitrary state |φ⟩,
    //      2) qubit "b" in an arbitrary state |ψ⟩,
    //      3) qubit "sum" in state |0⟩.
    // Goal: transform the "sum" qubit into the lowest bit of the binary sum of φ and ψ
    //         |0⟩ + |0⟩ → |0⟩
    //         |0⟩ + |1⟩ → |1⟩
    //         |1⟩ + |0⟩ → |1⟩
    //         |1⟩ + |1⟩ → |0⟩
    //       Any superposition should map appropriately.
    // Example:
    //         |+⟩ = (|0⟩ + |1⟩) / sqrt(2)
    //         |-⟩ = (|0⟩ - |1⟩) / sqrt(2)
    //         |+⟩ ⨂ |-⟩ ⨂ |0⟩ → (|000⟩ + |101⟩ - |011⟩ - |110⟩) / 2
    operation LowestBitSum (a : Qubit, b : Qubit, sum : Qubit) : Unit is Adj {
        CNOT(a, sum);
        CNOT(b, sum);
    }


    // Task 1.2. Carry of two bits
    // Inputs:
    //      1) qubit "a" in an arbitrary state |φ⟩,
    //      2) qubit "b" in an arbitrary state |ψ⟩,
    //      3) qubit "carry" in state |0⟩.
    // Goal: set the "carry" qubit to |1⟩ if the binary sum of φ and ψ produces a carry, and leave it in state |0⟩ otherwise.
    //         |0⟩ and |0⟩ → |0⟩
    //         |0⟩ and |1⟩ → |0⟩
    //         |1⟩ and |0⟩ → |0⟩
    //         |1⟩ and |1⟩ → |1⟩
    //       Any superposition should map appropriately.
    // Example:
    //         |+⟩ ⨂ |-⟩ ⨂ |0⟩ → (|000⟩ + |100⟩ - |010⟩ - |111⟩) / 2
    operation LowestBitCarry (a : Qubit, b : Qubit, carry : Qubit) : Unit is Adj {
        CCNOT(a, b, carry);
    }


    // Task 1.3. One-bit adder
    // Inputs:
    //      1) qubit "a" in an arbitrary state |φ⟩,
    //      2) qubit "b" in an arbitrary state |ψ⟩,
    //      3) two qubits "sum" and "carry" in state |0⟩.
    // Goals:
    //      1) transform the "sum" qubit into the lowest bit of the binary sum of φ and ψ,
    //      2) transform the "carry" qubit into the carry bit produced by that sum.
    operation OneBitAdder (a : Qubit, b : Qubit, sum : Qubit, carry : Qubit) : Unit is Adj {
        LowestBitSum(a, b, sum);
        LowestBitCarry(a, b, carry);
    }


    // Task 1.4. Summation of 3 bits
    // Inputs:
    //      1) qubit "a" in an arbitrary state |φ⟩,
    //      2) qubit "b" in an arbitrary state |ψ⟩,
    //      3) qubit "carryin" in an arbitrary state |ω⟩,
    //      4) qubit "sum" in state |0⟩.
    // Goal: transform the "sum" qubit into the lowest bit of the binary sum of φ, ψ and ω.
    operation HighBitSum (a : Qubit, b : Qubit, carryin : Qubit, sum : Qubit) : Unit is Adj {
        CNOT(a, sum);
        CNOT(b, sum);
        CNOT(carryin, sum);
    }



    // Task 1.5. Carry of 3 bits
    // Inputs:
    //      1) qubit "a" in an arbitrary state |φ⟩,
    //      2) qubit "b" in an arbitrary state |ψ⟩,
    //      3) qubit "carryin" in an arbitrary state |ω⟩,
    //      4) qubit "carryout" in state |0⟩.
    // Goal: transform the "carryout" qubit into the carry bit produced by the sum of φ, ψ and ω.
    operation HighBitCarry (a : Qubit, b : Qubit, carryin : Qubit, carryout : Qubit) : Unit is Adj {
        CCNOT(a, b, carryout);
        CCNOT(a, carryin, carryout);
        CCNOT(b, carryin, carryout);
    }


    // Task 1.6. Two-bit adder
    // Inputs:
    //      1) two-qubit register "a" in an arbitrary state |φ⟩,
    //      2) two-qubit register "b" in an arbitrary state |ψ⟩,
    //      3) two-qubit register "sum" in state |00⟩,
    //      4) qubit "carry" in state |0⟩.
    // Goals:
    //      1) transform the "sum" register into the binary sum of φ and ψ,
    //      2) transform the "carry" qubit into the carry bit produced by that sum.
    // Note: All qubit registers in this kata are in little-endian order.
    //       This means the least significant bit comes first, then the next least significant, and so on.
    //       In this exercise, for example, 1 would be represented as |10⟩, while 2 would be represented as |01⟩.
    //       The sum of |10⟩ and |11⟩ would be |001⟩, with the last qubit being the carry qubit.
    operation TwoBitAdder (a : Qubit[], b : Qubit[], sum : Qubit[], carry : Qubit) : Unit is Adj {
        // Hint: don't forget that you can allocate extra qubits.

        using (carrylow = Qubit()) {
            LowestBitSum(a[0], b[0], sum[0]);
            LowestBitCarry(a[0], b[0], carrylow);
            HighBitSum(a[1], b[1], carrylow, sum[1]);
            HighBitCarry(a[1], b[1], carrylow, carry);

            // reset ancillary
            Adjoint LowestBitCarry(a[0], b[0], carrylow);
        }
    }


    // Task 1.7. N-bit adder
    // Inputs:
    //      1) N qubit register "a" in an arbitrary state |φ⟩,
    //      2) N qubit register "b" in an arbitrary state |ψ⟩,
    //      3) N qubit register "sum" in state |0...0⟩,
    //      4) qubit "carry" in state |0⟩.
    // Goals:
    //      1) transform the "sum" register into the binary sum of φ and ψ,
    //      2) transform the "carry" qubit into the carry bit produced by that sum.
    // Challenge: can you do this without allocating extra qubits?
    // operation ArbitraryAdder (a : Qubit[], b : Qubit[], sum : Qubit[], carry : Qubit) : Unit is Adj {
        
    //     let N=Length(a);
    //     if ( N==1 ) {
    //         LowestBitSum(a[0], b[0], sum[0]);
    //         LowestBitCarry(a[0], b[0], carry);
    //     }
    //     else {
        
    //         using (carryBits = Qubit[N]) {


    //             LowestBitSum(a[0], b[0], sum[0]);
    //             LowestBitCarry(a[0], b[0], carryBits[0]);

    //             for (i in 1..N-1) {
    //                 HighBitSum(a[i], b[i], carryBits[i-1], sum[i]);
    //                 HighBitCarry(a[i], b[i], carryBits[i-1], carryBits[i]);
    //             }

    //             CNOT(carryBits[N-1], carry);


    //             // reset ancillary
    //             for (i in N-1..-1..1) {
    //                 Adjoint HighBitCarry(a[i], b[i], carryBits[i-1], carryBits[i]);
    //             }
    //             Adjoint LowestBitCarry(a[0], b[0], carryBits[0]);
    //         }
    //     }
    // }

    operation ArbitraryAdder (a : Qubit[], b : Qubit[], sum : Qubit[], carry : Qubit) : Unit is Adj {
        
        let N=Length(a);

        // calculate carry
        LowestBitCarry(a[0], b[0], sum[0]);

        for (i in 1..N-1) {
            HighBitCarry(a[i], b[i], sum[i-1], sum[i]);
        }

        CNOT(sum[N-1], carry);

        // cleanup sum[i] and calculate sum
        for (i in N-1..-1..1) {
            Adjoint HighBitCarry(a[i], b[i], sum[i-1], sum[i]);
            HighBitSum(a[i], b[i], sum[i-1], sum[i]);
        }

        Adjoint LowestBitCarry(a[0], b[0], sum[0]);
        LowestBitSum(a[0], b[0], sum[0]);
        
    }

    //////////////////////////////////////////////////////////////////
    // Part II. Simple in-place adder
    //////////////////////////////////////////////////////////////////

    // The adder from the previous section requires empty qubits to accept the result.
    // This section adapts the previous adder to calculate the sum in-place,
    // that is, to reuse one of the numerical inputs for storing the output.
    
    // Task 2.1. In-place summation of two bits
    // Inputs:
    //      1) qubit "a" in an arbitrary state |φ⟩,
    //      2) qubit "b" in an arbitrary state |ψ⟩.
    // Goal: transform qubit "b" into the lowest bit of the sum of φ and ψ.
    //       Leave qubit "a" unchanged.
    operation LowestBitSumInPlace (a : Qubit, b : Qubit) : Unit is Adj {
        CNOT(a, b);

    }


    // Something to think about: can we re-use one of the input bits to calculate the carry in-place as well? Why or why not?


    // Task 2.2. In-place one-bit adder
    // Inputs:
    //      1) qubit "a" in an arbitrary state |φ⟩,
    //      2) qubit "b" in an arbitrary state |ψ⟩,
    //      3) qubit "carry" in state |0⟩.
    // Goals:
    //      1) transform the "carry" qubit into the carry bit from the addition of φ and ψ,
    //      2) transform qubit "b" into the lowest bit of φ + ψ.
    //         Leave qubit "a" unchanged.
    operation OneBitAdderInPlace (a : Qubit, b : Qubit, carry : Qubit) : Unit is Adj {
        // Hint: think carefully about the order of operations.

//        CCNOT(a, b, carry);
        LowestBitCarry(a, b, carry);
        CNOT(a, b);
    }

    
    // Task 2.3. In-place summation of three bits
    // Inputs:
    //      1) qubit "a" in an arbitrary state |φ⟩,
    //      2) qubit "b" in an arbitrary state |ψ⟩,
    //      3) qubit "carryin" in an arbitrary state |ω⟩.
    // Goal: transform qubit "b" into the lowest bit from the addition of φ and ψ and ω.
    //       Leave qubits "a" and "carryin" unchanged.
    operation HighBitSumInPlace (a : Qubit, b : Qubit, carryin : Qubit) : Unit is Adj {
        CNOT(a, b);
        CNOT(carryin, b);
    }


    // Task 2.4. In-place two-bit adder
    // Inputs:
    //      1) two-qubit register "a" in an arbitrary state |φ⟩,
    //      2) two-qubit register "b" in an arbitrary state |ψ⟩,
    //      3) qubit "carry" in state |0⟩.
    // Goals:
    //      1) transform register "b" into the state |φ + ψ⟩,
    //      2) transform the "carry" qubit into the carry bit from the addition.
    //         Leave register "a" unchanged.
    operation TwoBitAdderInPlace (a : Qubit[], b : Qubit[], carry : Qubit) : Unit is Adj {

        using (carryInternal = Qubit()) {
            LowestBitCarry(a[0], b[0], carryInternal);
            HighBitCarry(a[1], b[1], carryInternal, carry);

            HighBitSumInPlace(a[1], b[1], carryInternal);
            Adjoint LowestBitCarry(a[0], b[0], carryInternal);

            LowestBitSumInPlace(a[0], b[0]);

        }
    }

    
    // Task 2.5. In-place N-bit adder
    // Inputs:
    //      1) N-qubit register "a" in an arbitrary state |φ⟩,
    //      2) N-qubit register "b" in an arbitrary state |ψ⟩,
    //      3) qubit "carry" in state |0⟩.
    // Goals:
    //      1) transform register "b" into the state |φ + ψ⟩,
    //      2) transform the "carry" qubit into the carry bit from the addition.
    //         Leave register "a" unchanged.
    operation ArbitraryAdderInPlace (a : Qubit[], b : Qubit[], carry : Qubit) : Unit is Adj {
        let N=Length(a);

        using (carryInternals = Qubit[N]) {

            LowestBitCarry(a[0], b[0], carryInternals[0]);

            for ( i in 1..N-1) {
                HighBitCarry(a[i], b[i], carryInternals[i-1], carryInternals[i]);
            }

            CNOT(carryInternals[N-1], carry);

            // undo carryInternals anc calc sum
            for ( i in N-1..-1..1) {
                Adjoint HighBitCarry(a[i], b[i], carryInternals[i-1], carryInternals[i]);
                HighBitSumInPlace(a[i], b[i], carryInternals[i-1]);
            }

            Adjoint LowestBitCarry(a[0], b[0], carryInternals[0]);
            LowestBitSumInPlace(a[0], b[0]);

        }
    }

    
    //////////////////////////////////////////////////////////////////
    // Part III*. Improved in-place adder
    //////////////////////////////////////////////////////////////////

    // The in-place adder doesn't require quite as many qubits for the inputs and outputs,
    // but it still requires an array of extra ("ancillary") qubits to perform the calculation.
    // A relatively recent algorithm allows you to perform the same calculation
    // using only one additional qubit.

    // Task 3.1. Majority gate
    // Inputs:
    //      1) qubit "a" in an arbitrary state |φ⟩,
    //      2) qubit "b" in an arbitrary state |ψ⟩,
    //      3) qubit "c" in an arbitrary state |ω⟩.
    // Goal: construct the "in-place majority" gate:
    //      1) transform qubit "a" into the carry bit from the addition of φ, ψ and ω,
    //      2) transform qubit "b" into |φ + ψ⟩,
    //      3) transform qubit "c" into |φ + ω⟩.
    operation Majority (a : Qubit, b : Qubit, c : Qubit) : Unit is Adj {
        CNOT(a, b);
        CNOT(a, c);
        CCNOT(b, c, a);
    }

    
    // Task 3.2. "UnMajority and Add" gate
    // Inputs:
    //      1) qubit "a" storing the carry bit from the sum φ + ψ + ω,
    //      2) qubit "b" in state |φ + ψ⟩,
    //      3) qubit "c" in state |φ + ω⟩.
    // Goal: construct the "un-majority and add", or "UMA" gate
    //      1) restore qubit "a" into state |φ⟩,
    //      2) transform qubit "b" into state |φ + ψ + ω⟩,
    //      3) restore qubit "c" into state |ω⟩.
    operation UnMajorityAdd (a : Qubit, b : Qubit, c : Qubit) : Unit is Adj {
        CCNOT(b, c, a);
        CNOT(a, c);
        CNOT(c, b);
    }


    // Task 3.3. One-bit majority-UMA adder
    // Inputs:
    //      1) qubit "a" in an arbitrary state |φ⟩,
    //      2) qubit "b" in an arbitrary state |ψ⟩,
    //      3) qubit "carry" in state |0⟩.
    // Goal: construct a one-bit binary adder from task 2.2 using Majority and UMA gates.
    operation OneBitMajUmaAdder (a : Qubit, b : Qubit, carry : Qubit) : Unit is Adj {
        // Hint: Allocate an extra qubit to hold the carry bit used in Majority and UMA gates during the computation.
        // It's less efficient here, but it will help in the next tasks.

        using (ancillary = Qubit()) {
            Majority(a, b, ancillary);
            CNOT(a, carry);
            UnMajorityAdd(a, b, ancillary);
        }
    }


    // Task 3.4. Two-bit majority-UMA adder
    // Inputs:
    //      1) two qubit register "a" in an arbitrary state |φ⟩,
    //      2) two qubit register "b" in an arbitrary state |ψ⟩,
    //      3) qubit "carry" in state |0⟩.
    // Goal: construct a two-bit binary adder from task 2.4 using Majority and UMA gates.
    operation TwoBitMajUmaAdder (a : Qubit[], b : Qubit[], carry : Qubit) : Unit is Adj {
        // Hint: think carefully about which qubits you need to pass to the two gates.

        using (ancillary = Qubit()) {
            Majority(a[0], b[0], ancillary);
            Majority(a[1], b[1], a[0]);
            CNOT(a[1], carry);
            UnMajorityAdd(a[1], b[1], a[0]);
            UnMajorityAdd(a[0], b[0], ancillary);
        }

    }


    // Task 3.5. N-bit majority-UMA adder
    // Inputs:
    //      1) N qubit register "a" in an arbitrary state |φ⟩,
    //      2) N qubit register "b" in an arbitrary state |ψ⟩,
    //      3) qubit "carry" in state |0⟩.
    // Goal: construct an N-bit binary adder from task 2.5 using only one extra qubit.
    operation ArbitraryMajUmaAdder (a : Qubit[], b : Qubit[], carry : Qubit) : Unit is Adj {
        
        let N=Length(a);

        using (ancillary = Qubit()) {

            Majority(a[0], b[0], ancillary);

            for (i in 1..N-1) {
                Majority(a[i], b[i], a[i-1]);
            }
            CNOT(a[N-1], carry);

            for (i in N-1..-1..1) {
                UnMajorityAdd(a[i], b[i], a[i-1]);
            }
            UnMajorityAdd(a[0], b[0], ancillary);
        }
    }


    //////////////////////////////////////////////////////////////////
    // Part IV*. In-place subtractor
    //////////////////////////////////////////////////////////////////

    // Subtracting a number is the same operation as adding a negative number.
    // As such, the binary adder we just built can be easily adapted to act as a subtractor instead.

    // Task 4.1. N-bit subtractor
    // Inputs:
    //      1) N qubit register "a" in an arbitrary state |φ⟩,
    //      2) N qubit register "b" in an arbitrary state |ψ⟩,
    //      3) qubit "borrow" in state |0⟩.
    // Goal: construct a binary subtractor:
    //      1) transform register "b" into the state |ψ - φ⟩ ,
    //      2) set the "borrow" qubit to |1⟩ if that subtraction required a borrow.
    //         Leave register "a" unchanged.
    operation Subtractor (a : Qubit[], b : Qubit[], borrow : Qubit) : Unit is Adj {
        // Hint: use the adder you already built, 
        // and experiment with inverting the registers before and after the addition.

        // transform b into 2ᴺ - 1 - b
        ApplyToEachA(X, b);

        // compute (2ᴺ - 1 - b) + a = 2ᴺ - 1 - (b - a) using existing adder
        // if this produced a carry, then (2ᴺ - 1 - (b - a)) > 2ᴺ - 1, so (b - a) < 0, and we need a borrow
        // this means we can use the carry qubit from the addition as the borrow qubit
        ArbitraryMajUmaAdder(a, b, borrow);

        // transform 2ᴺ - 1 - (b - a) into b - a
        ApplyToEachA(X, b);

    }
}