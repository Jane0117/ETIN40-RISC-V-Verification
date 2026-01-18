## VerdiPlay
source ./verdi_vcst.tcl
verdiWindowRestoreUserLayout -lastRunLayout
verdiDockWidgetSetCurTab -dock windowDock_vcstConsole_2
::vcst::creatInstAction
::vcst::createAnalyzerAction
::vcst::creatResetLayoutAction
::vcst::creatAssertAnalyzerAction
set ::vcst::EnableUDWin 0
qwConfig -type nWave -cmds [list {qwAddToolBarGroup -group "UDWinGroup"} {qwAddToolBarGroup -group "AssertAnalyzer"}]
srcSetOptions -lockActView on
::vcst::createAddTraceToWaveAction
source /usr/local-eit/cad2/synopsys/vcf24/vc_static/V-2023.12/auxx/monet/tcl/menu.tcl

verdiWindowPrependTitle -win $_nTrace1 -preTitle {}
verdiAboutDlg -banner {
VC Static

Version V-2023.12 for linux64 - Nov 24, 2023

Copyright (c) 2010 - 2023 Synopsys, Inc.
}
set ::vcst::_top "traffic"
set ::vcst::_elab ""
set ::vcst::_elabOpts {}
set ::vcst::_rtdbDir {/h/d3/v/sh5704ch-s/ICP-Verification/FPV/run/vcst_rtdb}
set ::vcst::_hiddenDir {.internal}
set ::vcst::_masterMode false
set ::vcst::_workLib "work"
set ::vcst::_upfOpts " -upf "
set ::vcst::_enableKdb "true"
set ::vcst::_simBinPath "traffic.exe"
set ::vcst::_goldenUpfConfig {}
set ::vcst::_nldmNschema {false}
set ::vcst::_kdbAlias {true}
set ::vcst::_covDut {}
set ::vcst::_splitbus {false}
set ::vcst::_enableVerdiLog {1}
set ::vcst::_fml_max_proof_depth {}
set ::vcst::_smartLoad {true}
set ::vcst::_compositeTrace {1}
set ::vcst::_strategyFilePath {}
set ::vcst::_enableVnrWriteKdb {false}
set ::vcst::_bIsFormalFlow {true}
set ::vcst::_bGlobalFsdbPresent {false}
set ::vcst::_sRunModes {}
set ::vcst::_enableVnrWriteKdbResolve {true}
set ::vcst::_diucFlow {false}
set ::vcst::_libArgs ""
set ::vcst::_seqXmlFile ""
schSetVCSTDelimiter -VHDLGenDelim "."
schUnifiedNetList -skipKdb
schSetPreference -turboLibs {} -turboLibPaths {}
verdiSetPrefEnv -bSpecifyWindowTitleForDockContainer off
paSetPreference -brightenPowerColor on
schSetPreference -showPassThroughNet on
paSetPreference -AnnotateSignal off
paSetPreference -highlightPowerObject off
srcAssertSetOpt -addSigToWave 0 -addSigWithExpGrp 1 -maskWave 0 -ShowCycleInfo 1
srcBlockFilelocateDlg on
verdiRunVcst -on
schSetVCSTDelimiter -hierDelim .
set ::vcst::_vcstAppHierDelim "."
srcSetXpropOption "tmerge"
set ::vcst::_powerDbDir ""
set ::vcst::_bRestore ""
::vcst::loadMainWin "1"
srcBlockFilelocateDlg off

setStyleFvProgress -css {font-family:Bitstream Vera Sans monospace;font-size:11px}
setStyleFvGoalProgress -css {font-family:Bitstream Vera Sans monospace;font-size:11px}
verdiSetFont -font "Bitstream Vera Sans" -size "11"
verdiSetPrefEnv -monoFontSize "11"
verdiVcstEnableAppMode -enable FRV

verdiRunVcstCmd "___fvWaitAnnotation
" -no_wait
verdiRunVcstCmd "___fvSetReuseWave
" -no_wait
srcSetPreference -tabNum 16
verdiSetStatusMsg -win Verdi_1 -color black { Design import ready }
verdiGetVcstCmdResult -xmlstr {<Command name="___fvWaitAnnotation
" received="1"></Command>}

verdiGetVcstCmdResult -xmlstr {<Command name="___fvSetReuseWave
" received="1"></Command>}

verdiSetPrefEnv -bDockNewWindowInContainerWhenFindSameType "off"
set ::vcst::_bRestore ""
verdiLayoutFreeze -off
verdiDockWidgetHide -dock windowDock_vcstConsole_2
verdiToolBar -rm toolbarHB_TOGGLE_PANEL toolbarHB_EMULATION_PANEL toolbarHB_PRODTYPE_PANEL UVM_AWARE_DEBUG AMS_CONFIG_TOOLBAR NOVAS_TBBR_INTERACTIVEVIEW_PANEL NOVAS_TBBR_DEBUG_REWIND_COMMAND NOVAS_TBBR_DEBUG_REWIND_UNDO_REDO_COMMAND NOVAS_TBBR_DEBUG_REVERSE_COMMAND NOVAS_TBBR_DEBUG_VSIM_COMMAND NOVAS_EMULATION_DEBUG_COMMAND CVG_CER_PANEL
verdiVcstOnPropSelectionChanged -strNum 0 -propList {}
syncSignoffCovParamFromRcFile
verdiGetVcstCmdResult -xmlstr {<Command name="___fvSyncSignoffCovParam" received="1"></Command>}

verdiLayoutFreeze -off
::vcst::showDebugViews -1 false false 
verdiShowWindow
verdiDockWidgetSetCurTab -dock widgetDock_VCF:TaskList
verdiVcstChangeGoalListTabName -tabName VCF:GoalList
verdiVcstChangeGoalListTabName -tabName VCF:GoalList(FPV)
verdiVcstChangeGoalListTabName -tabName VCF:GoalList
verdiVcstChangeGoalListTabName -tabName VCF:GoalList(FPV)
verdiVcstSetAppmode -mode FPV -fromVcst
verdiEmbedApp -winId 25166109 -label VCF:GoalList -type VcstActivityView -noCloseBtn
verdiEmbedApp -winId 25166115 -label VCF:TaskList -type vcstActivityTree -noCloseBtn
verdiDockWidgetMove -dock widgetDock_VCF:TaskList -dock widgetDock_<Inst._Tree>
verdiDockWidgetSetCurTab -dock widgetDock_VCF:GoalList
verdiVcstSyncMsgColor -errorColor "default_red" -warningColor "default_none" -infoColor "default_none"
srcSetBlackbox   -delim {.}
srcSetGlassbox  -delim {.}
verdiGetRCValue -section appSetting -key reuseWave 
verdiVcstResizeTopWin
vcstSetPrefEnv -infoColor "black"
verdiSetRCValue -section appSetting -key fvSize -value {PROPERTY_ELAPSED_TIME,267:PROPERTY_ENGINE,65:PROPERTY_NAME,385:PROPERTY_STATUS,75:PROPERTY_TRACE_DEPTH,65:PROPERTY_TYPE,65:PROPERTY_VACUITY,75:PROPERTY_WITNESS,75:};
verdiSetRCValue -section appSetting -key conSize -value {PROPERTY_CLASS,456:PROPERTY_EXPRESSION,100:PROPERTY_NAME,200:PROPERTY_TYPE,100:PROPERTY_VACUITY,100:PROPERTY_WITNESS,100:};
::vcst::showSourceCodeFromInfoView {traffic.chk.assume_continuous_waiting_main}; ::vcst::showDebugViews -1 false false 
verdiShowWindow
verdiGetVcstCmdResult -xmlstr {<Command name="___vcstCommandLog" received="1"></Command>}

verdiVcstOnPropSelectionChanged -strNum 0 -propList {}
verdiDockWidgetSetCurTab -dock widgetDock_VCF:GoalList
verdiVcstChangeGoalListTabName -tabName VCF:GoalList
verdiVcstChangeGoalListTabName -tabName VCF:GoalList(FPV)
verdiSetRCValue -section appSetting -key glbfilter -value {010}
verdiVcstCheckFv -taskName FPV
vcstRunCovCmd -async gui_vcst_set_parameters -is_running true
vcstRunCovCmd -async {gui_vcst_set_parameters -status_msg { _EnableMedHighEffort_0}}
verdiVcstChangeGoalListTabName -tabName VCF:GoalList
verdiVcstChangeGoalListTabName -tabName VCF:GoalList(FPV)
verdiSetRCValue -section appSetting -key glbfilter -value {010}
vcstRunCovCmd -async {gui_vcst_set_parameters -status_msg { _EnableMedHighEffort_0}}
receiveFvProgress /h/d3/v/sh5704ch-s/ICP-Verification/FPV/run/vcst_rtdb/.internal/verdi/gridUsage.xml0
verdiGetVcstCmdResult -xmlstr {<Command name="check_fv" status="1" />}
vcstRunCovCmd -async {gui_vcst_set_parameters -status_msg { _EnableMedHighEffort_0}}
vcstRunCovCmd -async {gui_vcst_set_parameters -status_msg { _EnableMedHighEffort_0}}
verdiVcstCheckFv -taskName FPV
vcstRunCovCmd -async gui_vcst_set_parameters -is_running false
vcstRunCovCmd -async {gui_vcst_set_parameters -status_msg { _EnableMedHighEffort_1}}
verdiSetRCValue -section appSetting -key fvSize -value {PROPERTY_ELAPSED_TIME,268:PROPERTY_ENGINE,65:PROPERTY_NAME,385:PROPERTY_STATUS,75:PROPERTY_TRACE_DEPTH,65:PROPERTY_TYPE,65:PROPERTY_VACUITY,75:PROPERTY_WITNESS,75:};
vcstRunCovCmd -async {gui_vcst_set_parameters -status_msg { _EnableMedHighEffort_1}}
vcstRunCovCmd -async {gui_vcst_set_parameters -status_msg { _EnableMedHighEffort_1}}
verdiSetRCValue -section appSetting -key conSize -value {PROPERTY_CLASS,473:PROPERTY_EXPRESSION,100:PROPERTY_NAME,183:PROPERTY_TYPE,100:PROPERTY_VACUITY,100:PROPERTY_WITNESS,100:};
verdiVcstGetTooltipByPropertyName -propName {traffic.chk.assert_green_no_waiting_main}
verdiGetVcstCmdResult -xmlstr {<Command name="___fvGetTooltip" received="1"></Command>}

verdiVcstGetTooltipByPropertyName -propName {traffic.chk.assert_honor_waiting_main}
verdiVcstGetTooltipByPropertyName -propName {traffic.chk.assert_honor_waiting_main}
verdiGetVcstCmdResult -xmlstr {<Command name="___fvGetTooltip" received="1"></Command>}

verdiGetVcstCmdResult -xmlstr {<Command name="___fvGetTooltip" received="1"></Command>}

verdiVcstGetTooltipByPropertyName -propName {traffic.chk.assert_honor_waiting_main}
verdiGetVcstCmdResult -xmlstr {<Command name="___fvGetTooltip" received="1"></Command>}

verdiVcstOnPropSelectionChanged -strNum 1 -propList {traffic.chk.assert_green_no_waiting_main}
srcShowDefine -incrSearch {traffic.chk.assert_green_no_waiting_main}; 
verdiVcstOnPropSelectionChanged -strNum 1 -propList {traffic.chk.assert_green_no_waiting_main}
verdiVcstGetTooltipByPropertyName -propName {traffic.chk.assert_green_no_waiting_main}
verdiGetVcstCmdResult -xmlstr {<Command name="___fvGetTooltip" received="1"></Command>}

verdiVcstGetTooltipByPropertyName -propName {traffic.chk.assert_honor_waiting_first}
verdiGetVcstCmdResult -xmlstr {<Command name="___fvGetTooltip" received="1"></Command>}

verdiVcstGetTooltipByPropertyName -propName {traffic.chk.assert_honor_waiting_first}
verdiGetVcstCmdResult -xmlstr {<Command name="___fvGetTooltip" received="1"></Command>}

verdiVcstGetTooltipByPropertyName -propName {traffic.chk.assert_honor_waiting_first}
verdiVcstOnPropSelectionChanged -strNum 1 -propList {traffic.chk.assert_honor_waiting_first}
verdiGetVcstCmdResult -xmlstr {<Command name="___fvGetTooltip" received="1"></Command>}

verdiVcstOnPropSelectionChanged -strNum 1 -propList {traffic.chk.assert_green_no_waiting_main}
verdiVcstOnPropSelectionChanged -strNum 1 -propList {traffic.chk.assert_green_no_waiting_main}
verdiVcstCheckFv -taskName FPV
vcstRunCovCmd -async gui_vcst_set_parameters -is_running true
verdiGetVcstCmdResult -xmlstr {<Command name="check_fv" status="0" />}
receiveFvProgress /h/d3/v/sh5704ch-s/ICP-Verification/FPV/run/vcst_rtdb/.internal/verdi/gridUsage.xml1
verdiVcstCheckFv -taskName FPV
vcstRunCovCmd -async gui_vcst_set_parameters -is_running false
vcstRunCovCmd -async {gui_vcst_set_parameters -status_msg { _EnableMedHighEffort_1}}
verdiVcstSetErrorIdentifier
vcstRunCovCmd -async {gui_vcst_set_parameters -status_msg { _EnableMedHighEffort_1}}
verdiVcstOnPropSelectionChanged -strNum 1 -propList {traffic.chk.assert_green_no_waiting_main}
verdiVcstOnPropSelectionChanged -strNum 1 -propList {traffic.chk.assert_green_no_waiting_main}
verdiVcstGetTooltipByPropertyName -propName {traffic.chk.assert_green_no_waiting_main}
verdiGetVcstCmdResult -xmlstr {<Command name="___fvGetTooltip" received="1"></Command>}

verdiVcstGetTooltipByPropertyName -propName {traffic.chk.assert_green_no_waiting_main}
verdiGetVcstCmdResult -xmlstr {<Command name="___fvGetTooltip" received="1"></Command>}

verdiVcstGetTooltipByPropertyName -propName {traffic.chk.assert_green_no_waiting_main}
verdiVcstGetTooltipByPropertyName -propName {traffic.chk.assert_green_no_waiting_main}
verdiGetVcstCmdResult -xmlstr {<Command name="___fvGetTooltip" received="1"></Command>}

verdiGetVcstCmdResult -xmlstr {<Command name="___fvGetTooltip" received="1"></Command>}

verdiVcstOnPropSelectionChanged -strNum 1 -propList {traffic.chk.assert_green_no_waiting_main}
verdiVcstOnPropSelectionChanged -strNum 1 -propList {traffic.chk.assert_green_no_waiting_main}
verdiVcstOnPropSelectionChanged -strNum 1 -propList {traffic.chk.assert_green_no_waiting_main}
verdiVcstCreateFormalCoreWidget -property traffic.chk.assert_green_no_waiting_main    -subtype vacuity -propCout {1} -depth {};
verdiGetVcstCmdResult -xmlstr {<Command name="action" received="1"></Command>}

verdiGetVcstCmdResult -xmlstr {<Command name="action" status="1"></Command>}

verdiVcstFormalCoreCoverage -disable 
verdiVcstFormalCoreCoverage -show 
report_fml_core -xmlFile /h/d3/v/sh5704ch-s/ICP-Verification/FPV/run/vcst_rtdb/.internal/verdi/formalCore.xml -trigger 
set ::vcst::EnableUDWin 0 ;srcSetOptions -lockActView off
verdiSetRCValue -section appSetting -key FVSetupCheckList -value {!clock/glitch/osc_loop/osc_seq/reset/comb_loop/multi_driver};
verdiSetRCValue -section appSetting -key fdc_w -value {650};verdiSetRCValue -section appSetting -key fdc_h -value {400};verdiSetRCValue -section appSetting -key fdc_x -value {873};verdiSetRCValue -section appSetting -key fdc_y -value {407};
verdiSetRCValue -section appSetting -key fdc_w -value {650};verdiSetRCValue -section appSetting -key fdc_h -value {400};verdiSetRCValue -section appSetting -key fdc_x -value {873};verdiSetRCValue -section appSetting -key fdc_y -value {407};
vcstPropertyDensity -includeCov 0 
verdiVcstConstantReport -xmlFile /h/d3/v/sh5704ch-s/ICP-Verification/FPV/run/vcst_rtdb/.internal/verdi/constant.xml 
vcstPropertyDensity -includeCov 0 
verdiVcstFormalCoreUpdated
report_fml_core -xmlFile /h/d3/v/sh5704ch-s/ICP-Verification/FPV/run/vcst_rtdb/.internal/verdi/formalCore.xml -trigger 
verdiVcstOnPropSelectionChanged -strNum 1 -propList {traffic.chk.assert_green_no_waiting_main}
verdiVcstFormalCoreUpdated
verdiVcstFormalCoreFinished;
report_fml_core -xmlFile /h/d3/v/sh5704ch-s/ICP-Verification/FPV/run/vcst_rtdb/.internal/verdi/formalCore.xml -trigger 
verdiVcstOnPropSelectionChanged -strNum 1 -propList {traffic.chk.assert_green_no_waiting_main}
verdiVcstOnPropSelectionChanged -strNum 1 -propList {traffic.chk.assert_honor_waiting_first}
wvDeleteMarker -win $_Verdi_1 -all
verdiSetStatusMsg -win $_Verdi_1 -2nd "Preparing FSDB..."
verdiGetVcstCmdResult -xmlstr {<Command name="view_trace" status="1" />}
verdiSetStatusMsg -win $_Verdi_1 -2nd "FSDB is ready, Waveform loading..."
sysWarnEnable -disable; set ::vcst::_sysWarnEnable 0
verdiLayoutFreeze -off
set ::vcst::_curWaveVw [wvCreateWindow]
srcSetPreference -annotate on
set currentWinId [string trimleft [wvGetCurrentWindow -name] \$_nWave];verdiDockWidgetFix -dock windowDock_nWave_$currentWinId;
verdiWindowBeWindow -win $::vcst::_curWaveVw
#verdiHideWindow -win $::vcst::_curWaveVw
set ::vcst::_fsdb $::vcst::_rtdbDir/.internal/formal/fpId0/trace_11.xml.replay.fsdb.vf;
expPropVcstDataUpdated -initFSDB $::vcst::_fsdb;
::vcst::wvOpenFsdb $::vcst::_curWaveVw $::vcst::_fsdb
verdiVcstFsdbAppMode -fsdb $::vcst::_fsdb -AppMode FPV
set ::vcst::_propClass {source}
set ::vcst::_propLoc {../sva/traffic.sva:44}
set ::vcst::_propType {assert}
set ::vcst::_propExpr {@(posedge clk) ($rose(waiting_first) |-> ( ##[0:(MAX_WAIT)] green_first))}
set ::vcst::_traceType {property}
set ::vcst::_sva {traffic.chk.assert_honor_waiting_first}
::vcst::setupSvaDebug 0 0 200

set ::vcst::traceTypeMap($::vcst::actualFsdb) property

wvSelectSignal {( "SOURCE-Property" 1 )} ;wvExpandBus ;wvGetSelectedSignals
vcst::setTraceAnalysisInfo {traffic.chk.waiting_first} {Uninitialized Registers} {Uninitialized Property State}
::vcst::saveTraceAnalysisStr {traffic.chk.waiting_first!;Uninitialized Registers!;Uninitialized Property State!;}
wvAddGroup -win $::vcst::_curWaveVw {Undriven};wvAddSignal -fromVCST -delim "." -win $::vcst::_curWaveVw -group { "Undriven/Uninitialized Registers" {traffic.chk.waiting_first} };wvCollapseGroup -win $::vcst::_curWaveVw {Undriven/Uninitialized Registers};
wvSelectGroup -win $::vcst::_curWaveVw {Undriven}; wvChangeDisplayAttr -win $::vcst::_curWaveVw -c ID_RED6
wvSelectGroup -win $::vcst::_curWaveVw {Undriven/Abstracted Outputs}; wvChangeDisplayAttr -win $::vcst::_curWaveVw -c ID_RED6
wvSelectGroup -win $::vcst::_curWaveVw {Undriven/Blackbox Outputs}; wvChangeDisplayAttr -win $::vcst::_curWaveVw -c ID_RED6
wvSelectGroup -win $::vcst::_curWaveVw {Undriven/Out-of-Bounds Accesses}; wvChangeDisplayAttr -win $::vcst::_curWaveVw -c ID_RED6
wvSelectGroup -win $::vcst::_curWaveVw {Undriven/Undriven/Snipped Signals}; wvChangeDisplayAttr -win $::vcst::_curWaveVw -c ID_RED6
wvSelectGroup -win $::vcst::_curWaveVw {Undriven/Uninitialized Registers}; wvChangeDisplayAttr -win $::vcst::_curWaveVw -c ID_RED6
wvSelectGroup -win $::vcst::_curWaveVw {Multi-driven}; wvChangeDisplayAttr -win $::vcst::_curWaveVw -c ID_RED6

verdiVcstOnPropSelectionChanged -strNum 1 -propList {traffic.chk.assert_honor_waiting_first}
wvGoToGroup -win $::vcst::_curWaveVw SOURCE-Property
wvSetPosition -win $::vcst::_curWaveVw {("Support-Signals" last)}
::vcst::addResetMarker 200
::vcst::showDebugViews -100 true true
srcShowDefine -incrSearch {traffic.chk.assert_honor_waiting_first}; 
wvZoomAll -win $::vcst::_curWaveVw
verdiSetStatusMsg -win $_Verdi_1 -2nd "Trace is loaded"
::vcst::enableAddTraceToWave
sysWarnEnable -enable; set ::vcst::_sysWarnEnable 1
wvDeleteMarker -win $_Verdi_1 -all
verdiSetStatusMsg -win $_Verdi_1 -2nd "Preparing FSDB..."
verdiGetVcstCmdResult -xmlstr {<Command name="view_trace" status="1" />}
verdiSetStatusMsg -win $_Verdi_1 -2nd "FSDB is ready, Waveform loading..."
sysWarnEnable -disable; set ::vcst::_sysWarnEnable 0
wvGetAllWindows
expPropGetAttr -is_nav_wave 225ae310
set currentWinId [string trimleft [wvGetCurrentWindow -name] \$_nWave];verdiDockWidgetFix -dock windowDock_nWave_$currentWinId;
verdiWindowBeWindow -win $::vcst::_curWaveVw
#verdiHideWindow -win $::vcst::_curWaveVw
set ::vcst::_fsdb $::vcst::_rtdbDir/.internal/formal/fpId0/trace_11.xml.replay.fsdb.vf;
expPropVcstDataUpdated -initFSDB $::vcst::_fsdb;
wvCloseFile -win $::vcst::_curWaveVw
::vcst::wvOpenFsdb $::vcst::_curWaveVw $::vcst::_fsdb
verdiVcstFsdbAppMode -fsdb $::vcst::_fsdb -AppMode FPV
set ::vcst::_propClass {source}
set ::vcst::_propLoc {../sva/traffic.sva:44}
set ::vcst::_propType {assert}
set ::vcst::_propExpr {@(posedge clk) ($rose(waiting_first) |-> ( ##[0:(MAX_WAIT)] green_first))}
set ::vcst::_traceType {property}
set ::vcst::_sva {traffic.chk.assert_honor_waiting_first}
::vcst::setupSvaDebug 0 0 200

set ::vcst::traceTypeMap($::vcst::actualFsdb) property

wvSelectSignal {( "SOURCE-Property" 1 )} ;wvExpandBus ;wvGetSelectedSignals
vcst::setTraceAnalysisInfo {traffic.chk.waiting_first} {Uninitialized Registers} {Uninitialized Property State}
::vcst::saveTraceAnalysisStr {traffic.chk.waiting_first!;Uninitialized Registers!;Uninitialized Property State!;}
wvAddGroup -win $::vcst::_curWaveVw {Undriven};wvAddSignal -fromVCST -delim "." -win $::vcst::_curWaveVw -group { "Undriven/Uninitialized Registers" {traffic.chk.waiting_first} };wvCollapseGroup -win $::vcst::_curWaveVw {Undriven/Uninitialized Registers};
wvSelectGroup -win $::vcst::_curWaveVw {Undriven}; wvChangeDisplayAttr -win $::vcst::_curWaveVw -c ID_RED6
wvSelectGroup -win $::vcst::_curWaveVw {Undriven/Abstracted Outputs}; wvChangeDisplayAttr -win $::vcst::_curWaveVw -c ID_RED6
wvSelectGroup -win $::vcst::_curWaveVw {Undriven/Blackbox Outputs}; wvChangeDisplayAttr -win $::vcst::_curWaveVw -c ID_RED6
wvSelectGroup -win $::vcst::_curWaveVw {Undriven/Out-of-Bounds Accesses}; wvChangeDisplayAttr -win $::vcst::_curWaveVw -c ID_RED6
wvSelectGroup -win $::vcst::_curWaveVw {Undriven/Undriven/Snipped Signals}; wvChangeDisplayAttr -win $::vcst::_curWaveVw -c ID_RED6
wvSelectGroup -win $::vcst::_curWaveVw {Undriven/Uninitialized Registers}; wvChangeDisplayAttr -win $::vcst::_curWaveVw -c ID_RED6
wvSelectGroup -win $::vcst::_curWaveVw {Multi-driven}; wvChangeDisplayAttr -win $::vcst::_curWaveVw -c ID_RED6

wvGoToGroup -win $::vcst::_curWaveVw SOURCE-Property
wvSetPosition -win $::vcst::_curWaveVw {("Support-Signals" last)}
::vcst::addResetMarker 200
::vcst::showDebugViews -100 true true
wvZoomAll -win $::vcst::_curWaveVw
verdiSetStatusMsg -win $_Verdi_1 -2nd "Trace is loaded"
::vcst::enableAddTraceToWave
sysWarnEnable -enable; set ::vcst::_sysWarnEnable 1
set currentWinId [string trimleft [wvGetCurrentWindow -name] \$_nWave];verdiDockWidgetUnfix -dock windowDock_nWave_$currentWinId;
set currentWinId [string trimleft [wvGetCurrentWindow -name] \$_nWave];verdiDockWidgetUnfix -dock windowDock_nWave_$currentWinId;
