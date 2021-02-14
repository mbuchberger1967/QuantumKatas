// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT license.

namespace Quantum.Kata.GroversAlgorithm {
    
    open Microsoft.Quantum.Intrinsic;
    open Microsoft.Quantum.Canon;
    open Microsoft.Quantum.Diagnostics;
    open Microsoft.Quantum.Convert;
    open Microsoft.Quantum.Math;
    open Microsoft.Quantum.Arrays;
    open Microsoft.Quantum.Measurement;
    
    
    //////////////////////////////////////////////////////////////////
    // Welcome!
    //////////////////////////////////////////////////////////////////
    
    // The "Solving SAT problem with Grover's algorithm" quantum kata is a series of exercises designed
    // to get you comfortable with using Grover's algorithm to solve realistic problems
    // using boolean satisfiability problem (SAT) as an example.
    // It covers the following topics:
    //  - writing oracles implementing boolean expressions and SAT instances,
    //  - using Grover's algorithm to solve problems with unknown number of solutions.
    
    // Each task is wrapped in one operation preceded by the description of the task.
    // Each task (except tasks in which you have to write a test) has a unit test associated with it,
    // which initially fails. Your goal is to fill in the blank (marked with // ... comment)
    // with some Q# code to make the failing test pass.
    
    // Within each section, tasks are given in approximate order of increasing difficulty;
    // harder ones are marked with asterisks.
    
    
    //////////////////////////////////////////////////////////////////
    // Part I. Oracles for SAT problems
    //////////////////////////////////////////////////////////////////
    
    // The most interesting part of learning Grover's algorithm is solving realistic problems.
    // This means using oracles which express an actual problem and not simply hard-code a known solution.
    // In this section we'll learn how to express boolean satisfiability problems as quantum oracles.

    // Task 1.1. The AND oracle: f(x) = x₀ ∧ x₁
    // Inputs:
    //      1) 2 qubits in an arbitrary state |x⟩ (input/query register)
    //      2) a qubit in an arbitrary state |y⟩ (target qubit)
    // Goal: Transform state |x, y⟩ into state |x, y ⊕ f(x)⟩ (⊕ is addition modulo 2),
    //       i.e., flip the target state if all qubits of the query register are in the |1⟩ state,
    //       and leave it unchanged otherwise.
    //       Leave the query register in the same state it started in.
    // Stretch goal: Can you implement the oracle so that it would work
    //               for queryRegister containing an arbitrary number of qubits?
    operation Oracle_And (queryRegister : Qubit[], target : Qubit) : Unit is Adj {        
        // for 2 bits
//        CCNOT(queryRegister[0], queryRegister[1], target);

        // for any number of bits
        Controlled X(queryRegister, target);
    }


    // Task 1.2. The OR oracle: f(x) = x₀ ∨ x₁
    // Inputs:
    //      1) 2 qubits in an arbitrary state |x⟩ (input/query register)
    //      2) a qubit in an arbitrary state |y⟩ (target qubit)
    // Goal: Transform state |x, y⟩ into state |x, y ⊕ f(x)⟩ (⊕ is addition modulo 2),
    //       i.e., flip the target state if at least one qubit of the query register is in the |1⟩ state,
    //       and leave it unchanged otherwise.
    //       Leave the query register in the same state it started in.
    // Stretch goal: Can you implement the oracle so that it would work
    //               for queryRegister containing an arbitrary number of qubits?
    operation Oracle_Or (queryRegister : Qubit[], target : Qubit) : Unit is Adj {        
        // x₀ ∨ x₁ = ¬ (¬x₀ ∧ ¬x₁)

//        within {
//            X(queryRegister[0]);
//            X(queryRegister[1]);
//        }
//        apply {
//            CCNOT(queryRegister[0], queryRegister[1], target);
//        }
        // Then flip target again to get negation
//        X(target);

        // for any number of bits
        // First, flip target if both qubits are in |0⟩ state
        (ControlledOnInt(0, X))(queryRegister, target);
        // Then flip target again to get negation
        X(target);
    }


    // Task 1.3. The XOR oracle: f(x) = x₀ ⊕ x₁
    // Inputs:
    //      1) 2 qubits in an arbitrary state |x⟩ (input/query register)
    //      2) a qubit in an arbitrary state |y⟩ (target qubit)
    // Goal: Transform state |x, y⟩ into state |x, y ⊕ f(x)⟩ (⊕ is addition modulo 2),
    //       i.e., flip the target state if the qubits of the query register are in different states,
    //       and leave it unchanged otherwise.
    //       Leave the query register in the same state it started in.
    // Stretch goal: Can you implement the oracle so that it would work
    //               for queryRegister containing an arbitrary number of qubits?
    operation Oracle_Xor (queryRegister : Qubit[], target : Qubit) : Unit is Adj {        
        // for two bits
//        CNOT(queryRegister[0], target);
//        CNOT(queryRegister[1], target);

        // any number of bits
        ApplyToEachA(CNOT(_, target), queryRegister);

    }


    // Task 1.4. Alternating bits oracle: f(x) = (x₀ ⊕ x₁) ∧ (x₁ ⊕ x₂) ∧ ... ∧ (xₙ₋₂ ⊕ xₙ₋₁)
    // Inputs:
    //      1) N qubits in an arbitrary state |x⟩ (input/query register)
    //      2) a qubit in an arbitrary state |y⟩ (target qubit)
    // Goal: Transform state |x, y⟩ into state |x, y ⊕ f(x)⟩ (⊕ is addition modulo 2).
    //       Leave the query register in the same state it started in.
    // 
    // Note that this oracle marks two states similar to the state explored in task 1.2 of GroversAlgorithm kata: 
    // |10101...⟩ and |01010...⟩
    // It is possible (and quite straightforward) to implement this oracle based on this observation; 
    // however, for the purposes of learning to write oracles to solve SAT problems we recommend using the representation above.
    operation Oracle_AlternatingBits (queryRegister : Qubit[], target : Qubit) : Unit is Adj {        
        let length = Length(queryRegister)-1;

//        using (ancilla = Qubit[length]) {
//            for (i in 0..length-1) {
//                CNOT(queryRegister[i], ancilla[i]);
//                CNOT(queryRegister[i+1], ancilla[i]);
//            }

//            Controlled X(ancilla, target);

            // reset ancilla
//            for (i in 0..length-1) {
//                Adjoint CNOT(queryRegister[i], ancilla[i]);
//                Adjoint CNOT(queryRegister[i+1], ancilla[i]);
//            }
//        }

        // Alternative
        using (ancilla = Qubit[length]) {
            for (i in 0..length-1) {
                Oracle_Xor(queryRegister[i..i+1], ancilla[i]);
            }

            Controlled X(ancilla, target);

            // reset ancilla
            for (i in 0..length-1) {
                Adjoint Oracle_Xor(queryRegister[i..i+1], ancilla[i]);
            }
        }

    }


    // Task 1.5. Evaluate one clause of a SAT formula
    // 
    // For general SAT problems, f(x) is represented as a conjunction (an AND operation) of several clauses on N variables, 
    // and each clause is a disjunction (an OR operation) of one or several variables or negated variables:
    //      clause(x) = ∨ₖ yₖ, where yₖ = either xⱼ or ¬xⱼ for some j in {0, ..., N-1}
    // 
    // For example, one of the possible clauses on two variables is 
    //      clause(x) = x₀ ∨ ¬x₁
    // 
    // Inputs:
    //      1) N qubits in an arbitrary state |x⟩ (input/query register)
    //      2) a qubit in an arbitrary state |y⟩ (target qubit)
    //      3) a 1-dimensional array of tuples "clause" which describes one clause of a SAT problem instance clause(x).
    //
    // "clause" is an array of one or more tuples, each of them describing one component of the clause.
    // Each tuple is an (Int, Bool) pair:
    //  - the first element is the index j of the variable xⱼ,
    //  - the second element is true if the variable is included as itself (xⱼ) and false if it is included as a negation (¬xⱼ)
    // 
    // Example:
    // The clause clause(x) = x₀ ∨ ¬x₁ can be represented as [(0, true), (1, false)].
    operation Oracle_SATClause (queryRegister : Qubit[], 
                                target : Qubit, 
                                clause : (Int, Bool)[]) : Unit is Adj {        

        let (clauseQubits, flip) = ExtractClauseQubits(queryRegister, clause);

        // flip all bits for flip[i]==true
//        for ( i in 0..Length(clauseQubits)-1){
//            if (flip[i]) {
//                X(clauseQubits[i]);
//            }
//        }
        
//        Oracle_Or(clauseQubits, target);

//        for ( i in 0..Length(clauseQubits)-1){
//            if (flip[i]) {
//                Adjoint X(clauseQubits[i]);
//            }
//        }

        within {
            // flip all bits for flip[i]==true, and undo after oracle
            ApplyPauliFromBitString(PauliX, true, flip, clauseQubits);
        }
        apply {
            Oracle_Or(clauseQubits, target);
        }
    }

    // returns all qubits and the flip (bit) information for wich clause has an index
    function ExtractClauseQubits(queryRegister : Qubit[], clause : (Int, Bool)[]) : (Qubit[], Bool[]) {

        mutable clauseQubits = new Qubit[Length(clause)];
        mutable flips = new Bool[Length(clause)];
        for (i in 0..Length(clause)-1) {
            let (index, isTrue) = clause[i];

            set clauseQubits w/= i <- queryRegister[index];
            set flips w/= i <- not isTrue;
        }
        
        return (clauseQubits, flips);
    }

    // Task 1.6. General SAT problem oracle
    //
    // For SAT problems, f(x) is represented as a conjunction (an AND operation) of M clauses on N variables, 
    // and each clause is a disjunction (an OR operation) of one or several variables or negated variables:
    //      f(x) = ∧ᵢ (∨ₖ yᵢₖ), where yᵢₖ = either xⱼ or ¬xⱼ for some j in {0, ..., N-1}
    //
    // Inputs:
    //      1) N qubits in an arbitrary state |x⟩ (input/query register)
    //      2) a qubit in an arbitrary state |y⟩ (target qubit)
    //      3) a 2-dimensional array of tuples "problem" which describes the SAT problem instance f(x).
    //
    // i-th element of "problem" describes the i-th clause of f(x);
    // it is an array of one or more tuples, each of them describing one component of the clause.
    // Each tuple is an (Int, Bool) pair:
    //  - the first element is the index j of the variable xⱼ,
    //  - the second element is true if the variable is included as itself (xⱼ) and false if it is included as a negation (¬xⱼ)
    // 
    // Example:
    // A more general case of the OR oracle for 3 variables f(x) = (x₀ ∨ x₁ ∨ x₂) can be represented as [[(0, true), (1, true), (2, true)]].
    // 
    // Goal: Transform state |x, y⟩ into state |x, y ⊕ f(x)⟩ (⊕ is addition modulo 2).
    //       Leave the query register in the same state it started in.
    operation Oracle_SAT (queryRegister : Qubit[], 
                          target : Qubit, 
                          problem : (Int, Bool)[][]) : Unit is Adj {      

        using (ancillaRegister = Qubit[Length(problem)]) {

            within {
                // evaluate all or clauses and store the result in the ancilla register
                for (i in 0..Length(problem)-1) {
                    Oracle_SATClause(queryRegister, ancillaRegister[i], problem[i]);
                }
            }
            apply {
                // if all ancilla bits are true -> AND processes to true so flip the target bit
                Controlled X(ancillaRegister, target);
            }
        }
    }


    //////////////////////////////////////////////////////////////////
    // Part II. Oracles for exactly-1 3-SAT problem
    //////////////////////////////////////////////////////////////////
    
    // The exactly-1 3-SAT problem (also known as "one-in-three 3-SAT") is a variant of a general 3-SAT problem.
    // It has a structure similar to a 3-SAT problem, but each clause must have exactly one true literal 
    // (while in a normal 3-SAT problem each clause must have at least one true literal).


    // Task 2.1. "Exactly one |1⟩" oracle
    // Inputs:
    //      1) 3 qubits in an arbitrary state |x⟩ (input/query register)
    //      2) a qubit in an arbitrary state |y⟩ (target qubit)
    //
    // Goal: Transform the state |x, y⟩ into the state |x, y ⊕ f(x)⟩ (⊕ is addition modulo 2),
    //       where f(x) = 1 if exactly one bit of x is in the |1⟩ state, and 0 otherwise.
    //       Leave the query register in the same state it started in.
    // Stretch goal: Can you implement the oracle so that it would work
    //               for queryRegister containing an arbitrary number of qubits?
    operation Oracle_Exactly1One (queryRegister : Qubit[], target : Qubit) : Unit is Adj {
        // for 3 qubits
        // for even number of 1s X results in 0, for odd number results in 1
//        ApplyToEachA(CNOT(_, target), queryRegister);
        // |111> has also an odd number, so cancel this out
//        Controlled X(queryRegister, target);

        // for any number of qubits
        // bits = 00..0
        mutable bits = new Bool[Length(queryRegister)];
        for (i in 0..Length(queryRegister)-1) {
            // create all bit strings with exactly 1 bit set to true and perfomr a controlled X
            (ControlledOnBitString(bits w/ i <- true, X))(queryRegister, target);
        }
    }

    // Task 2.2. "Exactly-1 3-SAT" oracle
    // Inputs:
    //      1) N qubits in an arbitrary state |x⟩ (input/query register)
    //      2) a qubit in an arbitrary state |y⟩ (target qubit)
    //      3) a 2-dimensional array of tuples "problem" which describes the SAT problem instance f(x).
    // "problem" describes the problem instance in the same format as in task 1.6;
    // each clause of the formula is guaranteed to have exactly 3 terms.
    // 
    // Goal: Transform state |x, y⟩ into state |x, y ⊕ f(x)⟩ (⊕ is addition modulo 2).
    //       Leave the query register in the same state it started in.
    // 
    // Example:
    // An instance of the problem f(x) = (x₀ ∨ x₁ ∨ x₂) can be represented as [[(0, true), (1, true), (2, true)]], 
    // and its solutions will be (true, false, false), (false, true, false) and (false, false, true),
    // but none of the variable assignments in which more than one variable is true, 
    // which are solutions for the general SAT problem.
    operation Oracle_Exactly1_3SAT (queryRegister : Qubit[], 
                                    target : Qubit, 
                                    problem : (Int, Bool)[][]) : Unit is Adj {        
        // Hint: can you reuse parts of the code in section 1?
        using (ancillaRegister = Qubit[Length(problem)]) {

            within {
                // evaluate all or clauses and store the result in the ancilla register
                for (i in 0..Length(problem)-1) {
                    Oracle_Exactly1_3SATClause(queryRegister, ancillaRegister[i], problem[i]);
                }
            }
            apply {
                // if all ancilla bits are true -> AND processes to true so flip the target bit
                Controlled X(ancillaRegister, target);
            }
        }
    }

    operation Oracle_Exactly1_3SATClause (queryRegister : Qubit[], 
                                target : Qubit, 
                                clause : (Int, Bool)[]) : Unit is Adj {        

        let (clauseQubits, flip) = ExtractClauseQubits(queryRegister, clause);

        within {
            // flip all bits for flip[i]==true, and undo after oracle
            ApplyPauliFromBitString(PauliX, true, flip, clauseQubits);
        }
        apply {
            Oracle_Exactly1One(clauseQubits, target);
        }
    }



    //////////////////////////////////////////////////////////////////
    // Part III. Using Grover's algorithm for problems with multiple solutions
    //////////////////////////////////////////////////////////////////
    
    // Task 3.1. Using Grover's algorithm
    // Goal: Implement Grover's algorithm and use it to find solutions to SAT instances from parts I and II.
    // This task is not covered by a test and allows you to experiment with running the algorithm.
    //
    // If you want to learn Grover's algorithm itself, try doing the GroversAlgorithm kata first.
    @Test("QuantumSimulator")
    operation T31_E2E_GroversAlgorithm () : Unit {

        // Hint: Experiment with SAT instances with different number of solutions and the number of algorithm iterations 
        // to see how the probability of the algorithm finding the correct answer changes depending on these two factors.
        // For example, 
        // - the AND oracle from task 1.1 has exactly one solution,
        // - the alternating bits oracle from task 1.4 has exactly two solutions,
        // - the OR oracle from task 1.2 for 2 qubits has exactly 3 solutions, and so on.

        let n=4;
        let N=PowI(2,n);
        let GroverIterationMax = Ceiling(PI()/4.0*Sqrt(IntAsDouble(N)))+1;

        Message("Evaluating Grover with Oracle_And");
        for (iteration in 1..GroverIterationMax) {
            let (answer, prob) = EvaluateGroverResult(Oracle_And, iteration, n);
            Message($"grover iterations: {iteration}   answer: {answer}   success with {prob}%");
        }

        Message("Evaluating Grover with Oracle_Or");
        for (iteration in 1..GroverIterationMax) {
            let (answer, prob) = EvaluateGroverResult(Oracle_Or, iteration, n);
            Message($"grover iterations: {iteration}   answer: {answer}   success with {prob}%");
        }
        Message("Evaluating Grover with Oracle_Xor");
        for (iteration in 1..GroverIterationMax) {
            let (answer, prob) = EvaluateGroverResult(Oracle_Xor, iteration, n);
            Message($"grover iterations: {iteration}   answer: {answer}   success with {prob}%");
        }
        Message("Evaluating Grover with Oracle_AlternatingBits");
        for (iteration in 1..GroverIterationMax) {
            let (answer, prob) = EvaluateGroverResult(Oracle_AlternatingBits, iteration, n);
            Message($"grover iterations: {iteration}   answer: {answer}   success with {prob}%");
        }
    }

    operation EvaluateGroverResult(oracle : ((Qubit[], Qubit) => Unit is Adj), iterations : Int, n : Int) : (Bool[] , Int) {
        
        let N=PowI(2,n);
        mutable correct = 0;
        mutable answer = new Bool[N];

        // 100 passes
        for (i in 1..100 ) {
            using ((register, output) = (Qubit[n],Qubit())) {
                GroversAlgorithm(register, oracle, iterations);

                let res = MultiM(register);
                // to check whether the result is correct, apply the oracle to the register plus ancilla after measurement
                oracle(register, output);
                if (MResetZ(output) == One) {
                    set correct += 1;
                    set answer = ResultArrayAsBoolArray(res);
                }
                ResetAll(register);
            }
        }
        
        return (answer, correct);
    }
    
    operation OracleConverterImpl(markingOracle : ((Qubit[], Qubit) => Unit is Adj), register : Qubit[]) : Unit is Adj {

        using (target = Qubit()) {
            // bring target in state |->
            X(target);
            H(target);

            // Apply the marking oracle; since the target is in the |-⟩ state,
            // flipping the target if the register satisfies the oracle condition will apply a -1 factor to the state
            markingOracle(register, target);

            // reset target before relasing
            H(target);
            X(target);
        }
    }

    function OracleConverter(markingOracle : ((Qubit[], Qubit) => Unit is Adj)) : ((Qubit[]) => Unit is Adj) {
        return OracleConverterImpl(markingOracle, _);
    }

    operation GroversAlgorithm (register : Qubit[], oracle : ((Qubit[], Qubit) => Unit is Adj), iterations : Int) : Unit {

        // convert markingOracle to phaseOracle
        let phaseOracle = OracleConverter(oracle);

        // bring register in equal superposition
        ApplyToEachA(H, register);

        for (i in 1 .. iterations) {
            phaseOracle(register);
            ApplyToEachA(H, register);
            ApplyToEachA(X, register);
            Controlled Z(Most(register), Tail(register));
            ApplyToEachA(X, register);
            ApplyToEachA(H, register);
        }
    }


    // Task 3.2. Universal implementation of Grover's algorithm
    // Inputs: 
    //      1) the number of qubits N,
    //      2) a marking oracle which implements a boolean expression, similar to the oracles from part I.
    // Output:
    //      An array of N boolean values which satisfy the expression implemented by the oracle
    //      (i.e., any basis state marked by the oracle).
    // 
    // Note that the similar task in the GroversAlgorithm kata required you to implement Grover's algorithm
    // in a way that would be robust to accidental failures, but you knew the optimal number of iterations
    // (the number that minimized the probability of such failure). 
    // In this task you also need to make your implementation robust to not knowing the optimal number of iterations.
    operation UniversalGroversAlgorithm (N : Int, oracle : ((Qubit[], Qubit) => Unit is Adj)) : Bool[] {
        // In this task you don't know the optimal number of iterations upfront, 
        // so it makes sense to try different numbers of iterations.
        // This way, even if you don't hit the "correct" number of iterations on one of your tries,
        // you'll eventually get a high enough success probability.

        // This solution tries numbers of iterations that are powers of 2;
        // this is not the only valid solution, since a lot of sequences will eventually yield the answer.
        mutable answer = new Bool[N];
        using ((register, output) = (Qubit[N], Qubit())) {
            mutable correct = false;
            mutable iter = 1;
            repeat {
                Message($"Trying search with {iter} iterations");
                GroversAlgorithm_Loop(register, oracle, iter);
                let res = MultiM(register);
                // to check whether the result is correct, apply the oracle to the register plus ancilla after measurement
                oracle(register, output);
                if (MResetZ(output) == One) {
                    set correct = true;
                    set answer = ResultArrayAsBoolArray(res);
                }
                ResetAll(register);
            } until (correct or iter > 100)  // the fail-safe to avoid going into an infinite loop
            fixup {
                set iter *= 2;
            }
            if (not correct) {
                fail "Failed to find an answer";
            }
        }
        Message($"{answer}");
        return answer;
    }
}
