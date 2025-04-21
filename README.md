# Crash Test Optimization Using Reinforcement Learning

This repository presents a pipeline to preprocess a **full vehicle FEA crash model** and generate a reduced, information-rich part-block structure to enable **Reinforcement Learning (RL)-based crash test optimization**.

We utilize the **2010 Toyota Yaris** crash test model, available publicly from George Mason University's [Center for Collision Safety and Analysis (CCSA)](https://www.ccsa.gmu.edu/models/2010-toyota-yaris/#panel12060718062).

---

## Objective

The project aims to:
- Parse a detailed `.key` file from LS-DYNA
- Extract geometric and mechanical features of components
- Reduce parts into simplified **feature blocks** while retaining key characteristics
- Prepare a final filtered dataset ready for use in RL-based structural optimization

---

## Source Model

- **Model:** 2010 Toyota Yaris  
- **Source:** [CCSA - George Mason University](https://www.ccsa.gmu.edu/models/2010-toyota-yaris/#panel12060718062)  
- **File Format:** `.key` file (LS-DYNA)

---

## Execution Pipeline

Run the following scripts **in order** to generate the final `Parts_filtered.mat`, which contains the reduced block-level mechanical part definitions.

---

### 1️⃣ `file_read.m`

**Purpose:**  
Parses the `.key` file and extracts FEA data.

**Inputs:**  
- Toyota Yaris `.key` file  
- `shell_list.m` (helper function)

**Outputs:**  
- `elements.mat`  
- `nodes.mat`  
- `parts.mat`  
- `materials.mat`

---

### 2️⃣ `area_elements.m`

**Purpose:**  
Calculates the area of all shell elements.

**Inputs:**  
- `elements.mat`  
- `nodes.mat`  
- `area3D.m` (helper function)

**Output:**  
- `shell_elements_area.mat`

---

### 3️⃣ `volume_elements.m`

**Purpose:**  
Computes volume of all solid (3D) elements.

**Inputs:**  
- `elements.mat`  
- `nodes.mat`

**Output:**  
- `Solid_elements_volume.mat`

---

### 4️⃣ `beam_discrete.m`

**Purpose:**  
Detects and discretizes beam elements.

**Inputs:**  
- `elements.mat`  
- `nodes.mat`

**Output:**  
- `elements_beam_discrete.mat`

---

### 5️⃣ `main.m`

**Purpose:**  
Binds shell, solid, and beam information into a unified mechanical part block structure.

**Inputs:**  
- `parts.mat`  
- `shell_elements_area.mat`  
- `Solid_elements_volume.mat`  
- `elements_beam_discrete.mat`  
- `area3D.m` (helper function)

**Output:**  
- `Parts_bounded.mat`

---

### 6️⃣ `final_filter.m`

**Purpose:**  
Filters the bounded parts based on spatial and geometric conditions:
- X-distance
- Split by feature/module (FM)
- Enclosure within other parts
- Volume threshold

**Inputs:**  
- `parts.mat`  
- `shell_elements_area.mat`  
- `Solid_elements_volume.mat`  
- `elements_beam_discrete.mat`  
- `split_part.m` (helper function)

**Output:**  
- `Parts_filtered.mat`

---

## 🧠 Final Output

The output `Parts_filtered.mat` contains a clean and reduced list of parts, grouped into blocks, that serve as input for downstream **Reinforcement Learning** algorithms to optimize crash test performance.

---
