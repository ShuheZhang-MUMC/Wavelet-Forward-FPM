# Wavelet-Forward Family Enabling Stitching-Free Full-Field Fourier Ptychographic Microscopy

[[Paper]](https://onlinelibrary.wiley.com/doi/abs/10.1002/lpor.202401183) (Laser & Photonics Reviews, Front Cover)
[[Codes]](https://github.com/ShuheZhang-MUMC/Wavelet-Forward-FPM/tree/main/Demos)

This is the official implementation of our paper [WL-FPM](https://onlinelibrary.wiley.com/doi/abs/10.1002/lpor.202401183), a novel reconstruction routine for Fourier ptychographic microscopy (FPM). Conventional image-domain optimizations require trade-offs between correction efficacy, data redundancy, and reconstruction accuracy in FPM. Furthermore, the existing linear time-invariant model for actual nonlinear, time-varying optical systems leads to forward model mismatch, complicating the corrections of the vignetting effect. **To overcome these challenges and achieve stitching-free FPM, a family of forward wavelet-transform models (WL-FPM) is proposed.** WL-FPM employs the reversibility of the wavelet transform for high-fidelity reconstruction in the multiscale feature domain. The wavelet loss function is updated in each iteration, and non-convex optimization is solved by complex back diffraction. WL-FPM offers stitching-free, high-resolution, and robust reconstruction under various challenging conditions, including vignetting effects, LED position mismatch, intensity fluctuations, and high-level noise environments, which outperform conventional FPM methods. Under a 4X objective with NA 0.1, WL-FPM achieves a 435-nm resolution and stitching-free full-field reconstruction of a 3.328 × 3.328 mm2 pathological section with distinct subcellular organelles. In live cell imaging, it provides a full-field observation with distinct lipids in a single cell. A large number of simulation and experimental results demonstrate its potential for biomedical applications.

<div align="center">
<img src="https://github.com/ShuheZhang-MUMC/Wavelet-Forward-FPM/blob/main/resources/pipeline.png" width = "800" alt="" align=center />
</div><br>

## News
<ul>
  <li>2024/12/11: Our paper has been selected to be featured on the front cover of the issue. 🎉 Cheers! </li>
  <li>2024/09/24: 🔥 Our paper has been accepted by Laser & Photonics Reviews!</li>
</ul>

