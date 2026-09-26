# Rod holder todo

## Next
- [ ] Print one bare snap plus a single-cell test tile from the `opengrid`
      library, check the snap fit by hand before printing the full 168 mm pot.
- [ ] Print the holder with `layout = "print"` and confirm no support is needed.
- [ ] Check 0.5 mm rod is actually retrievable from a 165.6 mm deep, 11.0 x
      10.5 mm compartment. If it is fiddly, add a front finger cutout as an option.
- [ ] Window rod retention: load short offcuts (10 to 60 mm) of 0.5 and 0.8 mm
      rod, tap and tilt the mounted holder, and check nothing escapes through
      the 20 mm diamonds, especially the wrapped corners. If it does, raise
      `window_start`, shrink `diamond_size`, or use `window_style = "slot"`.
- [ ] Check the diamond lattice prints cleanly front face down: 2.4 mm webs,
      45 degree side edges, and the wrapped corners. Check the pot is stiff
      enough on the wall with this much wall cut away (about 48 cm3 left of 59).
- [ ] Check the side card pockets print cleanly (10 to 11 mm bridges in
      vertical walls).
- [ ] Check the card pocket takes whatever card is to hand. card_thickness is
      0.7, which suits 300 gsm or folded paper. Measure before printing four.
- [ ] Print two holders and confirm they actually sit side by side on the board
      with the 0.4 mm tile_clearance.
- [ ] Decide whether back row visibility matters when holders are tiled (side
      windows are hidden by neighbours). Option: windows through the row
      divider as well, lined up with the front windows.

## Open questions
- [ ] Download `openGrid Tile Dimensions.pdf` from the Printables model (needs a
      Printables login) and check the library constants against David D's own
      drawing. The numbers currently come from agreement between three
      independent community implementations, which matched exactly, but the
      official drawing has not been read directly.

## Ideas
- [ ] Lid or rubber bung so rods cannot fall out if the holder is knocked.
- [ ] Variant with round graded bores instead of square compartments.
- [x] 1 cell square, 2 x 2 compartments, diamond lattice windows (v2.0.0)
