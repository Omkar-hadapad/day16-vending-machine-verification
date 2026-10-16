# Day 16 — Vending Machine FSM: RTL, Verification and Synthesis

## Project Overview

Day 16 implements and verifies a digital vending machine controller using a finite-state machine (FSM). The project includes basic digital building blocks, state-register logic, next-state logic, output decoding, and vending-machine transaction tests.

The design was simulated using Cadence NCSim, and synthesis reports were generated using Cadence Genus 21.14-s082_1 with the `tsmc18` standard-cell library.

## Objectives

- Verify basic combinational logic gates.
- Test an equality comparator and D flip-flop.
- Verify the two-bit state register and next-state logic.
- Check the output decoder for dispense and change signals.
- Test reset behavior and invalid simultaneous coin inputs.
- Compare selected behaviors of the structural implementation and RTL implementation.
- Review synthesis area, estimated power, and a reported setup-timing path.

## Design Blocks

| Block | Purpose |
|---|---|
| `vending_machine_top` | Top-level vending-machine design |
| `vending_next_state` | Computes the next FSM state |
| `vending_output_decoder` | Decodes state and inputs into output signals |
| `state_register_2bit` | Stores the current FSM state |
| `dff_sync_reset` modules | Implement the state-register storage elements |

### State Encoding Observed in the Tests

| State | Encoding | Meaning used by the tests |
|---|---|---|
| `S0` | `00` | Initial/ready state |
| `S5` | `01` | ₹5 accumulated |
| `S10` | `10` | ₹10 accumulated |

The testbench checks state transitions, dispensing behavior, change behavior, reset behavior, and invalid inputs. Refer to the RTL and testbench for the complete transition and output definitions.

## Verification

The testbench was run in Cadence NCSim. The simulation summary reported **111 passing checks and 0 failing checks** and finished at 445 ns using `$finish`.

### Test Summary

| Test | Verification area | Result |
|---|---|---|
| 1 | Basic logic gates | PASS |
| 2 | Equality comparator | PASS |
| 3 | D flip-flop | PASS |
| 4 | State register | PASS |
| 5 | Next-state logic | PASS |
| 6 | Output decoder | PASS |
| 7 | Machine reset | PASS |
| 8 | ₹5 + ₹5 + ₹5 transaction | PASS |
| 9 | ₹10 + ₹5 transaction | PASS |
| 10 | ₹10 + ₹10 transaction | PASS |
| 11 | Invalid simultaneous coin inputs | PASS |
| 12 | Structural versus RTL checks | PASS |
| 13 | Safety checks | PASS |

**Verification result:** All checks reported by this testbench passed. This result applies to the scenarios exercised; it does not by itself prove exhaustive functional coverage or formal equivalence.

## Synthesis and PPA Results

Synthesis was performed using Cadence Genus 21.14-s082_1. The reports identify the `tsmc18` library and the `slow (balanced_tree)` operating condition.

| Metric | Reported result |
|---|---:|
| Mapped standard-cell instances | 20 |
| Total standard-cell area | 349.272 area units |
| Estimated total power | 25.8744 µW |
| Reported Path 1 setup slack | +7.050 ns |
| Reported Path 1 data-path delay | 0.551 ns |

### Area Breakdown

| Category | Instances | Area | Area share |
|---|---:|---:|---:|
| Sequential | 2 | 113.098 | 32.4% |
| Inverters | 6 | 39.917 | 11.4% |
| Combinational logic | 12 | 196.258 | 56.2% |
| Physical cells | 0 | 0.000 | 0.0% |
| **Total** | **20** | **349.272** | **100%** |

The report excerpt does not explicitly specify the physical unit of the area value. The timing result is for one reported input-to-register setup path; it is not proof that every path meets setup and hold timing.

### Power Breakdown

| Category | Total power | Share |
|---|---:|---:|
| Register | 16.3055 µW | 63.02% |
| Logic | 7.99431 µW | 30.90% |
| Clock | 1.57464 µW | 6.09% |
| **Total** | **25.8744 µW** | **100% approximately** |

Power is the estimate reported for the stated simulation frame and analysis setup. Its accuracy depends on the activity data, constraints, library models, and analysis methodology.

### Timing Path Summary

- **Startpoint:** `coin_5`
- **Endpoint:** `DUT/STATE_REG/FF0/Q_reg/D`
- **Path type:** Input-to-register setup path
- **Data-path delay:** 551 ps
- **Required time:** 8601 ps
- **Slack:** +7050 ps (7.050 ns)
- **Result for this path:** MET

A full timing sign-off requires reviewing the worst paths across relevant path groups, hold checks, and unconstrained paths.

## Tools Used

- Verilog HDL
- Cadence NCSim — simulation
- Cadence Genus 21.14-s082_1 — synthesis and reporting
- `tsmc18` standard-cell library
- SDC timing constraints

## Suggested Repository Structure

```text
day16-vending-machine-verification/
├── rtl/
├── tb/
├── simulation/
├── synthesis/
├── constraints/
└── README.md
```

Use the actual filenames in your repository. Keep generated waveform databases and tool-specific temporary files out of version control unless they are intentionally required for review.

## Reproducing the Results

1. Review the RTL files and testbench.
2. Compile the design and testbench in the configured NCSim environment.
3. Run the simulation and inspect the complete log for failures.
4. Open the generated waveform database, if needed, to inspect reset, coin inputs, state transitions, dispense, and change signals.
5. Run the Genus synthesis flow using the project's library setup and timing constraints.
6. Save the area, power, and timing reports alongside the source files.
7. Re-run verification after any RTL or constraint changes.

Exact tool commands depend on the local simulator setup, library paths, and Genus scripts used in the project.

## Key Learning Outcomes

- Built and verified a modular FSM-based digital controller.
- Tested combinational and sequential building blocks.
- Exercised transaction sequences, reset behavior, and invalid input cases.
- Compared selected structural and RTL behaviors.
- Interpreted standard-cell area, power-category, and setup-timing reports.

## Project Status

**Day 16 simulation status: PASS — 111 checks passed, 0 checks failed.**

Synthesis area and power estimates were collected, and one setup path was reported as meeting timing. Full-design timing closure and post-layout verification should be confirmed separately if required.

---

## Next Project — DAY 17: DIGITAL STOPWATCH / TIMER

The next project will focus on designing and verifying a digital stopwatch/timer, including time counting, control inputs, reset behavior, and simulation-based verification.


