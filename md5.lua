-- Simple function to encode string into MD5 format.
local md5 = {}

local leftrotate = bit32.lrotate
local function tobytes(s)
    local bytes = {}
    for i = 1, #s do
        bytes[#bytes + 1] = string.byte(s, i)
    end
    return bytes
end

function md5.sumhexa(msg)
    local A, B, C, D = 0x67452301, 0xEFCDAB89, 0x98BADCFE, 0x10325476
    local s = {
        7,12,17,22, 7,12,17,22, 7,12,17,22, 7,12,17,22,
        5, 9,14,20, 5, 9,14,20, 5, 9,14,20, 5, 9,14,20,
        4,11,16,23, 4,11,16,23, 4,11,16,23, 4,11,16,23,
        6,10,15,21, 6,10,15,21, 6,10,15,21, 6,10,15,21
    }
    local K = {}
    for i = 1, 64 do
        K[i] = math.floor((2^32) * math.abs(math.sin(i)))
    end

    local orig_len = #msg * 8
    local bytes = tobytes(msg)
    table.insert(bytes, 0x80)
    while (#bytes % 64) ~= 56 do
        table.insert(bytes, 0)
    end

    for i = 0, 7 do
        table.insert(bytes, bit32.band(bit32.rshift(orig_len, 8 * i), 0xFF))
    end

    for chunk = 1, #bytes, 64 do
        local w = {}
        for i = 0, 15 do
            local b = chunk + i * 4
            w[i + 1] = bytes[b] + bit32.lshift(bytes[b + 1], 8)
                + bit32.lshift(bytes[b + 2], 16) + bit32.lshift(bytes[b + 3], 24)
        end

        local a, b, c, d = A, B, C, D

        for i = 1, 64 do
            local f, g
            if i <= 16 then
                f = bit32.bor(bit32.band(b, c), bit32.band(bit32.bnot(b), d))
                g = i - 1
            elseif i <= 32 then
                f = bit32.bor(bit32.band(d, b), bit32.band(bit32.bnot(d), c))
                g = (5 * (i - 1) + 1) % 16
            elseif i <= 48 then
                f = bit32.bxor(b, c, d)
                g = (3 * (i - 1) + 5) % 16
            else
                f = bit32.bxor(c, bit32.bor(b, bit32.bnot(d)))
                g = (7 * (i - 1)) % 16
            end

            local temp = d
            d = c
            c = b
            b = bit32.band(b + leftrotate((a + f + K[i] + w[g + 1]) % 2^32, s[i]), 0xFFFFFFFF)
            a = temp
        end

        A = (A + a) % 2^32
        B = (B + b) % 2^32
        C = (C + c) % 2^32
        D = (D + d) % 2^32
    end

    local function hex(n)
        return string.format("%02x%02x%02x%02x",
            bit32.band(n, 0xFF),
            bit32.band(bit32.rshift(n, 8), 0xFF),
            bit32.band(bit32.rshift(n, 16), 0xFF),
            bit32.band(bit32.rshift(n, 24), 0xFF)
        )
    end

    return hex(A) .. hex(B) .. hex(C) .. hex(D)
end

return md5