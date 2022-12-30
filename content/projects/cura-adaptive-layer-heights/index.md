+++
date = 2022-12-30T08:41:01+01:00
title = "Cura Adapter Layer Heights"
tags = ["Open Source", "Cura"]
+++

[Adapter Layer Heights](https://github.com/Ultimaker/CuraEngine/blob/main/src/settings/AdaptiveLayerHeights.cpp) is a feature for [Ultimaker Cura](https://ultimaker.com/nl/software/ultimaker-cura) that automatically detects and generates the height of each layer depending on the 3D model geometry.
This reduces total printing time while retaining the necessery detail in some areas of the 3D model.

Several websites have published articles about this feature after it's introduction:

* [all3dp.com](https://all3dp.com/2/cura-adaptive-layers-simply-explained/)
* [3duniverse.org](https://3duniverse.org/2018/04/06/ultimaker-cura-adaptive-layers-tutorial/)
* [the3dprinterbee.com](https://the3dprinterbee.com/cura-adaptive-layers/)
* [3mgbonev.com](https://3mgbonev.com/en/2022/05/07/cura-adaptive-layers-simply-explained/)

More details are available in the [paper](./adaptive_layer_heights_v004.pdf) I wrote that lead to it's implementation in Cura.
