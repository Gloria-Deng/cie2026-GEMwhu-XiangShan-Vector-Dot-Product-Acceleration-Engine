















def FeatureVendorXvdotv : SubtargetFeature<
    "xvdotv", "HasVendorXvdotv", "true",
    "'Xvdotv' (custom vector INT8 dot product, single 32-bit result)">;

def XvdotvAsmOperand : AssemblerPredicate<"all_of FeatureVendorXvdotv",
                                          "xvdotv">;






def VDOT_VV : RVInstVV<0b101100, OPMVV, (outs VR:$vd),
                       (ins VR:$vs2, VR:$vs1, vm), "vdot.vv", "$vd, $vs2, $vs1"> {
  let AsmVariantName = "Xvdotv"

                                                   ;
  let Predicates = [HasVendorXvdotv];
}
