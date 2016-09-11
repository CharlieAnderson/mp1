import lc3b_types::*;

/*
 * ZEXT[(offset-n) << 1]
 */
module zextadj #(parameter width = 8)
(
    input [width-1:0] in,
    output lc3b_word out
);

assign out = $signed({1'b0, in, 1'b0});
// maybe $signed(1'b0, in); could work
endmodule : zextadj

