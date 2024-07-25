pub const Number = struct {
    value: u128,
    exponent: u128,
    dotFound: bool,

    pub fn add(self: *Number, other: *Number) void {
        const value = self.value + other.value;
        const exponent = self.exponent;
        const dotFound = self.dotFound;

        if (other.exponent > self.exponent) {
            exponent = other.exponent;
        }

        self.*.dotFound = dotFound;
        self.*.exponent = exponent;
        self.*.value = value;
        return;
    }
};
