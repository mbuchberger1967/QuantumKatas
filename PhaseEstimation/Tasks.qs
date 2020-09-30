// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT license.

namespace Quantum.Kata.PhaseEstimation {
    
    open Microsoft.Quantum.Intrinsic;
    open Microsoft.Quantum.Canon;
    open Microsoft.Quantum.Diagnostics;
    open Microsoft.Quantum.Convert;
    open Microsoft.Quantum.Math;
    open Microsoft.Quantum.Characterization;
    open Microsoft.Quantum.Oracles;
    open Microsoft.Quantum.Arithmetic;
    open Microsoft.Quantum.Measurement;

    
    //////////////////////////////////////////////////////////////////
    // Welcome!
    //////////////////////////////////////////////////////////////////
    
    // The "Phase estimation" quantum kata is a series of exercises designed
    // to teach you the basics of phase estimation algorithms.
    // It covers the following topics:
    //  - quantum phase estimation,
    //  - iterative phase estimation,
    //  - preparing necessary inputs to phase estimation routines and applying them.
    
    // Each task is wrapped in one operation preceded by the description of the task.
    // Each task (except tasks in which you have to write a test) has a unit test associated with it,
    // which initially fails. Your goal is to fill in the blank (marked with // ... comment)
    // with some Q# code to make the failing test pass.
    
    // Within each section, tasks are given in approximate order of increasing difficulty;
    // harder ones are marked with asterisks.
    
    
    //////////////////////////////////////////////////////////////////
    // Part I. Quantum phase estimation (QPE)
    //////////////////////////////////////////////////////////////////
    
    // Task 1.1. Inputs to QPE: eigenstates of Z/S/T gates.
    // Inputs:
    //      1) a qubit in |0⟩ state.
    //      2) an integer indicating which eigenstate to prepare.
    // Goal: 
    //      Prepare one of the eigenstates of Z gate (which are the same as eigenstates of S or T gates):
    //      eigenstate |0⟩ if state = 0, or eigenstate |1⟩ if state = 1.
    operation Eigenstates_ZST (q : Qubit, state : Int) : Unit is Adj {
        Fact(state == 0 or state == 1, "state must ne 0 or 1");

        if (state == 1) {
            X(q);
        }
    }


    // Task 1.2. Inputs to QPE: powers of Z/S/T gates.
    // Inputs:
    //      1) a single-qubit unitary U.
    //      2) a positive integer power.
    // Output:
    //      A single-qubit unitary equal to U raised to the given power.
    function UnitaryPower (U : (Qubit => Unit is Adj + Ctl), power : Int) : (Qubit => Unit is Adj + Ctl) {
        // Hint: Remember that you can define auxiliary operations.

        return UnitaryPowerImpl(U, power, _);
    }

    operation UnitaryPowerImpl(U : (Qubit => Unit is Adj + Ctl), power : Int, q : Qubit) : Unit is Adj + Ctl {
        for (i in 1..power) {
            U(q);
        }
    }

    // Task 1.3. Validate inputs to QPE
    // Inputs:
    //      1) a single-qubit unitary U.
    //      2) a single-qubit state |ψ⟩ represented by a unitary P such that |ψ⟩ = P|0⟩
    //         (i.e., applying the unitary P to state |0⟩ prepares state |ψ⟩).
    // Goal:
    //      Assert that the given state is an eigenstate of the given unitary,
    //      i.e., do nothing if it is, and throw an exception if it is not.
    operation AssertIsEigenstate (U : (Qubit => Unit), P : (Qubit => Unit is Adj)) : Unit {
        
        using (q = Qubit()) {
            // Prepare the state |ψ⟩ = P|0⟩
            P(q);

            // apply unitary to qubit
            U(q);

            // if |ψ⟩ is an eigenstate, U should not modify the state except for a global phase.
            // SO if we undo P we should measure the original state |0⟩
            Adjoint P(q);

            AssertAllZero([q]);
        }

    }


    // Task 1.4. QPE for single-qubit unitaries
    // Inputs: 
    //      1) a single-qubit unitary U.
    //      2) a single-qubit eigenstate of U |ψ⟩ represented by a unitary P such that |ψ⟩ = P|0⟩
    //         (i.e., applying the unitary P to state |0⟩ prepares state |ψ⟩).
    //      3) an integer n.
    // Output:
    //      The phase of the eigenvalue that corresponds to the eigenstate |ψ⟩, with n bits of precision.
    //      The phase should be between 0 and 1.
    operation QPE (U : (Qubit => Unit is Adj + Ctl), P : (Qubit => Unit is Adj), n : Int) : Double {

        using ((eigenstate, phaseRegister) = (Qubit[1], Qubit[n])) {

            let oracle = DiscreteOracle(UnitaryPowerOracle(U, _, _));
            let phaseRegisterBE = BigEndian(phaseRegister);
            
            // prepare the eigenstate of U
            P(eigenstate[0]);

            // execute QPE to determine theta = j/2^n
            QuantumPhaseEstimation(oracle, eigenstate, phaseRegisterBE);

            // measure j, divide by 2^n to get theta
            let phase = IntAsDouble(MeasureInteger(BigEndianAsLittleEndian(phaseRegisterBE))) / IntAsDouble(PowI(2, n));

            ResetAll(eigenstate);
            ResetAll(phaseRegister);

            return phase;
        }        
    }

    operation UnitaryPowerOracle(U : (Qubit => Unit is Adj + Ctl), power : Int, q : Qubit[]) : Unit is Adj + Ctl {
        for (i in 1..power) {
            U(q[0]);
        }
    }


    // Task 1.5. Test your QPE implementation
    // Goal: Use your QPE implementation from task 1.4 to run quantum phase estimation 
    //       on several simple unitaries and their eigenstates.
    // This task is not covered by a test and allows you to experiment with running the algorithm.
    operation T15_E2E_QPE_Test () : Unit {
        // Z|0>=|0>, Z|1> = -|1>
        EqualityWithinToleranceFact(QPE(Z, I, 1), 0.0, 0.25);
        EqualityWithinToleranceFact(QPE(Z, X, 1), 0.5, 0.25);

        // S|0>=|0>, S|1> = i|1>
        EqualityWithinToleranceFact(QPE(S, I, 2), 0.0, 0.125);
        EqualityWithinToleranceFact(QPE(S, X, 2), 0.25, 0.125);

        // T|0>=|0>, T|1> = e^(2*pi*i/8)|1>
        EqualityWithinToleranceFact(QPE(T, I, 3), 0.0,   0.0625);
        EqualityWithinToleranceFact(QPE(T, X, 3), 0.125, 0.0625);

        // X|0>=|1>, X|1> = |0>
        // eigenstate |+> => eigenvalue +1
        EqualityWithinToleranceFact(QPE(X, H, 2), 0.0, 0.125);
        // eigenstate |-> or -|-> => eigenvalue -1
        // H*X = U(pi/2, pi, pi) = P
        EqualityWithinToleranceFact(QPE(X, MultiplyUnitary(H, X), 2), 0.5, 0.125);

        // Y|0>=-i|0>, Y|1> = |0>
        // eigenstate 1/sqrt(2)(-i|0>+|1>) -> eigenvalue +1
        // Rx(pi/2)*X|0> = 1/sqrt(2)(-i|0>+|1> -> Rx*X = P
        EqualityWithinToleranceFact(QPE(Y, MultiplyUnitary(Rx(PI()/2.0, _), X), 2), 0., 0.125);
        // eigenstate 1/sqrt(2)(|0>-i|1>) -> eigenvalue -1
        // Rx(pi/2) = P
        EqualityWithinToleranceFact(QPE(Y, Rx(PI()/2.0, _), 2), 0.5, 0.125);


        // U = (( i  0 ) (0 -i)), U|0> = i|0>, U|1> = -i|1>
        // eigenstate : |0> -> eigenvalue +i
        // P=I
        EqualityWithinToleranceFact(QPE(Rz(PI(), _), I, 2), 0.75, 0.125);
        // eigenstate : |1> -> eigenvalue -i
        // P=X
        EqualityWithinToleranceFact(QPE(Rz(PI(), _), X, 2), 0.25, 0.125);
    }

    // returns a unitary that performs a multiplication, U1 is the left and U2 is the right unitary (so U1 U2 |q>)
    function MultiplyUnitary (U1 : (Qubit => Unit is Adj + Ctl), U2 : (Qubit => Unit is Adj + Ctl)) : (Qubit => Unit is Adj + Ctl) {

        return MultiplyUnitaryImpl(U1, U2, _);
    }

   operation MultiplyUnitaryImpl(U1 : (Qubit => Unit is Adj + Ctl), U2 : (Qubit => Unit is Adj + Ctl), q : Qubit) : Unit is Adj + Ctl {
            U2(q);
            U1(q);
    }


    //////////////////////////////////////////////////////////////////
    // Part II. Iterative phase estimation
    //////////////////////////////////////////////////////////////////
    
    // Unlike quantum phase estimation, which is a single algorithm, 
    // iterative phase estimation is a whole class of algorithms based on the same idea:
    // treating phase estimation as a classical algorithm which learns the phase via a sequence of measurements
    // (the measurement performed on each iteration can depend on the outcomes of previous iterations).

    // A typical circuit for one iteration has the following structure:
    //
    //                 ┌───┐  ┌───┐       ┌───┐  ┌───┐
    // control:    |0>─┤ H ├──┤ R ├───┬───┤ H ├──┤ M ╞══
    //                 └───┘  └───┘┌──┴──┐└───┘  └───┘
    // eigenstate: |ψ>─────────────┤  Uᴹ ├──────────────
    //                             └─────┘
    // 
    // (R is a rotation gate, and M is a power of the unitary U;
    //  both depend on the current information about the phase).
    //
    // The result of the measurement performed on the top qubit defines the next iteration.


    // Task 2.1. Single-bit phase estimation
    // Inputs:
    //      1) a single-qubit unitary U that is guaranteed to have an eigenvalue +1 or -1 
    //         (with eigenphases 0.0 or 0.5, respectively).
    //      2) a single-qubit eigenstate of U |ψ⟩ represented by a unitary P such that |ψ⟩ = P|0⟩
    //         (i.e., applying the unitary P to state |0⟩ prepares state |ψ⟩).
    // Output:
    //      The eigenvalue which corresponds to the eigenstate |ψ⟩ (+1 or -1).
    //
    // You are allowed to allocate exactly two qubits and call Controlled U exactly once.
    operation SingleBitPE (U : (Qubit => Unit is Adj + Ctl), P : (Qubit => Unit is Adj)) : Int {
        // Note: It is possible to use the QPE implementation from task 1.4 to solve this task, 
        // but we suggest you implement the circuit by hand for the sake of learning.

        // Using QPE from above
//        let theta = QPE(U, P, 1);
//        return theta == 0.0 ? 1 | -1;

        // Iterative Phase Estimation
        using ((control, eigenstate)=(Qubit(), Qubit())) {
            //Prepare eigenstate
            P(eigenstate);

            //iteration
            H(control);
            
            // Rz(x<=pi/2) is ok, x> pi/2 gives error
//            Rz(PI()/1.5, control);

            Controlled U([control], eigenstate);

            H(control);

            let eigenvalue = M(control)==Zero ? +1 | -1;

            ResetAll([control, eigenstate]);

            return eigenvalue;
        }
    }


    // Task 2.2. Two bit phase estimation
    // Inputs:
    //      1) a single-qubit unitary U that is guaranteed to have an eigenvalue +1, i, -1 or -i
    //         (with eigenphases 0.0, 0.25, 0.5 or 0.75, respectively).
    //      2) a single-qubit eigenstate of U |ψ⟩ represented by a unitary P such that |ψ⟩ = P|0⟩
    //         (i.e., applying the unitary P to state |0⟩ prepares state |ψ⟩).
    // Output:
    //      The eigenphase which corresponds to the eigenstate |ψ⟩ (0.0, 0.25, 0.5 or 0.75).
    // The returned value has to be accurate within the absolute error of 0.001.
    //
    // You are allowed to allocate exactly two qubits and call Controlled U multiple times.
    operation TwoBitPE (U : (Qubit => Unit is Adj + Ctl), P : (Qubit => Unit is Adj)) : Double {
        // Hint: Start by applying the same circuit as in task 2.1.
        //       What are the possible outcomes for each eigenvalue?
        //       What eigenvalues you can and can not distinguish using this circuit?

        // Iterative Phase Estimation
        using ((control, eigenstate)=(Qubit(), Qubit())) {
            //Prepare eigenstate
            P(eigenstate);

            //iteration
            mutable (measuredZero, measuredOne) = (false, false); 
            mutable iter = 0;
            
            repeat {
                set iter += 1;
                H(control);
                Controlled U([control], eigenstate);
                H(control);

                let measure = MResetZ(control);
                set (measuredZero, measuredOne) = (measuredZero or measure==Zero, measuredOne or measure == One);
            } 
            // repeat the loop until we get both Zero and One measurement outcomes
            // or until we're reasonably certain that we won't get a different outcome
            until (iter >10 or measuredZero and measuredOne);

            Reset(eigenstate);

            // if only Zero or only One was measured, return eigenphase 0.0 or 0.5
            // all measurements yielded Zero => eigenvalue +1
            // all measurements yielded One => eigenvalue -1
            if ( not measuredZero or not measuredOne) {
                return measuredZero ? 0.0 | 0.5;
            }
        }

        // Hint 2: What eigenvalues you can and can not distinguish using this circuit?
        //         What circuit you can apply to distinguish them?

        using ((control, eigenstate)=(Qubit(), Qubit())) {
            //Prepare eigenstate
            P(eigenstate);

            H(control);
            S(control);
            Controlled U([control], eigenstate);
            H(control);

            let eigenphase = MResetZ(control)==Zero ? 0.75 | 0.25;
            Reset(eigenstate);
            return eigenphase;
        }

    }


    // To be continued...
}
