const std = @import("std");
const testing = std.testing;
const Allocator = std.mem.Allocator;

// Essa fila armazena inteiros i8
pub const fila_i8 = struct {
    array: []?i8,
    ponteiro: usize = 0, // Indica a posição em que o próximo valor será lido
    final: usize = 0, // Indica a posição em que o próximo valor será inserido
    allocator: Allocator,
    pub const errors = error{
        NullValue, // Este erro ocorre quando tenta-se ler um valor nulo
        Overwriting, // Este erro ocorre quando estamos sobrescrevendo um valor não nulo
        InvalidInput, // Este erro ocorre quando tentamos adicionar um valor inválido
    };

    pub fn Criar(allocator: Allocator, size: usize) !fila_i8 {
        const array = try allocator.alloc(?i8, size);
        @memset(array, null);
        const fila = fila_i8{
            .array = array,
            .ponteiro = 0,
            .final = 0,
            .allocator = allocator,
        };

        return fila;
    }
    pub fn Destruir(self: *fila_i8) void {
        self.allocator.free(self.array);
    }

    // Esta é uma função auxiliar que incrementa tanto o ponteiro quanto o final
    // de forma que se ele exceder o tamanho da array, ele volta ao zero
    fn Increment(self: *fila_i8, property: *usize) void {
        property.* = (property.* + 1) % self.array.len;
    }

    pub fn Add(self: *fila_i8, value: ?i8, force: bool) errors!void {
        if (value == null) {
            return errors.InvalidInput;
        }
        if (self.array[self.final] != null and !force) {
            return errors.Overwriting;
        } else if (self.array[self.final] != null and force) {
            self.array[self.final] = value;
            Increment(self, &self.final);
            Increment(self, &self.ponteiro); // Precisamos incrementar o ponteiro para que ele imprima o próximo valor mais antigo
        } else {
            self.array[self.final] = value;
            Increment(self, &self.final);
        }
    }

    pub fn Pop(self: *fila_i8) errors!i8 {
        if (self.array[self.ponteiro]) |v| {
            self.array[self.ponteiro] = null;
            Increment(self, &self.ponteiro);
            return v;
        } else {
            return errors.NullValue;
        }
    }

    pub fn Print(self: *fila_i8) void {
        std.debug.print("Legenda: \n", .{});
        std.debug.print("\x1b[30;46;1;4mponteiro\x1b[0m\n", .{});
        std.debug.print("\x1b[31;1mfinal\x1b[0m\n", .{});
        for (self.array, 0..) |v, i| {
            if (self.ponteiro == (self.final % self.array.len) and i == self.ponteiro) {
                std.debug.print("\x1b[31;46;1;4m", .{});
            } else if (i == self.ponteiro) {
                std.debug.print("\x1b[30;46;1;4m", .{});
            } else if (i == (self.final % self.array.len)) {
                std.debug.print("\x1b[31;1m", .{});
            } else {
                std.debug.print("\x1b[0m", .{});
            }
            std.debug.print(" {?} \x1b[0m", .{v});
        }
        std.debug.print("\x1b[0m\n", .{});
    }
};

test "Fila Leitura" {
    const allocator = std.testing.allocator;
    var fila = try fila_i8.Criar(allocator, 5);
    defer fila.Destruir();

    try fila.Add(1, false);
    try fila.Add(2, false);
    try fila.Add(3, false);
    try fila.Add(4, false);
    try fila.Add(5, false);

    // Ler todos os valores da fila
    try testing.expect(try fila.Pop() == 1);
    try testing.expect(try fila.Pop() == 2);
    try testing.expect(try fila.Pop() == 3);
    try testing.expect(try fila.Pop() == 4);
    try testing.expect(try fila.Pop() == 5);
}

test "Fila Overwrite" {
    const allocator = std.testing.allocator;
    var fila = try fila_i8.Criar(allocator, 3);
    defer fila.Destruir();

    try fila.Add(1, false);
    try fila.Add(2, false);
    try fila.Add(3, false);
    try testing.expectError(error.Overwriting, fila.Add(4, false));
}

test "Fila Null Value" {
    const allocator = std.testing.allocator;
    var fila = try fila_i8.Criar(allocator, 3);
    defer fila.Destruir();

    try fila.Add(1, false);
    try fila.Add(2, false);
    try fila.Add(3, false);

    _ = try fila.Pop();
    _ = try fila.Pop();
    _ = try fila.Pop();

    const ponteiro_antigo = fila.ponteiro;

    try testing.expectError(error.NullValue, fila.Pop());

    // Ao acontecer o erro, o ponteiro não deve ser incrementado
    try testing.expect(ponteiro_antigo == fila.ponteiro);
}

test "Fila Force Overwrite" {
    const allocator = std.testing.allocator;
    var fila = try fila_i8.Criar(allocator, 3);
    defer fila.Destruir();

    try fila.Add(1, false);
    try fila.Add(2, false);
    try fila.Add(3, false);

    try fila.Add(4, true);

    try testing.expectEqual(2, fila.Pop());
    try testing.expectEqual(3, fila.Pop());
    try testing.expectEqual(4, fila.Pop());
}
