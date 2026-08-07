# Bridge Deck Pressure-Flow Scour Simulations
Source: *Journey to the Correct Result* (Subhadip Das, HWRE Lab, IITK, 2016)

This repository contains structured 2D CFD numerical simulations using `sedFoam_rbgh` (OpenFOAM 2412) to replicate the experimental research on bridge deck pressure-flow scour.

---

## 1. Case Configurations

This repository contains two primary test cases corresponding to different physical scour outcomes:

| Directory | Experiment | Target Scour Pattern | Soffit Elevation ($y_{\text{soffit}}$) | Water Depth ($Y$) |
| :--- | :--- | :--- | :--- | :--- |
| **[`Exp_01a_UnderDeckScour`](file:///E:/DKS/BridgeDeckScour/Exp_01a_UnderDeckScour)** | Exp-01a | Max scour occurs **under the bridge** | $0.072\text{ m}$ | $0.12\text{ m}$ |
| **[`Exp_03b_DownstreamScour`](file:///E:/DKS/BridgeDeckScour/Exp_03b_DownstreamScour)** | Exp-03b | Max scour occurs **near downstream edge** | $0.072\text{ m}$ | $0.1107\text{ m}$ |

---

## 2. Model Physics & Features

1.  **Pure `blockMesh` Topology with Solid Roof Deck:** The Plexiglas bridge deck is represented as a solid block extending from the soffit ($y = 0.072\text{ m}$) all the way to the top of the domain. This forces the bridge opening to be the only flow passage through the structure. Unnecessary cell elements in the solid deck zone are carved out, avoiding the need for `snappyHexMesh`.
2.  **Physical Boundary Layer Inflow:** Rather than a uniform velocity profile, a logarithmic velocity boundary layer profile is specified at the inlet to prevent shear singular explosions at the bed interface:
    $$u(y) = \frac{u_*}{\kappa} \ln\left(\frac{y}{y_0}\right)$$
3.  **Turbulence Stabilization:** Initial turbulence fields (`k.b` and `omega.b`) are damped inside the static sand bed ($y < 0$) using `#codeStream` to ensure numerical stability from the first time step.
4.  **Stiff Coupling Stabilization:** Under-relaxation factors (`U.a: 0.5`, `U.b: 0.5`, `p_rbgh: 0.7`, `pa: 0.7`) are applied in `system/fvSolution` to handle the strong momentum coupling of the fine Ahmedabad sand ($d_{50} = 0.212\text{ mm}$). Packing limits are set to `alphaMax: 0.635` and `alphaMaxG: 0.645` to prevent numerical singularities.

---

## 3. How to Run

To run either of the cases, navigate to its folder and execute:
```bash
./Allrun
```

The script will automatically:
1. Initialize the pristine boundary fields from `0_org/` to `0/`.
2. Generate the structured mesh using `blockMesh`.
3. Decompose the domain for parallel execution (`decomposePar`).
4. Execute the two-phase solver in parallel:
   ```bash
   mpirun -np 8 sedFoam_rbgh -parallel > log.sedFoam 2>&1
   ```
