# Basic clock/reset constraints. Adjust for your FPV tool if needed.

# Example for VC Formal-style commands. Replace if your tool differs.
if {[info commands create_clock] ne ""} {
    create_clock clk -period 10
}

# You can add reset assumptions in your properties file.
