// Inspirado na competição do H2 Challenge em que eu tive que fazer uma média móvel, eu decidi implementar uma fila em zig
// no código do h2 havia o seguinte:
//
// for(int i = 0, i<len-1, i++){
//  array[i+1] = array[i]
// }
// array[0] = val
//
// Isso é extremamente ineficiente, pois isso é O(N), mas pode ser O(1) utilizando uma fila

const fila_i8 = @import("fila.zig").fila_i8;
const std = @import("std");
const stdin = std.io.getStdIn().reader();
const stdout = std.io.getStdOut().writer();

pub fn main() !void {
    // Vamos continuamente receber o input do usuário e imprimir a média atual

    var buf: [5]u8 = undefined;
    var val: ?i8 = undefined;

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    var fila = try fila_i8.Criar(allocator, 5);

    while (true) {
        try stdout.print("Escreva um número: ", .{});

        if (stdin.readUntilDelimiterOrEof(buf[0..], '\n')) |input| {
            val = std.fmt.parseInt(i8, input.?, 10) catch null;
            if (val == null) {
                try stdout.print("ERR: Valor inválido, tente um i8\n", .{});
            }
        } else |err| {
            try stdout.print("ERR {}: Valor inválido, tente um i8\n", .{err});
        }
        fila.Add(val, true) catch {};
        fila.Print();
        try stdout.print("média: {d:2.4}\n", .{media(&fila)});
    }
}

fn media(fila: *fila_i8) f32 {
    var soma: f32 = 0;
    for (fila.array) |v| {
        if (v == null) continue;
        soma += @floatFromInt(v.?);
    }
    const len: f32 = @floatFromInt(fila.array.len);
    return soma / len;
}
