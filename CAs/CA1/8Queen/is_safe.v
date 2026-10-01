module is_safe (
    row1, column1, row2, column2,
    safe
);
    input [2:0] row1, column1, row2, column2;
    output safe;
    wire [7:0] row_difference,
               column_difference, 
               absolute_row_difference,
               absolute_column_difference;
    wire same_row, same_column, diagonal;

    assign row_difference = row1 - row2;
    assign column_difference = column1 - column2;
    
    abs absolute_row_3bit 
        (.value(absolute_row_difference), .number(row_difference));
    abs absolute_column_3bit
        (.value(absolute_column_difference), .number(column_difference));
    
    assign same_row = (row1 == row2);
    assign same_column = (column1 == column2);
    assign diagonal = (absolute_row_difference == absolute_column_difference);
    
    assign safe = ~(same_row || same_column || diagonal);
endmodule