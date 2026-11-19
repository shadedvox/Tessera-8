# GF180MCU SRAM macro power pins are on Metal3. The default core grid
# uses Metal4 straps; connect the macro grid's Metal3 pin shapes to the
# vertical PDN layer so OpenROAD can drop vias where the straps cross them.
source $::env(SCRIPTS_DIR)/openroad/common/pdn_cfg.tcl

add_pdn_connect \
    -grid macro \
    -layers "Metal3 $::env(PDN_VERTICAL_LAYER)"
