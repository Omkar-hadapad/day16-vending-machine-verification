# Day 16 — Vending Machine FSM

<p align="center">
  <b>Digital VLSI • Verilog RTL • FSM Design • Functional Verification • Cadence Genus</b>
</p>

<p align="center">
  <code>Specification → RTL → Testbench → Simulation → Synthesis → Technology Mapping → Area → Power → Timing → PPA Review</code>
</p>

<p align="center">
  <img alt="Project" src="https://img.shields.io/badge/Project-Day%2016-blue">
  <img alt="HDL" src="https://img.shields.io/badge/HDL-Verilog-8A2BE2">
  <img alt="Synthesis" src="https://img.shields.io/badge/Synthesis-Cadence%20Genus-orange">
  <img alt="Verification" src="https://img.shields.io/badge/Verification-111%20Pass%20%7C%200%20Fail-success">
</p>

---

## 1. Project Information

| Parameter | Details |
|---|---|
| **Project** | Day 16 — Vending Machine FSM |
| **Author** | Omkar Kalmesh Hadapad |
| **Domain** | Digital VLSI / RTL Design / Functional Verification |
| **Design Type** | Finite-state machine (FSM) control circuit |
| **HDL** | Verilog HDL |
| **Simulation Tool** | Cadence NCSim (`ncsim`) |
| **Synthesis Tool** | Cadence Genus 21.14-s082_1 |
| **Technology Library** | `tsmc18` |
| **Top Module** | `vending_machine_top` |
| **Operating Condition** | `slow (balanced_tree)` |
| **Wireload Mode** | `enclosed` |
| **Analysis** | Functional verification, hierarchy, mapped area, power, timing |
| **Simulation Summary** | 111 reported passes, 0 reported failures |
| **Physical-Design Status** | Post-route implementation and extracted-parasitic closure are not established by the available reports |

> **Measurement note:** The area report gives `349.272`, but the provided excerpt does not explicitly confirm the physical unit. This README therefore calls it *reported area units*, not µm².

---

## 2. Project Overview

This project implements and verifies a vending-machine controller using a finite-state machine. The design handles tested ₹5 and ₹10 coin inputs, tracks the current amount through state transitions, and generates `dispense` and `change` outputs according to the implemented output decoder.

The project includes basic combinational blocks, a D flip-flop, a two-bit state register, next-state logic, output decoding, reset checks, transaction scenarios, and structural-versus-RTL checks. The design is then analyzed using Cadence Genus for standard-cell mapping, area, estimated power, and a reported setup-timing path.

The exact transaction rules and output timing should be interpreted from the RTL specification and testbench. The test results documented here reflect the checks visible in the supplied simulation transcript.

### Functional concept

```text
            coin_5 / coin_10
                    |
                    v
          +--------------------+
          |   Next-State Logic |
          +--------------------+
                    |
                    v
          +--------------------+
 clk ---> |   State Register   | <--- reset
          +--------------------+
                    |
                    v
          +--------------------+
          |   Output Decoder   |
          +--------------------+
              |           |
              v           v
           dispense     change
```

---

## 3. Objectives

1. Understand FSM-based control logic for a vending machine.
2. Verify basic combinational gates and equality-comparator behavior.
3. Verify D flip-flop reset and capture behavior.
4. Verify the two-bit state register.
5. Check next-state transitions for the tested coin-input combinations.
6. Check dispense and change output decoding.
7. Verify reset behavior and invalid simultaneous coin inputs.
8. Compare structural and RTL behavior for selected test cases.
9. Synthesize the design using Cadence Genus.
10. Analyze mapped standard cells, cell area, and estimated power.
11. Interpret a setup timing report and calculate slack.
12. Distinguish simulation and synthesis results from post-layout sign-off.

---

## 4. Functional Verification Summary

### 1. Simulation result

| Verification item | Reported result |
|---|---:|
| Final pass count | **111** |
| Final fail count | **0** |
| Testbench result | **PROJECT STATUS = PASS** |
| Simulator | Cadence NCSim |
| Simulation termination | `$finish` at approximately 445 ns |

The supplied transcript reports 111 passing checks and zero failing checks. This confirms the checks that were executed by this testbench; it does not, by itself, prove exhaustive correctness, formal equivalence, or ASIC sign-off.

### 2. Test sections visible in the transcript

| Test | Test area | Result |
|---:|---|---|
| 1 | Basic gates — NOT, AND, OR, XOR, NAND, NOR | PASS |
| 2 | Equality comparator | PASS |
| 3 | D flip-flop reset and load | PASS |
| 4 | State-register reset and state loading | PASS |
| 5 | Next-state logic | PASS |
| 6 | Output decoder | PASS |
| 7 | Machine reset | PASS |
| 8 | ₹5 + ₹5 + ₹5 transaction | PASS |
| 9 | ₹10 + ₹5 transaction | PASS |
| 10 | ₹10 + ₹10 transaction | PASS |
| 11 | Invalid simultaneous coin inputs | PASS |
| 12 | Structural versus RTL checks | PASS |
| 13 | Safety checks | PASS |

### 3. Observed FSM encodings

The transcript uses the following state encodings in its checks:

| State label | Encoding | Interpretation used in tests |
|---|---|---|
| `S0` | `00` | Initial/ready state |
| `S5` | `01` | State after the tested ₹5 input |
| `S10` | `10` | State after the tested ₹10 accumulation |

The testbench checks transitions from these states for no coin, ₹5, ₹10, simultaneous coin inputs, and an invalid state. Confirm the complete state-transition table against the RTL before treating this table as the full formal specification.

### 4. Transaction scenarios checked

- **₹5 + ₹5 + ₹5:** the transcript shows the machine moving through `00`, `01`, and `10`, with dispense asserted at the tested ₹15 condition.
- **₹10 + ₹5:** the transcript checks dispense and change behavior across the corresponding state/coin sequence.
- **₹10 + ₹10:** the transcript checks dispense and change for the tested ₹20 condition.
- **Invalid simultaneous coin inputs:** the test expects the next state to return to `00` and checks that dispense and change are not asserted for that invalid input combination.
- **Reset:** the test checks the state reset to `00` and inactive dispense/change outputs.

These are testbench observations. The intended product price, exact change policy, and output pulse duration should be documented from the design specification and RTL.

### 5. Initial unknown state observation

The first printed line includes `STATE=xx` at time zero, before the state is shown as `00` after reset handling. An unknown initial state is common in RTL simulation before a register has been reset. Confirm that reset is asserted at startup and that state/output checks occur after the appropriate reset and clock events.

### 6. Simulation transcript encoding

Some printed messages in the terminal are garbled where currency symbols or other non-ASCII characters appear. This looks like a terminal text-encoding issue rather than a failed assertion: the displayed expected and actual values still match. For portable logs, use ASCII labels such as `COIN_5`, `COIN_10`, and `CHANGE`.

---

## 5. Hardware Architecture

A typical FSM-based vending-machine controller consists of state storage, next-state combinational logic, and output-decoding logic.

```text
                         +----------------------+
 coin_5 ---------------->|                      |
 coin_10 --------------->|   Next-State Logic   |---- next_state
 current_state -------->|                      |
                         +----------------------+
                                    |
                                    v
                         +----------------------+
 clk ------------------->|                      |
 reset ----------------->|   State Register     |---- current_state
                         |                      |
                         +----------------------+
                                    |
                                    v
                         +----------------------+
 current_state --------->|   Output Decoder     |---- dispense
 coin inputs ----------->|                      |---- change
                         +----------------------+
```

### Main blocks

| Block | Role |
|---|---|
| `vending_machine_top` | Top-level design module |
| `DUT` / `vending_machine_structural` | Structural design hierarchy shown in the Genus report |
| `NEXT_LOGIC` / `vending_next_state` | Computes the next state |
| `OUTPUT_LOGIC` / `vending_output_decoder` | Decodes state/input conditions into outputs |
| `STATE_REG` / `state_register_2bit` | Stores the current state |
| `FF0`, `FF1` | Hierarchical state-register submodules shown in the hierarchy report |

> The hierarchy report describes logical hierarchy, while the mapped-cell report describes the technology-mapped netlist. Do not add parent and child hierarchy counts or areas as though they were independent hardware blocks.

---

## 6. Genus Hierarchy Report Analysis

### 1. Reported hierarchy

```text
vending_machine_top
└── DUT (vending_machine_structural)
    ├── NEXT_LOGIC (vending_next_state)
    ├── OUTPUT_LOGIC (vending_output_decoder)
    └── STATE_REG (state_register_2bit)
        ├── FF0 (dff_sync_reset)
        └── FF1 (dff_sync_reset_12)
```

### 2. Hierarchy area summary

| Hierarchy block | Reported cell count | Reported area |
|---|---:|---:|
| `vending_machine_top` | 20 | 349.272 |
| `DUT` | 20 | 349.272 |
| `NEXT_LOGIC` | 10 | 133.056 |
| `OUTPUT_LOGIC` | 6 | 89.813 |
| `STATE_REG` | 4 | 126.403 |
| `FF0` | 2 | 63.202 |
| `FF1` | 2 | 63.202 |

The reported hierarchy entries are not additive: child entries are included within their parent hierarchy. The mapped-cell inventory reports two `DFFTRX1` instances, while the hierarchy lists nested module instances. Inspect the mapped netlist and synthesis reports together when tracing logical registers to physical cells.

---

## 7. Genus Standard-Cell Area Report

### 1. Overall results

| Metric | Reported result |
|---|---:|
| Top module | `vending_machine_top` |
| Mapped standard-cell instances | **20** |
| Total reported cell area | **349.272 area units** |
| Library | `tsmc18` |
| Synthesis tool | Cadence Genus 21.14-s082_1 |

### 2. Standard-cell inventory

| Standard cell | Instances | Reported area |
|---|---:|---:|
| `AOI22X1` | 1 | 16.632 |
| `AOI31X1` | 1 | 16.632 |
| `AOI33X1` | 1 | 26.611 |
| `DFFTRX1` | 2 | 113.098 |
| `INVX1` | 2 | 13.306 |
| `INVXL` | 4 | 26.611 |
| `NAND2X1` | 1 | 9.979 |
| `NAND3BX1` | 3 | 49.896 |
| `NOR2BX1` | 1 | 13.306 |
| `NOR2X1` | 2 | 19.958 |
| `OAI211XL` | 1 | 19.958 |
| `OAI32X1` | 1 | 23.285 |
| **Total** | **20** | **349.272** |

### 3. Area by category

| Category | Instances | Reported area | Share |
|---|---:|---:|---:|
| Sequential | 2 | 113.098 | 32.4% |
| Inverters | 6 | 39.917 | 11.4% |
| Other combinational logic | 12 | 196.258 | 56.2% |
| Physical cells | 0 | 0.000 | 0.0% |
| **Total** | **20** | **349.272** | **100%** |

```text
Other combinational logic  56.2%  ████████████████████████████
Sequential cells           32.4%  ████████████████
Inverters                  11.4%  ██████
Physical cells              0.0%
```

### Area interpretation

- Combinational logic is the largest reported area category at 56.2%.
- Sequential cells account for 32.4% of reported mapped area.
- The report lists zero physical cells in this mapped-cell summary; this does not mean that a completed physical layout has zero area.
- The report excerpt does not explicitly confirm the area unit, so the value is not labeled as µm².

---

## 8. Genus Power Report Analysis

### 1. Overall power summary

| Metric | Reported result |
|---|---:|
| **Total estimated power** | **2.58744e-05 W = 25.8744 µW** |
| Leakage power | `9.01768e-09 W` ≈ 9.018 nW |
| Internal power | `1.85418e-05 W` = 18.5418 µW |
| Switching power | `7.32361e-06 W` = 7.32361 µW |
| Power-analysis frame | `stim#0/frame#0` |

### 2. Power by category

| Category | Reported total | Share |
|---|---:|---:|
| Register | 16.3055 µW | 63.02% |
| Logic | 7.99431 µW | 30.90% |
| Clock | 1.57464 µW | 6.09% |
| Memory, latch, bbox, pad, pm | 0 | 0.00% |
| **Subtotal** | **25.8744 µW** | **100%** |

```text
Register power  63.02%  ████████████████████████████████
Logic power     30.90%  ███████████████
Clock power      6.09%  ███
```

### Power interpretation and limitations

- Register power is the largest reported category.
- Internal power contributes approximately 71.66% of total power; switching contributes approximately 28.30%.
- Leakage is very small in this estimate.
- Power depends on switching activity, clock assumptions, voltage, library models, and the analysis setup.
- Confirm whether activity was derived from simulation or default assumptions before comparing this result with another design.
- This is a synthesis-stage estimate; extracted-parasitic post-route power is not established by the available report.

A common approximation for dynamic switching power is:

\[
P_{\text{switching}} = \alpha C V^2 f
\]

where \(\alpha\) is switching activity, \(C\) is effective capacitance, \(V\) is supply voltage, and \(f\) is frequency.

---

## 9. Genus Timing Report Analysis

### 1. Reported path

| Timing item | Reported value |
|---|---:|
| Path status | **MET** |
| Setup slack | **+7050 ps = +7.050 ns** |
| Startpoint | Input `coin_5` |
| Endpoint | `DUT/STATE_REG/FF0/Q_reg/D` |
| Launch clock edge | 0 ps |
| Capture clock edge | 10,000 ps (10 ns) |
| Input delay | 1,000 ps (1 ns) |
| Clock uncertainty | 1,000 ps (1 ns) |
| Setup time | 399 ps |
| Data-path delay | 551 ps |
| Data arrival time | 1,551 ps |
| Required time | 8,601 ps |

### 2. Path through mapped logic

```text
coin_5
   |
   v
INVX1      (cell delay: 70 ps)
   |
   v
AOI22X1    (cell delay: 176 ps)
   |
   v
NOR2X1     (cell delay: 74 ps)
   |
   v
AOI31X1    (cell delay: 170 ps)
   |
   v
NOR2X1     (cell delay: 62 ps)
   |
   v
FF0/Q_reg/D
```

The listed cell delays add to approximately 552 ps; the report gives a data-path delay of 551 ps. This 1 ps difference is consistent with rounding in the displayed values.

### 3. Slack calculation

\[
T_{\text{required}} = 10000 - 399 - 1000 = 8601\text{ ps}
\]

\[
T_{\text{arrival}} = 1000 + 551 = 1551\text{ ps}
\]

\[
\text{Slack} = 8601 - 1551 = 7050\text{ ps}
\]

The path is marked **MET** with **+7.050 ns slack** under the shown constraints.

### Timing interpretation and limitations

- Positive slack means the displayed setup path meets its timing requirement.
- One MET path does not prove that every setup and hold path meets timing.
- Review the full timing summary, worst negative slack (WNS), total negative slack (TNS), hold checks, unconstrained paths, and SDC constraints.
- The shown wireload-mode timing analysis does not establish routed interconnect delay or extracted-parasitic timing.
- Confirm that the clock period, input delay, uncertainty, and path exceptions represent the intended design environment.

---

## 10. PPA Summary

| Metric | Result | Evidence / qualification |
|---|---:|---|
| Mapped standard-cell count | 20 | Genus cell summary |
| Total reported area | 349.272 area units | Physical area unit not confirmed in excerpt |
| Total estimated power | 25.8744 µW | Synthesis-stage power estimate |
| Reported setup slack | +7.050 ns | One input-to-register setup path |
| Path status | MET | Applies to the displayed path only |
| Simulation | 111 pass / 0 fail | Supplied NCSim transcript |
| Post-route PPA | Not established | No extracted-parasitic post-route evidence in the reviewed reports |

---

## 11. Important Observations

1. The simulation transcript reports 111 passing checks and zero failures.
2. The mapped-cell report lists 20 standard-cell instances and a total reported area of 349.272.
3. Combinational logic accounts for 56.2% of the reported mapped area.
4. Register power is the largest reported power category at 63.02%.
5. The displayed input-to-register setup path is marked MET with +7.050 ns slack.
6. The hierarchy report contains nested child modules; parent and child areas must not be added together.
7. The initial state appears as `xx` at time zero and becomes `00` after reset handling; verify reset sequencing in the testbench.
8. Some terminal test labels are garbled around currency symbols, likely due to text encoding.
9. The available evidence does not establish full-design setup/hold closure, extracted-parasitic power, or final physical-design closure.

---

## 12. Recommended Repository Structure

```text
day16-vending-machine/
├── README.md
├── rtl/
│   ├── vending_machine_top.v
│   ├── vending_machine_structural.v
│   ├── vending_next_state.v
│   ├── vending_output_decoder.v
│   └── state_register_2bit.v
├── tb/
│   └── day16_tb.v
├── sim/
│   ├── simulation.log
│   └── waves.shm/
├── genus/
│   ├── constraints_top.sdc
│   ├── reports/
│   │   ├── hierarchy.rpt
│   │   ├── area.rpt
│   │   ├── power.rpt
│   │   └── timing.rpt
│   ├── mapped_netlist.v
│   └── synthesis.log
├── images/
│   ├── verification_summary.png
│   ├── hierarchy.png
│   ├── area_distribution.png
│   ├── power_distribution.png
│   └── timing_path.png
└── docs/
    └── Day16_Vending_Machine_Report.pdf
```

> This is a suggested structure. Keep the actual filenames from your working project, and include generated reports or waveform files only when they are available and useful to reviewers.

---

## 13. Industry Relevance

A vending-machine controller is a practical FSM exercise that connects state encoding, input validation, output decoding, synchronous reset behavior, and self-checking verification. These concepts are used in digital control systems, embedded controllers, protocol logic, and ASIC RTL design.

The Genus reports provide additional practice in reading a hierarchy, understanding standard-cell mapping, separating sequential and combinational area, interpreting power categories, and calculating setup slack. The results should be presented as synthesis-stage evidence until full timing and physical-design checks are completed.

---

## 14. Interview Questions

1. What is a finite-state machine, and why is it suitable for a vending-machine controller?
2. What do the current-state and next-state signals represent?
3. What is the difference between Moore and Mealy output logic?
4. Why is reset required in a synchronous FSM?
5. How should simultaneous coin inputs be handled?
6. What is the role of the state register?
7. What does technology mapping do in Cadence Genus?
8. Why can the hierarchy cell count differ from the mapped standard-cell count?
9. What is the difference between cell area and core area?
10. What are internal, switching, and leakage power?
11. How is setup slack calculated?
12. Why does a single MET path not prove full timing closure?
13. Why should synthesis-stage power not be described as final silicon power?
14. What additional checks are needed before claiming post-layout PPA closure?

---

## 15. Project Status

| Stage | Status |
|---|---|
| Simulation transcript reviewed | Complete for the supplied log |
| Reported test checks | 111 pass / 0 fail |
| Hierarchy report reviewed | Complete for the available excerpt |
| Standard-cell area reviewed | Complete for the available excerpt |
| Power report reviewed | Complete for the available excerpt; activity assumptions should be confirmed |
| One setup timing path reviewed | Complete for the available excerpt |
| Full setup/hold timing closure | Not established |
| Post-route PPA closure | Not established |

---

## 16. Final Genus Results

| Parameter | Reported value |
|---|---:|
| Top module | `vending_machine_top` |
| Standard-cell count | 20 |
| Total reported area | 349.272 area units |
| Total estimated power | 25.8744 µW |
| Displayed path slack | +7.050 ns |
| Displayed path status | MET |
| Simulation summary | 111 pass / 0 fail |
| Post-route status | Not established |

**Conclusion:** The supplied evidence shows a successful reported simulation run and provides a synthesis-stage view of the vending-machine FSM's hierarchy, mapped cell area, estimated power, and one setup timing path. Before claiming complete timing or physical-design closure, review the full setup/hold timing summaries, confirm power activity assumptions, and inspect post-route reports if available.

---

## 17. Next Project — Day 17: Digital Stopwatch / Timer

The next project builds on sequential logic and FSM control by designing a digital stopwatch/timer.

**Planned focus:**

- Define the stopwatch/timer operating modes and behavior.
- Design clock division or timing-pulse generation for the selected simulation/implementation environment.
- Implement start, stop, reset, and count control.
- Build the counter and display-value logic.
- Verify reset, start/stop, count progression, and rollover conditions.
- Create a self-checking Verilog testbench.
- Run simulation and debug any boundary-condition failures.
- Synthesize the design using Cadence Genus.
- Review mapped area, estimated power, and timing reports.

**Key learning goal:** develop a reliable sequential timing circuit and verify its behavior across control events, count boundaries, and reset conditions.

**Status:** Planned — not yet completed or verified.

---

## 18. Author

**Omkar Kalmesh Hadapad**  
Electronics and Communication Engineering  
Digital VLSI • Verilog RTL • Cadence Genus

---

**Day 16 Complete — Next: Day 17 · Digital Stopwatch / Timer**

---

<p align="center">
  <b>Day 16 Review — Vending Machine FSM · Functional Verification and Genus Report Analysis</b>
</p>
