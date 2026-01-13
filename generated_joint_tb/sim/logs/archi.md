# Joint UVM Architecture (Decode -> Execute)

[decode_in_agent]  -->  [decode DUT]  -->  [decode_out_agent]  ---> (ref_model/scoreboard/coverage)
       |                                   |
       |                                   v
       |                             [joint_ref_model]
       |                                   |
       v                                   v
[decode_wb_agent] ------------------> [joint_scoreboard] <--- [execute_out_agent] <-- [execute DUT] <-- [execute_in_agent]
                                               |
                                               v
                                         [joint_coverage]

# Decode UVM Structure

[decode_in_agent] --> [decode_in_if] --> [decode DUT] --> [decode_out_if] --> [decode_out_agent]
       |
       v
[decode_wb_agent] --> (regfile writeback model)

[decode_out_agent] --> [joint_ref_model]
[decode_out_agent] --> [joint_scoreboard]
[decode_out_agent] --> [joint_coverage]

# Decode UVM Architecture (Block Style)

TB
  TEST
    decode_env
      decode_in_uvc
        decode_in_agent
          mon | drv | sqr
        decode_in_cfg
        decode_in_if
      decode_out_uvc
        decode_out_agent
          mon | drv | sqr
        decode_out_cfg
        decode_out_if
      decode_wb_uvc
        decode_wb_agent
          mon | drv | sqr
        decode_wb_cfg
        decode_wb_if
      virtual_sqr
      fifo (from decode_out_agent)
      scb (joint_scoreboard)
      ref_model (joint_ref_model)
      coverage (joint_coverage)
      decode_config
        decode_in_cfg | decode_out_cfg | decode_wb_cfg
  DUT (decode)
