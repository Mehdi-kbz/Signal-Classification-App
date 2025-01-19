# Signal Processing and Detrended Fluctuation Analysis (DFA) Project

![emotions](https://github.com/user-attachments/assets/9d576408-dabd-4920-b2b4-d4249e3e07cc)
![tendance_globale_deg2](https://github.com/user-attachments/assets/fc27ec75-ad7c-4afe-9c78-6fdb0a2a96e5)
![tendances_locales_deg2](https://github.com/user-attachments/assets/f9f9a756-2bd6-48b3-95b3-3ad8168f06b9)
![q_2_2_5_Weierstrass_bruite](https://github.com/user-attachments/assets/598fef52-4278-4519-a971-aa772069833c)
<img width="1470" alt="periodogramme" src="https://github.com/user-attachments/assets/881d1f95-6c7f-4ad7-bb63-bec467cf51c7" />
<img width="524" alt="ECG" src="https://github.com/user-attachments/assets/80da25d3-ae39-4286-999b-e5a07c88e83f" />

---

## Table of Contents

- [Overview](#overview)
- [Key Objectives](#key-objectives)
- [Techniques and Methods](#techniques-and-methods)
- [Applications](#applications)
- [Results and Observations](#results-and-observations)
- [Setup and Execution](#setup-and-execution)
- [Conclusion](#conclusion)
- [References](#references)

---

## Overview

This project focuses on leveraging **Detrended Fluctuation Analysis (DFA)** for analyzing and classifying signals, particularly vocal and physiological signals. By calculating the **Hurst Exponent (H)**, the project aims to uncover long-term dependencies in signals and assess their characteristics, even under noisy conditions.

---

## Key Objectives

1. Analyze long-term dependencies in signals using DFA.
2. Classify signals based on emotional context, gender, and physiological characteristics.
3. Examine the impact of noise on signal properties and enhance the robustness of signal processing techniques.
4. Apply DFA to real-world data like:
   - Vocal signals (RAVDESS database).
   - ECG signals (MIT-BIH Arrhythmia Database).

---

## Techniques and Methods

### 1. **Signal Analysis**
   - **Autocorrelation Function**: Evaluate randomness and memory of the signals.
   - **Power Spectrum**: Examine spectral properties under different noise levels.
   - **Spectrogram Analysis**: Visualize temporal-frequency representation.

### 2. **Detrended Fluctuation Analysis (DFA)**
   - Step 1: Centering and integrating the signal.
   - Step 2: Segmenting the signal and estimating local trends.
   - Step 3: Computing the fluctuation function \( F^2(N) \).
   - Step 4: Calculating the Hurst Exponent (\( H \)).

### 3. **Noise Simulation**
   - Introduced Gaussian white noise with varying Signal-to-Noise Ratios (SNRs).
   - Evaluated effects on speech signals, Weierstrass signals, and physiological data.

### 4. **Classification**
   - Emotional state detection from vocal signals.
   - Gender-based analysis of vocal characteristics.
   - Anomaly detection in ECG signals.

---

## Applications

1. **Speech Signal Analysis**:
   - Detect and classify emotional states (Angry, Happy, Sad).
   - Investigate the impact of noise on vocal properties.

2. **ECG Signal Analysis**:
   - Identify normal vs. pathological heart rhythms.
   - Evaluate long-term correlations in cardiac dynamics.

3. **General Signal Processing**:
   - Apply DFA to other physiological signals (e.g., EEG, blood pressure).

---

## Results and Observations

### Vocal Signals (RAVDESS Database)
- **Emotional Classification**:
  - Sad signals exhibit higher Hurst Exponent values (e.g., \( H \approx 1.15 \)).
  - Angry signals demonstrate lower Hurst Exponent values (\( H \approx 0.14 \)).

- **Gender Classification**:
  - Male voices typically have higher \( H \) values due to more stable harmonics.

### ECG Signals (MIT-BIH Database)
- **Normal vs. Pathological**:
  - Normal ECG: \( H \approx 1.706 \) (indicating strong long-term correlations).
  - Pathological ECG: \( H \approx 0.736 \) (reflecting irregular rhythms).

### Noise Impact
- Adding noise significantly reduced \( H \), demonstrating its disruptive effect on long-term dependencies.

---

## Setup and Execution

### Prerequisites
- **Python 3.7+**
- Libraries:
  - `numpy`
  - `matplotlib`
  - `scipy`

### Steps to Run
1. Clone this repository and navigate to the project directory:
   ```bash
    git clone https://github.com/Mehdi-kbz/Signal-Classification-App
    cd Signal-Classification-App
   ```
2. Install required dependencies:
   ```bash
    pip install -r requirements.txt
   ```
3. Run the DFA analysis:
   ```bash
    python dfa_analysis.py
   ```
4. Visualize results:
Output graphs will be saved in the results/ folder.

### Conclusion
This project successfully demonstrates the applicability of DFA for signal classification and analysis. The Hurst Exponent proves to be a valuable metric for understanding the intrinsic characteristics of signals, enabling effective classification and noise impact analysis. Future work may include integrating machine learning techniques for more robust classification and applying DFA to a broader range of physiological signals.
