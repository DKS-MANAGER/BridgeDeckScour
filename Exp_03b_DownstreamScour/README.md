# Bridge Pressure-Flow Scour — Case Exp-03b (Downstream Scour)
Source: *Journey to the Correct Result* (Subhadip Das, HWRE Lab, IITK, 2016)

This case simulates the bridge deck pressure-flow scour under **Exp-03b** conditions using the two-phase sediment transport solver `sedFoam_rbgh` in OpenFOAM 2412.

---

## 1. Experimental Parameters & Setup (Ground Truth)

| Parameter | Value | Description |
| :--- | :--- | :--- |
| **Water depth ($Y$)** | $0.1107\text{ m}$ | Free-surface elevation (Rigid Lid) |
| **Approach velocity ($U$)** | $0.23\text{ m/s}$ | Mean inlet velocity |
| **Discharge ($Q$)** | $7.64\text{ L/s}$ | Volumetric flow rate |
| **Bridge opening ($H_b$)** | $0.072\text{ m}$ | Clearance beneath bridge deck |
| **Bridge deck length** | $0.153\text{ m}$ | Streamwise length of Plexiglas deck |
| **Bridge deck thickness** | $0.010\text{ m}$ | Thickness of the deck plate |
| **Sand size ($d_{50}$)** | $0.000212\text{ m}$ | Ahmedabad sand diameter |
| **Sand density ($\rho_s$)** | $2650\text{ kg/m}^3$ | Solid phase density |
| **Water density ($\rho_f$)** | $1000\text{ kg/m}^3$ | Fluid phase density |
| **Initial bed depth** | $0.12\text{ m}$ | Depth of erodible sediment |
| **Scour Location** | **Near downstream edge** | Expected experimental result |

---

## 2. Derived Computational Geometry
The elevation of the bridge deck soffit is computed using the physical water depth and bridge opening:
$$\text{soffit\_y} = Y - H_b = 0.1107\text{ m} - 0.072\text{ m} = 0.0387\text{ m}$$

*   **Domain Top ($y_{\text{top}}$):** $0.1107\text{ m}$ (Water Surface datum)
*   **Soffit Elevation ($y_{\text{soffit}}$):** $0.0387\text{ m}$
*   **Bed Surface ($y_{\text{bed}}$):** $0.0\text{ m}$ (Reference datum)
*   **Bed Bottom ($y_{\text{bedbottom}}$):** $-0.12\text{ m}$ (Sediment bottom)

### Streamwise (X) Partitioning
*   **Inlet / Upstream Zone:** $x \in [-0.5, 0.0]\text{ m}$ (Length: $0.5\text{ m}$)
*   **Bridge Deck Zone:** $x \in [0.0, 0.153]\text{ m}$ (Length: $0.153\text{ m}$)
*   **Outlet / Downstream Zone:** $x \in [0.153, 2.0]\text{ m}$ (Length: $1.847\text{ m}$)

---

## 3. BlockMesh Topology & Mesh Layout

The domain is constructed as a multi-block structured mesh with the solid bridge deck carved out (no mesh is generated above the soffit in the deck zone):

```
   y-levels:
   L3 (Y = 0.1107m)          12─────────────13             14─────────────15
                             │   Block 6   │  [ NO MESH ]  │   Block 7   │  (Solid Bridge Deck)
   L2 (y = 0.0387m, Soffit)    8──────────────9─────────────10─────────────11
                             │   Block 3   │   Block 4   │   Block 5   │  (Water Flow Domain)
   L1 (y = 0.0m, Bed top)     4──────────────5─────────────6──────────────7
                             │   Block 0   │   Block 1   │   Block 2   │  (Erodible Sand Bed)
   L0 (y = -0.12m, Bed bot)   0──────────────1─────────────2──────────────3

                             x = -0.5       x = 0.0       x = 0.153    x = 2.0
```

---

## 4. Boundary Patches

*   **`inlet`**: Left boundaries representing incoming flow with a logarithmic velocity profile starting at $0$ at the bed interface ($y = 0.0\text{ m}$) and scaling to $V_a = 0.23\text{ m/s}$ at the water surface ($y = 0.1107\text{ m}$).
*   **`outlet`**: Right boundaries with hydrostatic pressure-coupled outflow.
*   **`bottom`**: Lower channel bed surface (rigid boundary at $y = -0.12\text{ m}$).
*   **`top`**: Upper water surface modeled as a rigid lid (slip/no-slip wall).
*   **`bridgeDeck`**: Wall boundary representing the physical deck:
    *   **Upstream Wall:** Vertical face at $x = 0.0\text{ m}, y \in [0.0387, 0.1107]\text{ m}$
    *   **Soffit:** Horizontal face at $y = 0.0387\text{ m}, x \in [0.0, 0.153]\text{ m}$
    *   **Downstream Wall:** Vertical face at $x = 0.153\text{ m}, y \in [0.0387, 0.1107]\text{ m}$
