# Define a procedure which generates a circular reinforced concrete section # with one layer of steel evenly distributed around the perimeter and a confined core.
# Formal arguments
# id - tag for the section that is generated by this procedure
# ri - inner radius of the section
# ro - overall (outer) radius of the section
# cover - cover thickness
# coreID - material tag for the core patch
# coverID - material tag for the cover patches
# steelID - material tag for the reinforcing steel
# numBars - number of reinforcing bars around the section perimeter
# barArea - cross-sectional area of each reinforcing bar
# nfCoreR - number of radial divisions in the core (number of "rings")
# nfCoreT - number of theta divisions in the core (number of "wedges")
# nfCoverR - number of radial divisions in the cover
# nfCoverT - number of theta divisions in the cover
#
# Notes
# The center of the reinforcing bars are placed at the inner radius
# The core concrete ends at the inner radius (same as reinforcing bars)
# The reinforcing bars are all the same size
# The center of the section is at (0,0) in the local axis system
# Zero degrees is along section y-axis
#
proc RCcircSection {id ri ro cover coreID coverID steelID numBars barArea nfCoreR nfCoreT nfCoverR nfCoverT} {
# Define the fiber section
  section fiberSec $id -GJ 1e5 {
    # Core radius
    set rc [expr $ro-$cover]
    # Define the core patch
    patch circ $coreID $nfCoreT $nfCoreR 0 0 $ri $rc 0 360
    # Define the cover patch
    patch circ $coverID $nfCoverT $nfCoverR 0 0 $rc $ro 0 360
    if {$numBars <= 0} {
      return
    }
    # Determine angle increment between bars
    set theta [expr 360.0/$numBars]
    # Define the reinforcing layer
    layer circ $steelID $numBars $barArea 0 0 $rc $theta 360
  }
}