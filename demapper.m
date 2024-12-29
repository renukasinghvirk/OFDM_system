function [b] = demapper(symbol)
%   DEMAPPER Maps a QPSK symbol to its corresponding bit sequence.
%   Converts a complex QPSK symbol into a binary sequence of 2 bits,
%   where the real and imaginary parts of the symbol represent the
%   first and second bits, respectively.
%
%   INPUT:
%   - symbol: A complex QPSK symbol.
%
%   OUTPUT:
%   - b: A column vector of 2 bits representing the symbol.
%
%   The real part determines the first bit (1 if > 0, else 0), 
%   and the imaginary part determines the second bit.
%
bit1 = real(symbol) > 0;
bit2 = imag(symbol) > 0;

% b is a two colomn vector col1: real, col2: imag
b = [bit1 bit2];
b = b';
b = b(:);

end

