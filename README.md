# Wavelet-Forward Family Enabling Stitching-Free Full-Field Fourier Ptychographic Microscopy

[[Paper]](https://onlinelibrary.wiley.com/doi/abs/10.1002/lpor.202401183) (Laser & Photonics Reviews, Front Cover)
[[Codes]](https://github.com/ShuheZhang-MUMC/Wavelet-Forward-FPM/tree/main/Demos)

This is the official implementation of our paper [WL-FPM](https://onlinelibrary.wiley.com/doi/abs/10.1002/lpor.202401183), a novel reconstruction routine for Fourier ptychographic microscopy (FPM). Conventional image-domain optimizations require trade-offs between correction efficacy, data redundancy, and reconstruction accuracy in FPM. Furthermore, the existing linear time-invariant model for actual nonlinear, time-varying optical systems leads to forward model mismatch, complicating the corrections of the vignetting effect. **To overcome these challenges and achieve stitching-free FPM, a family of forward wavelet-transform models (WL-FPM) is proposed.** WL-FPM employs the reversibility of the wavelet transform for high-fidelity reconstruction in the multiscale feature domain. The wavelet loss function is updated in each iteration, and non-convex optimization is solved by complex back diffraction. WL-FPM offers stitching-free, high-resolution, and robust reconstruction under various challenging conditions, including vignetting effects, LED position mismatch, intensity fluctuations, and high-level noise environments. 

## How does it work?
The wavelet-forward FPM is built on our previously developed [ELFPIE](https://www.sciencedirect.com/science/article/pii/S0165168423001627), we embed the inverse problem of FPM under the framework of feature extraction/recovering and propose a multiscale wavelet transformation data fidelity. The following picture shows the working pipeline of the Wavelet forward FPM. Step 1: Acquire the original images. Step 2: Generate predicted images. Step 3: Evaluate the diﬀerence between the predicted and original images. Step 4: Decompose multidimensional information using wavelet transform. Step 5: Calculate feature domain errors with a loss function. Step 6: Learn parameters and gradient information. Step 7: Implement update iterations. Step 8: Use an optimizer to accelerate the non-convex optimization process.

<div align="center">
<img src="https://github.com/ShuheZhang-MUMC/Wavelet-Forward-FPM/blob/main/resources/pipeline.png" width = "760" alt="" align=center />
</div><br>

## News
<ul>
  <li>2024/12/11: Our paper has been selected to be featured on the front cover of the issue. 🎉 Cheers! </li>
  <li>2024/09/24: 🔥 Our paper has been accepted by Laser & Photonics Reviews!</li>
</ul>

## How to use
We released our MATLAB codes.

### Requirements
MATLAB R2023b and newer. 

### Codes
**USAF resolution testing target**
Experimental results for the USAF target are available in the folder [USAF](https://github.com/ShuheZhang-MUMC/Wavelet-Forward-FPM/tree/main/Demos/USAF). <be>
These images were collected when illuminated by white light LEDs, so there is very low coherence. A total of 225 images were collected. 

**Fish gill sample**
Experimental results for Fish gill are available in the folder [fish](https://github.com/ShuheZhang-MUMC/Wavelet-Forward-FPM/tree/main/Demos/fish_samples)
These images were collected by RGB images, sequentially. The LED panel is a circular shape. A total of 93 images were collected.
<br>

## Overview
We show the stitch-free whole field-of-view reconstruction of pathology slides of rat colon tissue. a1–a3) Raw images for red, green, and blue illuminations. b) Full-FOV reconstruction according to ePIE and WL-FPM. c1,c2) Comparison of local details of ePIE and WL-FPM reconstruction methods (orange box). c3–c5) Comparison of local details between the original image, ePIE, and WL-FPM reconstruction methods (green boxes). d1,d2) The stitched imaging and WL-FPM reconstruction for the zoomed-in region f3 (red box) in b)
<div align="center">
<img src="https://github.com/ShuheZhang-MUMC/Wavelet-Forward-FPM/blob/main/resources/samples.png" width = "760" alt="" align=center />
</div><br>


## Citation
> @article{WaveletFPM, <br>
author = {Wu, Hao and Wang, Jiacheng and Pan, Haoyu and Lyu, Jifu and Zhang, Shuhe and Zhou, Jinhua}, <br>
title = {Wavelet-Forward Family Enabling Stitching-Free Full-Field Fourier Ptychographic Microscopy}, <br>
journal = {Laser \& Photonics Reviews}, <br>
volume = {n/a}, <br>
number = {n/a}, <br>
pages = {2401183} <br>
} <br>

