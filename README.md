# Summary
Chl-light-profiles repository was made to help people **process** *.nc* files, **view** the content, and **extract** and **visualize** the data included in this type of file using the R programming language. Satellite products were downloaded from the [Copernicus Marine Service ](https://data.marine.copernicus.eu/products) using a monthly 4 km spatial resolution with an interpolation procedure (L4 product) at the southern portion of the Gulf of California.

While the *main_code.R* in the main branch includes basic functions and objects to process and extract data, *light.R* and *chlorophyll.R* scripts include more extensive data wrangling and processing with examples.

# *light* branch
Through this script, you can visualize how light is absorbed from the surface to 100 m. To estimate values throughout the water column, water turbidity (K<sub>d490</sub>) data is transformed into (K<sub>dPAR</sub>) following the equation of Morel et al. [(2007)](https://www.researchgate.net/publication/228069006_Examining_the_consistency_of_products_derived_from_various_ocean_color_sensors_in_open_ocean_Case_1_waters_in_the_perspective_of_a_multi-sensor_approach) for Case I waters (<0.2 m<sup>-1</sup>): K<sub>dPAR</sub>= 0.0864 + 0.0884 * K<sub>d490</sub> - 0.00137 * K<sub>d490</sub><sup>-1</sup>.

Afterward, the amount of light expressed as a percentage at each meter was calculated with Beer's Law (Kirk, [2011](https://www.researchgate.net/publication/281709482_Light_and_Photosynthesis_in_Aquatic_Systems); Valiela, [2015](https://www.researchgate.net/publication/304875880_Marine_Ecological_Processes)): I<sub>z</sub> = I<sub>0</sub> * e<sup>-kz</sup>. Where *I<sub>0</sub>* is the amount of light at the surface (100%), *k* equals the estimated value of *K<sub>dPAR</sub>*, *z* is the depth (0 - 100 m), and *I<sub>z</sub>* is the amount of light at a certain depth.

Plotted profiles represent the calculated values during summer (September; red) and winter (February; blue).

# *chlorophyll* branch
Through this script, you can visualize how chlorophyll is distributed from the surface to 100 m. To estimate values throughout the water column, I used the formulas proposed by Hidalgo-González and Alvarez-Borrego [(2000)](https://www.researchgate.net/publication/263565814_Chlorophyll_profiles_and_the_water_column_structure_in_the_Gulf_of_California), where a correction for satellite-derived data and the season formulas were applied.

Plotted profiles represent the calculated values during summer (September; red) and winter (February; blue), along with the dashed lines that depict light at 1% of the incident at surface.
