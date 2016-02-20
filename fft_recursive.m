function output=fft_recursive(input)
[M,N]=size(input);

 % If N > 2, split the sequence to odd and even
 % Apply fft to the odd and even sequences
 if(N ~=2)
        [even,odd]=even_odd(input);
        A=fft_recursive(even);
        B=fft_recursive(odd);
        for k=1:1:N/2
            % Apply butterfly if there are only 2 samples
            [output(k),output(k+N/2)]= butterfly(A(k),B(k)*exp(-2*j*(pi/N)*(k-1)));
        end
    % If there are only 2 samples left do butterfly    
    else
        [P,Q]=even_odd(input);
        
        [output(1),output(2)] = butterfly(P(1),Q(1));
     end
end

