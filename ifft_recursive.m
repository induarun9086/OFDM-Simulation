function output=ifft_recursive(input)
    [M,N]=size(input);
    % Conjugate the input
    ifft_output=input';
    ifft_output=transpose(ifft_output);
    % Apply FFT
    output=fft_recursive(ifft_output)/N;
    % Conjugate the FFTed output 
    ifft_output=output';
    output=transpose(ifft_output);
end

