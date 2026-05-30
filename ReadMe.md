# Data-Driven Inverse Kinematics for a Two-Segment Continuum Robot

[![MATLAB](https://img.shields.io/badge/MATLAB-R2023b-blue.svg)](https://www.mathworks.com/products/matlab.html)

A supervised learning approach to solving inverse kinematics for tendon-driven continuum robots using neural networks, achieving real-time performance with accuracy comparable to numerical optimization.

## Overview

Continuum robots offer significant advantages in minimally invasive surgery and confined-space operations due to their inherent compliance and dexterous maneuverability. However, solving inverse kinematics (IK) for these robots remains challenging due to highly nonlinear mapping and kinematic redundancy.

This project presents a **data-driven framework** that:
- Uses a numerical IK solver (fmincon with SQP) as a benchmark to generate ground-truth training data
- Trains a feedforward neural network (MLP) to approximate the solver
- Achieves 3x faster computation
- Mitigates distribution shift using a **DAgger-inspired noise augmentation strategy**

## Key Results

| Metric | Numerical Solver | Neural Network (MLP) |
|--------|------------------|----------------------|
| Mean Position Error | ~0.01 mm | 3.14-3.82 mm |
| Computation Time | ~14 ms | ~4 ms |
| Speedup | 1x | 3x |

<img width="750" height="350" alt="anim_fig8_180deg" src="https://github.com/user-attachments/assets/8a451a0b-49c5-4f6c-92de-6a9ffda683b7" />
<img width="750" height="350" alt="anim_circle_90deg" src="https://github.com/user-attachments/assets/14b80f0e-a859-49bb-a518-e993d72cf483" />



## Repository Structure

- **data**
  - `ik_dataset_dh_v4.mat` - Training data with DAgger augmentation
  - `ik_net_dh_v4.mat` - Trained neural network
  
- **forward_kinematics**
  - `fwk.m` - Forward kinematics (tendons → tip position)
- **numerical_solver**
  - `opt.m` - Reference fmincon-based IK solver
- **data_generation**
  - `generate_dataset_dh_v4.m` - Generate training data with noise augmentation
- **training**
  - `train_nn_dh_v4.m` - MLP training [128-64-32] architecture
- **evaluation**
  - `evaluate_comparison.m` - Comprehensive benchmarking
  - `animate_comparisons_dh_v4.m` - Side-by-side animation

**`ReadMe.md`**

## Robot Model

- **Type**: Two-segment, tendon-driven continuum robot
- **Actuation**: 6 tendons (3 per segment, equally spaced at 120°)
- **Tendon bounds**: 105 mm to 320 mm
- **DOF**: 6 actuators → 3 task-space dimensions (x, y, z position)
- **Home position**: [0, 0, 210] mm

## Methodology

### 1. Numerical IK Solver (Benchmark)

Uses MATLAB's `fmincon` with SQP algorithm, minimizing:
f(L) = 10·||p_target - FK(L)||² + 0.1·||L - L_prev||²

subject to bound constraints `105 ≤ L_i ≤ 320`.

### 2. Training Data Generation

Generates IK solutions from diverse trajectories:
- **Figure-eight patterns**: 5 radii × 5 z-heights × 8 rotations × 4 offsets
- **Circular patterns**: 8 radii × 8 z-heights × 12 start offsets

### 3. DAgger-Inspired Noise Augmentation

Adds Gaussian noise (σ = 2, 5, 10, 15 mm) to `L_prev` during training, creating 4 augmented copies per sample. This teaches the network to recover from its own prediction errors during autoregressive deployment.

### 4. Neural Network Architecture

| Hyperparameter | Value |
|----------------|-------|
| Network type | Feedforward MLP |
| Hidden layers | [128, 64, 32] |
| Activation (hidden) | tansig |
| Activation (output) | purelin |
| Training algorithm | Scaled Conjugate Gradient |
| Max epochs | 5000 |
| Early stopping patience | 200 epochs |
| Data split | 70/15/15 (train/val/test) |

Usage Instructions

Prerequisites:
- MATLAB R2023b or later
- Deep Learning Toolbox
- Optimization Toolbox

Step 1: Generate the training dataset

Open MATLAB, navigate to the cloned repository folder, and run the data generation script:

    generate_dataset_dh_v4

This script will create the training data by solving inverse kinematics for figure-eight and circular trajectories across the robot's workspace. The dataset will be saved as ik_dataset_dh_v4.mat in the data/ folder.

Step 2: Train the neural network

Run the training script:

    train_nn_dh_v4

This loads the dataset, creates a feedforward neural network with [128-64-32] architecture, trains it using scaled conjugate gradient, and saves the trained network as ik_net_dh_v4.mat.

Step 3: Evaluate performance

Run the evaluation script:

    evaluate_comparison

This compares the numerical solver and the trained neural network on test trajectories, generates error tables, and produces trajectory tracking plots.

Optional: Generate animations

To create side-by-side comparison GIFs of the numerical and learned solvers:

    animate_comparisons_dh_v4

## Results Summary

### Trajectory Tracking (Position Error)

| Trajectory | Numerical (mm) | NN (mm) |
|------------|----------------|---------|
| Figure-8 (0°) | 0.01 ± 0.01 | 3.68 ± 2.06 |
| Figure-8 (90°) | 0.01 ± 0.01 | 3.60 ± 2.00 |
| Figure-8 (180°) | 0.01 ± 0.01 | 3.64 ± 1.99 |
| Figure-8 (270°) | 0.01 ± 0.01 | 3.60 ± 2.00 |
| Circle (0°) | 0.00 ± 0.00 | 3.14 ± 1.45 |
| Circle (90°) | 0.00 ± 0.00 | 3.82 ± 2.08 |
| Circle (180°) | 0.00 ± 0.00 | 3.16 ± 1.45 |
| Circle (270°) | 0.00 ± 0.00 | 3.80 ± 2.06 |

### Generalization to Unseen Trajectories

- **Spiral**: Effective tracking with bounded errors
- **Square**: Reasonable performance despite not being in training
- **Lemniscate**: Successful interpolation beyond training patterns

## Key Findings

- **Distribution shift is critical**: Without DAgger-inspired noise augmentation, errors compound catastrophically on circular trajectories (no natural "reset" point)

- **Training data quality > Network architecture**: The preliminary approach failed because it used forward-sampled configurations rather than actual IK solutions

- **Speed-accuracy trade-off**: MLP provides >300x speedup with acceptable accuracy (3-4 mm vs 0.01 mm) for real-time applications

- **Starting offset matters**: Some angular offsets produce trajectories less represented in training data, increasing errors

## Limitations

- Simulation only (no hardware validation)
- Position-only control (3 DOF, not full 6-DOF pose)
- Fixed workspace range
- Single numerical solver configuration

## Future Work

- Hardware validation on physical continuum robot
- Extend to 6-DOF control (including orientation)
- Online learning / fine-tuning during deployment
- Full DAgger algorithm with iterative data collection
- Advanced architectures (LSTM, GRU, Transformers)

## Citation

If you use this code or findings in your research, please cite:

```bibtex
@bachelorsthesis{paul2025datadriven,
  author = {Shourav Chandra Paul},
  title = {Data-Driven Inverse Kinematics for a Two-Segment Continuum Robot Using Supervised Neural Network Regression},
  school = {The Chinese University of Hong Kong},
  year = {2025},
  supervisor = {Prof. Jiewen Lai}
}
```

## Acknowledgments

- **Prof. Jiewen Lai** - Supervisor
- **Ms. Xiu Yang** - Research assistant, provided forward kinematics model and numerical optimization framework
- **Department of Electronic Engineering** - The Chinese University of Hong Kong



## Contact

Shourav Chandra Paul - [GitHub](https://github.com/Paul632-bit)

