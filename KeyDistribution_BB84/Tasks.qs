// Copyright (c) Microsoft Corporation.
// Licensed under the MIT license.

namespace Quantum.Kata.KeyDistribution {
    
    open Microsoft.Quantum.Arrays;
    open Microsoft.Quantum.Measurement;
    open Microsoft.Quantum.Canon;
    open Microsoft.Quantum.Intrinsic;
    open Microsoft.Quantum.Diagnostics;
    open Microsoft.Quantum.Convert;
    open Microsoft.Quantum.Math;
    
    
    //////////////////////////////////////////////////////////////////
    // Welcome!
    //////////////////////////////////////////////////////////////////
    
    // "Key Distribution" quantum kata is a series of exercises designed
    // to get you familiar with programming in Q#.
    // It covers the BB84 protocol for quantum key distribution. The BB84 Protocol
    // allows two parties, Alice and Bob, to share a random secret key. 
    
    // Each task is wrapped in one operation preceded by the description 
    // of the task. Each task (except tasks in which you have to write a 
    // test) has a unit test associated with it, which initially fails. 
    // Your goal is to fill in the blank (marked with // ... comment)
    // with some Q# code to make the failing test pass.
    

    //////////////////////////////////////////////////////////////////
    // Part I. Preparation
    //////////////////////////////////////////////////////////////////
	
    // Task 1.1. Diagonal polarization
    // Input: N qubits (stored in an array of length N).
    //        Each qubit is either in |0⟩ or in |1⟩ state.
    // Goal:  Convert the qubits to diagonal polarization:
    //	      if qs[i] was in state |0⟩, it should become |+⟩ = (|0⟩ + |1⟩) / sqrt(2),
    //	      if qs[i] was in state |1⟩, it should become |-⟩ = (|0⟩ - |1⟩) / sqrt(2).
    operation DiagonalPolarization (qs : Qubit[]) : Unit {
        ApplyToEachA(H, qs);
    }


    // Task 1.2. Equal superposition
    // Input: A qubit in the |0⟩ state.
    // Goal:  Change the qubit state to a superposition state 
    //        that has equal probabilities of measuring 0 and 1.
    // Note that this is not the same as keeping the qubit in the |0⟩ state with 50% probability
    // and converting it to the |1⟩ state with 50% probability!
    operation EqualSuperposition (q : Qubit) : Unit {
        H(q);
    }
    

    //////////////////////////////////////////////////////////////////
    // Part II. BB84 Protocol
    //////////////////////////////////////////////////////////////////
    
	// Task 2.1. Generate random array
    // Input:  An integer N.
    // Output: A Bool array of length N, where each element is chosen at random. 
    // 
    // This will be used by both Alice and Bob to choose either the sequence of bits to send
    // or the sequence of bases (false indicates |0⟩/|1⟩ basis, and true indicates |+⟩/|-⟩ basis) to use when encoding/measuring the bits.
    operation RandomArray (N : Int) : Bool[] {
        mutable result = new Bool[N];
        for (i in 0..N-1) {
            set result w/= i <- RandomInt(2)==1;
        }
        return result;
    }


    // Task 2.2. Prepare Alice's qubits
    // Inputs:
    //      1) "qs": an array of N qubits in the |0⟩ states,
    //	    2) "bases": a Bool array of length N;
    //         bases[i] indicates the basis to prepare the i-th qubit in:
    //         - false: use |0⟩/|1⟩ (computational) basis
    //         - true: use |+⟩/|-⟩ (Hadamard/diagonal) basis
    //      3) "bits": a Bool array of length N;
    //         bits[i] indicates the bit to encode in the i-th qubit: false = 0, true = 1.
    // Goal: Prepare the qubits in the described state.
    operation PrepareAlicesQubits (qs : Qubit[], bases : Bool[], bits : Bool[]) : Unit {
        // The following lines enforce the constraints on the input that you are given.
        // You don't need to modify them. Feel free to remove them, this won't cause your code to fail.
        Fact(Length(qs) == Length(bases), "Input arrays should have the same length");
        Fact(Length(qs) == Length(bits), "Input arrays should have the same length");

        let n = Length(qs);
        for ( i in 0..n-1) {
            if (bits[i]) {
                X(qs[i]);
            }
            if (bases[i]) {
                H(qs[i]);
            }
        }
    }


    // Task 2.3. Measure Bob's qubits
    // Inputs:
    //      1) "qs": an array of N qubits;
    //         each qubit is in one of the following states: |0⟩, |1⟩, |+⟩ or |-⟩.
    //	    2) "bases": a Bool array of length N;
    //         bases[i] indicates the basis used to prepare the i-th qubit:
    //         - false: use |0⟩/|1⟩ (computational) basis
    //         - true: use |+⟩/|-⟩ (Hadamard/diagonal) basis
    // Output: Measure each qubit in the corresponding basis and return an array of results 
    //         (encoding measurement result Zero as false and One as true).
    // The state of the qubits at the end of the operation does not matter.
    operation MeasureBobsQubits (qs : Qubit[], bases : Bool[]) : Bool[] {
        // The following lines enforce the constraints on the input that you are given.
        // You don't need to modify them. Feel free to remove them, this won't cause your code to fail.
        Fact(Length(qs) == Length(bases), "Input arrays should have the same length");
        
        for (i in 0..Length(qs)-1) {
            if (bases[i]) {
                H(qs[i]);
            }
        }
        return ResultArrayAsBoolArray(MultiM(qs));
    }


    // Task 2.4. Generate the shared key!
    // Inputs:
    //      1) "basesAlice" and "basesBob": Bool arrays of length N 
    //         describing Alice's and Bobs's choice of bases, respectively;
    //      2) "measurementsBob": a Bool array of length N describing Bob's measurement results.
    // Output: a Bool array representing the shared key generated by the protocol.
    // Note that you don't need to know both Alice's and Bob's bits to figure out the shared key!
    function GenerateSharedKey (basesAlice : Bool[], basesBob : Bool[], measurementsBob : Bool[]) : Bool[] {
        // The following lines enforce the constraints on the input that you are given.
        // You don't need to modify them. Feel free to remove them, this won't cause your code to fail.
        Fact(Length(basesAlice) == Length(basesBob), "Input arrays should have the same length");
        Fact(Length(basesAlice) == Length(measurementsBob), "Input arrays should have the same length");

        mutable key = new Bool[0];
        for ((a, b, bit) in Zip3(basesAlice, basesBob, measurementsBob)) {
            if ( a==b ) {
                set key += [bit];
            }
        }
        return key;
    }


    // Task 2.5. Was communication secure?
    // Inputs:
    //      1) "keyAlice" and "keyBob": Bool arrays of equal length N describing 
    //         the versions of the shared key obtained by Alice and Bob, respectively,
    //      2) "threshold": an integer between 50 and 100 - the percentage of the key bits that have to match.
    // Output: true if the percentage of matching bits is greater than or equal to the threshold,
    //	       and false otherwise.
    function CheckKeysMatch (keyAlice : Bool[], keyBob : Bool[], threshold : Int) : Bool {
        // The following lines enforce the constraints on the input that you are given.
        // You don't need to modify them. Feel free to remove them, this won't cause your code to fail.
        Fact(Length(keyAlice) == Length(keyBob), "Input arrays should have the same length");

        let n = Length(keyBob);
        mutable count = 0;

        for ((a,b) in Zip(keyAlice, keyBob)) {
            if ( a == b) {
                set count += 1;
            }
        }
//        Message($"errors {count} in {n} bits vs treshold {threshold}");
        return IntAsDouble(count)/IntAsDouble(n) >= IntAsDouble(threshold)/100.0;
    }


    // Task 2.6. Putting it all together 
    // Goal: Implement the entire BB84 protocol using tasks 2.1 - 2.5
    //       and following the comments in the operation template.
    // 
    // This is an open-ended task and is not covered by a test; 
    // you can run T26_BB84Protocol_Test to run your code.
    operation T26_BB84Protocol_Test () : Unit {

        let n=20;
        let threshold = 99;

        using (qs = Qubit[20]) {

            // 1. Alice chooses a random set of bits to encode in her qubits 
            //    and a random set of bases to prepare her qubits in.
            let bitsAlice = RandomArray(n);
            let basesAlice = RandomArray(n);

            // 2. Alice allocates qubits, encodes them using her choices and sends them to Bob.
            //    (Note that you can not reflect "sending the qubits to Bob" in Q#)
            PrepareAlicesQubits(qs, basesAlice, bitsAlice);

            // 3. Bob chooses a random set of bases to measure Alice's qubits in.
            let basesBob = RandomArray(n);

            // 4. Bob measures Alice's qubits in his chosen bases.
            let bitsBob = MeasureBobsQubits(qs, basesBob);

            // 5. Alice and Bob compare their chosen bases and use the bits in the matching positions to create a shared key.
            let keyAlice = GenerateSharedKey(basesAlice, basesBob, bitsAlice);
            let keyBob = GenerateSharedKey(basesAlice, basesBob, bitsBob);

            // 6. Alice and Bob check to make sure nobody eavesdropped by comparing a subset of their keys
            //    and verifying that more than a certain percentage of the bits match.
            // For this step, you can check the percentage of matching bits using the entire key 
            // (in practice only a subset of indices is chosen to minimize the number of discarded bits).
            if (CheckKeysMatch(keyAlice, keyBob, threshold)) {
                Message($"Successfully generated keys {keyAlice}/{keyBob}");
            }

            ResetAll(qs);
        }
        // If you've done everything correctly, the generated keys will always match, since there is no eavesdropping going on.
        // In the next section you will explore the effects introduced by eavesdropping.
    }


    //////////////////////////////////////////////////////////////////
    // Part III. Eavesdropping
    //////////////////////////////////////////////////////////////////

    // Task 3.1. Eavesdrop!
    // In this task you will try to implement an eavesdropper, Eve. 
    // Eve will intercept a qubit from the quantum channel that Alice and Bob are using. 
    // She will measure it in either the |0⟩/|1⟩ basis or the |+⟩/|-⟩ basis,
    // reconstruct the qubit into the original state and send it back to the channel. 
    // Eve hopes that if she properly reconstructs the qubit after measurement she won't be caught!
    //
    // Inputs:
    //      1) "q": a qubit in one of the following states: |0⟩, |1⟩, |+⟩ or |-⟩,
    //      2) "basis": Eve's guess of the basis she should use for measuring.
    //         Recall that false indicates |0⟩/|1⟩ basis and true indicates |+⟩/|-⟩ basis.
    // Output: the bit encoded in the qubit (false for |0⟩/|+⟩ states, true for |1⟩/|-⟩ states).
    // Note: in this task you are guaranteed that the basis you're given matches 
    //       the one in which the qubit is encoded, that is, if you are given a qubit in state
    //       |0⟩ or |1⟩, you will be given basis = false, and if you are given a qubit in state
    //       |+⟩ or |-⟩, you will be given basis = true. This is different from a real
    //       eavesdropping scenario, in which you have to guess the basis yourself.

    operation Eavesdrop (q : Qubit, basis : Bool) : Bool {
        // mutable result = Zero;

        // within {
        //     if (basis) {
        //         H(q);
        //     }
        // }
        // apply {
        //     set result = M(q);
        // }
        // return result == One;

        // compact version
        return Measure([basis ? PauliX | PauliZ], [q]) == One;
    }
    

    // Task 3.2. Catch the eavesdropper
    // Add an eavesdropper into the BB84 protocol from task 2.6.
    // Note that now we should be able to detect Eve and therefore we have to discard some of our keys!
    //
    // This is an open-ended task and is not covered by a test; 
    // you can run T32_BB84ProtocolWithEavesdropper_Test to run your code.
    operation T32_BB84ProtocolWithEavesdropper_Test () : Unit {
        let n=20;
        let threshold = 90;

        using (qs = Qubit[20]) {

            // 1. Alice chooses a random set of bits to encode in her qubits 
            //    and a random set of bases to prepare her qubits in.
            let bitsAlice = RandomArray(n);
            let basesAlice = RandomArray(n);

            // 2. Alice allocates qubits, encodes them using her choices and sends them to Bob.
            //    (Note that you can not reflect "sending the qubits to Bob" in Q#)
            PrepareAlicesQubits(qs, basesAlice, bitsAlice);

            // Eve eavesdrops on all qubits, guessing the basis at random
            
            for (i in 0..n-1) {
                let b = Eavesdrop(qs[i], RandomInt(2)==1);
            }


            // 3. Bob chooses a random set of bases to measure Alice's qubits in.
            let basesBob = RandomArray(n);

            // 4. Bob measures Alice's qubits in his chosen bases.
            let bitsBob = MeasureBobsQubits(qs, basesBob);

            // 5. Alice and Bob compare their chosen bases and use the bits in the matching positions to create a shared key.
            let keyAlice = GenerateSharedKey(basesAlice, basesBob, bitsAlice);
            let keyBob = GenerateSharedKey(basesAlice, basesBob, bitsBob);

            // 6. Alice and Bob check to make sure nobody eavesdropped by comparing a subset of their keys
            //    and verifying that more than a certain percentage of the bits match.
            // For this step, you can check the percentage of matching bits using the entire key 
            // (in practice only a subset of indices is chosen to minimize the number of discarded bits).
            if (CheckKeysMatch(keyAlice, keyBob, threshold)) {
                Message($"Successfully generated keys {keyAlice}/{keyBob}");
            }
            else {
                Message($"Caught an eavesdropper, discarding the keys {keyAlice}/{keyBob}");
            }

            ResetAll(qs);
        }

    }
}
