#!/bin/csh -f
setenv VCS_HOME /usr/local-eit/cad2/synopsys/vcf24/vc_static/V-2023.12/vcs-mx
setenv VC_STATIC_HOME /usr/local-eit/cad2/synopsys/vcf24/vc_static/V-2023.12
setenv SYNOPSYS_SIM_SETUP /h/d3/v/sh5704ch-s/ICP-Verification/FPV/run/vcst_rtdb/.internal/design/synopsys_sim.setup

$VCS_HOME/bin/vlogan  -kdb=common_elab /h/d3/v/sh5704ch-s/ICP-Verification/FPV/run/vcst_rtdb/.internal/design/undef_vcs.v -Xvd_opts=-silent,+disable_message+C00373,-ssy,-ssv,-ssz -file /h/d3/v/sh5704ch-s/ICP-Verification/FPV/run/vcst_rtdb/.internal/design/analyzeCmd1 -Xufe=parallel:incrdump  -full64  -libfile_opt 

$VCS_HOME/bin/vcs -file /h/d3/v/sh5704ch-s/ICP-Verification/FPV/run/vcst_rtdb/.internal/design/elaborateCmd -Xvcstatic_extns=0x4  -Xvcstatic_extns=0x1000  -Xvcstatic_extns=0x100  +warn=noSM_CCE  -units  -error=IRRIPS  -kdb=common_elab  -Xufe=parallel:incrdump  +warn=noKDB-ELAB-E  -Xverdi_elab_opts=-saveLevel  -verdi_opts "-logdir /h/d3/v/sh5704ch-s/ICP-Verification/FPV/run/vcst_rtdb/verdi/elabcomLog " -Xvd_opts=,-ssy,-ssv,-ssz,-silent,+disable_message+C00373, -full64 
