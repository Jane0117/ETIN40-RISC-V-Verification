verdiVcstPostRestoreCmd ""
debRestoreSession vcst.ses
verdiWindowWorkMode -win $_Verdi_1 -formalVerification
verdiDockWidgetDisplay -dock windowDock_vcstConsole_2
verdiWindowResize -win $_Verdi_1 -10 "19" "960" "1136"
verdiSetActWin -dock widgetDock_VCF:GoalList
schSetVCSTDelimiter -VHDLGenDelim "."
schUnifiedNetList
schSetVCSTDelimiter -hierDelim "."
srcSetXpropOption "tmerge"
wvSetPreference -overwrite off
wvSetPreference -getAllSignal off
simSetSimulator "-vcssv" -exec \
           "/h/d3/v/sh5704ch-s/ICP-Verification/FPV/run/vcst_rtdb/.internal/design/traffic.exe" \
           -args
debImport "-simflow" "-smart_load_kdb" "-dbdir" \
          "/h/d3/v/sh5704ch-s/ICP-Verification/FPV/run/vcst_rtdb/.internal/design/traffic.exe.daidir" \
          -autoalias
debRestoreSession vcst.ses
srcSetPreference -tabNum 16
verdiWindowRestoreUserLayout -win $_Verdi_1 "UserRestart_1_vcst"
verdiDockWidgetSetCurTab -dock widgetDock_MTB_SOURCE_TAB_1
verdiDockWidgetSetCurTab -dock widgetDock_VCF:GoalList
debLoadUserDefinedFile \
           /h/d3/v/sh5704ch-s/ICP-Verification/FPV/run/vcst_rtdb/.internal/verdi/constant.uddb
srcSetOptions -userAnnot on -win $_nTrace1 -field 2
opVerdiComponents -xmlstr \
           "<Command delimiter=\"/\" name=\"schSession\">
<HighlightObjs clear=\"true\"/>
</Command>
"
opVerdiComponents -xmlstr \
           "<Command delimiter=\"/\" name=\"schSession\">
<HighlightObjs>
<H_Nets>
<H_Net name=\"traffic/rst\" text=\"C:0\" color=\"2\"/>
</H_Nets>
</HighlightObjs>
</Command>
"
verdiWindowResize -win $_Verdi_1 "0" "0" "960" "825"
verdiSetActWin -win $_vcstConsole_2
verdiSetActWin -dock widgetDock_VCF:GoalList
verdiDockWidgetDisplay -dock widgetDock_VCF:ComplexityReport
verdiSetActWin -dock widgetDock_VCF:ComplexityReport
verdiSetActWin -dock widgetDock_VCF:GoalList
verdiSetActWin -dock widgetDock_VCF:DesignCheck
verdiDockWidgetSetCurTab -dock widgetDock_VCF:ComplexityReport
verdiSetActWin -dock widgetDock_VCF:ComplexityReport
verdiDockWidgetSetCurTab -dock widgetDock_VCF:DesignCheck
verdiSetActWin -dock widgetDock_VCF:DesignCheck
verdiSetActWin -dock widgetDock_VCF:GoalList
verdiRunVcstCmd check_fv

verdiRunVcstCmd check_fv

verdiDockWidgetSetCurTab -dock windowDock_vcstConsole_2
verdiSetActWin -win $_vcstConsole_2
verdiDockWidgetSetCurTab -dock widgetDock_VCF:ComplexityReport
verdiSetActWin -dock widgetDock_VCF:ComplexityReport
verdiDockWidgetSetCurTab -dock windowDock_vcstConsole_2
verdiSetActWin -win $_vcstConsole_2
verdiSetActWin -dock widgetDock_VCF:GoalList
verdiRunVcstCmd check_fv

verdiSetActWin -win $_vcstConsole_2
debExit
