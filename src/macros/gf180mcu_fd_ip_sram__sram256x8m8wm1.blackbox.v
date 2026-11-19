/*
 * GF180MCU SRAM black-box declaration.
 * Physical views and timing libraries are provided by the pinned official
 * Google gf180mcu_fd_ip_sram Git submodule.
 * SPDX-License-Identifier: Apache-2.0
 */
(* blackbox *)
module gf180mcu_fd_ip_sram__sram256x8m8wm1 (
    inout wire VDD,
    inout wire VSS,
    input wire CLK,
    input wire CEN,
    input wire GWEN,
    input wire [7:0] WEN,
    input wire [7:0] A,
    input wire [7:0] D,
    output wire [7:0] Q
);
endmodule
